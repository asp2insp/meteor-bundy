Template.profile.events({
  'click #logout-link': () ->
    Meteor.logout()
    Router.go('/')
    return false
})

Template.editProfile.events({
  'submit #profile-edit-form': (e, t) ->
    e.preventDefault()
    saveProfile()
    return false

  'click #save-profile': () ->
    saveProfile()
    return false

  'click #logout-link': () ->
    Meteor.logout()
    Router.go('/')
    return false
})

saveProfile = () ->
  user = Meteor.user()
  profile = {}
  profile.phone = $("#phonenumber").val()
  profile.name = $("#name").val();
  profile.type = if user.isAdmin then $("#type").val() else user.profile?.type
  Meteor.users.update(Meteor.userId(), {$set: {profile: profile}})
  Router.go('/profile')