Template.editTutor.viewmodel ((data) -> data),
  tutor: -> Employees.findOne @_id()
  editOrNew: -> if @_id()? then 'Edit' else 'New Tutor'
  deleteShown: -> !!@_id()?
  email: -> @emails?()[0]?.address
  save: ->
    data = {
      profile: {
        name: @profile().name
        emails: [{address: @email()}]
        phone: @profile().phone
        type: @profile().type
      }
      _id: if @_id()? then @_id() else undefined
    }
    console.log data
    Meteor.call('upsertEmployee', @_id(), data)
  delete: ->
    Employees.remove({_id: @_id()})
    Router.go('clients')

Template.tutors.helpers({
  blank: -> {_id: null, profile: {phone: '', name: '', email: '', type: ''}}
})
