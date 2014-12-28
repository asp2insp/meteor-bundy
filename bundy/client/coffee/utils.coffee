window.Utils = {
  userIsAnEmployee: () ->
    return EmployeeTypes.find({type: Meteor.user().profile.type}).count() > 0
}