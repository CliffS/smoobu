Request = require 'request-promise-native'
{ URL, URLSearchParams } = require 'url'
Path    = require 'path'
util    = require 'util'
Moment  = require 'moment'

HOST = 'https://login.smoobu.com/'

fixdate = (date) ->
  return date if typeof date is 'string'
  Moment(date).format 'YYYY-MM-DD'

class Smoobu

  constructor: (@apiKey, @customerID, @verificationHash) ->

  get: (path..., search) ->
    uri = new URL HOST
    if typeof search is 'object'
      uri.search = new URLSearchParams search
    else
      path.push search
    uri.pathname = Path.join  path...
    Request
      # proxy: 'http://localhost:8888'
      strictSSL: false
      url: uri
      json: true
      headers:
        'API-Key': @apiKey

  post: (path..., params) ->
    uri = new URL HOST
    uri.pathname = Path.join path...
    params.customerId = @customerID
    params.verificationHash = @verificationHash
    Request
      # proxy: 'http://localhost:8888'
      strictSSL: false
      uri: uri
      json: true
      method: 'POST'
      body: params

  availability: (arrival, departure, apartments) ->
    apartments = [ apartments ] unless Array.isArray apartments
    @post 'booking', 'checkApartmentAvailability',
      arrivalDate:  fixdate arrival
      departureDate:  fixdate departure
      apartments: apartments

  getReservations: (params, page) ->
    @get 'api', 'apartment', id.toString(), 'booking', params
    .then (result) =>
      result.bookings

  reservations: (id, start, end, cancellations = true) ->
    Promise.resolve()
    .then =>
      params = {}
      params.showCancellation = cancellations
      params.from = fixdate start if start
      params.to = fixdate end if end
      bookings = []
      loop
        result = await @get 'api', 'apartment', id.toString(), 'booking', params
        bookings.push result.bookings...
        params.page = result.page + 1
        break if result.page is result.page_count
      bookings


  apartments: ->
    @get 'api', 'apartment', user_id: @customerID
    .then (result) ->
      result.apartments

  apartmentIDs: ->
    @apartments()
    .then (apartments) ->
      (apartment.apartmentId for apartment in apartments)


module.exports = Smoobu
