Template.billingHeader.helpers({
   months: () ->
    return BillingPeriods
  currentYear: () ->
    return moment().year()
})

Template.approvePay.helpers({
  reviewedEmployeesSelector: () ->
    return {_id: {$in: Session.get('reviewedEmployees')}}
  unreviewedEmployeesSelector: () ->
    return {_id: {$nin: Session.get('reviewedEmployees')}}
})

Template.approveEmployee.helpers({
  employeeBillingSelector: () ->
    date_range = findDateRangeForBillingPeriod(Session.get('billingPeriodIndex'))
    return {
      employee_id: this?._id,
      start_time: {$gte: date_range?.start, $lt: date_range?.end}
    }
})

Template.approveClient.helpers({
  clientBillingSelector: () ->
    date_range = findDateRangeForBillingPeriod(Session.get('billingPeriodIndex'))
    return {
      client_id: this?._id,
      start_time: {$gte: date_range?.start, $lt: date_range?.end}
    }
})

Template.approveBill.helpers({
  reviewedClientsSelector: () ->
    return {_id: {$in: Session.get('reviewedClients')}}
  unreviewedClientsSelector: () ->
    return {_id: {$nin: Session.get('reviewedClients')}}
})

# Update the list of reviewed employees
Tracker.autorun(() ->
  billingPeriod = Session.get('billingPeriodIndex')
  date_range = findDateRangeForBillingPeriod?(billingPeriod) || {}
  reviewedEmployees = []
  PayStubs?.find({pay_date: {$gte: date_range.start, $lt: date_range.end}}).forEach((stub) ->
    reviewedEmployees.push(stub.employee_id)
  )
  Session.set('reviewedEmployees', reviewedEmployees)
)

# Update the list of reviewed clients
Tracker.autorun(() ->
  billingPeriod = Session.get('billingPeriodIndex')
  date_range = findDateRangeForBillingPeriod?(billingPeriod) || {}
  reviewedClients = []
  ClientInvoices?.find({date_issued: {$gte: date_range.start, $lt: date_range.end}}).forEach((invoice) ->
    reviewedClients.push(invoice.client_id)
  )
  Session.set('reviewedClients', reviewedClients)
)

Template.billingHeader.events({
  'click #monthdropdown a': (e, t) ->
    e.preventDefault()
    selectBillingPeriod($(e.currentTarget).text())
})

Template.approveClient.events({
  'click .edit-session': (e, t) ->
    Session.set('editSession', Sessions.findOne($(e.currentTarget).data('id')))
  'click .approve': (e, t) ->
    selector = getHelper('clientBillingSelector', t)()
    getIdsForTable('BillingClientSessions', selector).done(() ->
      Meteor.call('createInvoice', this, Session.get('billingPeriodIndex'), (error, result) ->
        if error?
          console.log(error)
        else
          Router.go('/approve-bill')
      )
    ).fail(() ->
      console.log(this) # TODO: replace with visible error
    )
})

Template.approveEmployee.events({
  'click .edit-session': (e, t) ->
    Session.set('editSession', Sessions.findOne($(e.currentTarget).data('id')))
  'click .approve': (e, t) ->
    selector = getHelper('employeeBillingSelector', t)()
    getIdsForTable('BillingEmployeeSessions', selector).done(() ->
      Meteor.call('createPayStub', this, Session.get('billingPeriodIndex'), (error, result) ->
        if error?
          console.log(error)
        else
          Router.go('/approve-pay')
      )
    ).fail(() ->
      console.log(this) # TODO: replace with visible error
    )
})

@getHelper = (helperName, tInst) ->
  return _.bind(tInst.view.template.__helpers[' ' + helperName], tInst.data)

Template.billingHeader.rendered = () ->
  index = Session.get('billingPeriodIndex')
  unless index?
    selectBillingPeriod(BillingPeriods[findBillingPeriod(Date.now())].name)
  else
    $('#monthtext').text(BillingPeriods[index].name)

Template.billingSteps.rendered = () ->
  _.forEach(this.findAll('a.billing-step'), (a) ->
    if a.pathname == location.pathname

      $(a).parent().addClass('active')
  )

selectBillingPeriod = (periodName) ->
  $('#monthtext').text(periodName)
  Session.set('billingPeriodIndex', lodash.findIndex(BillingPeriods, {name: periodName}))