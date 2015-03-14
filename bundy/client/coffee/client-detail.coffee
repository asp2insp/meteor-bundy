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

Template.sidebarCancellations.helpers({
  cancellations: () ->
    cancellations = []
    Sessions.find({client_id: Template.currentData()?.client_id}).forEach((session) ->
      if session.cancellation_type? and Cancellations[session.cancellation_type]?
        cancellations.push({
          name: session.cancellation_type
          date: moment(session.start_time).format("MM/DD/YYYY")
        })
    )
    return cancellations
})