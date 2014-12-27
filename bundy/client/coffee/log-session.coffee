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
  'submit #log-session': (e, t) ->
    e.preventDefault()
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
  session.notes = $('#notes').val()
  day = moment($("#date").val())
  start = moment($("#starttime").val(), 'h:mma')
  end = moment($("#endtime").val(), 'h:mma')
  session.start_time = day.clone()
                          .add(start.hours(), 'hours')
                          .add(start.minutes(), 'minutes')
                          .toDate()
  session.end_time = day.clone()
                        .add(end.hours(), 'hours')
                        .add(end.minutes(), 'minutes')
                        .toDate()

  _(session).chain()
            .tap(calculateUnits)
            .tap(calculateBillingAdjustments)
            .tap(calculateTotalBill)
            .tap(calculatePayAdjustments)
            .tap(calculateTotalPay)
  Sessions.insert(session)


calculateUnits = (session) ->
  start = moment(session.start_time)
  end = moment(session.end_time)
  session.units = moment.duration(end.diff(start)).asHours()
  return session

calculatePayAdjustments = (session) ->
  session.pay_adjustments = []
  _.forEach(Employees.findOne(session.employee_id).pay_adjustments, (adj) ->
    if conditionsMet(adj, session)
      session.pay_adjustments.push(adj)
  )
  return session

calculateBillingAdjustments = (session) ->
  session.billing_adjustments = []
  _.forEach(Clients.findOne(session.client_id).billing_adjustments, (adj) ->
    if conditionsMet(adj, session)
      session.billing_adjustments.push(adj)
  )
  return session

conditionsMet = (adj, session) ->
  return _.reduce(adj.conditions, (res, value, cond) ->
    return session[cond] == value && res
  , true)

calculateTotalBill = (session) ->
  rate = BillingRates.findOne(session.billing_rate_id)
  session.total_bill = session.units * rate.unit_bill_rate
  session.total_bill += _.reduce(session.billing_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  , 0)
  return session

calculateTotalPay = (session) ->
  rate = BillingRates.findOne(session.billing_rate_id)
  session.total_pay = session.units * rate.unit_pay_rate
  session.total_pay += _.reduce(session.billing_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  , 0)
