# smoobu

[api]: https://docs.smoobu.com/
[smoobu]: https://smoobu.com/
[coffee2]: https://coffeescript.org/v2/
[bent]: https://www.npmjs.com/package/bent
[apikey]: https://login.smoobu.com/en/settings/channels/edit/70

## A simple library to access the Smoobu Host API.

This module implements (or will implemement) a the [Smoobu][smoobu]
API as at 23 January 2020.  Currently it does not handle OAuth2
authentication.

The library is witten in [Coffeescript V2][coffee2] using native
Promises and its only dependency is [bent][bent].  You do not
need Coffeescript to use the library; it is precompiled to
Javascript ES6.

## Install

```
npm install smoobu
```

Get your API key from [here][apikey].


## Example

```javascript
const Smoobu = require('smoobu');
const API_KEY = "X.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

const smoobu = new Smoobu(API_KEY);

user = await smoobu.user();
console.log(`User ${user.id} is`, user.firstName, user.lastName);
```

## Constructor

```javascript
const smoobu = new Smoobu(API_KEY);
```

~~If you wish to go through a proxy server, a proxy may
be passed in as a second argument.  This is currently experimental
and will only work with the forked version of `bent`.~~

## Methods

Each method in this library maps to a function in the Smoobu API. Please
see the [API documentation][api].

A number of methods have different return values from the underlying
API call and these are documented below.  In particular, dates are
returned as javascript native dates rather than a string form.  When a
date is passed to a method, it may always be passed as a native
javascript date or as a string in the form 'YYYY-MM-DD'.

All methods return Promises which resolve to a single result object
to the `.then()`. Optional parameters are shown within square
brackets: `[` and `]`.  Methods may be called either as Promises or using
async/await syntax.  No errors are dealt with inside the library
so all calls should have a `.catch(err)` to pick up the error.  See
the `Errors` section of this document for more information.

### Get the user details

```javascript
smoobu.user();
```

This is the [Get User](https://docs.smoobu.com/#get-user-api) API call.  The
promise resolves to an object as below:

```javascript
{
  id: 7,
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com'
}
```

### Get current availability

This is the [Availability](https://docs.smoobu.com/#smoobu-availability-api)
API call.  The method should be called with the arrival date, the departure
date and optionally the apartment(s) to check.  The apartments parameter
can be passed as a number, an array of numbers or left out, in which
case all apartments will be checked.

```javascript
smoobu.availability(arrival, departure [, apartments])
```

The promise resolves to the same structure as shown on the Smoobu API.

### Create Booking

This has not yet been implemented.

### Update Booking

This has not yet been implemented.

### Cancel Booking

This will mark a booking as cancelled.

```javascript
smoobu.cancelBooking(reservationID);
```

### Get Bookings

This is the raw access to the
[Get Bookings](https://docs.smoobu.com/#get-bookings-api) API call.  It
takes an object as described on the Smoobu documentation and returns
the raw data shown there.  It does not handle paging internally.

See `reservations()` below for an easier interface.

```javascript
smoobu.getBookings(params);
```

### Get reservations

This is a wrapper around `getBookings()`  You pass it an apartment ID,
an optional start date, an optional end date and an optional boolean
for including cancellations (defaulting to `true`).

The method will collect all pages together and return a simple array
of all the bookings found.  To pass a later parameter but default an
earlier one, simply pass `null`.

```javascript
smoobu.reservations(apartmentID [, fromDate [, toDate [, showCancellation]]]);
```

The array returned will be in the same form as the `bookings` key from
`getBookings()` but will be the data from all pages.

### Get a single reservation

This implements the [Get Booking](https://docs.smoobu.com/#get-booking-api)
API call.  As single reservation ID is passed and and the full reservation
details are returned.

```javascript
smoobu.reservation(bookingID);
```

### Get rates

This implements the [Get Rates](https://docs.smoobu.com/#get-rates-api)
API call.  It is passed a start date and an end date and, optionally,
an apartment ID or an array of apartments IDs.

For each apartment, it returns a list of days within the range, showing
the price, the minimum stay and the availability.

```javascript
smoobu.getRates(startDate, endDate, apartments);
```

### Set rates

This implements the [Post Rates](https://docs.smoobu.com/#post-rates-api)
API call.  This implementation relies on a Rate class which may
found as Smoobu.Rate.

For each rate change to be made, you create a `Rate` object, passing
it the start date and the end date of the range to be changed.  Using that
object, you set either the `price` property or the `minstay` property
or both.  You then pass the rate object or an array of rate objects to
the `setRates()` method.

For example:

```javascript
const Rate = Smoobu.Rate;
const rate = new Rate(new Date(), '2020-12-31');
rate.price = 123.45;     // in the currency of the property
rate.minstay = 2;        // in days
smoobu.setRates(rate, apartment);
```

Note that both arguments to `setRates()` can be singletons or arrays.
Thus you can set the rates for multiple periods on multiple apartments,
if you wish.
