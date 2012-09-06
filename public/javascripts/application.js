$(function() {
  var padding = 20;
  var viewport_width = 0;
  var viewport_height = 0;
  var content_width = 0;

  $(window).resize(function() {
    viewport_width = $(window).width();
    viewport_height = $(window).height();
    var wrapper_width = viewport_width - (padding * 2);
    var wrapper_height = viewport_height - (padding * 2);
    var column_gap_width = (padding * 2) + 1;
    var column_width = (wrapper_width / 2.0) - column_gap_width;

    $("#wrapper").show();
    $("#content-wrapper, #content-clip, #content-window, #content").css({ "width": wrapper_width + "px", "height": wrapper_height + "px" });
    $("#content-wrapper").css("padding", padding + "px");
    $("#content").css({ "-webkit-column-width": column_width + "px", "-moz-column-width": column_width + "px", "column-width": column_width + "px",
     "-webkit-column-gap": column_gap_width + "px", "-moz-column-gap": column_gap_width + "px", "column-gap": column_gap_width + "px" });

    //$("#content").css("overflow", "auto");
    content_width = $("#content")[0].scrollWidth;
    //$("#content").css("overflow", "visible");

    $("#nav-wrapper").css("left", (column_width - 107) + "px");
  }).resize();

  function get_index() {
    var index = parseInt(location.hash.substr(1)); 
    if(isNaN(index)) index = 0;
    return index;
  }

  function get_max_index() {
    return Math.ceil(content_width / (viewport_width + 0.0));
  }

  $(window).bind('hashchange', function() {
    $("#content-window").animate({ "margin-left": -(viewport_width * get_index()) + "px" }, 500, "swing");
  }).trigger('hashchange');

  $(window).keydown(function(event) {
    var index = get_index();

    if(event.keyCode == 32 || event.keyCode == 39) {
      event.preventDefault();
      index++;
      if(index >= get_max_index()) index = get_max_index() - 1;
    }
    else if(event.keyCode == 8 || event.keyCode == 37) {
      event.preventDefault();
      index--;
      if(index < 0) index = 0;
    }

    location.hash = "#" + index;
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

//  $("#story_export").colorbox({ width: 250, height: 200, iframe: true });

  $("#success a").click(function(e) {
    $("#success").remove();
    e.preventDefault();
  });
});
