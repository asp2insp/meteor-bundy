Template.profile.viewmodel({
  save: -> saveProfile()
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