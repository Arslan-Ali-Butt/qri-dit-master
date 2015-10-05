$(document).ready ->
  window.hasChanges = false

  $(document).on 'change', 'textarea,input[type=text],input[type=checkbox]', (e) ->
    target = $(e.target)
    unless target.parents('.search-form')
      window.hasChanges = true

  $(document).on 'submit', 'form', (e) ->
    window.hasChanges = false
    true

  $(document).on 'hidden.bs.modal', '#myModal', (e) ->
    window.hasChanges = false
    true

unsavedChangesHandler = () ->
  if window.hasChanges
    "It looks like you have been editing something. If you leave before saving, then your changes will be lost."
  else
    `undefined`

Unloader.init()
Unloader.register(unsavedChangesHandler)
