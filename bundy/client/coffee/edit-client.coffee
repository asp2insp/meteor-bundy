Template.editClient.viewmodel ((data) -> data),
  client: -> Clients.findOne @_id()
  editOrNew: -> if @_id()? then 'Edit' else 'New Client'
  deleteShown: -> !!@_id()?
  save: ->
    data = {
      name: @name()
      email: @email()
      phone: @phone()
      _id: if @_id()? then @_id() else undefined
    }
    Meteor.call('upsertClient', @_id(), data)
  delete: ->
    Clients.remove({_id: @_id()})
    Router.go('clients')

Template.clients.helpers({
  blank: -> {_id: null, phone: '', name: '', email: ''}
})