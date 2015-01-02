Template.editSession.rendered = () ->
  this.autorun(() ->
    session = Sessions.findOne(Session.get('editSessionId'))
    if session?
      lodash.forEach(session, (value, key) ->
        el = this.$('input#'+key)[0]
        if el?
          $(el).attr('value', value)
      )
  )