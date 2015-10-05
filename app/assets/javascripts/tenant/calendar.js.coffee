$(document).ready ->
  if $('#calendar').length > 0

    # Draggable event to drop into calendar
    $('.external-event').each ->
      $(this).draggable
        zIndex: 999
        revert: true
        revertDuration: 0

    events_url  = $('#calendar').data('events_url') || $('#calendar').data('events-url')
    qrid_id     = $('#calendar').data('qrid_id') || $('#calendar').data('qrid-id') || ''
    assignee_id = $('#calendar').data('assignee_id') || $('#calendar').data('assignee-id') || ''

    editable = (events_url.indexOf("my_assignments") is -1)
    defaultView = (if (qrid_id is '' and assignee_id is '') then 'agendaDay' else 'agendaWeek')

    $('#calendar').data('eventSource', events_url + '?qrid_id=' + qrid_id + '&assignee_id=' + assignee_id)

    if editable
      $('#calendar').fullCalendar
        header:
          left: 'prev,next today'
          center: 'title'
          right: 'month,agendaWeek,agendaDay'
        defaultView: defaultView
        editable: true
        droppable: true
        contentHeight: 1100
        slotEventOverlap: false
        dropAccept: '.external-event'
        events: $('#calendar').data('eventSource')
        ignoreTimezone: false
        timeFormat: 'hh:mm tt'
        firstHour: (new Date()).getHours()

        drop: (date, allDay) ->
          if isDateInThePast(date)
            showAlertMessage('Assignment cannot be set for date in the past', 'danger')
            return false

          end_at = new Date(date.getTime() + parseInt($(this).data('duration')) * 60000)
          renderTempEvent '', date, end_at, allDay

          $.ajax
            dataType: 'script'
            url:      events_url + '/new'
            data:
              qrid_id: qrid_id
              assignee_id: $('#assignee_id').val() || assignee_id
              start_at: date
              end_at: end_at
              comment: ''

          return false

        dayClick: (date, allDay, jsEvent, view) ->
          if isDateInThePast(date)
            showAlertMessage('Assignment cannot be set for date in the past', 'danger')
            return false

          end_at = new Date(date.getTime() + 30 * 60 * 1000)
          renderTempEvent '', date, end_at, allDay

          $.ajax
            dataType: 'script'
            url:      events_url + '/new'
            data:
              qrid_id: qrid_id
              assignee_id: $('#assignee_id').val() || assignee_id
              start_at: date
              end_at: end_at

          return false

        eventClick: (calEvent, jsEvent, view) ->
          if calEvent.recurrence != null
            requestData = 
              instance_start: calEvent.start
              instance_end: calEvent.end
              assignee_id: calEvent.assignee_id
              qrid_id: calEvent.qrid_id
              comment: calEvent.comment

          if calEvent.url
            $.ajax
              dataType: 'script'
              url:      calEvent.url
              data: requestData
            return false

        eventDrop: (calEvent, dayDelta, minuteDelta, allDay, revertFunc) ->
          if calEvent.status != 'Open'
            showAlertMessage('Non-Open assignment cannot be rescheduled', 'danger')
            revertFunc()
            return false

          if isDateInThePast(calEvent.start)
            showAlertMessage('Assignment cannot be set for date in the past', 'danger')
            revertFunc()
            return false

          if calEvent.recurrence != null
            requestData = 
              instance_start: calEvent.start
              instance_end: calEvent.end
              assignee_id: calEvent.assignee_id
              qrid_id: calEvent.qrid_id
              comment: calEvent.comment
              day_delta: dayDelta
              minute_delta: minuteDelta
          else
            requestData = 
              day_delta: dayDelta
              minute_delta: minuteDelta

          if calEvent.url
            $.ajax
              dataType: 'script'
              url:      calEvent.url
              data: requestData                

            return false

        eventResize: (calEvent, dayDelta, minuteDelta, revertFunc) ->
          if calEvent.status != 'Open'
            showAlertMessage('Non-Open assignment cannot be rescheduled', 'danger')
            revertFunc()
            return false

          if calEvent.url
            url = calEvent.url.replace(/edit$/, 'reschedule')
            $.ajax
              dataType: 'script'
              type:     'post'
              url:      url
              data:
                cal_action:   'resize'
                day_delta:    dayDelta
                minute_delta: minuteDelta

              error: (xhr, status, error) ->
                revertFunc()

            return false

        eventRender: (calEvent, element) ->
          if calEvent.recurrence
            element.addClass 'recurrent'
            element.append("<i class='fa fa-repeat'></i>")
        
        loading: (isLoading,view) ->
          if(isLoading)
            $("#calendar_loading").css("display", "block");
          else
            $("#calendar_loading").css("display", "none");

    else
      $('#calendar').fullCalendar
        header:
          left: 'prev,next today'
          center: 'title'
          right: 'month,agendaWeek,agendaDay'
        defaultView: 'agendaWeek'
        editable: false
        droppable: false
        contentHeight: 600
        slotEventOverlap: false
        dropAccept: '.external-event'
        events: $('#calendar').data('eventSource')
        ignoreTimezone: false
        timeFormat: 'hh:mm tt'
        firstHour: (new Date()).getHours()
        loading: (isLoading,view) ->
          if(isLoading)
            $("#calendar_loading").css("display", "block");
          else
            $("#calendar_loading").css("display", "none");


    $(document).on 'hide.bs.modal', '#myModal', (e) ->
      $('#calendar').fullCalendar('refetchEvents')

    $(window).resize ->
        $('.external-event.ui-draggable').first().css('width', $('.fc-widget-header.fc-sun').first().innerWidth() + 'px')

    $('.external-event.ui-draggable').first().css('width', $('.fc-widget-header.fc-sun').first().innerWidth() + 'px')

@isDateInThePast = (date) ->
  check = $.fullCalendar.formatDate(date,'yyyy-MM-dd')
  today = $.fullCalendar.formatDate(new Date(),'yyyy-MM-dd')
  return check < today

@showAlertMessage = (msg, type) ->
  $('<div class=\"alert alert-dismissable alert-' + type + '\"><button aria-hidden=\"true\" class=\"close\" data-dismiss=\"alert\" type=\"button\">&times;<\/button>' + msg + '<\/div>').appendTo('#flash').hide().fadeIn().delay(3000).fadeOut()

@renderTempEvent = (title, start_at, end_at, allDay) ->
  event =
    title: title
    start: start_at
    end: end_at
    allDay: allDay
    color: '#009659'
    textColor: 'white'
  $('#calendar').fullCalendar 'renderEvent', event
