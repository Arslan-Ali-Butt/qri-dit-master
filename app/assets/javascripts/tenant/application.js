// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs

//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.mouse
//= require jquery.ui.position
//= require jquery.ui.draggable
//= require jquery.ui.droppable
//= require jquery.ui.resizable
//= require jquery.ui.selectable
//= require jquery.ui.sortable
//= require jquery.ui.accordion
//= require jquery.ui.autocomplete
//= require jquery.ui.button
//= require jquery.ui.datepicker
//= require jquery.ui.dialog
//= require jquery.ui.menu
//= require jquery.ui.progressbar
//= require jquery.ui.slider
//= require jquery.ui.spinner
//= require jquery.ui.tabs
// require jquery.ui.tooltip
//= require jquery.ui.effect.all

//= require jquery.ui.touch-punch

//= require bootstrap
//= require bootstrap-datepicker
//= require bootstrap-timepicker
//= require bootstrap-wysiwyg
//= require bootstrap-colorpicker
//= require bootstrap-modalmanager
//= require bootstrap-modal

//= require jquery.mjs.nestedSortable
//= require fullcalendar
//= require selectize
//= require moment
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap3
//= require dataTables/jquery.dataTables.api.fnGetColumnData

//= require jquery.blueimp-gallery.min
//= require bootstrap-image-gallery
//= require jquery.autosize
//= require jquery.remotipart
//= require jquery.formatter
//= require jquery.timer
//= require bootstrap-editable
//= require inline-editing.js
//= require csrf-token.js
//= require URI

//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl

//turbolinks reference causing an issue with Safar menus, conflicting with something else, looking for an update to fix
//= require turbolinks
//= require tenant/turbolinks-unloader

//=require load-image.all.min

//= require_tree .

// jQuery.extend({

//   getQueryParameters : function(str) {
    // return (str || document.location.search).replace(/(^\?)/,'').split("&").map(function(n){return n = n.split("="),this[n[0]] = n[1],this}.bind({}))[0];
//   }

// });

$(document).ready(function(){
  $(document).on('click', '.refresh-page', function () {
    window.location.reload(true);
  });
});
