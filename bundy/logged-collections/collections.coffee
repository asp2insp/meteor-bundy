@lc = {}

class EventLog
  constructor: (@indexedFields) ->
    check(@indexedFields, [String])

  startLogging: (collection, options) ->
    indexedFields = @indexedFields
    collection.after.insert((user_id, doc) ->
      ev = _.pick(doc, indexedFields)
      ev.action = 'insert'
      ev.collection = collection._name
      ev.ts = Date.now()
      ev.user_id = user_id
      ev.rollback = {action: '$remove', selector: {_id: this._id}, payload: null}
      if options.desc
        ev.desc = options.desc(doc)
      if options.indexOn
        _.forEach(options.indexOn, (func, prop) ->
          ev[prop] = func(doc)
        )
      lc._EventLog.insert(ev)
    )
    collection.before.remove((user_id, doc) ->
      ev = _.pick(doc, indexedFields)
      ev.action = 'remove'
      ev.collection = collection._name
      ev.ts = Date.now()
      ev.user_id = user_id
      if options.desc
        ev.desc = options.desc(doc)
      if options.indexOn
        _.forEach(options.indexOn, (func, prop) ->
          ev[prop] = func(doc)
        )
      ev.rollback = {action: '$insert', selector: null, payload: doc}
      lc._EventLog.insert(ev)
    )
    collection.after.update((userId, doc, fieldNames, modifier, options) ->
      ev = _.pick(doc, indexedFields)
      ev.action = 'update'
      ev.collection = collection._name
      ev.ts = Date.now()
      ev.user_id = user_id
      if options.desc
        ev.desc = options.desc(doc)
      if options.indexOn
        _.forEach(options.indexOn, (func, prop) ->
          ev[prop] = func(doc)
        )
      ev.rollback = {action: '$update', selector: {_id: this._id}, payload: _.pick(this.previous, fieldNames)}
      lc._EventLog.insert(ev)
    )

@lc.EventLog = EventLog

# {ts, indexedFields..., action, type, desc, user_id, rollback}
@lc._EventLog = new Mongo.Collection('lc.EventLog')
