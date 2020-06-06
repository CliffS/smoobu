Bent    = require 'bent'
Path    = require 'path'
Query   = require 'querystring'
util    = require 'util'
{ fixdate } = require './helper'
Rate    = require './Rate'

HOST = 'https://login.smoobu.com/'

class Smoobu

  constructor: (apiKey, proxy) ->
    headers =
      'API-KEY': apiKey
      'Cache-Control': 'no-cache'
    if proxy
      @GET  = Bent HOST, 'GET',    'json', headers, proxy
      @POST = Bent HOST, 'POST',   'json', headers, proxy
      @DEL  = Bent HOST, 'DELETE', 'json', headers, proxy
    else
      @GET  = Bent HOST, 'GET',    'json', headers
      @POST = Bent HOST, 'POST',   'json', headers
      @DEL  = Bent HOST, 'DELETE', 'json', headers

  Object.defineProperty @, 'Rate', value: Rate

  get: (path..., search) ->
    if typeof search is 'object'
      query = {}
      for k, v of search
        if Array.isArray v
          k = k + '[]'
        query[k] = v
      search = Query.encode query
    else
      path.push search
      search = ''
    path = path.join '/'
    path = path + '?' + search if search
    # console.log 'GET PATH', path
    @GET path
    .catch (err) =>
      if err.statusCode
        body = await err.responseBody
        result = new Error err.message
        result.response = try
          JSON.parse body.toString()
        result.path = path
        throw result
      throw err

  del: (path...) ->
    path = path.join '/'
    @DEL path
    .catch (err) =>
      body = await err.responseBody
      result = new Error err.message
      result.response = JSON.parse body.toString()
      throw result

  post: (path..., params = {}) ->
    (
      if @customerID
        Promise.resolve @customerID
      else
        @user()
        .then (user) =>
          @customerID = user.id
    )
    .then (id) =>
      path = path.join '/'
      params.customerId = id
      # console.log 'POST PATH', path
      @POST path, params
    .catch (err) =>
      body = await err.responseBody
      result = new Error err.message
      result.response = JSON.parse body.toString()
      throw result

  user: ->
    @get 'api', 'me'

  availability: (arrival, departure, apartments = []) ->
    # console.log typeof arrival
    apartments = [ apartments ] unless Array.isArray apartments
    @post 'booking', 'checkApartmentAvailability',
      arrivalDate:  fixdate arrival
      departureDate:  fixdate departure
      apartments: apartments

  createBooking: ->
    throw new Error "Function not implemented"

  updateBooking: ->
    throw new Error "Function not implemented"

  cancelBooking: (id) ->
    @del 'api', 'reservations', id

  # this is the raw getBookings API call, requiring page handling
  getBookings: (params) ->
    @get 'api', 'reservations', params

  # this will get reservations for single id, paging if necessary
  reservations: (id, start, end, cancellations = true) ->
    Promise.resolve()
    .then =>
      throw new Error "ID required" unless id
      params = {}
      params.apartmentId = id
      params.showCancellation = cancellations
      params.from = fixdate start if start
      params.to = fixdate end if end
      bookings = []
      loop
        result = await @getBookings params
        bookings.push result.bookings...
        params.page = result.page + 1
        break if result.page > result.page_count
      bookings

  reservation: (id) ->
    Promise.resolve()
    .then =>
      throw new Error "ID required" unless id
      @get 'api', 'reservations', id

  getRates: (start, end, apartments) ->
    apartments = [ apartments ] unless Array.isArray apartments
    # console.log apartments
    params =
      start_date: fixdate start
      end_date: fixdate end
      apartments: apartments
    @get 'api', 'rates', params
    .then (result) =>
      result.data

  setRates: (rates, apartments) ->
    Promise.resolve()
    .then =>
      rates = [ rates ] unless Array.isArray rates
      apartments = [ apartments ] unless Array.isArray apartments
      unless rates.every (r) -> r.constructor.name is 'Rate'
        throw new Error "rates must be created with new Rate()"
      @post 'api', 'rates',
        apartments: apartments
        operations: (rate.operation for rate in rates)

  apartments: ->
    @get 'api', 'apartments'
    .then (result) =>
      apartments = {}
      apartments[app.id] = app.name for app in result.apartments
      apartments

  apartment: (id) ->
    # console.log 'ID', id
    @get 'api', 'apartments', id

  messages: (id, onlyGuest = false) ->
    messages = []
    params =
      onlyRelatedToGuest: onlyGuest
    loop
      result = await @get 'api', 'reservations', id, 'messages', params
      messages.push result.messages...
      params.page = result.page + 1
      break if result.page is result.page_count
    for message in messages
      message.createdAt = new Date message.createdAt
      message.type = switch message.type
        when 1 then 'inbox'
        when 2 then 'outbox'
        else 'unknown type'
    messages

  messageGuest: ->
    throw new Error "Function not implemented"

  messageHost: ->
    throw new Error "Function not implemented"


module.exports = Smoobu
