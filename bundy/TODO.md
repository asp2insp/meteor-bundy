# Current
- Update Log Session to use viewmodel
- Update Edit Session to use viewmodel
- Update Employee table to get rid of profile object
- Update edit tutor to use viewmodel


# Core
 - Billing Rate management
 - Monthly Billing flow
 - P/L reports
  - Annual
  - Monthly? Trends?
- Cancellation expungement
  - automatic (after X billing cycles)
  - manual (forgiveness)

# Cleanup
 - Search in DataTables doesn't work
 - Invoices/PayStubs should notify when they need updating! (Low Priority)
 - Resolve Employee/Tutor misnaming

# Wishlist
 - Smart session pre-fill

# Debt
 - Clients aren't User objects.
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