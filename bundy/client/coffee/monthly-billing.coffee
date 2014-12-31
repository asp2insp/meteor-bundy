
Template.monthlyBilling.helpers({
  months: () ->
    return BillingPeriods
  currentYear: () ->
    return moment().year()
})

Template.monthlyBilling.events({
  'click #monthdropdown a': (e, t) ->
    e.preventDefault()
    selectedMonth = $(e.currentTarget).text()
    $('#monthtext').text(selectedMonth)
    Session.set('billingPeriodIndex', lodash.findIndex(BillingPeriods, {name: selectedMonth}))
})