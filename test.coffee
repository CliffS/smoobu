#!/usr/bin/env coffee

Smoobu = require './src/smoobu'

SMOOBU = require './smoobu'     # the json file

smoobu = new Smoobu SMOOBU.key, SMOOBU.id, SMOOBU.hash

today = new Date
days2 = new Date().setDate today.getDate() + 2
days4 = new Date().setDate today.getDate() + 4

smoobu.user()
.then (result) ->
  console.log result
  smoobu.availability days2, days4
.then (result) ->
  console.log result
.catch (err) ->
  console.log err
