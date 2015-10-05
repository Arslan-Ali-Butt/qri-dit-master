$(document).ready(function(){
  $(".btn-minimize").click(function(){
      $(this).closest(".box").children(".box-content").slideToggle();
      $(this).children("i").toggleClass("fa-chevron-up");
      $(this).children("i").toggleClass("fa-chevron-down");
      return false;
  });
});
