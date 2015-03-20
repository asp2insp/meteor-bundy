Template.editClient.rendered = () ->
  id = Template.currentData()?.id
  if id?
    Session.set('editClient', Clients.findOne(id))
  client = Session.get('editClient')
  if client?
    lodash.forEach($("#editclientmodal input"), (el) ->
      if $(el).data("keyPath")?
        keyPath = prefix($(el).data("keyPath"))
        $(el).val(getComposite(keyPath))
    )
  else
    Session.set('editClient', {})

Template.editClient.events({
  'change input': (e, t) ->
    newValue = $(e.currentTarget).val()
    key = $(e.currentTarget).data("keyPath")
    setComposite(prefix('editClient', key), newValue)
  'click #savebutton': (e, t) ->
    client = Session.get('editClient')
    Meteor.call('upsertClient', client?._id, client)
    Session.set('editClient', null)
  'click #deletebutton': (e, t) ->
    Clients.remove({_id: Session.get('editClient')?._id})
    Session.set('editClient', null)
    Router.go('clients')
})

Template.editClient.helpers({
  editOrNew: () ->
    id = Template.currentData()?.id
    return if id? then 'Edit' else 'New Client'
})