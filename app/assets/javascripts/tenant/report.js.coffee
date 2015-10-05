#= require jquery.smooth-scroll

jQuery ($) ->
  $('.mark-all-as-read').click ->
    $(this).button('loading')
    commentId = $('.reportnote-collection').find('tr').first().data('resource-id')
    markAllCommentsAsRead(commentId)

  markAllCommentsAsRead = (commentId) ->
    $.ajax
      dataType: 'script'
      type:     'post'
      url:      "#{$('table.report-comments').data('comments-url')}/#{commentId}"
      data:
        _method: 'put'
        silent: true
        is_author: false
        update_all_notes: true # mark all comments up until the one in question as read
        tenant_report_note:
          unread_by_manager:   false
      error: (xhr, status, error) ->
        console.log error

  handleHighlightedComments = ->
    if $('.reportnote-collection').length > 0

      commentId = window.location.hash.split('-')[1]

      if commentId?
        $.smoothScroll
          scrollTarget: "tr[data-resource-id=#{commentId}]"
          afterScroll: ->
            $("tr[data-resource-id='#{commentId}']").fadeOut ->
              $("tr[data-resource-id='#{commentId}']").fadeIn()

        markAllCommentsAsRead(commentId)

  handleHighlightedComments()