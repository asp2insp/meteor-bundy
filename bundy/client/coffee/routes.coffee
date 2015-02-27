finalRoutes = []

navRoutes = [
  new NavRoute('sessions', 'fa-calendar', {isEmployeeRoute: true})
  new NavRoute('my-sessions', 'fa-user', {label: 'My Sessions', parentName: 'sessions', isEmployeeRoute: true})
  new NavRoute('log', 'fa-plus', {parentName: 'sessions', isEmployeeRoute: true})
  new NavRoute('action-history', 'fa-clock-o', {label: 'Action History', isEmployeeRoute: true})
]

adminRoutes = [
  new NavRoute('tutors', 'fa-university')
  new NavRoute('tutors/:_id', '', {
    isMainNav: false,
    template: 'employeeDetail',
    data: () ->
      return Employees.findOne(this.params._id)
  })
  new NavRoute('clients', 'fa-users')
  new NavRoute('clients/:_id', '', {
    isMainNav: false,
    template: 'clientDetail',
    data: () ->
      return Clients.findOne(this.params._id)
  })
  new NavRoute('approve-pay', 'fa-money', {label: 'Monthly Billing'})
  new NavRoute('approve-pay/:_id', '', {
    isMainNav: false,
    template: 'approveEmployee',
    data: () ->
      return Employees.findOne(this.params._id)
  })
  new NavRoute('approve-bill', '', {isMainNav: false})
  new NavRoute('approve-bill/:_id', '', {
    isMainNav: false,
    template: 'approveClient',
    data: () ->
      return Clients.findOne(this.params._id)
  })
  new NavRoute('send-invoices', '', {isMainNav: false})
  new NavRoute('send-pay', '', {isMainNav: false})

  new NavRoute('billingRates', 'fa-dollar', {label: 'Billing Rates'})

  new NavRoute('accounting', 'fa-line-chart')
  new NavRoute('monthlyPL', 'fa-pie-chart',  {parentName: 'accounting', label: 'Monthly P/L'})
  new NavRoute('annualPL', 'fa-area-chart',  {parentName: 'accounting', label: 'Annual P/L'})

  new NavRoute('profile', '', {isMainNav: false})
  new NavRoute('edit-profile', '', {isMainNav: false})


  new NavRoute('sign-up', '', {isMainNav: false, template: 'signUp'})
  new NavRoute('', '', {isMainNav: false, redirect: 'log'})
  new NavRoute('index', '', {isMainNav: false, redirect: 'log'})
]

demos = [
  new NavRoute('dashboard', 'fa-dashboard')
  new NavRoute('forms', 'fa-edit')
  new NavRoute('ui-elements', 'fa-wrench', {label: 'UI Elements'})
  new NavRoute('buttons', '', {parentName: 'ui-elements'})
  new NavRoute('typography', '', {parentName: 'ui-elements'})
  new NavRoute('grid', '', {parentName: 'ui-elements'})
  new NavRoute('notifications', '', {parentName: 'ui-elements'})
  new NavRoute('panels-and-wells', '', {parentName: 'ui-elements', label: 'Panels and Wells'})
  new NavRoute('pages', 'fa-files-o', {label: "Sample Pages"})
  new NavRoute('blank', '', {parentName: 'pages', label: "Blank Page"})
]

finalRoutes.push navRoutes...
finalRoutes.push adminRoutes...

#finalRoutes.push demos...

navRouteList = new NavRouteList(finalRoutes)

Session.set('navRoots', navRouteList.rootNavRoutes)

Router.onBeforeAction(() ->
  if !Meteor.userId()
    this.render('logIn')
  else
    this.next()
)