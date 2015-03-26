Template.editTutor.viewmodel ((data) -> data),
  tutor: -> Employees.findOne @_id()
  editOrNew: -> if @_id?()? then 'Edit' else 'New Tutor'
  deleteShown: -> !!@_id()?
  email: -> @emails?()[0]?.address
  save: ->
    data = {
      name: @name()
      email: @email()
      phone: @phone()
      type: @type()
      _id: if @_id()? then @_id() else undefined
    }
    console.log data
    Meteor.call('upsertEmployee', @_id(), data)
  delete: ->
    Employees.remove({_id: @_id()})
    Router.go('clients')

Template.tutors.helpers({
  blank: -> {_id: null, phone: '', name: '', email: '', type: ''}
})
