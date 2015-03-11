Template.editClient.rendered = () ->
  id = Template.currentData()?.id
  if id?
    Session.set('editClient', Clients.findOne(id))
  client = Session.get('editClient')
  if client?
    lodash.forEach(flatKeys(client), (key) ->
      value = getComposite('editClient.' + key)
      el = this.$('#'+key.replace(/\./g, '__'))[0]
      if el?
        if value instanceof Date
          $(el).val(moment(value)?.format('YYYY-MM-DDTHH:mm:ss'))
        else
          $(el).val(value)
    )
  else
    Session.set('editClient', {})

Template.editClient.events({
  'change input': (e, t) ->
    newValue = $(e.currentTarget).val()
    key = e.currentTarget.id.replace(/__/g, '.')
    setComposite('editClient.' + key, newValue)
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