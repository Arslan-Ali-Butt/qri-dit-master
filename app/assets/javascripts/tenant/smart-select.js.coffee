$(document).on 'submit', '.smart-select', (e) ->
  $el = $(e.target).find('#id')
  if $el.length and $el.val() != ''
    e.preventDefault()
    # url = window.location.href
    # url = url.replace(/\/?[0-9]*$/, '')
    # url = url.replace(/\?.*$/, '')
    url = $(e.target).prop('action') + '/' + $el.val()
    window.location = url

$(document).on 'submit', '.smart-select-trial', (e) ->
  $el = $(e.target).find('#id')
  if $el.length and $el.val() != ''
    e.preventDefault()
    url = $(e.target).prop('action') + '/' + $el.val() + '/trial'
    window.location = url

$(document).on 'submit', '.smart-select-edit', (e) ->
  $el = $(e.target).find('#id')
  if $el.length and $el.val() != ''
    e.preventDefault()
    url = $(e.target).prop('action') + '/' + $el.val() + '/edit'
    window.location = url
