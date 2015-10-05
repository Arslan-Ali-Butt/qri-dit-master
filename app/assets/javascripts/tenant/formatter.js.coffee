$(document).ready ->
  if $('.user-form, .staff-form, .client-form').length > 0
    $('input[name="tenant_user[phone_cell]"]').formatter({'pattern': '{{999}}-{{999}}-{{9999}}'})
    $('input[name="tenant_user[phone_landline]"]').formatter({'pattern': '{{999}}-{{999}}-{{9999}}'})
    $('input[name="tenant_user[phone_emergency]"]').formatter({'pattern': '{{999}}-{{999}}-{{9999}}'})
    $('input[name="tenant_user[phone_emergency_2]"]').formatter({'pattern': '{{999}}-{{999}}-{{9999}}'})
