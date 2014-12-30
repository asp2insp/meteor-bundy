Template.employeeDetail.helpers({
  employeeSelector: () ->
    return {employee_id: Meteor.userId()}
  rates: () ->
    return BillingRates.find({employee_id: Meteor.userId()})
})