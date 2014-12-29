Template.clientDetail.helpers({
  clientSelector: () ->
    return {client_id: Template.currentData()?._id}
})