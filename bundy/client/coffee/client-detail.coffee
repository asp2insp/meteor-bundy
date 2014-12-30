Template.clientDetail.helpers({
  clientSelector: () ->
    return {client_id: Template.currentData()?._id}
  rates: () ->
    return BillingRates.find({client_id: Template.currentData()?._id})
})

Template.sidebarRates.helpers({
  employeeName: () ->
    return Employees.findOne(Template.currentData()?.employee_id)?.name
})