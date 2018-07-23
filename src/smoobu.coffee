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
      urilsearch = new URLSearchParams search
    else
      path.push search
    uri.pathname = Path.join  path...
    Request
      url: uri
      json: true
      headers:
        'API-Key': @apiKey

  post: (path..., params) ->
    uri = new URL HOST
    uri.pathname = Path.join path...
    params.customerId = @customerID.toString()
    params.verificationHash = @verificationHash
    search = new URLSearchParams params
    search.sort()
    console.log params
    Request
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

  reservations: (id) ->
    @get 'api', 'apartment', id.toString(), 'booking',
      showCancellation: true


  apartments: ->
    @get 'api', 'apartment', user_id: @customerID
    .then (result) ->
      result.apartments

  apartmentIDs: ->
    @apartments()
    .then (apartments) ->
      (apartment.apartmentId for apartment in apartments)


module.exports = Smoobu
