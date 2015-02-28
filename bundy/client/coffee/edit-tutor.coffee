Template.editTutor.rendered = () ->
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

Template.editTutor.events({
  'change input': (e, t) ->
    newValue = $(e.currentTarget).val()
    key = e.currentTarget.id.replace(/__/g, '.')
    setComposite('editTutor.' + key, newValue)
  'click #savebutton': (e, t) ->
    tutor = Session.get('editTutor')
    Meteor.call('upsertEmployee', tutor?._id, tutor)
    Session.set('editTutor', null)
  'click #deletebutton': (e, t) ->
    Employees.remove({_id: Session.get('editTutorId')})
    Session.set('editTutor', null)
})

Template.editTutor.helpers({
  editOrNew: () ->
    id = Template.currentData()?.id
    return if id? then 'Edit' else 'New Tutor'
})