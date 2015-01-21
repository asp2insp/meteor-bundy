Meteor.methods({
  createPayStub: (sessionIds, billingPeriodIndex) ->
    check(sessionIds, [String])
    this.unblock()
    sessions = Sessions.find({_id: {$in: sessionIds}}).fetch()
    if sessions.length != sessionIds.length
      throw new Meteor.Error('Params list constains invalid IDs')

    employee_id = _.first(sessions).employee_id
    if not lodash.all(sessions, {employee_id: employee_id})
      throw new Meteor.Error('Cannot create pay stub for session range which spans multiple employee IDs')

    # Check to see if we're creating a new pay stub or updating an existing one
    pay_stub_q = PayStubs.find({session_ids: {$in: sessionIds}})
    pay_stub = {}
    if pay_stub_q.count() > 1
      throw new Meteor.Error('Multiple pay stubs claim the same session IDs. Contact the admin.')
    else if pay_stub_q.count() == 1
      pay_stub = _.first(pay_stub_q.fetch())

    if pay_stub.employee_id? and pay_stub.employee_id != employee_id
      throw new Meteor.Error('A pay stub exists for these sessions for a different employee!')

    if pay_stub.session_ids? and not _.isEqual(pay_stub.session_ids, _.intersection(pay_stub.session_ids, sessionIds))
      throw new Meteor.Error('The existing pay stub contains sessions which are not in this list. You may only add sessions to a stub through this method')

    pay_stub.date = new Date()
    pay_stub.amount = _.reduce(sessions, (amt, session) ->
      return amt + session.total_pay
    , 0)

    pay_stub.employee_id ?= employee_id
    pay_stub.client_ids = _.pluck(sessions, 'client_id')
    pay_stub.session_ids = sessionIds
    pay_stub.pay_date = findPayDateForBillingPeriod(billingPeriodIndex)

    if pay_stub._id?
      PayStubs.update({_id: pay_stub._id}, pay_stub)
    else
      PayStubs.insert(pay_stub)

  createInvoice: (sessionIds, billingPeriodIndex) ->
    check(sessionIds, [String])
    this.unblock()
    sessions = Sessions.find({_id: {$in: sessionIds}}).fetch()
    if sessions.length != sessionIds.length
      throw new Meteor.Error('Params list constains invalid IDs')

    client_id = _.first(sessions).client_id
    if not lodash.all(sessions, {client_id: client_id})
      throw new Meteor.Error('Cannot create invoice for session range which spans multiple client IDs')

    # Check to see if we're creating a new invoice or updating an existing one
    invoice_q = ClientInvoices.find({session_ids: {$in: sessionIds}})
    invoice = {}
    if invoice_q.count() > 1
      throw new Meteor.Error('Multiple invoices claim the same session IDs. Contact the admin.')
    else if invoice_q.count() == 1
      invoice = _.first(invoice_q.fetch())

    if invoice.client_id? and invoice.client_id != client_id
      throw new Meteor.Error('An invoice exists for these sessions for a different client!')

    if invoice.session_ids? and not _.isEqual(invoice.session_ids, _.intersection(invoice.session_ids, sessionIds))
      throw new Meteor.Error('The existing invoice contains sessions which are not in this list. You may only add sessions to an invoice through this method')

    invoice.date = new Date()
    invoice.amount = _.reduce(sessions, (amt, session) ->
      return amt + session.total_bill
    , 0)

    # {date_issued, date_due, amount, memo, client_id, [employee_ids], [session_ids]}
    invoice.client_id ?= client_id
    invoice.employee_ids = _.pluck(sessions, 'employee_id')
    invoice.session_ids = sessionIds
    invoice.date_issued = findPayDateForBillingPeriod(billingPeriodIndex)

    if invoice._id?
      ClientInvoices.update({_id: invoice._id}, invoice)
    else
      ClientInvoices.insert(invoice)
})

Accounts.config({
  forbidClientAccountCreation : true
});
