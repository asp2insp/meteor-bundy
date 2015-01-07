Template.billingHeader.helpers({
   months: () ->
    return BillingPeriods
  currentYear: () ->
    return moment().year()
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

Template.approveBill.rendered = () ->
  this.autorun(() ->
    unless Session.get('reviewedClients')
      return
    if this.unreviewed?
      Blaze.remove(this.unreviewed)
    if this.reviewed?
      Blaze.remove(this.reviewed)
    this.unreviewed = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingClients,
        selector: {_id: {$nin: Session.get('reviewedClients')}},
        class: "table table-condensed"
      },
      this.templateInstance().find('#unreviewed')
    )
    this.reviewed = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingClients,
        selector: {_id: {$in: Session.get('reviewedClients')}},
        class: "table table-condensed"
      },
      this.templateInstance().find('#reviewed')
    )
  )

Template.approvePay.rendered = () ->
  this.autorun(() ->
    unless Session.get('reviewedEmployees')
      return
    if this.unreviewed?
      Blaze.remove(this.unreviewed)
    if this.reviewed?
      Blaze.remove(this.reviewed)
    this.unreviewed = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingEmployees,
        selector: {_id: {$nin: Session.get('reviewedEmployees')}},
        class: "table table-condensed"
      },
      this.templateInstance().find('#unreviewed')
    )
    this.reviewed = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingEmployees,
        selector: {_id: {$in: Session.get('reviewedEmployees')}},
        class: "table table-condensed"
      },
      this.templateInstance().find('#reviewed')
    )
  )

Template.sendPay.rendered = () ->
  this.autorun(() ->
    unless Session.get('billingPeriodIndex')?
      return
    if this.approved?
      Blaze.remove(this.approved)
    if this.sent?
      Blaze.remove(this.sent)
    date_range = findDateRangeForBillingPeriod(Session.get('billingPeriodIndex'))
    this.approved = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingPayStubs,
        selector: {},
        class: "table table-condensed"
      },
      this.templateInstance().find('#approved')
    )
    this.sent = Blaze.renderWithData(
      Template.tabular,
      {
        table: TabularTables.BillingPayStubs,
        selector: {},
        class: "table table-condensed"
      },
      this.templateInstance().find('#sent')
    )
  )

Meteor.startup(() ->
  # Update the list of reviewed employees
  Tracker.autorun(() ->
    billingPeriod = Session.get('billingPeriodIndex')
    unless billingPeriod?
      return
    date_range = findDateRangeForBillingPeriod?(billingPeriod) || {}
    reviewedEmployees = []
    PayStubs.find({pay_date: {$gte: date_range.start, $lt: date_range.end}}).forEach((stub) ->
      reviewedEmployees.push(stub.employee_id)
    )
    Session.set('reviewedEmployees', reviewedEmployees)
  )

  # Update the list of reviewed clients
  Tracker.autorun(() ->
    billingPeriod = Session.get('billingPeriodIndex')
    unless billingPeriod?
      return
    date_range = findDateRangeForBillingPeriod?(billingPeriod) || {}
    reviewedClients = []
    ClientInvoices.find({date_issued: {$gte: date_range.start, $lt: date_range.end}}).forEach((invoice) ->
      reviewedClients.push(invoice.client_id)
    )
    Session.set('reviewedClients', reviewedClients)
  )
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
    if _s.contains(location.pathname, a.pathname)
      $(a).parent().addClass('active')
  )

selectBillingPeriod = (periodName) ->
  $('#monthtext').text(periodName)
  Session.set('billingPeriodIndex', lodash.findIndex(BillingPeriods, {name: periodName}))