# Core
 - Tutor management
 - Client Management
 - Billing Rate management
 - Monthly Billing flow
 - P/L reports
  - Annual
  - Monthly? Trends?

# Cleanup
 - Search in DataTables doesn't work
 - Invoices/PayStubs should notify when they need updating!

# Wishlist
 - Smart session pre-fill
 - Collection logging
  - Undo/Redo stack at user level

# Debt
 - Clients aren't User objects.
 - Route generation is hardcoded at startup. Makes login difficult
  - Can modify nav-lib to accept an isAdmin param - can use reactive source
 - Need to replace hardcoded HTML in tables.coffee with tmpl: calls.
 - Need to replace hardcoded '/tutors/:_id' paths with IronRouter's pathFor helper