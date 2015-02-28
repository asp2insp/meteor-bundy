Template.editTutor.rendered = () ->
  this.autorun(() ->
    id = Template.currentData()?.id
    if id?
      Session.set('editTutor', Employees.findOne(id))
    tutor = Session.get('editTutor')
    if tutor?
      lodash.forEach(flatKeys(tutor), (key) ->
        value = getComposite('editTutor.' + key)
        el = this.$('#'+key.replace(/\./g, '__'))[0]
        if el?
          if value instanceof Date
            $(el).val(moment(value)?.format('YYYY-MM-DDTHH:mm:ss'))
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
    Meteor.call('upsertEmployee', tutor._id, tutor)
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

Template.editTutor.helpers({
  editOrNew: () ->
    id = Template.currentData()?.id
    return if id? then 'Edit' else 'New Tutor'
})