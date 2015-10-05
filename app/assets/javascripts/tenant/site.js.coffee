$(document).on 'change', '#copy_owner_address', (e) ->
  if $(this).is(':checked')
    $('#tenant_site_address_attributes_house_number').val $('#owner_address_house_number').val()
    $('#tenant_site_address_attributes_street_name').val $('#owner_address_street_name').val()
    $('#tenant_site_address_attributes_line_1').val $('#owner_address_line_2').val()
    $('#tenant_site_address_attributes_line_2').val $('#owner_address_line_2').val()
    $('#tenant_site_address_attributes_city').val $('#owner_address_city').val()
    $('#tenant_site_address_attributes_province').val $('#owner_address_province').val()
    $('#tenant_site_address_attributes_postal_code').val $('#owner_address_postal_code').val()
    $('#tenant_site_address_attributes_country').val $('#owner_address_country').val()

    $('#tenant_site_address_attributes_country').trigger 'change'
  else
    $('#tenant_site_address_attributes_house_number').val ''
    $('#tenant_site_address_attributes_street_name').val ''
    $('#tenant_site_address_attributes_line_2').val ''
    $('#tenant_site_address_attributes_city').val ''
    $('#tenant_site_address_attributes_province').val ''
    $('#tenant_site_address_attributes_postal_code').val ''
    $('#tenant_site_address_attributes_country').val ''

    $('#tenant_site_address_attributes_country').trigger 'change'
  