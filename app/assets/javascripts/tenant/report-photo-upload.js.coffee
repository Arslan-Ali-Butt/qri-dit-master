$(document).on 'change', '.report-photo input[type=file]', (e) ->
  target = $(e.target)
  container = target.parent()
  form = $('#report-photo-upload')
  container.find('input').each ->
    $(this).appendTo(form)
    $(this).clone().appendTo(container)

  task_id = container.find('input[type=hidden]').val()
  $("<div class='thumbnail' data-resource-id='new' style='float:left'><a class='thumbnail loading'><\/a><\/div>").appendTo('.reportphoto-collection#collection_' + task_id).hide().fadeIn()
  $('#send-report').prop('disabled', true)
  form.trigger('submit.rails')
  form.empty()
