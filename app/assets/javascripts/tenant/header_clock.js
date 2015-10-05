$(document).ready(function() {
  var header_timer_pad = function(length,number) {
    var str = number.toString();
    while (str.length < length) {
        str = '0' + str;
    }   
    return str;
  };

  var header_timer = function() {
    var today = new Date();
    var day = today.getDay();
    var date = today.getDate();
    var month = today.getMonth();
    var year = today.getFullYear();
    var hours = today.getHours();
    var minutes = today.getMinutes();
    var seconds = today.getSeconds();
    var month_titles = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
    var day_titles = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");

    $('#header_clock').html(day_titles[day] + ', ' + month_titles[month] + ' ' + date.toString() + ' ' + year.toString() + ' ' + header_timer_pad(2,hours.toString()) + ':' + header_timer_pad(2,minutes.toString()) + ':' + header_timer_pad(2,seconds.toString()));
    
    timer = setTimeout(function() {
      header_timer();
    }, 500);
  };

  header_timer(); 
});