Meteor.isServer && myLog = new lc.EventLog(['client_id', 'employee_id'])

# {name, phone, email, [bonus pay items], type}
@Employees = Meteor.users
Meteor.isServer && myLog.startLogging(Employees, {
  desc: (user) ->
    return user.profile.name
  indexOn: {
    'employee_id': (user) ->
      return user._id
  }
})

# {name, phone, email, [billing_adjustments]}
@Clients = new Mongo.Collection('Clients')
Meteor.isServer && myLog.startLogging(Clients, {
  desc: (client) ->
    return client.name
  indexOn: {
    'client_id': (client) ->
      return client._id
  }
})

# {client_id, employee_id, session_type, unit_bill_rate, unit_pay_rate}
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

# {date_issued, date_due, amount, memo, client_id, [employee_ids], [session_ids]}
@ClientInvoices = new Mongo.Collection('ClientInvoices')

# {date, amount, memo, client}
@ClientPayReceipts = new Mongo.Collection('ClientPayReceipts')

@EmployeeTypes = new Mongo.Collection('EmployeeTypes')

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

  Meteor.publishComposite("Sessions_denormalized", (tableName, ids, fields) ->
    check(tableName, String)
    check(ids, [String])
    check(fields, Match.Optional(Object))

    return {
      find: () ->
        return Sessions.find({_id: {$in: ids}}, {fields: fields});
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

if Meteor.isClient
  Meteor.subscribe("userData")
