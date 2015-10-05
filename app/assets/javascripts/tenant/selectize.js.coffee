$(document).ready ->
  $('.selectize').selectize(
    plugins: ['remove_button'],
    onItemAdd: (value, $item)->
      if value == '0'
        this.removeItem(value)
        this.refreshItems()
        i=1
        numOfItems = Object.keys(this.options).length
        while i < numOfItems
          this.addItem(i)
          ++i
  )
  $('.selectize-client-id').selectize(
    plugins: ['remove_button']
  )
  $('.selectize-site-id').selectize(
    plugins: ['remove_button']
  )
  $('.selectize-qrid-id').selectize(
    plugins: ['remove_button']
  )
  $('.selectize-reporter-id').selectize(
    plugins: ['remove_button']
  )
  $('.selectize-zone-id').selectize(
    plugins: ['remove_button']
  )
  $reporters=$('.selectize-time-reporter').selectize(
    plugins: ['remove_button']
  )
  $zones=$('#staff_zone_id').selectize({
    plugins: ['remove_button'],
    onChange: (value)->
      if !value.length
        uurl='/users.json'
      else
        uurl='/users.json?staff_zone_id='+value

      reporters  = $reporters[0].selectize
      reporters.disable();
      reporters.clearOptions();
      reporters.load (callback)->
        xhr && xhr.abort();
        xhr = $.ajax ({
          url: uurl,
          success: (results) ->
              reporters.enable()
              callback(results)
          ,
          error: () ->
              callback()
        })
          
  })

  if($('time_index').length!=0)
    reporters  = $reporters[0].selectize
    zones = $zones[0].selectize

  # this setTimeout is a workaround for QRID-814, can't figure out why it happens
  # in the first place
  setTimeout ->
    if $('select.selectize').length > 0    
      $('select.selectize').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-client-id').length > 0    
      $('select.selectize-client-id').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-site-id').length > 0    
      $('select.selectize-site-id').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-qrid-id').length > 0    
      $('select.selectize-qrid-id').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-reporter-id').length > 0        
      $('select.selectize-reporter-id').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-zone-id').length > 0    
      $('select.selectize-zone-id').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select.selectize-time-reporter').length > 0
      $('select.selectize-time-reporter').each ->
        this.selectize.clear() if $(this).val() == ''

    if $('select#staff_zone_id').length > 0
      $('select#staff_zone_id').each ->
        this.selectize.clear() if $(this).val() == ''

  , 100