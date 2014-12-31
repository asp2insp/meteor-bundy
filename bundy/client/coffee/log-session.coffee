Template.log.helpers({
  getClientsOfUser: () ->
    clients = []
    if Utils.userIsAnEmployee()
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
  'submit #log-session': (e, t) ->
    e.preventDefault()
    logSession()
    $('#log-session')[0].reset()
    displaySuccessAlert()
})

Template.log.rendered = () ->
  $(this.findAll('.clockpicker')).clockpicker({
    #placement: 'top',
    autoclose: false,
    twelvehour: true,
    donetext: 'Done'
  })
  $('#successalert').hide()

displaySuccessAlert = () ->
  $('#successalert').show()
  $('#successalert').fadeOut(1600)

# {employee_id, client_id, billing_rate_id, start_time, end_time, units,
#  notes, [pay_adjustments], [billing_adjustments], total_bill, total_pay}
logSession = () ->
  session = {}
  session.employee_id = Meteor.userId()
  session.client_id = $('#client').val()
  rate = BillingRates.findOne($('#sessiontype').val())
  session.billing_rate = _.pick(rate, ['session_type', 'unit_bill_rate', 'unit_pay_rate'])
  session.billing_rate.origin_id = rate._id
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
  _.forEach(Employees.findOne({_id: session.employee_id}).pay_adjustments, (adj) ->
    if conditionsMet(adj, session)
      session.pay_adjustments.push(_.pick(adj, ['name', 'amount']))
  )
  return session

calculateBillingAdjustments = (session) ->
  session.billing_adjustments = []
  _.forEach(Clients.findOne({_id: session.client_id}).billing_adjustments, (adj) ->
    if conditionsMet(adj, session)
      session.billing_adjustments.push(_.pick(adj, ['name', 'amount']))
  )
  return session

conditionsMet = (adj, session) ->
  adj.conditions ?= {}
  # local minimongo for resolving constraints
  currentSession = new Meteor.Collection(null);
  currentSession.insert(session)
  return currentSession.find(adj.conditions).count() == 1

calculateTotalBill = (session) ->
  session.total_bill = session.units * session.billing_rate.unit_bill_rate
  session.total_bill += _.reduce(session.billing_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  , 0)
  return session

calculateTotalPay = (session) ->
  session.total_pay = session.units * session.billing_rate.unit_pay_rate
  session.total_pay += _.reduce(session.pay_adjustments, (sum, adj) ->
    sum = sum || 0
    return sum + adj.amount
  , 0)
