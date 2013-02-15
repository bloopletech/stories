;(function($) {
  var content_width = 0;
  var scroll_width = 0;
  var content, slider, padding;

  var enabled = false;
  function recalc_enabled_columns() {
    if(!enabled) {
      location.hash = "#0";
      $(window).scrollLeft(0).scrollTop(0);
      enabled = true;
    }

    var column_gap_width = (parseInt(padding.css("padding-top")) * 2) + parseInt(content.css("-webkit-column-rule-width") || content.css("column-rule-width"));
    var inner_width = window.innerWidth - column_gap_width;
    var inner_height = window.innerHeight - column_gap_width;
    var column_width = Math.floor((inner_width - column_gap_width) / 2);
    scroll_width = (column_width + column_gap_width) * 2;

    padding.css({ "width": inner_width + "px", "height": inner_height + "px", "overflow": "hidden" });
    content.css({ "width": inner_width + "px", "height": inner_height + "px", "-webkit-column-width": column_width + "px",
     "-moz-column-width": column_width + "px", "column-width": column_width + "px", "-webkit-column-gap": column_gap_width + "px",
     "-moz-column-gap": column_gap_width + "px", "column-gap": column_gap_width + "px" });
    content_width = content[0].scrollWidth;
  }

  function recalc_disabled_columns() {
    padding.css({ "width": "", "height": "", "overflow": "" });
    content.css({ "width": "", "height": "", "-webkit-column-width": "", "-moz-column-width": "", "column-width": "",
     "-webkit-column-gap": "", "-moz-column-gap": "", "column-gap": "" });
    slider.css({ "margin-left": "" });
    scroll_width = 0;
    content_width = 0;

    if(enabled) {
      $(window).scrollLeft(0).scrollTop(0);
      location.hash = "#0";
      enabled = false;
    }
  }

  function get_index() {
    var index = parseInt(location.hash.substr(1)); 
    if(isNaN(index)) index = 0;
    return index;
  }

  function get_max_index() {
    return Math.ceil(content_width / (scroll_width + 0.0));
  }

  //Cargo-culting from colorbox
  var twoup = $.fn.twoup = $.twoup = function(column_rule) {
    if(content) {
      alert("You already have a twoup!");
      return;
    }

    twoup.content = content = $("<div></div>").css({ "-webkit-column-rule": column_rule, "-moz-column-rule": column_rule, "column-rule": column_rule });
    twoup.slider = slider = $("<div></div>");
    twoup.padding = padding = $(this).css({ "overflow": "hidden" });

    var children = padding.children().detach();
    padding.append(slider);
    slider.append(content);
    content.append(children);

    //at the moment, only WebKit and MSIE10 has proper support for css3 columns AND getting the right width for a column element with overflow
    if(!$.browser.webkit && (!$.browser.msie || $.browser.version < 10)) return;

    $(window).resize(function() {
      if(twoup.displaying_columns()) recalc_enabled_columns();
      else recalc_disabled_columns();
    }).resize();

    $(window).bind('hashchange', function() {
      slider.animate({ "margin-left": -(scroll_width * get_index()) + "px" }, 500, "swing");
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

    return this;
  };

  twoup.displaying_columns = function() {
    //if the window width is narrower than 1000px, then the content column width would be too narrow
    return $(window).width() >= 1000;
  };

  twoup.column_width = function() {
    return twoup.displaying_columns() ? parseInt(content.css("-webkit-column-width") || content.css("-moz-column-width") || content.css("column-width")) : content.width()
  };
})(jQuery);
