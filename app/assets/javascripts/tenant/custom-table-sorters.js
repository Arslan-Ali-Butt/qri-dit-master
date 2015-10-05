$.fn.dataTableExt.afnSortData['dom-text'] = function  ( oSettings, iColumn )
{
  return $.map( oSettings.oApi._fnGetTrNodes(oSettings), function (tr, i) {
    return $('td:eq('+iColumn+') input', tr).val();
  } );
}