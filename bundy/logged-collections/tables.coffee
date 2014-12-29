@lc = @lc || {}
@lc.ui = @lc.ui || {}

@lc.ui.EventTable = new Tabular.Table({
  name: 'lc.EventTable',
  collection: @lc._EventLog,
  order: [[0, "desc"]],
  dom: "<'row'<'col-xs-12't>>" +
       "<'row'<'col-xs-6'i><'col-xs-6'p>>",
  columns: [
    {
      data: 'ts',
      title: 'Date',
      render: (val) ->
        return moment(val).calendar()
    },
    {
      data: 'user_id',
      title: 'User',
      render: (val) ->
        return Meteor.users.findOne(val).profile.name
    },
    {data: 'action', title: 'Action'},
    {data: 'desc', title: 'Desc'},
  ]
})



UI.registerHelper('lc', () ->
  return lc.ui
)