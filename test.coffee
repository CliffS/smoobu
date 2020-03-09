#!/usr/bin/env coffee

Smoobu = require './src/smoobu'

SMOOBU = require './smoobu'     # the json file

smoobu = new Smoobu SMOOBU.key

today = new Date
days2 = new Date()
days2.setDate today.getDate() + 2
days4 = new Date()
days4.setDate today.getDate() + 4

smoobu.user()
.then (result) ->
  console.log result
  smoobu.availability days2, days4
.then (result) ->
  console.log result
  smoobu.apartments()
.then (result) ->
  console.log result
  # Promise.all (smoobu.apartment id for id in Object.keys result)
  smoobu.apartment 24975
.then (result) ->
  console.log result
  smoobu.getBookings
    from: '2020-01-01'
    to:   '2020-02-29'
    showCancellation: true
.then (result) ->
  console.log "getBookings:", result.total_items
  smoobu.reservations 24975, '2019-01-01', '2019-12-31', false
.then (result) ->
  console.log "Total reservations:", result.length
  smoobu.reservation 1503312
.then (result) ->
  console.log result
  smoobu.messages 2838737
.then (result) ->
  console.log result
  console.log m.message for m in result
  smoobu.getRates '2020-12-01', '2021-01-31', 24975
.then (result) ->
  console.log result
  Rate = Smoobu.Rate
  rate = new Rate  '2020-12-01', '2021-01-31'
  console.log rate
.catch (err) ->
  console.log err
