# $(document).ready ->
# 	$('#new_admin_logo').fileupload
# 		dataType: 'script'
# 		maxNumberOfFiles: 1
# 		maxFileSize: 1048576
# 		add: (e, data) ->
# 			types = /(\.|\/)(gif|jpe?g|png|mov|mpeg|mpeg4|avi)$/i
# 			file = data.files[0]
# 			if types.test(file.type) || types.test(file.name)
# 				data.context = $(tmpl("template-upload", file))
# 				$('.uploads .thumbnails').append(data.context)
# 				data.submit()
# 			else
# 				alert("#{file.name} is not a gif, jpg or png image file")
# 		progress: (e, data) ->
# 			if data.context
# 				progress = parseInt(data.loaded / data.total * 100, 10);
# 				data.context.find('.progress-bar').css('width', progress + '%');
# 		fail: (e, data) ->
# 			alert(data.files[data.index].error)