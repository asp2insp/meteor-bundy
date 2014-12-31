finalRoutes = []

navRoutes = [
  new NavRoute('sessions', 'fa-calendar')
  new NavRoute('my-sessions', 'fa-user', {label: 'My Sessions', parentName: 'sessions'})
  new NavRoute('log', 'fa-plus', {parentName: 'sessions'})

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
  new NavRoute('approve-bill', '', {isMainNav: false})
  new NavRoute('send-invoices', '', {isMainNav: false})
  new NavRoute('send-pay', '', {isMainNav: false})
  new NavRoute('accounting', 'fa-line-chart')
  new NavRoute('action-history', 'fa-clock-o', {label: 'Action History'})

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

#finalRoutes.push demos...

navRouteList = new NavRouteList(finalRoutes)

Session.set('navRoots', navRouteList.rootNavRoutes)

Router.onBeforeAction(() ->
  if !Meteor.userId()
    this.render('logIn');
  else
    this.next();
{except: ['sign-up']})