Meteor.isServer && myLog = new lc.EventLog(['client_id', 'employee_id'])

userIsAdmin = (userId) ->
  return Meteor.users.findOne(userId).isAdmin

@BillingPeriods = [
      {name: 'January', is_pre_paid: false, month_range: [1]},
      {name: 'February', is_pre_paid: false, month_range: [2]},
      {name: 'March', is_pre_paid: false, month_range: [3]},
      {name: 'April', is_pre_paid: false, month_range: [4]},
      {name: 'May', is_pre_paid: false, month_range: [5]},
      {name: 'Summer (June/July)', is_pre_paid: true, month_range: [6,7]},
      {name: 'August', is_pre_paid: false, month_range: [8]},
      {name: 'September', is_pre_paid: false, month_range: [9]},
      {name: 'October', is_pre_paid: false, month_range: [10]},
      {name: 'November', is_pre_paid: false, month_range: [11]},
      {name: 'December', is_pre_paid: false, month_range: [12]},
]

@findPayDateForBillingPeriod = (index) ->
  start = findDateRangeForBillingPeriod(index)?.start
  return moment(start).add(15, 'days').toDate()

# returns index into @BillingPeriods
@findBillingPeriod = (timestamp) ->
  month = moment(timestamp).format('MMMM')
  return lodash.findIndex(BillingPeriods, (val) ->
    return _s.include(val.name, month)
  )

# Returns {start: Date, end: Date}
@findDateRangeForBillingPeriod = (index) ->
  month_range = BillingPeriods[index]?.month_range
  if month_range?
    return {
      start: moment(month_range[0], 'M').toDate(),
      end: moment(month_range[month_range.length-1], 'M').add(1, 'month').toDate()
    }
  else
    return null

ADMIN_PERMISSIONS = {
  insert: (userId, where) ->
    return userIsAdmin(userId)

  update: (userId, where, fields, modifier) ->
    return userIsAdmin(userId)

  remove: (userId, docs) ->
    return userIsAdmin(userId)
}

# {name, phone, email, [bonus pay items], type}
@Employees = Meteor.users
Employees.allow(ADMIN_PERMISSIONS)

Meteor.isServer && myLog.startLogging(Employees, {
  indexOn: {
    'employee_id': (user) ->
      return user._id
  }
})

# {name, phone, email, [billing_adjustments]}
@Clients = new Mongo.Collection('Clients')
Clients.allow(ADMIN_PERMISSIONS)

Meteor.isServer && myLog.startLogging(Clients, {
  desc: (client) ->
    return client.name
  indexOn: {
    'client_id': (client) ->
      return client._id
  }
})

# {client_id, employee_id, session_type, unit_bill_rate, unit_pay_rate, pre_paid}
@BillingRates = new Mongo.Collection('BillingRates')
Meteor.isServer && myLog.startLogging(BillingRates, {
  desc: (rate) ->
    return _.join(' ', Clients.findOne(rate.client_id).name, Employees.findOne(rate.employee_id), rate.session_type)
})

# {employee_id, client_id, billing_rate, start_time, end_time, units,
#  notes, [pay_adjustments], [billing_adjustments], total_bill, total_pay}
@Sessions = new Mongo.Collection('Sessions')
Meteor.isServer && myLog.startLogging(Sessions, {
  desc: (session) ->
    return _.join(' ', session.start_time.toDateString(), session.billing_rate.session_type)
  indexOn: {
    'session_id': (session) ->
      return session._id
  }
})

# {date, amount, memo, employee_id, [client_ids], [session_ids]}
@PayStubs = new Mongo.Collection('PayStubs')
PayStubs.allow(ADMIN_PERMISSIONS)

Meteor.isServer && myLog.startLogging(PayStubs, {
  desc: (payStub) ->
    return payStub.pay_date.toDateString() + ': $' + payStub.amount
  indexOn: {
    'paystub_id': (payStub) ->
      return payStub._id
  }
})

# {date_issued, date_due, date_paid, date_deposited, amount, memo, client_id, [employee_ids], [session_ids]}
@ClientInvoices = new Mongo.Collection('ClientInvoices')
ClientInvoices.allow(ADMIN_PERMISSIONS)

Meteor.isServer && myLog.startLogging(ClientInvoices, {
  desc: (invoice) ->
    return invoice.date_issued.toDateString() + ': $' + invoice.amount
  indexOn: {
    'invoice_id': (invoice) ->
      return invoice._id
  }
})

# TODO: Fill this with pre-computed types
@EmployeeTypes = new Mongo.Collection('EmployeeTypes')

# {name, date, amount}
@Expenses = new Mongo.Collection('Expenses')

# {type_code, description, adjustment_factor}
@Cancellations = {
  A: {
    description: 'Cancellation with 24 hours notice'
    adjustment_factor: 0
  }
  B: {
    description: 'No-Show or cancelation with less than 24 hours notice'
    adjustment_factor: 1
  }
  C: {
    description: 'Sick'
    adjustment_factor: 0
  }
  D: {
    description: 'School Holiday'
    adjustment_factor: 0
  }
}

