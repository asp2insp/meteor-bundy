Template.monthlyPL.events({
  'click #monthdropdown a': (e, t) ->
    e.preventDefault()
    selectProfitLossPeriod($(e.currentTarget).text())
})

Template.monthlyPL.helpers({
  'revenue_recieved': () ->
    index = Session.get('profitLossPeriodIndex')
    date_range = findDateRangeForBillingPeriod(index)
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
    index = Session.get('profitLossPeriodIndex')
    date_range = findDateRangeForBillingPeriod(index)
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
  'payroll': () ->
    index = Session.get('profitLossPeriodIndex')
    date_range = findDateRangeForBillingPeriod(index)
    payroll = []
    PayStubs.find({
      pay_date:  {$gte: date_range?.start, $lt: date_range?.end}
    }).forEach((payStub) ->
      employee_name = Employees.findOne(payStub.employee_id)?.profile?.name
      payroll.push({name: employee_name, amount: payStub.amount})
    )
    return payroll
  'other': () ->
    index = Session.get('profitLossPeriodIndex')
    date_range = findDateRangeForBillingPeriod(index)
    return Expenses.find({
      date:  {$gte: date_range?.start, $lt: date_range?.end}
    }).fetch()
  'total_revenue': () ->
    recieved = getHelper('revenue_recieved', Template.instance())()
    outstanding = getHelper('revenue_outstanding', Template.instance())()
    recieved_total = _.reduce(recieved, (sum, lineItem) ->
      return sum + lineItem.amount
    , 0)
    outstanding_total = _.reduce(outstanding, (sum, lineItem) ->
      return sum + lineItem.amount
    , 0)
    return recieved_total + outstanding_total
  'total_expenses': () ->
    payroll = getHelper('payroll', Template.instance())()
    other = getHelper('other', Template.instance())()
    payroll_total = _.reduce(payroll, (sum, lineItem) ->
      return sum + lineItem.amount
    , 0)
    other_total = _.reduce(other_total, (sum, lineItem) ->
      return sum + lineItem.amount
    , 0)
    return payroll_total + other_total
  'net': () ->
    total_revenue = getHelper('total_revenue', Template.instance())()
    total_expenses = getHelper('total_expenses', Template.instance())()
    return total_revenue - total_expenses
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
  this.autorun(() ->
    index = Session.get('profitLossPeriodIndex')
    date_range = findDateRangeForBillingPeriod(index)
    Meteor.subscribe('Invoices_withSessions_withClients', null, null, null, date_range)
    Meteor.subscribe('PayStubs_withSessions_withClients', null, null, null, date_range)
    # Meteor.subscribe('Invoices_withSessions_withClients', null, null, null, date_range)
  )

Template.annualPL.rendered = () ->
  Meteor.subscribe('PeriodProfitLoss')

Template.annualPL.helpers({
  'billingPeriods': () ->
    return lodash.map(PeriodProfitLoss.find().fetch(), (period) ->
      period.net = period.revenue - period.expenses
      if period.net < 0
        period.net = '(' + (period.net * -1) + ')'
      return period
    )
})

@PeriodProfitLoss = new Mongo.Collection('periodprofitloss')

