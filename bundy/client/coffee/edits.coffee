Template.editSession.rendered = () ->
  this.autorun(() ->
    session = Session.get('editSession')
    if session?
      lodash.forEach(session, (value, key) ->
        el = this.$('#'+key)[0]
        if el?
          if value instanceof Date
            $(el).val(moment(value).format('YYYY-MM-DDTHH:mm:ss'))
          else
            $(el).val(value)
      )
  )

Template.editSession.events({
  'change input': (e, t) ->
    session = Session.get('editSession')
    newValue = $(e.currentTarget).val()
    key = e.currentTarget.id
    session[key] = convertToTargetType(newValue, session[key], 'YYYY-MM-DDTHH:mm:ss')
    cascadeChanges(session, [key])
    Session.set('editSession', session)
  'click #savebutton': (e, t) ->
    session = Session.get('editSession')
    Sessions.update({_id: session._id}, session)
  'click #deletebutton': (e, t) ->
    Sessions.remove({_id: Session.get('editSessionId')})
  'click a.remove': (e, t) ->
    key = _.last($(e.currentTarget).parentsUntil('.row')).id
    session = Session.get('editSession')
    cascadeChanges(session, [key])
    Session.set('editSession', session)
  'adjustmentAdded form.addform': (e, t) ->
    key = _.last($(e.currentTarget).parentsUntil('.row')).id
    session = Session.get('editSession')
    cascadeChanges(session, [key])
    Session.set('editSession', session)
})

Template.editAdjustments.helpers({
  getAdjustments: () ->
    return getComposite(this.key)
})

Template.editAdjustments.events({
  'click a.remove': (e, t) ->
    adjustments = getComposite(t.data.key) || []
    lodash.remove(adjustments, {name: $(e.currentTarget).data('name')})
    setComposite(t.data.key, adjustments)
  'submit form.addform': (e, t) ->
    e.preventDefault()
    adjustments = getComposite(t.data.key) || []
    adjustments.push({
      name: $(t.find('.name')).val(),
      amount: $(t.find('.amount')).val() - 0
    })
    setComposite(t.data.key, adjustments)
    $(t.find('.name')).val('')
    $(t.find('.amount')).val('')
    $('button.addbutton').blur()
    $(e.currentTarget).trigger('adjustmentAdded')
})

@getIdsForTable = (tableName, currentSelector) ->
  deferred = new $.Deferred()
  Meteor.call("tabular_getInfo", tableName, currentSelector, {}, 0, 10000, (error, result) ->
    if error?
      deferred.rejectWith(error)
    else
      deferred.resolveWith(result.ids)
  )
  return deferred


cascadeChanges = (session, changed_keys) ->
  nextKeys = []
  _.forEach(changed_keys, (key) ->
    switch key
      when 'start_time', 'end_time'
        calculateUnits(session)
        nextKeys.push('units')
      when 'units', 'pay_adjustments', 'billing_adjustments'
        calculateTotalBill(session)
        calculateTotalPay(session)
        nextKeys.push('total_bill')
        nextKeys.push('total_pay')
  )
  if nextKeys.length > 0
    cascadeChanges(session, nextKeys)


@convertToTargetType = (value, target, formatString) ->
  if target?
    switch typeof target
      when 'string' then return ''+value
      when 'number' then return value - 0
      when 'object'
        if target instanceof Date && formatString?
          return moment(value, formatString).toDate()
  return value
