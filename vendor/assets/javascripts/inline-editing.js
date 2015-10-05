var g_gogogadgetqridbuilder;

$(document).ready(function () {

    $(document).on('click', 'input.form-control.input-sm.wider-input', function() {
        $(this).select();
    });

    var KEYPRESS_RETURN = 13, tenant_qrid_estimated_duration_change, tenant_qrid_name_change, task_question_toggle_button, permatask_question_toggle_button, tenant_qrid_default_task_ids, tenant_qrid_permatask_ids, content_span_permatask_click, add_node_qrid_tasks, add_task_to_instructions_qrid_tasks, add_instructions_qrid_tasks, add_node_permatasks, add_task_to_instructions_permatasks, add_task_to_instructions_template_tasks, add_instructions_permatasks, add_node_template_tasks, content_span_task_click, child_of_task_exists, maticulate, maticulate_nominate, maticulate_edit,add_instructions_template_tasks, ensure_parents_checked, are_you_sure, qrid_builder = function () {

        $('.dd3-item[data-resource-id] > .dd3-content.question, .dd3-item[data-resource-id] > .dd3-content.group, .dd3-item[data-resource-id] > .dd3-content.instructions, .dd3-item > .dd3-content.photo, .dd3-item > .dd3-content.comment').each(function() {
          var el_span = $('<span></span>'),cls_handle = ['dd-handle', 'dd3-handle', 'fa', 'fa-arrows'],siblings_selection = '',cls;
          el_span.text('Drag');
          el_span.attr('rel','tooltip');
          el_span.attr('title','Drag Selection');
          for(cls in cls_handle) {
            if(cls_handle[cls]) {            
              siblings_selection += '.' + cls_handle[cls];            
              el_span.addClass(cls_handle[cls]);
            }
          }

          if($(this).siblings(siblings_selection).length === 0) {
            $(this).parent().prepend(el_span);    
          }
        });

        $('.dd3-content span.editable').editable({
            inputclass: 'form-control input-sm wider-input'
        });

        // add the id of each answer to each answer button
        $('.toggle').each(function () {
            var button_name = $(this).data("toggle-condition"), the_id = $(this).parents('.dd3-item:eq(0)').children('ol.dd-list').children('.dd3-item').children('.answer').children('span:contains("' + button_name + '"):eq(0)').parents('.dd3-item:eq(0)').attr('data-resource-id');
            $(this).attr('data-resource-id', the_id);
        });

        // hides answers
        $('.question:visible').next('ol').children('.dd3-item').each(function () {
            if ($(this).find('.comment:visible, .photo:visible, .question:visible, .instructions:visible').length > 0) {
                $(this).find('.dd3-content:eq(0)').hide();
                $(this).show();
            } else {
                $(this).hide();
            }
        });

        $('.question:visible, .comment:visible, .photo:visible, .instructions:visible').each(function () {
            var condition_id = $(this).parents('.dd3-item:eq(1)').attr('data-resource-id'),el_toggle = '.toggle[data-resource-id=' + condition_id + ']';
            if($(el_toggle).data('value-set') !== true) {
              $(el_toggle).addClass('active');
              $(el_toggle).siblings('.active').removeClass('active');
              $(el_toggle).data('value-set', true);
              $(el_toggle).siblings().data('value-set', false);
            }
        });

        $('#tenant_qrid_estimated_duration').off('change');
        $('#tenant_qrid_estimated_duration').on('change', tenant_qrid_estimated_duration_change);
        $('#tenant_qrid_name').off('change');
        $('#tenant_qrid_name').on('change', tenant_qrid_name_change);
        $('[name="tenant_qrid[permatask_ids][]"]').off('click');
        $('[name="tenant_qrid[permatask_ids][]"]').on('click', tenant_qrid_permatask_ids);		
    }, add_toggles = function() {
        $('.form-group-template-tasks .toggle, .form-group-tasks .toggle').off('click');
        $('.form-group-template-tasks .toggle, .form-group-tasks .toggle').on('click', task_question_toggle_button);
        $('.form-group-permatasks .toggle').off('click');
        $('.form-group-permatasks .toggle').on('click', permatask_question_toggle_button);

    }, permatask_editing = function () {
        $('.form-group-permatasks .dd3-content span.editable').editable();
        $('.form-group-permatasks .dd3-content span').on('click', content_span_permatask_click);
    }, add_qrid_tasks = function () {
        $('.form-group-tasks .add-node,.form-group-tasks .add-instructions,.form-group-tasks add-node:contains("Create New Group")').off('click');
        $('.form-group-tasks .group > .controls .add-node,.form-group-tasks .question > .controls .add-node,.form-group-tasks .add-node:contains("Create New Group")').on('click', add_node_qrid_tasks);        
        $('.form-group-tasks .instructions > .controls > .add-node').on('click', add_task_to_instructions_qrid_tasks);
        $('.form-group-tasks .group > .controls .add-instructions, .form-group-tasks .question > .controls .add-instructions').on('click', add_instructions_qrid_tasks);
    }, add_permatasks = function () {
        $('.form-group-permatasks .add-node,.form-group-permatasks .add-instructions').off('click');
        $('.form-group-permatasks .group > .controls .add-node,.form-group-permatasks .question > .controls .add-node,.add-node:contains("Create Permatask")').on('click', add_node_permatasks);        
$('.form-group-permatasks .instructions > .controls .add-node').on('click', add_task_to_instructions_permatasks);
        $('.form-group-permatasks .group > .controls .add-instructions, .form-group-permatasks .question > .controls .add-instructions').on('click', add_instructions_permatasks);
    }, add_template_tasks = function () {
        $('.form-group-template-tasks .add-node,.form-group-template-tasks .add-instructions,.form-group-template-tasks .add-node:contains("Create New Group")').off('click');
        $('.form-group-template-tasks .group > .controls .add-node,.form-group-template-tasks .question > .controls .add-node,.form-group-template-tasks .add-node:contains("Create New Group")').on('click', add_node_template_tasks);        
$('.form-group-template-tasks .instructions > .controls .add-node').on('click', add_task_to_instructions_template_tasks);
        $('.form-group-template-tasks .group > .controls .add-instructions, .form-group-template-tasks .question > .controls .add-instructions').on('click', add_instructions_template_tasks);
    }, add_nominate_selection = function() {
      $('.dd-checkbox').off('click');
      $('.dd-checkbox input').on('click', dd_checkbox_click);    
    }, move_task = function (id, new_parent_id) {

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/tasks/' + id,
            data: {
                'tenant_task': {                    
                    'parent_id': new_parent_id,
                    'active': '1'
                }
            },
            success: function () {
                $(window).hasChanges = false;
                return true;
            },
            error: function (errors) {
                var msg = '';
                if (errors && errors.responseText) { //ajax error, errors = xhr object
                    msg = errors.responseText;
                } else { //validation error (client-side or server-side)
                    $.each(errors, function (k, v) { msg += k + ": " + v + "<br>"; });
                }
                $('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show();
            }
        });
    }, move_permatask = function (id, new_parent_id) {

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/permatasks/' + id,
            data: {
                'tenant_permatask': {
                    'id' : id,
                    'parent_id': new_parent_id,
                    'active': '1'
                }
            },
            success: function () {
                $(window).hasChanges = false;
                return true;
            },
            error: function (errors) {
                var msg = '';
                if (errors && errors.responseText) { //ajax error, errors = xhr object
                    msg = errors.responseText;
                } else { //validation error (client-side or server-side)
                    $.each(errors, function (k, v) { msg += k + ": " + v + "<br>"; });
                }
                $('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show();
            }
        });
    }, content_span_permatask_editable_blur = function (evt) {

        var line_name = $(this).val();

        $(window).hasChanges = false;

        $('.dd3-content span').editable('submit', {
            ajaxOptions: {
                type: 'put',
                dataType: 'script',
                data: {
                    'tenant_permatask' : {
                        'name' : line_name,
                        'id' : evt.data.id,
                        'parent_id': evt.data.parent_id,
                        'active': '1'
                    }
                }
            },
            type: 'text',
            send: 'always',
            url: '/permatasks/' + evt.data.id,
            title: 'Enter username',
            onblur: 'submit',
            success: function () {
                $(window).hasChanges = false;
                maticulate();
                return true;
            },
            error: function (errors) {
                var msg = '';
                if (errors && errors.responseText) {
                    msg = errors.responseText;
                } else {
                    $.each(errors, function (k, v) { msg += k + ": " + v + "<br>"; });
                }
                $('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show();
            }
        });
    }, task_editing = function () {
        $('.form-group-tasks .dd3-content span.editable, .form-group-template-tasks .dd3-content span.editable').editable();
        $('.form-group-tasks .dd3-content span, .form-group-template-tasks .dd3-content span.editable').on('click', content_span_task_click);
    }, content_span_permatask_editable_keypress = function (evt) {
      if(evt.which === KEYPRESS_RETURN) {
        $(this).trigger('blur', evt.data);      
      }    
    }, content_span_task_editable_keypress = function (evt) {
      if(evt.which === KEYPRESS_RETURN) {
        $(this).trigger('blur', evt.data);      
      }    
    }, content_span_task_editable_blur = function (evt) {
        var line_name = $(this).val();
        $('.dd3-content span').editable('submit', {
            ajaxOptions: {
                type: 'put',
                dataType: 'script',
                data: {
                    'tenant_task' : {
                        'name' : line_name,
                        'id' : evt.data.id,
                        'parent_id': evt.data.parent_id,
                        'work_type_id': evt.data.work_type,
                        'task_type': evt.data.task_type,
                        'client_type': evt.data.client_type,
                        'active': '1'
                    }
                }
            },
            type: 'text',
            send: 'always',
            url: '/tasks/' + evt.data.id,
            title: 'Enter username',
            onblur: 'submit',
            success: function () {
                $(window).hasChanges = false;
                maticulate();
                return true;
            },
            error: function (errors) {
                var msg = '';
                if (errors && errors.responseText) { //ajax error, errors = xhr object
                    msg = errors.responseText;
                } else { //validation error (client-side or server-side)
                    $.each(errors, function (k, v) { msg += k + ": " + v + "<br>"; });
                }

                $('#msg').removeClass('alert-success').addClass('alert-error').html(msg).show();
            }
        });
    }, has_child_tasks = function(el) {
	  var total_children = 0, child_count;
      $(el).parent('.dd3-item').children('.dd-list').children('.dd3-item').each(function() {
		child_count = 0;			
				
		if($(this).children('.dd3-content.answer').length > 0) {
			$(this).children('.dd-list').children('.dd3-item').each(function() {
				child_count += $(this).children('.dd3-content.question, .dd3-content.instructions, .dd3-content.group, .dd3-content.photo, .dd3-content.comment');
			});
		}
		
		child_count += $(this).children('.dd3-content.question,.dd3-content.instructions,.dd3-content.group,.dd3-content.photo,.dd3-content.comment').length;
			
		if($(this).attr('style') && $(this).attr('style').length > 0) {
			if(!($(this).css('display') === 'none')) {												
				total_children += child_count;
			}
		} else {
			total_children += child_count;
		}		
      });

      return total_children;
    }, has_child_tasks_of_type = function(el, query) {
	  var total_children = 0, child_count;
      $(el).parent('.dd3-item').children('.dd-list').children('.dd3-item').each(function() {
		child_count = 0;			
				
		if($(this).children('.dd3-content.answer').length > 0) {
			$(this).children('.dd-list').children('.dd3-item').each(function() {
				child_count += $(this).children(query);
			});
		}
		
		child_count += $(this).children(query).length;
			
		if($(this).attr('style') && $(this).attr('style').length > 0) {
			if(!($(this).css('display') === 'none')) {												
				total_children += child_count;
			}
		} else {
			total_children += child_count;
		}		
      });

      return total_children;
    }, add_glyphicon_accordian = function () {
      $('.dd3-content.group, .dd3-content.question, .dd3-content.instructions').each(function () {
		if(has_child_tasks(this)) {
			if($(this).children('i.glyphicon.glyphicon-circle-arrow-up,i.glyphicon.glyphicon-circle-arrow-down').length === 0) {          
				$(this).prepend("<i class='glyphicon glyphicon-circle-arrow-up' title='Expand / Collapse Selection' rel='tooltip'></i>");
			}
        }
      });
    }, immediate_children_of_task = function(el) {      
      if($(el).hasClass('instructions') === true) {
        return $(el).next('.dd-list').children('.dd3-item').children('.dd3-content');
      }
      
      return $(el).parent('.dd3-item').children('.dd-list').children('.dd3-item:visible').children('.dd-list').children('.dd3-item').children('.dd3-content');
    }, parent_task_of_button = function(el) {
      return($(el).parent('.controls').parent('.dd3-content'));
    }; 
    
    tenant_qrid_estimated_duration_change = function () {
        var qrid_id = $('.data-storage').data("qrid-id"), duration = $(this).val(), site_id = $('.data-storage').data("site-id"), work_type_id = $('.data-storage').data("work-type-id"), qrid_name = $('#tenant_qrid_name').val(), permatask_ids = [], default_ids = [];

        $('[name="tenant_qrid[permatask_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                permatask_ids.push($(this).val());
            }
        });

        $('[name="tenant_qrid[default_task_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                default_ids.push($(this).val());
            }
        });

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/qrids/' + qrid_id,
            data: {
                'tenant_qrid': {
                    'name': qrid_name,
                    'permatask_ids': permatask_ids,
                    'default_task_ids': default_ids,
                    'work_type_id': work_type_id,
                    'site_id': site_id,
                    'estimated_duration': duration
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    tenant_qrid_name_change = function () {
        var qrid_id = $('.data-storage').data("qrid-id"), duration = $('#tenant_qrid_estimated_duration').val(), site_id = $('.data-storage').data("site-id"), work_type_id = $('.data-storage').data("work-type-id"), qrid_name = $('#tenant_qrid_name').val(), permatask_ids = [], default_ids = [];

        $('[name="tenant_qrid[permatask_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                permatask_ids.push($(this).val());
            }
        });

        $('[name="tenant_qrid[default_task_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                default_ids.push($(this).val());
            }
        });

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/qrids/' + qrid_id,
            data: {
                'tenant_qrid': {
                    'name': qrid_name,
                    'permatask_ids': permatask_ids,
                    'default_task_ids': default_ids,
                    'work_type_id': work_type_id,
                    'site_id': site_id,
                    'estimated_duration': duration
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    task_question_toggle_button = function (evt) {
        evt.preventDefault();
        $(this).addClass('active');
        $(this).siblings().data('value-set', true);
        $(this).siblings('.active').removeClass('active');

        var new_parent_id = $(this).attr('data-resource-id');

        $(this).closest('.dd3-item').children('ol.dd-list').children('.dd3-item').filter(':visible').children('ol.dd-list').children('.dd3-item').filter(':visible').each(function () {
            var task_id = $(this).data('resource-id');
            move_task(task_id, new_parent_id);   
        });        
    };

    permatask_question_toggle_button = function (evt) {
        $(this).addClass('active');

        evt.preventDefault();

        $(this).siblings('.active').removeClass('active');

        var new_parent_id = $(this).attr('data-resource-id');

        $(this).closest('.dd3-item').children('ol.dd-list').children('.dd3-item').filter(':visible').children('ol.dd-list').children('.dd3-item').filter(':visible').each(function () {
            var permatask_id = $(this).data('resource-id');
            move_permatask(permatask_id, new_parent_id);   
        }); 
    };

    tenant_qrid_default_task_ids = function () {
        var qrid_id = $('.data-storage').data("qrid-id"), site_id = $('.data-storage').data("site-id"), work_type_id = $('.data-storage').data("work-type-id"), qrid_name = $('#tenant_qrid_name').val(), duration = $('#tenant_qrid_estimated_duration').val(), default_ids = [], permatask_ids = [];

        $('[name="tenant_qrid[default_task_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                default_ids.push($(this).val());
            }
        });

        $('[name="tenant_qrid[permatask_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                permatask_ids.push($(this).val());
            }
        });

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/qrids/' + qrid_id,
            data: {
                'tenant_qrid': {
                    'name': qrid_name,
                    'permatask_ids': permatask_ids,
                    'default_task_ids': default_ids,
                    'work_type_id': work_type_id,
                    'site_id': site_id,
                    'estimated_duration': duration
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    tenant_qrid_permatask_ids = function () {
        var qrid_id = $('.data-storage').data("qrid-id"), site_id = $('.data-storage').data("site-id"), work_type_id = $('.data-storage').data("work-type-id"), qrid_name = $('#tenant_qrid_name').val(), duration = $('#tenant_qrid_estimated_duration').val(), permatask_ids = [], default_ids = [];

        $('[name="tenant_qrid[permatask_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                permatask_ids.push($(this).val());
            }
        });

        $('[name="tenant_qrid[default_task_ids][]"]').each(function () {
            if ($(this).is(':checked')) {
                default_ids.push($(this).val());
            }
        });

        return $.ajax({
            type: 'put',
            dataType: 'script',
            url: '/qrids/' + qrid_id,
            data: {
                'tenant_qrid': {
                    'name': qrid_name,
                    'permatask_ids': permatask_ids,
                    'default_task_ids': default_ids,
                    'work_type_id': work_type_id,
                    'site_id': site_id,
                    'estimated_duration': duration
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    content_span_permatask_click = function () {
        var id = $(this).parents('.dd-item').data("resource-id"), parent_id = $(this).closest('.dd-item').parents('.dd-item').data("resource-id"), opts = { 'id': id, 'parent_id': parent_id };
        $('input').off('blur');
        $('input').on('blur', null , opts, content_span_permatask_editable_blur);
        $('input').unbind('keypress', content_span_permatask_editable_keypress);
        $('input').on('keypress', null, opts, content_span_permatask_editable_keypress);
    };

    add_node_qrid_tasks = function () {
        var parent_id = $(this).data("resource-id"), task_type = $(this).data("resource-type"), qrid_id = $('.data-storage').data("qrid-id"), work_type_id = $('.data-storage').data("work-type-id"), client_type = $('.data-storage').data("client-type"), on_top = "1", active_button, the_title;

        if ($(document).find('#tenant_qrid_work_type_id').length !== 0) {
            work_type_id = $(document).find('#tenant_qrid_work_type_id').val();
        }

        if (task_type === 'Comment') {
            the_title = 'Please explain';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
                return false;
            }

            if (child_of_task_exists(parent_task_of_button(this), '.comment')) {                
                alert('A comment box already exists for this question');
                return false;
            }

            parent_id = $(this).parents('.controls').find('.active').data("resource-id");            

        } else if (task_type === 'Photo') {
            the_title = 'Please add a photo';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
                return false;
            }

            if (child_of_task_exists(parent_task_of_button(this), '.photo')) {                
                alert('A photo request already exists for this question');
                return false;
            }
            
            parent_id = $(this).parents('.controls').find('.active').data("resource-id");

        } else if (task_type === 'Question' && $(this).parents('.dd3-content:eq(0)').hasClass('question')) {
            the_title = 'New Question';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
                return false;
            }

            parent_id = $(this).parents('.controls').find('.active').data('resource-id');

        } else {
            the_title = 'New ' + task_type;
        }

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/tasks',
            data: {
                'on_top': on_top,
                'tenant_task': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'work_type_id': work_type_id,
                    'qrid_id': qrid_id,
                    'client_type': client_type,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_task_to_instructions_qrid_tasks = function () {
        var parent_id = $(this).data("resource-id"), task_type = $(this).data("resource-type"), qrid_id = $('.data-storage').data("qrid-id"), work_type_id = $('.data-storage').data("work-type-id"), client_type = $('.data-storage').data("client-type"), on_top = "1", the_title;

        if ($(document).find('#tenant_qrid_work_type_id').length !== 0) {
            work_type_id = $(document).find('#tenant_qrid_work_type_id').val();
        }

        if (task_type === 'Comment') {
          the_title = 'Please explain';

          if (child_of_task_exists(parent_task_of_button(this), '.comment')) {
              alert('A comment box already exists for this instruction.');
              return false;
          }
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');
        } else if (task_type === 'Photo') {
          the_title = 'Please add a photo';

          if (child_of_task_exists(parent_task_of_button(this), '.photo')) {
              alert('A photo request already exists for this instruction.');
              return false;
          }
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');
        }

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/tasks',
            data: {
                'on_top': on_top,
                'tenant_task': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'work_type_id': work_type_id,
                    'qrid_id': qrid_id,
                    'client_type': client_type,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_instructions_qrid_tasks = function () {
        var parent_id, task_type = $(this).data("resource-type"), qrid_id = $('.data-storage').data("qrid-id"), work_type_id = $('.data-storage').data("work-type-id"), client_type = $('.data-storage').data("client-type"), on_top = "1",group_id = $(this).parent('.controls').parent('.dd3-content.group').parent('.dd3-item').attr('data-resource-id'), answer_id = $(this).parent('.controls').find('.active').attr('data-resource-id'), the_title;

        if(group_id) {
          parent_id = group_id;
        }
        else if(answer_id) {
          parent_id = answer_id;
        }
        else {
          alert('You must select an answer before adding instructions to this question.');
          return false;
        }

        the_title = 'Enter instructions';

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/tasks',
            data: {
                'on_top': on_top,
                'tenant_task': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'work_type_id': work_type_id,
                    'qrid_id': qrid_id,
                    'client_type': client_type,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_node_permatasks = function () {
        var parent_id = $(this).data("resource-id"), task_type = $(this).data("resource-type"), on_top = "1", the_title, active_button, client_type, work_type_id;

        if ($(document).find('#tenant_qrid_work_type_id').length) {
            work_type_id = $(document).find('#tenant_qrid_work_type_id').val();
            client_type = $(document).find('#client_type').val();
        }

        if (task_type === 'Comment') {
            the_title = 'Please explain';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
            }

            if (child_of_task_exists(parent_task_of_button(this), '.comment')) {                
                alert('A comment box already exists for this question');
                return false;
            }

            parent_id = $(this).parents('.controls').find('.active').data("resource-id");
            

        } else if (task_type === 'Photo') {
            the_title = 'Please add a photo';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
            }

            if (child_of_task_exists(parent_task_of_button(this), '.photo')) {
                alert('A photo request already exists for this question');
                return false;
            }
            
            parent_id = $(this).parents('.controls').find('.active').data("resource-id");

        } else if (task_type === 'Question' && $(this).parents('.dd3-content:eq(0)').hasClass('question')) {
            the_title = 'New Question';

            active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
            if (active_button === 'undefined' || !active_button) {
                alert('Please select a condition first');
                return false;
            }

            parent_id = $(this).parents('.controls').find('.active').data("resource-id");
        } else {
          // is this the big black 'Create Permatask' button ?
          if($(this).parent().parent().hasClass('form-group-permatasks') === true) {
            // if it is the new item is labeled 'New Permatask' even though the task_type is 'Group'
            the_title = 'New ' + 'Permatask';
          } else {
            // otherwise use the task type as a label
            the_title = 'New ' + task_type;
          }         
        }

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/permatasks',
            data: {
                'on_top': on_top,
                'tenant_permatask': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_task_to_instructions_permatasks = function () {
        var parent_id = $(this).data("resource-id"), task_type = $(this).data("resource-type"), on_top = "1", the_title, client_type, work_type_id;

        if ($(document).find('#tenant_qrid_work_type_id').length !== 0) {
            work_type_id = $(document).find('#tenant_qrid_work_type_id').val();
            client_type = $(document).find('#client_type').val();
        }

        if (task_type === 'Comment') {
          the_title = 'Please explain';

          if (child_of_task_exists(parent_task_of_button(this), '.comment')) {
              alert('A comment box already exists for this instruction.');
              return false;
          }
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');
        } else if (task_type === 'Photo') {
          the_title = 'Please add a photo';

          if (child_of_task_exists(parent_task_of_button(this), '.photo')) {
              alert('A photo request already exists for this instruction.');
              return false;
          }
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');
        }

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/permatasks',
            data: {
                'on_top': on_top,
                'tenant_permatask': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_instructions_permatasks = function () {
        var parent_id, task_type = $(this).data("resource-type"), on_top = "1", the_title, client_type, work_type_id, group_id = $(this).parent('.controls').parent('.dd3-content.group').parent('.dd3-item').attr('data-resource-id'), answer_id = $(this).parent('.controls').find('.active').attr('data-resource-id');

        if ($(document).find('#tenant_qrid_work_type_id').length !== 0) {
            work_type_id = $(document).find('#tenant_qrid_work_type_id').val();
            client_type = $(document).find('#client_type').val();
        }

        if(group_id) {
          parent_id = group_id;
        } else if(answer_id) {
          parent_id = answer_id;
        } else {
          alert('You must select an answer before adding instructions to this question.');
          return false;
        }

        the_title = 'Enter instructions';

        return $.ajax({
            type: 'post',
            dataType: 'script',
            url: '/permatasks',
            data: {
                'on_top': on_top,
                'tenant_permatask': {
                    'name': the_title,
                    'task_type': task_type,
                    'parent_id': parent_id,
                    'active': '1'
                }
            },
            beforeSend: function () { return; },
            success: function () {
                maticulate();
                return true;
            },
            error: function () { return; }
        });
    };

    add_node_template_tasks = function () {
        var client_type = $('.data-storage').data("client-type"), parent_id = $(this).data("resource-id"), task_type = $(this).data("resource-type"), the_title, work_type_id = $('.data-storage').data("work-type-id"), on_top = "1", active_button;

        if (task_type === 'Comment') {
          the_title = 'Please explain';

          active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
          if(active_button === 'undefined' || !active_button) {
            alert('Please select a condition first');
            return false;
          }

          if (child_of_task_exists(parent_task_of_button(this), '.comment')) {
              alert('A comment box already exists for this question');
              return false;
          } 
          
          parent_id = $(this).parents('.controls').find('.active').data("resource-id");

        } else if (task_type === 'Photo') {
          the_title = 'Please add a photo';

          active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
          if(active_button === 'undefined' || !active_button) {
            alert('Please select a condition first');
            return false;
          }

          if (child_of_task_exists(parent_task_of_button(this), '.photo')) {
              alert('A comment box already exists for this question');
              return false;
          }
          
          parent_id = $(this).parents('.controls').find('.active').data("resource-id");

        } else if (task_type === 'Question' && $(this).parents('.dd3-content:eq(0)').hasClass('question'))  {
          the_title = 'New Question';

          active_button = $(this).parents('.controls').find('.active').data("toggle-condition");
          if(active_button === 'undefined' || !active_button) {
            alert('Please select a condition first');
            return false;
          }

          parent_id = $(this).parents('.controls').find('.active').data("resource-id");

        } else {
          the_title = 'New ' + task_type;
        }

        return $.ajax({
          type: 'post',
          dataType: 'script',
          url: '/tasks',
          data: {
            'on_top': on_top,
            'tenant_task': {
              'name': the_title,
              'task_type': task_type,
              'parent_id': parent_id,
              'work_type_id': work_type_id,
              'client_type': client_type,
              'active': '1'
            }
          },
          beforeSend: function () { return; },
          success: function () {
            maticulate();
            return true;
          },
          error: function () { return; }
        });
    };

    add_task_to_instructions_template_tasks = function () {
        var client_type = $('.data-storage').data('client-type'), parent_id = $(this).data('resource-id'), task_type = $(this).data('resource-type'), the_title, work_type_id = $('.data-storage').data('work-type-id'), on_top = "1";

        if (task_type === 'Comment') {
          the_title = 'Please explain';

          if (child_of_task_exists(parent_task_of_button(this), '.comment')) {
              alert('A comment box already exists for this instruction.');
              return false;
          } 
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');          
        } else if (task_type === 'Photo') {
          the_title = 'Please add a photo';

          if (child_of_task_exists(parent_task_of_button(this), '.photo')) {
              alert('A photo request already exists for this instruction.');
              return false;
          }
          
          parent_id = parent_task_of_button(this).parent().data('resource-id');
        }

        return $.ajax({
          type: 'post',
          dataType: 'script',
          url: '/tasks',
          data: {
            'on_top': on_top,
            'tenant_task': {
              'name': the_title,
              'task_type': task_type,
              'parent_id': parent_id,
              'work_type_id': work_type_id,
              'client_type': client_type,
              'active': '1'
            }
          },
          beforeSend: function () { return; },
          success: function () {
            maticulate();
            return true;
          },
          error: function () { return; }
        });
    };

    content_span_task_click = function () {
        var id = $(this).parents('.dd-item').data("resource-id"), parent_id = $(this).closest('.dd-item').parents('.dd-item').data("resource-id"), task_type = $(this).data("task-type"), work_type_id = $('.data-storage').data("work-type-id"), client_type = $('.data-storage').data("client-type"), opts = { 'id': id, 'parent_id': parent_id, 'task_type': task_type, 'work_type_id': work_type_id, 'client_type': client_type};

        $('.editable-input input').off('blur');
        $('.editable-input input').on('blur', null, opts, content_span_task_editable_blur);
        $('.editable-input input').unbind('keypress', content_span_task_editable_keypress);
        $('.editable-input input').on('keypress', null, opts, content_span_task_editable_keypress);
    };

    child_of_task_exists = function(el,sel) {
      var does_exist = 0, child_els = immediate_children_of_task(el).filter(sel);
      if(child_els.length) {
        $(child_els).parent('.dd3-item').each(function() {
          if($(this).attr('style') === 'undefined' || !$(this).attr('style') || $(this).css('display') !== 'none') {
            does_exist += 1;
          }
        });
      }

      return does_exist;
    };

    add_instructions_template_tasks = function () {
        var client_type = $('.data-storage').data('client-type'), parent_id, task_type = $(this).data('resource-type'), the_title, work_type_id = $('.data-storage').data('work-type-id'), on_top = "1",group_id = $(this).parent('.controls').parent('.dd3-content.group').parent('.dd3-item').attr('data-resource-id'),answer_id = $(this).parent('.controls').find('.active').attr('data-resource-id');

        if(group_id) {
          parent_id = group_id;
        }
        else if(answer_id) {
          parent_id = answer_id;
        }
        else {
          alert('You must select an answer before adding instructions to this question.');
          return false;
        }

        the_title = 'Enter instructions';

        return $.ajax({
          type: 'post',
          dataType: 'script',
          url: '/tasks',
          data: {
            'on_top': on_top,
            'tenant_task': {
              'name': the_title,
              'task_type': task_type,
              'parent_id': parent_id,
              'work_type_id': work_type_id,
              'client_type': client_type,
              'active': '1'
            }
          },
          beforeSend: function () { return; },
          success: function () {
            maticulate();
            return true;
          },
          error: function () { return; }
        });
    }; 

    ensure_parents_checked = function(el) {
      var el = $(el).parent('.dd-checkbox').parent('.dd3-item').parent('.dd-list').siblings('.dd-checkbox').children('input');
      if(el.length) {
        $(el).prop('checked', true);
        ensure_parents_checked(el);
      }      
    };

    ensure_children_unchecked = function(el) {
      var ol = $(el).parent('.dd-checkbox').siblings('.dd-list');
      if(ol.length) {
        $(ol).children('.dd3-item').children('.dd-checkbox').each(function() {
          $(this).children('input').prop('checked', false);
          ensure_children_unchecked(this);
        });
      }      
    };

    dd_checkbox_click = function() {
      if($(this).prop('checked'))
        ensure_parents_checked(this);
      else if(!$(this).prop('checked')) {
        ensure_children_unchecked(this);
      }
    };

    maticulate = function() {
      var step_regex = /\/(nominate|edit|customize|tasks|permatasks|augment)$/, matches, current_step;
      matches = step_regex.exec(window.location.pathname);
      if(matches != null && matches[1].length) {
        current_step = matches[1];
        switch(current_step) {
          case 'nominate':        
            are_you_sure();
			    case 'augment':            
            maticulate_nominate();
            break;
          case 'customize':
            are_you_sure();
          case 'edit':
          case 'tasks':
          case 'permatasks':
            maticulate_edit();
            break;
        }
      }
    };
    
    are_you_sure = function() {
      window.clean_exit = false;
      
      $('.clean-exit').off('click');
      $('.clean-exit').on('click',function() {
	      window.clean_exit = true
      });
      
      $(window).off('unload');
      $(window).on('unload', function() {
	      if(window.clean_exit === true) {
	        return(true);
	      } else if(window.clean_exit === false) {
	        return(true);
	      }
      });

      $(window).off('beforeunload');

      handleUnload = function(evt) {
        if(window.clean_exit === true) {
            if (evt != null)
            {
                evt.preventDefault();    
            }
          } else if(window.clean_exit === false) {
            return('Are you sure you want to navigate away from this page? Progress may be lost.');
          }
      };

      Unloader.init();
      Unloader.register(handleUnload);
    };

    maticulate_nominate = function() {
        $.fn.editable.defaults.mode = 'inline';

        qrid_builder();
        add_glyphicon_accordian();
        add_nominate_selection();

        $('.toggle').each(function() {
          if($(this).hasClass('active') === false) {
            $(this).css('background-color', '#908686');
          } else if($(this).hasClass('active') === true) {
            $(this).css('background-color', '#635c5c');
          }
        });
        
        $('.dd-handle').css('visibility','hidden');
        $('.dd3-content').css('padding-left','6px');
    };

    maticulate_edit = function() {
        $.fn.editable.defaults.mode = 'inline';

        qrid_builder();
        task_editing();
        permatask_editing();
        add_qrid_tasks();
        add_template_tasks();
        add_permatasks();
        add_toggles();
        add_glyphicon_accordian();
    };

	  window.maticulate = maticulate;
	  window.has_child_tasks = has_child_tasks;
	  window.has_child_tasks_of_type = has_child_tasks_of_type;	
	  window.add_glyphicon_accordian = add_glyphicon_accordian

    if (g_gogogadgetqridbuilder !== 'undefined' && g_gogogadgetqridbuilder === true) {

        maticulate();

        var step_regex = /\/(nominate)$/, matches, current_step;
        matches = step_regex.exec(window.location.pathname);
        if(matches != null && matches[1].length) {
          current_step = matches[1];
          if(current_step == 'nominate') {
            $('input[type="checkbox"]').prop('checked',false);
            $('input[type="checkbox"]').prop('disabled',false);
          }
        }
        
        $('ol.sortable-tree .dd3-content').addClass('collapse-children');
        $('ol.static-tree .dd3-content').addClass('collapse-children');
        $('.loading-big').hide();
        $('.maticulating').each(function() {
          $(this).removeClass('maticulating');        
        });
    }
});