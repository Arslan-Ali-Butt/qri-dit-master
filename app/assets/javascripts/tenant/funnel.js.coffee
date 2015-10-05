$(document).on 'change', '#client_type.funnel', (e) ->
  $clients = $(this).closest('form').find('.selectize-client-id')
  if $clients
    val = $(this).val()
    if val != '0'
      clients_url = '/clients.json?client_type=' + val
      $.getJSON clients_url, (data) ->
        control = $clients[0].selectize
        control.enable()
        control.clear()
        control.clearOptions()

        $.each data, (i, client) ->
          control.addOption(
            value: client.id
            text: client.name
          )

        if $('#tenant_qrid_estimated_duration').length > 0 or $('.site-form').length > 0
          control.addOption(
            value: 0
            text: 'Add new ...'
          )

        control.refreshOptions(val != '')

$(document).on 'change', '.selectize-client-id.funnel', (e) ->
  $sites = $(this).closest('form').find('.selectize-site-id')
  if $sites.length > 0
    val = $(this).val()
    if val != '0'
      sites_url = '/sites.json?owner_id=' + val
      $.getJSON sites_url, (data) ->
        control = $sites[0].selectize
        control.enable()
        control.clear()
        control.clearOptions()

        $.each data, (i, site) ->
          control.addOption(
            value: site.id
            text: site.name
          )

        if $('#tenant_qrid_estimated_duration').length > 0
          control.addOption(
            value: 0
            text: 'Add new ...'
          )

        control.refreshOptions(val != '')

$(document).on 'change', '.selectize-site-id.funnel', (e) ->
  $qrids = $(this).closest('form').find('.selectize-qrid-id')
  if $qrids
    val = $(this).val()
    if val != '0'
      qrids_url = '/qrids.json?site_id=' + val
      $.getJSON qrids_url, (data) ->
        control = $qrids[0].selectize
        control.enable()
        control.clear()
        control.clearOptions()

        $.each data, (i, qrid) ->
          control.addOption(
            value: qrid.id
            text: qrid.name
          )

        control.refreshOptions(val != '')

$(document).on 'change', '#staff_work_type_id.funnel, #staff_zone_id.funnel', (e) ->
  $reporters = $(this).closest('form').find('.selectize-reporter-id')
  if $reporters
    reporters_url = '/reporters.json?staff_work_type_id=' + $('#staff_work_type_id').val() + '&staff_zone_id='  + $('#staff_zone_id').val()
    $.getJSON reporters_url, (data) ->
      control = $reporters[0].selectize
      control.enable()
      control.clear()
      control.clearOptions()

      $.each data, (i, reporter) ->
        control.addOption(
          value: reporter.id
          text: reporter.name
        )

      control.refreshOptions()
