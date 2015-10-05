#= require tenant/custom-table-sorters

#@custom sort function
jQuery.fn.dataTableExt.oSort['qdate-asc']  = (x,y) ->
    return to_date(x)>to_date(y);
 
jQuery.fn.dataTableExt.oSort['qdate-desc'] = (x,y) ->
    return to_date(x)<to_date(y);
months=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
date_regex=new RegExp("(\\w{3})\\s(\\d{1,2}),\\s(\\d{4})\\s-\\s(\\d{1,2}):(\\d{1,2})","ig")
to_date = (str) ->
  isDate=date_regex.test(str)
  str2=str
  if(!isDate)
    str2=str.replace("-",", "+(new Date().getFullYear())+" -")
  new Date(str2)
$(document).ready ->
  initDatatable(!/\.pdf$/.test(window.location.href))
@initDatatable = (paginate) ->
  if $('.datatable#qrid-table').length > 0
    window.oTable = $('.datatable').dataTable(
      #bPaginate: paginate
      #sPaginationType: 'bootstrap'
      #bFilter: false
      #aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      #iDisplayLength: -1
      # oLanguage:
      #   sSearch: 'Search all columns:'
      #aaSorting: [[8, 'asc']]
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#qrid-table').data('source')
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })
      aoColumns: [
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: false}
        {bSortable: true}
        ##{iDataSort: 9}
        ##{bVisible: false}
        {bSortable: false}
        {bSortable: false}
      ]
      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )
  else if $('.datatable#reports-table').length > 0
    window.oTable = $('.datatable').dataTable(
      #bPaginate: paginate
      # sPaginationType: 'bootstrap'
      # bFilter: false
      # aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      # iDisplayLength: -1
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#reports-table').data('source')
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })

        #aoData

        
    
      # oLanguage:
      #   sSearch: 'Search all columns:'
      # aoColumns: [
      #   { "sSortDataType": "dom-text", "sType": "numeric" },
      #   { "sSortDataType": "dom-text", "sType": "numeric" },
      #   null,
      #   null,
      #   null,
      #   null,
      #   null,
      #   null,
      #   { "sType": "qdate"},
      #   null,
      #   null,
      #   { "sSortDataType": "dom-text", "sType": "numeric" },
      #   null
      # ]
      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )
  else if $('.datatable#clients-table').length > 0
    window.oTable = $('.datatable').dataTable(
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#clients-table').data('source')
      aoColumns: [
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: false}
        {bSortable: false}
        {bSortable: false}
        {bSortable: false}
        {bSortable: false}
        {bSortable: false}
      ]
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })

      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )

  else if $('.datatable#time-table').length > 0
    window.oTable = $('.datatable').dataTable(
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#time-table').data('source')
      aoColumns: [
        {bSortable: true}
        {bSortable: false}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: false}
      ]
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })

      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )

  else if $('.datatable#sites-table').length > 0
    window.oTable = $('.datatable').dataTable(
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#sites-table').data('source')
      aoColumns: [
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: false}
        {bSortable: false}
      ]
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })

      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )

  else if $('.datatable#staff-table').length > 0
    window.oTable = $('.datatable').dataTable(
      sPaginationType: "bootstrap"
      bProcessing: true
      bServerSide: true
      sAjaxSource: $('#staff-table').data('source')
      aoColumns: [
        {bSortable: true}
        {bSortable: true}
        {bSortable: true}
        {bSortable: false }
        {bSortable: false}
        {bSortable: true}
        {bSortable: false}
      ]
      fnServerParams: (aoData) ->

        $.each URI.parseQuery(document.location.search), (key, value) ->
          aoData.push({ "name": key, "value": value })

      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )


  else if $('.datatable').length > 0
    window.oTable = $('.datatable').dataTable(
      bPaginate: paginate
      sPaginationType: 'bootstrap'
      bFilter: false
      aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      iDisplayLength: -1
      oLanguage:
        sSearch: 'Search all columns:'
      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength == -1 or oSettings._iDisplayLength >= oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find(".dataTables_paginate").hide()
        else
          $(oSettings.nTableWrapper).find(".dataTables_paginate").show()
    )
