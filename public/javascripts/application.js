$(function() {
  if(!$.browser.webkit) {
    alert("Page flipping may not work in your browser; you can try a WebKit-based browser (Google Chrome, Chromium, Safari, etc.) instead.");
  }

  var padding = 20;
  var viewport_width = 0;
  var viewport_height = 0;
  var wrapper_width = 0;
  var wrapper_height = 0;
  var column_gap_width = 0;
  var column_width = 0;

  $(window).resize(function() {
    viewport_width = $(window).width();
    viewport_height = $(window).height();
    wrapper_width = viewport_width - (padding * 2);
    wrapper_height = viewport_height - (padding * 2);
    column_gap_width = (padding * 2) + 1;
    column_width = (wrapper_width / 2.0) - column_gap_width;
    $("#wrapper").show();
    $("#wrapper, #content-wrapper, #content-window, #content").css("height", wrapper_height + "px");
    $("#wrapper, #content-wrapper, #content-window").css("width", wrapper_width + "px");
    $("#wrapper").css("padding", padding + "px");
    $("#content").css({ "-webkit-column-width": column_width + "px", "-moz-column-width": column_width + "px", "column-width": column_width + "px",
     "-webkit-column-gap": column_gap_width + "px", "-moz-column-gap": column_gap_width + "px", "column-gap": column_gap_width + "px" });
    $("#nav-wrapper").css("left", (column_width - 107) + "px");
  }).resize();

  function get_index()
  {
    var index = parseInt(location.hash.substr(1)); 
    if(isNaN(index)) index = 0;
    return index;
  }

  function get_max_index()
  {
    x = Math.ceil($("#content")[0].scrollWidth / (viewport_width + 0.0)); 
    return x;
  }

  function go_next_page()
  {
    var index = get_index();
    index += 1;
    if(index >= get_max_index()) index = get_max_index() - 1;
    location.hash = "#" + index;
  }

  $(window).bind('hashchange', function()
  {
    $("#content-window").css("margin-left", -(viewport_width * get_index()) + "px");
  }).trigger('hashchange');

  $(window).keydown(function(event)
  {
    if(event.keyCode == 32)
    {
      event.preventDefault();
      go_next_page();      
    }
    else if(event.keyCode == 8)
    {
      event.preventDefault();
      history.back();
    }
  });

  $("body").click(go_next_page); 

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

//  $("#story_export").colorbox({ width: 250, height: 200, iframe: true });

  $("#success a").click(function(e) {
    $("#success").remove();
    e.preventDefault();
  });
});
