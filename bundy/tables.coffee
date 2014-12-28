TabularTables = {}
Meteor.isClient && Template.registerHelper('TabularTables', TabularTables)

TabularTables.Sessions = new Tabular.Table({
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
    {data: 'client.name', title: 'Client'},
    {data: 'units', title: 'Units'},
    {data: 'rate.unit_pay_amount', title: 'Rate'},
    {
      title: 'Adjustments',
      data: 'pay_adjustments',
      render: (val) ->
        return _.reduce(val, (l, r) ->
          return l + r.name
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
    {data: 'pay_adjustments', title: 'Pay Adjustments', tmpl: Meteor.isClient && Template.adjustmentsCell}
  ]
})