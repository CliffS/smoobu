
Date::ymd = ->
  day = "0#{@getDate()}".substr(-2)
  month = "0#{@getMonth() + 1}".substr(-2)
  year = @getFullYear()
  "#{year}-#{month}-#{day}"

exports.fixdate = (date) ->
  if typeof date is 'string'
    return date if date.match /^\d{4}-\d\d-\d\d$/
  if date instanceof Date
    return date.ymd()
  throw new Error "Invalid date passed: #{date}"
