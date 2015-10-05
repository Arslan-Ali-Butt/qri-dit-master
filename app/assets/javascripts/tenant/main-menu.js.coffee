$(document).ready ->
  $('ul.secondary-menu li.active').parents('li').addClass('active-parent')
  $('.navbar-nav > li').not('.active-parent').hover ->
    $('.active-parent').addClass('notselected')
    $(this).mouseleave ->
      $('.active-parent').removeClass('notselected')
  $('.navbar-default > li').hover ->
    $('ul.secondary-menu').not(this).hide()
    $(this).children('ul.secondary-menu').show()
    $(this).mouseleave ->
     $(this).children('ul.secondary-menu').hide()
     $('.active-parent').children('ul.secondary-menu').show()