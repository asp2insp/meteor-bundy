Template.clientDetail.helpers({
  clientSelector: () ->
    return {client_id: Template.currentData()?._id}
  rates: () ->
    return BillingRates.find({client_id: Template.currentData()?._id})
})

Template.sidebarRatesWithClient.helpers({
  clientName: () ->
    return Clients.findOne(Template.currentData()?.client_id)?.name
})

Template.sidebarRatesWithEmployee.helpers({
  employeeName: () ->
    return Employees.findOne(Template.currentData()?.employee_id)?.profile?.name
})