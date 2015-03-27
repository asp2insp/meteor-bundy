Template.profile.viewmodel({
  save: -> saveProfile()
  name: -> Meteor.user().name
  email: -> Meteor.user().email
  phone: -> Meteor.user().phone
  type: -> Meteor.user().type
  logout: ->
    Meteor.logout()
    Router.go('/')
})

Template.editProfile.viewmodel({
  save: -> saveProfile()
  name: -> Meteor.user().name
  email: -> Meteor.user().email
  phone: -> Meteor.user().phone
  type: -> Meteor.user().type
  logout: ->
    Meteor.logout()
    Router.go('/')
})

saveProfile = () ->
  user = Meteor.user()
  profile = {}
  profile.phone = $("#phonenumber").val()
  profile.name = $("#name").val();
  profile.type = if user.isAdmin then $("#type").val() else user.profile?.type
  Meteor.users.update(Meteor.userId(), {$set: {profile: profile}})
  Router.go('/profile')