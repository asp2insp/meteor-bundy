Template.editTutor.rendered = () ->
  this.autorun(() ->
    tutor = Session.get('editTutor')
    if tutor?
      lodash.forEach(tutor, (value, key) ->
        el = this.$('#'+key)[0]
        if el?
          if value instanceof Date
            $(el).val(moment(value).format('YYYY-MM-DDTHH:mm:ss'))
          else
            $(el).val(value)
      )
    else
      Session.set('editTutor', {})
  )

Template.editTutor.events({
  'change input': (e, t) ->
    tutor = Session.get('editTutor')
    newValue = $(e.currentTarget).val()
    key = e.currentTarget.id
    tutor[key] = convertToTargetType(newValue, tutor?[key], 'YYYY-MM-DDTHH:mm:ss')
    Session.set('editTutor', tutor)
  'click #savebutton': (e, t) ->
    tutor = Session.get('editTutor')
    Employees.upsert({_id: tutor._id}, tutor)
  'click #deletebutton': (e, t) ->
    Employees.remove({_id: Session.get('editTutorId')})
  'click a.remove': (e, t) ->
    key = _.last($(e.currentTarget).parentsUntil('.row')).id
    tutor = Session.get('editTutor')
    Session.set('editTutor', tutor)
  'adjustmentAdded form.addform': (e, t) ->
    key = _.last($(e.currentTarget).parentsUntil('.row')).id
    tutor = Session.get('editTutor')
    Session.set('editTutor', tutor)
})