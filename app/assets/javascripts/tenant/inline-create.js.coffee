$(document).on 'change', '.selectize-zone-id', (e) ->
  if $(this).val() is '0'
    $.get '/zones/new.js'

$(document).on 'change', '.selectize-work-type-id', (e) ->
  if $(this).val() is '0'
    $.get '/work_types/new.js'

$(document).on 'change', '.selectize-client-id', (e) ->
  if $(this).val() is '0'
    $.get '/clients/new.js'

$(document).on 'change', '.selectize-site-id', (e) ->
  if $(this).val() is '0'
    url = '/sites/new.js'
    if $('.selectize-client-id').length > 0 and $('.selectize-client-id').val != '0'
      url = url + '?owner_id=' + $('.selectize-client-id').val()
    $.get url
