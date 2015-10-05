$(document).on 'change', '#assignee_id', (e) ->
  updateEventSource()

$(document).on 'click', '#qrid_calendar_view', (e) ->
  $('#qrid_calendar_view').addClass('active')
  $('#reporter_calendar_view').removeClass('active')
  qrid_id = $('#calendar').data('qrid_id') || $('#calendar').data('qrid-id') || ''
  events_url = $('#calendar').data('events_url') || $('#calendar').data('events-url')
  new_event_source = events_url + '?qrid_id=' + qrid_id
  switchEventSource(new_event_source)

$(document).on 'click', '#reporter_calendar_view', (e) ->
  updateEventSource()

@updateEventSource = () ->
  events_url = $('#calendar').data('events_url') || $('#calendar').data('events-url')
  if $('#assignee_id').val() == ''
    $('#qrid_calendar_view').addClass('active')
    $('#reporter_calendar_view').removeClass('active').addClass('disabled')
    $('#assignee_badge').hide()

    $('#assignee_daily_hours').text('')
    qrid_id = $('#calendar').data('qrid_id') || $('#calendar').data('qrid-id') || ''
    new_event_source = events_url + '?qrid_id=' + qrid_id
  else
    $('#qrid_calendar_view').removeClass('active')
    $('#reporter_calendar_view').addClass('active').removeClass('disabled')
    $('#assignee_badge').show()

    $.getJSON '/reporters/' + $('#assignee_id').val() + '.json', (data) ->
      $('#reporter_calendar_view a').text("#{data.name}'s Schedule")
      if data.staff_daily_hours?
        $('#assignee_daily_hours').html("<p>#{data.name}'s Preferred Working Time Notes: #{data.staff_daily_hours}</p>")
      else
        $('#assignee_daily_hours').html('')

    new_event_source = events_url + '?assignee_id=' + $('#assignee_id').val()

  switchEventSource(new_event_source)

@switchEventSource = (new_event_source) ->
  if new_event_source != $('#calendar').data('eventSource')
    $('#calendar').fullCalendar('removeEventSource', $('#calendar').data('eventSource'))
    $('#calendar').fullCalendar('addEventSource', new_event_source)
    $('#calendar').data('eventSource', new_event_source)
