Template.log.helpers({
  getClientsOfUser: () ->
    clients = []
    if userIsAnEmployee
      BillingRates.find({employee_id: Meteor.userId()}).forEach((rate) ->
        client = Clients.findOne({_id: rate.client_id})
        if !_.findWhere(clients, {_id: client._id})
          clients.push(client)
      )
    return clients
  getSessionTypes: () ->
    rates = []
    BillingRates.find({employee_id: Meteor.userId(), client_id: Session.get('selectedClientId')})
                .forEach((rate) ->
                  rates.push(rate)
    )
    return rates
})

Template.log.events({
  'change #client': (e, t) ->
    Session.set('selectedClientId', $('#client').val())
  'change #sessiontype': (e, t) ->
    Session.set('selectedRateId', $('#sessiontype').val())
  'submit #logsession': (e, t) ->
    logSession()
})

userIsAnEmployee = () ->
  return EmployeeTypes.find({type: Meteor.user().profile.type}).count() > 0

# {employee_id, client_id, billing_rate_id, start_time, end_time, units,
#  notes, [pay_adjustments], [billing_adjustments], total_bill, total_pay}
logSession = () ->
  session = {}
  session.employee_id = Meteor.userId()
  session.client_id = Session.get('selectedClientId')
  session.billing_rate_id = Session.get('selectedRateId')
  rate = BillingRates.findOne(session.billing_rate_id)
  session.notes = $('#notes').val()

  # Figure out number of units from the times
  calculateUnits(session)

  # Calculate the total bill
  calculateBillingAdjustments(session)
  calculateTotalBill(session)

  # Calculate the total pay
  calculatePayAdjustments(session)
  calculateTotalPay(session)


calculateUnits = (session) ->
  session.units = 0
  return session

calculatePayAdjustments = (session) ->
  session.pay_adjustments = []
  return session

calculateBillingAdjustments = (session) ->
  session.billing_adjustments = []
  return session

calculateTotalBill = (session) ->
  session.total_bill = session.units * rate.unit_bill_rate
  session.total_bill += _.reduce(session.billing_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  )
  return session

calculateTotalPay = (session) ->
  session.total_pay = session.units * rate.unit_pay_rate
  session.total_pay += _.reduce(session.billing_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  )