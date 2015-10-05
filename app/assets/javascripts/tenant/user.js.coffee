$(document).ready ->
  if $('.staff-form').length > 0
    #$('#disable_assignment_notifications').hide() unless $('#tenant_staff_role_ids_3').is(':checked')
    $('#disable_report_notifications').hide()     unless $('#tenant_staff_role_ids_1').is(':checked') || $('#tenant_staff_role_ids_2').is(':checked')

$(document).on 'change', '#tenant_staff_role_ids_3', (e) ->
  if $(this).is(':checked')
    $('#disable_report_notifications').hide()
    #$('#disable_assignment_notifications').show()
  else
    $('#disable_report_notifications').hide()
    #$('#disable_assignment_notifications').hide()

$(document).on 'change', '#tenant_staff_role_ids_1, #tenant_staff_role_ids_2', (e) ->
  if $(this).is(':checked')
    $('#disable_report_notifications').show()
  else
    $('#disable_report_notifications').hide()
