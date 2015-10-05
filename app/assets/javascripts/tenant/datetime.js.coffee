jQuery ($) ->
	$('.datetime').each ->
		$(@).text(moment.unix($(@).data('datetime')).format('MMMM Do YYYY'))