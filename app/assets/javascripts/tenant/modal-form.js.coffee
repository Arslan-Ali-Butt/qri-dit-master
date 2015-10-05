$(document).on 'submit', '#myModal form', (e) ->
  $('#myModal .modal-body').html("<div class='loading-big'><\/div>")
  $('#myModal .modal-footer').empty()
