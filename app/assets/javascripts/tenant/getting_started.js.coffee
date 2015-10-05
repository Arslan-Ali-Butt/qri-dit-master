$(document).ready ->
  if $('#getting_started_popup').length > 0
    $.ajax
      dataType: 'html'
      url:      '/dashboard/getting_started'

      success: (response, status, xhr) ->
        $('#myModal').html response
        $('#myModal').modal 'show'

      error: (xhr, status, error) ->
        console.log error
