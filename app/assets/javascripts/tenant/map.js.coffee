$(document).ready ->
  if $('#map_site').length > 0
    initMap()

@initMap = ->
  window.googlemap = new GoogleMap()

class GoogleMap
  constructor: ->
    lat = $('#tenant_site_latitude').val() || 16.775833
    lng = $('#tenant_site_longitude').val() || 3.009444
    zoom = (if $('#tenant_site_latitude').val() then 14 else 4)
    latLng = new google.maps.LatLng(lat, lng)
    @map = new google.maps.Map(document.getElementById('map_site'),
      mapTypeId: google.maps.MapTypeId.ROADMAP
      center: latLng
      zoom: zoom
    )
    @marker = new google.maps.Marker(
      position: latLng
      map: @map
      draggable: ($('.site-form').length > 0)
      icon: $('#tenant_site_image').val()
    )
    @geocoder = new google.maps.Geocoder()

    if $('.site-form').length > 0
      @bindEvents()

    unless $('#tenant_site_latitude').val()
      @findAddress()

  bindEvents: =>
    google.maps.event.addListener @marker, 'dragend', =>
      latLng = @marker.getPosition()
      @map.panTo latLng
      @updateCoordinates latLng

    $(document).on 'change', '#tenant_site_address_attributes_house_number', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_street_name', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_line_2', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_city', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_province', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_postal_code', (e) =>
      @findAddress()
    $(document).on 'change', '#tenant_site_address_attributes_country', (e) =>
      @findAddress()

  findAddress: =>
    house     = $('#tenant_site_address_attributes_house_number').val()
    street    = $('#tenant_site_address_attributes_street_name').val()
    line_2    = $('#tenant_site_address_attributes_line_2').val()
    city      = $('#tenant_site_address_attributes_city').val()
    province  = $('#tenant_site_address_attributes_province').val()
    postal_code = $('#tenant_site_address_attributes_postal_code').val()
    country   = $('#tenant_site_address_attributes_country option:selected').text()
    address   = house + ' ' + street + ', ' + line_2 + ', ' + city + ', ' + province + ' ' + postal_code + ', ' + country
    @geocoder.geocode
      address: address
      partialmatch: true
    , @geocodeResult

  geocodeResult: (results, status) =>
    if status is 'OK' and results.length > 0
      @map.fitBounds results[0].geometry.viewport
      @marker.setPosition results[0].geometry.location
      @updateCoordinates results[0].geometry.location
    else
      console.log 'Geocode was not successful for the following reason: ' + status

  updateCoordinates: (latLng) =>
    $('#tenant_site_latitude').val(latLng.lat())
    $('#tenant_site_longitude').val(latLng.lng())
