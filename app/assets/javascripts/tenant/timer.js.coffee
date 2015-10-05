#$(document).ready ->
#  if $('#stopwatch').length > 0
#    $.timer(updateTimer, 70, true)

$currentTime = 0
@updateTimer = ->
  timeString = formatTime($currentTime)
  $('#stopwatch').html timeString
  $currentTime += 70

@formatTime = (time) ->
  time = parseInt(time / 1000)
  s = time % 60
  time = parseInt(time / 60)
  m = time % 60
  time = parseInt(time / 60)
  h = time
  '' + h + ':' + pad(m, 2) + ':' + pad(s, 2)

@pad = (number, length) ->
  str = '' + number
  str = '0' + str  while str.length < length
  str
