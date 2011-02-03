$(function()
{
  $("#previous-page").mousedown(function() {
    var current = parseInt($("#wrapper").css("margin-top"));
    if(current < 0) $("#wrapper").css("margin-top", (current + vheight()) + "px");
  });

  $("#next-page").mousedown(function() {
    var current = parseInt($("#wrapper").css("margin-top"));
    if((current - vheight()) > -pheight()) $("#wrapper").css("margin-top", (current - vheight()) + "px");
  });

  setTimeout(function() {
    scrollTo(200, 0);
  }, 1);
});