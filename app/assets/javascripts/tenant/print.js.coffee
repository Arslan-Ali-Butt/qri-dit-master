
jQuery ($) ->
	window.print() if $('#printable-container').length > 0

$(document).on 'click', '.btn-print', (e) ->
  # if window.oTable
    # oSettings = window.oTable.fnSettings()
    # oSettings._iDisplayLength = 10000
    # window.oTable.fnDraw()

    # window.oTable.fnDestroy()
    # initDatatable(false)

  window.print()