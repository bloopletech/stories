$(function() {
  if(!$("html").hasClass("manipulate")) {
    $("#wrapper").twoup("1px solid silver");
    $(window).resize(function() {
      $.twoup.content.css("position", "relative");
      $("#nav-wrapper").css("left", ($.twoup.column_width() - $("#nav-wrapper").width()) + "px");
    }).resize();
  }

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

//  $("#story_export").colorbox({ width: 250, height: 200, iframe: true });

  $("#success a").click(function(e) {
    $("#success").remove();
    e.preventDefault();
  });
});
