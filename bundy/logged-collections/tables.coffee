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
        return Meteor.users.findOne(val)?.profile.name
    },
    {data: 'action', title: 'Action', sortable: false},
    {data: 'desc', title: 'Desc'},
    {
      data: 'rollback'
      title: 'Rollback',
      sortable: false,
      render: (val, type, doc) ->
        if val.rb_ts?
          return 'Rolled back: ' + moment(val.rb_ts).calendar()
        else
          return '<button class="btn btn-warning btn-circle lc-eventUndo pull-right" type="button"' +
               'data-eventId="'+doc._id+'">' +
               '<i class="fa fa-undo"></i>' +
               '</button>'
    }
  ]
})

Meteor.isClient && Template.lc_eventsList.helpers({
  makeSelector: () ->
    return Template.currentData()
})

Meteor.isClient && Template.lc_eventsList.events({
  'click button.lc-eventUndo': (event, template) ->
    event_id = $(event.currentTarget).data('eventid')
    Meteor.call('performRollback', event_id)
})

Meteor.methods({
  performRollback: (event_id) ->
    if Meteor.isClient
      return
    ev = lc._EventLog.findOne(event_id)
    collection = lc._collections[ev.collection]
    unless collection?
      throw new Meteor.Error('Cannot find a Collection named ' + ev.collection)
    switch ev.rollback.action
      when '$remove' then collection.remove(ev.rollback.selector)
      when '$insert' then collection.insert(ev.rollback.payload)
      when '$update' then collection.update(ev.rollback.selector, {$set: ev.rollback.payload})
      else
        throw new Meteor.Error('Unsupported rollback action: ' + ev.rollback.action)
    lc._EventLog.update({_id: event_id}, {$set: {'rollback.rb_ts': Date.now()}})
})



UI.registerHelper('lc', () ->
  return lc.ui
)