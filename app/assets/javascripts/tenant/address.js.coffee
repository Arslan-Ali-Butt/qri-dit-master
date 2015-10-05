$(document).on 'change', '#tenant_user_address_attributes_country, 
  #tenant_client_address_attributes_country, #tenant_staff_address_attributes_country', (e) ->
    updateRegionList($(e.currentTarget).attr('id'))

$(document).on 'change', '#tenant_site_address_attributes_country', (e) ->
  updateRegionList2()


@updateRegionList = (trigger = 'tenant_user_address_attributes_country') ->


  regions_url = '/address/regions.json?country=' + $("##{trigger}").val()
  $.getJSON regions_url, (data) ->
    $label = $('#province_label')

    province_selector = trigger.replace('_country', '_province')
    model = trigger.replace('_address_attributes_country', '')

    $el = $("##{province_selector}")
    if data.length is 0
      $label.text('State / Province')
      $el.replaceWith("<input class=\"form-control\" id=\"#{province_selector}\" name=\"#{model}[address_attributes][province]\" type=\"text\">")
    else
      $label.text(data[0].type.charAt(0).toUpperCase() + data[0].type.slice(1))
      $el.replaceWith("<select class=\"form-control\" id=\"#{province_selector}\" name=\"#{model}[address_attributes][province]\">")
      $el = $("##{province_selector}")
      $el.html('<option value="">Please select a ' + data[0].type + '</option>')
      $.each data, (i, region) ->
        $el.append $('<option></option>').attr('value', region.code).text(region.name)


@updateRegionList2 = () ->
  regions_url = '/address/regions.json?country=' + $('#tenant_site_address_attributes_country').val()
  $.getJSON regions_url, (data) ->
    $label = $('#province_label')
    $el = $('#tenant_site_address_attributes_province')
    old_val = $('#tenant_site_address_attributes_province').val()
    if data.length is 0
      $label.text('State / Province')
      $el.replaceWith('<input class=\"form-control\" id=\"tenant_site_address_attributes_province\" name=\"tenant_site[address_attributes][province]\" type=\"text\">')
    else
      $label.text(data[0].type.charAt(0).toUpperCase() + data[0].type.slice(1))
      $el.replaceWith('<select class=\"form-control\" id=\"tenant_site_address_attributes_province\" name=\"tenant_site[address_attributes][province]\">')
      $el = $('#tenant_site_address_attributes_province')
      $el.html('<option value="">Please select a ' + data[0].type + '</option>')
      $.each data, (i, region) ->
        $el.append $('<option></option>').attr('value', region.code).text(region.name)

    if old_val
      $el.val old_val
    else if $('#copy_owner_address').is(':checked') and $('#owner_address_province').val()
      $el.val $('#owner_address_province').val()
    