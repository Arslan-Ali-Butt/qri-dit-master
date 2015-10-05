$(document).ready ->
  if $('#map_all').length > 0
    initMapAll()

@initMapAll = ->
  window.googlemap = new GoogleMapAll()

class GoogleMapAll
  constructor: ->
    @map = new google.maps.Map(document.getElementById('map_all'),
      mapTypeId: google.maps.MapTypeId.ROADMAP
      center: new google.maps.LatLng(0, 0)
      zoom: 6
    )
    @greatestDistance = 0
    @latLngPoints = []


    latlngbounds = new google.maps.LatLngBounds()

    assignments_url = $('#map_all').data('assignments_url') || $('#map_all').data('assignments-url')
    $.getJSON assignments_url, (data) =>
      $.each data, (i, assignment) =>
        latLng = new google.maps.LatLng(assignment.latitude, assignment.longitude)

        if @latLngPoints.length >= 1
          $.each @latLngPoints, (i, latLngPoint) =>
            distance = google.maps.geometry.spherical.computeDistanceBetween latLngPoint, latLng

            if distance > @greatestDistance
              @greatestDistance = distance

              
        @latLngPoints.push latLng

        marker = new google.maps.Marker(
          position: latLng
          map: window.googlemap.map
          title: assignment.title
        )
        marker.setIcon($('#icon_complete img').attr('src'))     if assignment.status == 'Done'
        marker.setIcon($('#icon_in_progress img').attr('src'))  if assignment.status == 'In Progress'
        marker.setIcon($('#icon_assigned img').attr('src'))     if assignment.status == 'Open'
        latlngbounds.extend latLng

        contentString = ['<dl>',
                        '<dt>Reporter</dt><dd>' + assignment.assignee + '</dd>',
                        '<dt>Time</dt><dd>' + assignment.start_at + '</dd>',
                        '<dt>Site</dt><dd>' + assignment.site + '</dd>',
                        '<dt>Work Type</dt><dd>' + assignment.work_type + '</dd>',
                        '<dd><a href="' + assignment.url_view + '">View Assignment</a></dd>',
                        '</dl>'].join('\n')
        infowindow = new google.maps.InfoWindow(content: contentString)
        google.maps.event.addListener marker, 'click', ->
          infowindow.open window.googlemap.map, marker

      # according to the interwebs, at zoom level 6 (our default), the scale is 1485m/px
      if window.googlemap.greatestDistance > (1485 * $('map_all').height()) or window.googlemap.greatestDistance > (1485 * $('map_all').width())
        window.googlemap.map.fitBounds latlngbounds 
      else
        window.googlemap.map.setCenter(latlngbounds.getCenter())
        window.googlemap.map.setZoom(6)
