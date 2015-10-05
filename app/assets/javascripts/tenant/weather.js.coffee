$(document).ready ->
  if $('#weather_div').length > 0
    initWeather()

@initWeather = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition(geoWeatherSuccess, geoWeatherError)
  else
    geoWeatherError('Geolocation is not supported')

@geoWeatherSuccess = (position) ->
  return  if $('#weather_div').hasClass('success')
  $('#weather_div').addClass('success')

  $.ajax
    dataType: 'html'
    url:      '/dashboard/weather'
    data:
      latitude:   position.coords.latitude
      longitude:  position.coords.longitude
      accuracy:   position.coords.accuracy

    success: (response, status, xhr) ->
      $('#weather_div').html response

    error: (xhr, status, error) ->
      console.log error

@geoWeatherError = (msg) ->
  $('#weather_div').html(if typeof msg is 'string' then msg else 'Geolocation is disabled')
