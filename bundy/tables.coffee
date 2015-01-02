TabularTables = {}
Meteor.isClient && Template.registerHelper('TabularTables', TabularTables)

EmployeeSessionsColumns = [
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
  {
    data: 'billing_rate',
    title: 'Subject',
    render: (rate) ->
      return rate.session_type
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
  {data: 'total_pay', title: 'Total'},
  {data: 'notes', title: 'Notes'}
]

TabularTables.EmployeeSessions = new Tabular.Table({
  name: 'SessionList',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  order: [[0, "desc"]],
  columns: EmployeeSessionsColumns
})

TabularTables.Employees = new Tabular.Table({
  name: 'Employees',
  collection: Employees,
  columns: [
    {
      data: 'profile.name',
      title: 'Name',
      render: (name, type, doc) ->
        return '<a href="tutors/' + doc._id + '">' + name + '</a>'
    },
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

ClientSessionColumns = [
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
  {
    data: 'billing_rate',
    title: 'Subject',
    render: (rate) ->
      return rate.session_type
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
  {data: 'total_bill', title: 'Total'},
  {data: 'notes', title: 'Notes'}
]

TabularTables.ClientSessions = new Tabular.Table({
  name: 'ClientSessions',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  columns: ClientSessionColumns
})

TabularTables.BillingClients = new Tabular.Table({
  name: 'BillingClients',
  collection: Clients,
  pub: 'Clients_withInvoices',
  dom: 't',
  columns: [
    {
      data: 'name',
      title: 'Name',
      sortable: false,
      render: (name, type, doc) ->
        return '<a href="approve-bill/' + doc._id + '">' + name + '</a>'
    }
  ]
})

TabularTables.BillingEmployees = new Tabular.Table({
  name: 'BillingEmployees',
  collection: Employees,
  pub: 'Employees_withPayStubs',
  dom: 't',
  columns: [
    {
      data: 'profile.name',
      title: 'Name',
      sortable: false,
      render: (name, type, doc) ->
        return '<a href="approve-pay/' + doc._id + '">' + name + '</a>'
    }
  ]
})

EmployeeReviewSessionColumns = lodash.cloneDeep(EmployeeSessionsColumns)
EmployeeReviewSessionColumns.push({
  data: '_id',
  title: 'Edit',
  render: (_id, type, doc) ->
    return '<div class="btn btn-primary edit-session" data-id="' + _id +
           '" data-toggle="modal", data-target="#editsessionmodal" >Edit</div>'
})

TabularTables.BillingEmployeeSessions = new Tabular.Table({
  name: 'BillingEmployeeSessions',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  order: [[0, "desc"]],
  dom: 't',
  pageLength: 1000,
  columns: EmployeeReviewSessionColumns
})

ClientReviewSessionColumns = lodash.cloneDeep(ClientSessionColumns)
ClientReviewSessionColumns.push({
  data: '_id',
  title: 'Edit',
  render: (_id, type, doc) ->
    return '<div class="btn btn-primary edit-session" data-id="' + _id +
           '" data-toggle="modal", data-target="#editsessionmodal" >Edit</div>'
})

TabularTables.BillingClientSessions = new Tabular.Table({
  name: 'BillingClientSessions',
  collection: Sessions,
  pub: 'Sessions_denormalized',
  order: [[0, "desc"]],
  dom: 't',
  pageLength: 1000,
  columns: ClientReviewSessionColumns
})