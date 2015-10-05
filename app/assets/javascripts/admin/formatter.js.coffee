$(document).ready ->
  $('[data-stripe="number"]').formatter pattern: '{{9999}}-{{9999}}-{{9999}}-{{9999}}'
  $('[name="admin_tenant[phone]"]').formatter pattern: '{{999}}-{{999}}-{{9999}}'
