$(document).ready ->
  if $('#geolocation_task').length > 0
    initGeolocationTask()

@initGeolocationTask = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition(geoSuccess, geoError)
  else
    geoError('Geolocation is not supported')

@geoSuccess = (position) ->
  return  if $('#geolocation_task').hasClass('success')
  $('#geolocation_task').addClass('success')
  showAlertMessage('You are located', 'success')

  $.ajax
    dataType: 'script'
    type:     'post'
    url:      window.location.href
    data:
      latitude:   position.coords.latitude
      longitude:  position.coords.longitude
      accuracy:   position.coords.accuracy

    error: (xhr, status, error) ->
      console.log error
      window.location = '/my_qrids'


@geoError = (msg) ->
  $('#geolocation_task').addClass('error')
  showAlertMessage((if typeof msg is 'string' then msg else 'Geolocation services have been disabled on this device. Please enable in order to use QRIDit Homewatch effectively.'), 'danger')

@showAlertMessage = (msg, type) ->
  $('<div class=\"alert alert-dismissable alert-' + type + '\"><button aria-hidden=\"true\" class=\"close\" data-dismiss=\"alert\" type=\"button\">&times;<\/button>' + msg + '<\/div>').appendTo('#flash').hide().fadeIn().delay(3000).fadeOut()
