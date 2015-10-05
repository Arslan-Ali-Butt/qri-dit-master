$(document).ready ->
  if $('.datatable').length > 0
    oTable = $('.datatable').dataTable(
      sPaginationType: 'bootstrap'
      bFilter: false
      oLanguage:
        sSearch: 'Search all columns:'
    )
