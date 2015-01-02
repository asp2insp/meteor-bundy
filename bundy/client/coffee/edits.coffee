Template.editSession.rendered = () ->
  this.autorun(() ->
    session = Sessions.findOne(Session.get('editSessionId'))
    if session?
      lodash.forEach(session, (value, key) ->
        el = this.$('#'+key)[0]
        if el?
          if value instanceof Date
            $(el).val(moment(value).format('YYYY-MM-DDTHH:mm:ss'))
          else
            $(el).val(value)
      )
      Session.set('editSession', session)
  )

Template.editSession.events({
  'change input': (e, t) ->
    session = Session.get('editSession')
    newValue = $(e.currentTarget).val()
    session[e.currentTarget.id] = convertToTargetType(newValue, session[e.currentTarget.id], 'YYYY-MM-DDTHH:mm:ss')
    Session.set('editSession', session)
  'click #savebutton': (e, t) ->
    session = Session.get('editSession')
    Sessions.update({_id: session._id}, session)
    $('#editsessionmodal').modal('hide')
})

convertToTargetType = (value, target, formatString) ->
  switch typeof target
    when 'string' then return ''+value
    when 'number' then return value - 0
    when 'object'
      if target instanceof Date && formatString?
        return moment(value, formatString).toDate()
    else
      return value