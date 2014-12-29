window.Utils = {
  userIsAnEmployee: () ->
    return EmployeeTypes.find({type: Meteor.user()?.profile?.type}).count() > 0
}

UI.registerHelper('companyName', () ->
  return 'Gaskin Tutor Billing'
)

UI.registerHelper('employeeSelector', () ->
  return {employee_id: Meteor.userId()}
)