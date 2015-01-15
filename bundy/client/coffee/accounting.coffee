Meteor.subscribe('Invoices_withSessions_withClients')

Template.monthlyPL.events({
  'click #monthdropdown a': (e, t) ->
    e.preventDefault()
    selectProfitLossPeriod($(e.currentTarget).text())
})

Template.monthlyPL.helpers({
  'revenue_recieved': () ->
    periodIndex = Session.get('profitLossPeriodIndex')
    unless periodIndex?
      return
    date_range = findDateRangeForBillingPeriod(periodIndex)
    recieved = []
    ClientInvoices.find(
      {
        date_paid: {$exists: true},
        date_issued: {$gte: date_range?.start, $lt: date_range?.end}
      }
    ).forEach((invoice) ->
      client_name = Clients.findOne(invoice.client_id)?.name
      recieved.push({name: client_name, amount: invoice.amount})
    )
    return recieved
  'revenue_outstanding': () ->
    periodIndex = Session.get('profitLossPeriodIndex')
    unless periodIndex?
      return
    date_range = findDateRangeForBillingPeriod(periodIndex)
    outstanding = []
    ClientInvoices.find(
      {
        date_paid: {$exists: false},
        date_issued: {$gte: date_range?.start, $lt: date_range?.end}
      }
    ).forEach((invoice) ->
      client_name = Clients.findOne(invoice.client_id)?.name
      outstanding.push({name: client_name, amount: invoice.amount})
    )
    return outstanding
})

selectProfitLossPeriod = (periodName) ->
  $('#monthtext').text(periodName)
  Session.set('profitLossPeriodIndex', lodash.findIndex(BillingPeriods, {name: periodName}))

Template.monthlyPL.rendered = () ->
  index = Session.get('profitLossPeriodIndex')
  unless index?
    selectProfitLossPeriod(BillingPeriods[findBillingPeriod(Date.now())].name)
  else
    $('#monthtext').text(BillingPeriods[index].name)
