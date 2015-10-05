$(document).on 'submit', '.search-form', (e) ->
  e.preventDefault()
  search()

$(document).on 'keyup', '.search-form #q', (e) ->
  search()

$(document).on 'focus', '.search-form #q', (e) ->
  unless $('.search-form').hasClass('open')
    $('.search-form').addClass('open')
    $('<div class="dropdown-backdrop"/>').insertAfter($(this)).on('click', hideResults)
    search()

@search = () ->
  $search = $('.search-form #q')
  q = $search.val()
  return  if $search.prop('searched') is q

  $search.prop 'searched', q

  $el = $('.search-form ul')
  $el.empty()
  if q.length < 3
    $el.append $('<li class="dropdown-header" role="presentation"></li>').text('Start typing.')
  else
    $el.append $('<li class="dropdown-header" role="presentation"></li>').text('Searching...')

    search_url = '/search.json?q=' + encodeURIComponent(q)
    $.getJSON search_url, (data) ->
      $el = $('.search-form ul')
      $el.empty()
      $.each data, (i, section) ->
        if section.list.length
          $el.append $('<li class="divider" role="presentation"/>') unless $el.is(':empty')
          $el.append $('<li class="dropdown-header" role="presentation"></li>').text(section.title)
          $.each section.list, (i, item) ->
            $item = $('<li role="presentation"></li>')
            $item.append $('<a></a>').text(item.name).prop('href', item.url)
            $item.append $('<div class="subtitle"></div>').text('(' + item.subtitle + ')') if item.subtitle
            $el.append $item

      $el.append $('<li class="dropdown-header" role="presentation"></li>').text('No results.') if $el.is(':empty')

@hideResults = () ->
  $('.dropdown-backdrop').remove()
  $('.search-form').removeClass('open')
