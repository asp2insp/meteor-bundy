
// {name, amount}
RateAdjustments = new Mongo.Collection('RateAdjustments');

// {name, phone, email, [bonus pay items], type}
Employees = Meteor.users

// {name, phone, email, [billing_adjustments]}
Clients = new Mongo.Collection('Clients');

// {client_id, employee_id, session_type, unit_bill_rate, unit_pay_rate}
BillingRates = new Mongo.Collection('BillingRates');

// {employee_id, client_id, billing_rate_id, start_time, end_time, units,
//  notes, [pay_adjustments], [billing_adjustments], total_bill, total_pay}
Sessions = new Mongo.Collection('Sessions');

// {date, amount, memo, employee_id, [client_ids], [session_ids]}
PayStubs = new Mongo.Collection('PayStubs');

// {date_issued, date_due, amount, memo, client_id, [employee_ids], [session_ids]}
ClientInvoices = new Mongo.Collection('ClientInvoices');

// {date, amount, memo, client}
ClientPayReceipts = new Mongo.Collection('ClientPayReceipts');

EmployeeTypes = new Mongo.Collection('EmployeeTypes');

if (Meteor.isServer) {
    // server
    Meteor.publish("userData", function () {
      if (this.userId) {
        return Meteor.users.find({_id: this.userId},
                                 {fields: {'isAdmin': 1}});
      } else {
        this.ready();
      }
    });
}

if (Meteor.isClient) {
    // client
    Meteor.subscribe("userData");
}