if Meteor.isServer
  Meteor.publish("userData", () ->
    if this.userId
      return Meteor.users.find({_id: this.userId}, {fields: {
                                  'isAdmin': 1,
                                  'pay_adjustments': 1,
                               }})
    else
      this.ready()
  )

  Meteor.publish('employees', () ->
    if this.userId
      if userIsAdmin(this.userId)
        return Employees.find({}, {fields: {'profile': 1, 'emails': 1, 'pay_adjustments': 1}})
      else
        return Employees.findOne(this.userId, {fields: {'profile': 1, 'emails': 1, 'pay_adjustments': 1}})
  )
  Meteor.publish("clients", () ->
    if this.userId
      if userIsAdmin(this.userId)
        return Clients.find({})
      ids = []
      BillingRates.find({employee_id: this.userId}).forEach((rate) ->
        ids.push(rate.client_id)
      )
      return Clients.find({_id: {$in: ids}})
  )

  Meteor.publish("rates", () ->
    if this.userId
      if userIsAdmin(this.userId)
        return BillingRates.find()
      return BillingRates.find({employee_id: this.userId})
  )

  Meteor.publish("employee_types", () ->
    return EmployeeTypes.find()
  )

  Meteor.publishComposite("Sessions_denormalized", (tableName, ids, fields) ->
    check(tableName, String)
    check(ids, [String])
    check(fields, Match.Optional(Object))

    return {
      find: () ->
        return Sessions.find({_id: {$in: ids}});
      ,
      children: [
        {
          find: (session) ->
            return Clients.find({_id: session.client_id}, {limit: 1, fields: {name: 1}, sort: {_id: 1}})
        },
        {
          find: (session) ->
            return BillingRates.find({_id: session.billing_rate_id}, {limit: 1, sort: {_id: 1}})
        },
        {
          find: (session) ->
            return Employees.find({_id: session.employee_id}, {limit: 1})
        }
      ]
    }
  )

  Meteor.publishComposite("Clients_withRates", (tableName, ids, fields) ->
    check(tableName, String)
    check(ids, [String])
    check(fields, Match.Optional(Object))

    return {
      find: () ->
        return Clients.find({_id: {$in: ids}}, {fields: fields});
      ,
      children: [
        {
          find: (client) ->
            return BillingRates.find({client_id: client._id}, {sort: {_id: 1}})
        }
      ]
    }
  )

  Meteor.publishComposite("Clients_withInvoices", (tableName, ids, fields) ->
    check(tableName, String)
    check(ids, [String])
    check(fields, Match.Optional(Object))

    return {
      find: () ->
        return Clients.find({_id: {$in: ids}}, {fields: fields});
      ,
      children: [
        {
          find: (client) ->
            return ClientInvoices.find({client_id: client._id})
        }
      ]
    }
  )
  Meteor.publishComposite("Employees_withPayStubs", (tableName, ids, fields) ->
    check(tableName, String)
    check(ids, [String])
    check(fields, Match.Optional(Object))

    return {
      find: () ->
        return Employees.find({_id: {$in: ids}}, {fields: fields});
      ,
      children: [
        {
          find: (employee) ->
            return PayStubs.find({employee_id: employee._id})
        }
      ]
    }
  )
  Meteor.publishComposite('PayStubs_withSessions_withClients', (tableName, ids, fields, date_range) ->
    if date_range?
      return {
        find: () ->
          PayStubs.find({pay_date: {$gte: date_range.start, $lt: date_range.end}})
      }
    return {
      find: () ->
        return PayStubs.find({_id: {$in: ids}}, {fields: fields});
      ,
      children: [
        {
          find: (stub) ->
            return Sessions.find({_id: {$in: stub.session_ids}})
        }
      ]
    }
  )
  Meteor.publishComposite('Invoices_withSessions_withClients', (tableName, ids, fields, date_range) ->
    if date_range?
      return {
        find: () ->
          return ClientInvoices.find({date_issued: {$gte: date_range.start, $lt: date_range.end}})
      }

    return {
      find: () ->
        return ClientInvoices.find({_id: {$in: ids}}, {fields: fields});
      ,
      children: [
        {
          find: (invoice) ->
            return Sessions.find({_id: {$in: invoice.session_ids}})
        }
      ]
    }
  )
  Meteor.publish('PeriodProfitLoss', () ->
    self = this
    initializing = true;
    lodash.forEach(BillingPeriods, (period, index) ->
      date_range = findDateRangeForBillingPeriod(index)
      invoicesForPeriod = ClientInvoices.find({date_issued: {$gte: date_range.start, $lt: date_range.end}}).fetch()
      payStubsForPeriod = PayStubs.find({pay_date: {$gte: date_range.start, $lt: date_range.end}}).fetch()
      expensesForPeriod = Expenses.find({date: {$gte: date_range.start, $lt: date_range.end}}).fetch()
      lodash.assign(period, {
        revenue: lodash.reduce(invoicesForPeriod, (sum, invoice) ->
          return sum + invoice.amount
        , 0)
        expenses: (
          lodash.reduce(payStubsForPeriod, (sum, payStub) ->
            return sum + payStub.amount
          , 0) +
          lodash.reduce(expensesForPeriod, (sum, expense) ->
            return sum + expense.amount
          , 0)
        )
      })
      self.added("periodprofitloss", period.name, period);
    )
    self.ready();
  )


if Meteor.isClient
  Meteor.subscribe("userData")
  Meteor.subscribe("clients")
  Meteor.subscribe("rates")
  Meteor.subscribe("employee_types")
  Meteor.subscribe('employees')
