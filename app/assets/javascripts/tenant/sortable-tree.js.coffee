$(document).ready ->

  sortable_tree_root = $('ol.sortable-tree')
    
  defaultUrl = sortable_tree_root.data('default_url') || sortable_tree_root.data('default-url')
  window.rebuildUrl = sortable_tree_root.data('rebuild_url') || sortable_tree_root.data('rebuild-url')
  maxLevels  = sortable_tree_root.data('max_levels')  || sortable_tree_root.data('max-levels')
  
  $(sortable_tree_root).nestedSortable
    items:            'li'
    helper:           'clone'
    handle:           '.dd-handle'
    listClass:        'dd-list'
    tolerance:        'pointer'
    maxLevels:        maxLevels
    revert:           250
    tabSize:          25
    opacity:          0.6
    placeholder:      'placeholder'
    disableNesting:   'no-nest'
    toleranceElement: '> div'
    forcePlaceholderSize: true
    isAllowed: (placeholder, placeholderParent, currentItem) ->
      getTaskType = (task) ->
        if $(task).hasClass("answer")
          task_type = "answer"
        else if $(task).hasClass("group")
          task_type = "group"
        else if $(task).hasClass("instructions")
          task_type = "instructions"
        else if $(task).hasClass("question")
          task_type = "question"
        else if $(task).hasClass("comment")
          task_type = "comment"
        else if $(task).hasClass("photo")
          task_type = "photo"
        else
          task_type = "unknown"
      
        task_type

      parent_task = $(placeholderParent).children(".dd3-content")
      if $(parent_task).length
        item_task = $(currentItem).children(".dd3-content")

        if $(item_task).length
          switch getTaskType(parent_task)
            when "answer", "question"
              switch getTaskType(item_task)
                when "question", "group", "instructions"
                  go = true
                when "photo"
                  go = true unless window.has_child_tasks_of_type("photo")
                when "comment"
                  go = true unless window.has_child_tasks_of_type("comment")
                else
                  go = false
            when "group"
              switch getTaskType(item_task)
                when "question", "group", "instructions"
                  go = true
                else
                  go = false
            when "instructions"
              switch getTaskType(item_task)
                when "photo"
                  go = true unless window.has_child_tasks_of_type("photo")
                when "comment"
                  go = true unless window.has_child_tasks_of_type("comment")
                else
                  go = false
            when "comment"
              go = false
            when "photo"
              go = false
            else
              go = false
        else
          go = false
      else
        go = true
      
    
      if !go 
        $(placeholder).addClass('ui-nestedSortable-error')
      else
        $(placeholder).removeClass('ui-nestedSortable-error')
      go

  $(sortable_tree_root).on 'sortupdate', (event, ui) =>
    item      = ui.item
    attrName  = 'resource-id'
    id        = item.data(attrName)
    prevId    = item.prev().data(attrName)
    nextId    = item.next().data(attrName)
    parentId  = item.parent().parent().data(attrName)
    $(".question, .instructions, .group").each ->
      if $(this).parent(".dd3-item").length && !window.has_child_tasks(this)      
        $(this).addClass('collapse-children')
        $(this).children('i').remove();

    $.ajax
      type:     'post'
      dataType: 'script'
      url:      rebuildUrl
      data:
        id:        id
        parent_id: parentId
        prev_id:   prevId
        next_id:   nextId

      success: (response, status, xhr) ->
        window.maticulate

      error: (xhr, status, error) ->
        console.log error
        window.location = defaultUrl
  
$(document).on "click", ".dd3-content .glyphicon-circle-arrow-up, .dd3-content .glyphicon-circle-arrow-down", (e) ->
  if $(this).parent(".dd3-content").hasClass("collapse-children") is true
    $(this).parent(".dd3-content").removeClass "collapse-children"
    $(this).parent(".dd3-content").siblings(".dd-list").children(".dd3-item").children(".dd3-content.answer.collapse-children").removeClass "collapse-children"
  else
    $(this).parent(".dd3-content").addClass "collapse-children"
    $(this).parent(".dd3-content").siblings(".dd-list").children(".dd3-item").children(".dd3-content.answer").addClass "collapse-children"
  return

$(document).on 'click', '.nestable-menu', (e) ->
  target = $(e.target)
  parent = $(e.target).parent()
  
  if target? && $(target).data('action')?
    action = $(target).data('action')
  else if parent? && $(parent).data('action')?
    action = $(parent).data('action')

  confirmMessage = ($(e.target).data('confirm') or $(e.target).parent().data('confirm'))
  if confirmMessage == '' or confirmMessage == undefined or 
    $('ol.sortable-tree .dd3-content.collapse-children').length == 0 or $('ol.sortable-tree').find('li').length < 300 or 
    confirm(confirmMessage)
      if action is 'expand-all'
        $('ol.sortable-tree .dd3-content').removeClass('collapse-children')
        $('ol.sortable-tree .dd3-content .expand-group i').tooltip 'destroy'
        $('ol.sortable-tree .dd3-content .expand-group').removeClass('expand-group').addClass('collapse-group').find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up').attr('title', 'Collapse this entire group')
        $('ol.sortable-tree .dd3-content .collapse-group i').tooltip()
      if action is 'collapse-all'
        $('ol.sortable-tree .dd3-content').addClass('collapse-children') 
        $('ol.sortable-tree .dd3-content .collapse-group i').tooltip 'destroy'
        $('ol.sortable-tree .dd3-content .collapse-group').removeClass('collapse-group').addClass('expand-group').find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down').attr('title', 'Expand this entire group')
        $('ol.sortable-tree .dd3-content .expand-group i').tooltip()

$(document).on 'click', '.expand-group', (e) ->
  $(e.target).parents('.dd3-content').removeClass('collapse-children').next().find('.dd3-content').removeClass('collapse-children')
  $(e.currentTarget).find('i').tooltip('destroy')
  $(e.target).parents('.dd3-content').next().find('.expand-group i').tooltip('destroy')
  $(e.currentTarget).removeClass('expand-group').addClass('collapse-group').find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up').attr('title', 'Collapse this entire group')
  $(e.target).parents('.dd3-content').next().find('.expand-group').removeClass('expand-group').addClass('collapse-group').find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up').attr('title', 'Collapse this entire group')
  $(e.currentTarget).find('i').tooltip()
  $(e.target).parents('.dd3-content').next().find('.collapse-group i').tooltip()

$(document).on 'click', '.collapse-group', (e) ->
  $(e.target).parents('.dd3-content').addClass('collapse-children').next().find('.dd3-content').addClass('collapse-children')
  $(e.currentTarget).find('i').tooltip('destroy')
  $(e.target).parents('.dd3-content').next().find('.collapse-group i').tooltip('destroy')
  $(e.currentTarget).removeClass('collapse-group').addClass('expand-group').find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down').attr('title', 'Expand this entire group')
  $(e.target).parents('.dd3-content').next().find('.collapse-group').removeClass('collapse-group').addClass('expand-group').find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down').attr('title', 'Expand this entire group')
  $(e.currentTarget).find('i').tooltip()
  $(e.target).parents('.dd3-content').next().find('.expand-group i').tooltip()

$(document).on 'change', '.dd-checkbox input', (e) ->
  e.preventDefault()
  if $(this).is(':checked')
    $(this).parent().parent().find('input[type=checkbox]').prop 'checked', true
  else
    $(this).parent().parent().find('input[type=checkbox]').prop 'checked', false

$(document).on 'change', '.qrid-radio', (e) ->
  $(this).parent().parent().children().children('.qrid-options').hide()
  $(this).parent().children('.qrid-options').show()