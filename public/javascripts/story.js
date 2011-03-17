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

  /*setTimeout(function() {
    scrollTo(200, 0);
  }, 1);

  function updateLastRead()
  {
    var scroll_top = $(window).scrollTop();
    if(nearBottomOfPage()) scroll_top = 0;
    $.post(story_url, { 'story[offset]': scroll_top, '_method': 'put' });
  }
  setInterval(updateLastRead, 10000);*/

  $("#story_export").colorbox({ width: 250, height: 200, iframe: true });
});