TabularTables = {}
Meteor.isClient && Template.registerHelper('TabularTables', TabularTables)

TabularTables.EmployeeSessions = new Tabular.Table({
  name: 'SessionList',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  order: [[0, "desc"]],
  columns: [
    {
      data: 'start_time',
      title: 'Date',
      render: (val, type, doc) ->
        if val instanceof Date
          return moment(val).calendar()
        else
          return 'N/A';
    },
    {
      data: 'client_id',
      title: 'Client',
      render: (val) ->
        return Clients.findOne(val).name
    },
    {data: 'units', title: 'Units'},
    {
      data: 'billing_rate',
      title: 'Rate',
      render: (rate) ->
        return rate.unit_pay_rate
    },
    {
      title: 'Adjustments',
      data: 'pay_adjustments',
      render: (val) ->
        return _.reduce(val, (l, r) ->
          return l + r.name + ': ' + r.amount + '<br>'
        , '')
    },
    {data: 'total_pay', title: 'Total'}
  ]
});

TabularTables.Employees = new Tabular.Table({
  name: 'Employees',
  collection: Employees,
  columns: [
    {data: 'profile.name', title: 'Name'},
    {data: 'profile.type', title: 'Type'},
    {
      data: 'pay_adjustments',
      title: 'Pay Adjustments',
      render: (val) ->
        return _.join(', ', _.pluck(val, 'name')...)
    }
  ]
})

TabularTables.Clients = new Tabular.Table({
  name: 'Clients',
  collection: Clients,
  pub: 'Clients_withRates',
  columns: [
    {
      data: 'name',
      title: 'Name',
      render: (name, type, doc) ->
        return '<a href="clients/' + doc._id + '">' + name + '</a>'
    },
    {
      data: '_id',
      title: 'Rates',
      render: (client_id) ->
        rates = []
        BillingRates.find({client_id: client_id}).forEach((rate) ->
          rates.push(rate.session_type + ': ' + rate.unit_bill_rate)
        )
        return _.join('<br>', rates...)
      ,
    },
    {
      data: 'billing_adjustments',
      title: 'Billing Adjustments',
      render: (val) ->
        return _.join(', ', _.pluck(val, 'name')...)
    }
  ]
})

TabularTables.ClientSessions = new Tabular.Table({
  name: 'ClientSessions',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  columns: [
    {
      data: 'start_time',
      title: 'Date',
      render: (val, type, doc) ->
        if val instanceof Date
          return moment(val).calendar()
        else
          return 'N/A';
    },
    {
      data: 'employee_id',
      title: 'Tutor',
      render: (_id, type, doc) ->
        employee = Employees.findOne(_id)
        return '<a href="tutors/' + _id + '">' + employee.profile.name + '</a>'
    },
    {data: 'units', title: 'Units'},
    {
      data: 'billing_rate',
      title: 'Rate',
      render: (rate) ->
        return rate.unit_bill_rate
    },
    {
      title: 'Adjustments',
      data: 'billing_adjustments',
      render: (val) ->
        return _.reduce(val, (l, r) ->
          return l + r.name + ': ' + r.amount + '<br>'
        , '')
    },
    {data: 'total_bill', title: 'Total'}
  ]
})