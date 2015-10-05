$(document).ready ->
  if $('.assignment-form').length > 0 || $('.report-filter-form').length > 0
    initCalendarPickers()

    $('.assignment-form').on 'submit', (e) ->
      saveCalendarPickers()

    $('.report-filter-form').on 'submit', (e) ->
      saveCalendarPickers()

$(document).on 'ajax:before', '.assignment-form', (e) ->
  saveCalendarPickers()

$(document).on 'change', '#tenant_assignment_recurrence', (e) ->
  if $('#tenant_assignment_recurrence').val() != ''
    $('#recurring_until_at').show()
  else
    $('#recurring_until_at').hide()

$(document).on 'change', '#tenant_assignment_qrid_id', (e) ->
  duration = $('#tenant_assignment_qrid_id option:selected').data('duration')
  $('#wrapper_end_at input[type=text]').val duration if duration?


@initCalendarPickers = () ->
  $('.date-picker').datepicker()
  $('.time-picker').timepicker()

  start_at  = $('#wrapper_start_at input[type=hidden]').val()
  if start_at != ''
    date = moment.unix(start_at)
    $('#wrapper_start_at .date-picker').val moment(date).format('DD/MM/YYYY')
    $('#wrapper_start_at .time-picker').val moment(date).format('hh:mm A')

  end_at    = $('#wrapper_end_at input[type=hidden]').val()
  if end_at != ''
    date = moment.unix(end_at)
    duration = (end_at - start_at) / 3600
    $('#wrapper_end_at .date-picker').val moment(date).format('DD/MM/YYYY')
    $('#wrapper_end_at .time-picker').val moment(date).format('hh:mm A')
    $('#wrapper_end_at #duration').val duration

  until_at    = $('#recurring_until_at input[type=hidden]').val()
  if until_at != ''
    date = moment.unix(until_at)
    $('#recurring_until_at .date-picker').val moment(date).format('DD/MM/YYYY')

  if $('#tenant_assignment_recurrence').val() != ''
    $('#recurring_until_at').show()


@saveCalendarPickers = () ->
  start_date  = $('#wrapper_start_at .date-picker').val()
  start_time  = $('#wrapper_start_at .time-picker').val()
  if start_date != ''
    start_at    = moment(start_date + ' ' + start_time, 'DD/MM/YYYY hh:mm A');
    $('#wrapper_start_at input[type=hidden]').val(start_at)
  else
    $('#wrapper_start_at input[type=hidden]').val('')

  end_date  = $('#wrapper_end_at .date-picker').val()
  end_time  = $('#wrapper_end_at .time-picker').val()

  if $('#wrapper_end_at #duration').length > 0 and start_date != ''
    duration  = $('#wrapper_end_at #duration').val()
    end_at = new Date(start_at)
    end_at.setMinutes end_at.getMinutes() + Math.round(parseFloat(duration) * 60)
    $('#wrapper_end_at input[type=hidden]').val(end_at)

  else if end_date == ''
    $('#wrapper_end_at input[type=hidden]').val('')
  else
    end_at    = moment(end_date + ' ' + end_time, 'DD/MM/YYYY hh:mm A');
    $('#wrapper_end_at input[type=hidden]').val(end_at)

  until_date  = $('#recurring_until_at .date-picker').val()
  if until_date == ''
    $('#recurring_until_at input[type=hidden]').val('')
  else
    until_at    = moment(until_date, 'DD/MM/YYYY');
    $('#recurring_until_at input[type=hidden]').val(until_at)
