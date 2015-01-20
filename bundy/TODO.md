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
 - Invoices/PayStubs should notify when they need updating! (Low Priority)

# Wishlist
 - Smart session pre-fill

# Debt
 - Clients aren't User objects.
 - Route generation is hardcoded at startup. Makes login difficult
  - Can modify nav-lib to accept an isAdmin param - can use reactive source
 - Need to replace hardcoded HTML in tables.coffee with tmpl: calls.
 - Need to replace hardcoded '/tutors/:_id' paths with IronRouter's pathFor helper




## Feedback

Totals on Invoice/Pay Stub creation page
Preview on Invoice/Pay Stub creation

Auto fill date/time for log session

Add date deposited into bank to Invoice (and UI for adding deposit/paid flag)
Alphabetize Monthly Billing Clients

Revenue/Expenses segmented by tutor (PL page clone but per tutor)

Flat Rate has effective pre-pay day in notes


Types of Cancellations:
A: Gave 24 hours notice (2/semester) (track allocation of cancellations)
B: No-Show or cancel < 24 hours - full charge, full pay
C: Sick - No Charge
D: School Holiday - No Charge