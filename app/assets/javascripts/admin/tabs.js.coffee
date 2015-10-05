$(document).ready ->
  $('.nav-tabs > li > a[data-toggle="tab"]').click (e) ->
    e.preventDefault()
    $(this).tab 'show'
