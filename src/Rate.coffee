Property = require './Property'
{ fixdate } = require './helper'

class Rate extends Property

  constructor: (start, end) ->
    super()
    @start = fixdate start
    @end = fixdate end if end?

  @property 'price',
    get: ->
      @daily_price
    set: (val) ->
      @daily_price = parseFloat val

  @property 'minstay',
    get: ->
      @min_length_of_stay
    set: (val) ->
      val = Math.abs val
      throw new Error "minstay must be a numeric value" unless isFinite val
      @min_length_of_stay = val

  @property 'operation',
    get: ->
      unless @min_length_of_stay or @daily_price
        throw new Error "Must set either price or minstay (or both)"
      retval = {}
      retval.dates = [
        if @end?
          "#{@start}:#{@end}"
        else @start
      ]
      retval.daily_price = @daily_price if @daily_price
      retval.min_length_of_stay = @min_length_of_stay if @min_length_of_stay
      retval


module.exports = Rate
