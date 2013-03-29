$(function() {
  $("#wrapper").twoup("none");

  if($.twoup.enabled()) {
    $("body").append('<div id="story-progress"><span id="story-page"></span><input type="range" min="1" id="story-progress-slider"><span id="story-percent"></span></div>');

    $("#story-progress-slider").change(function() {
      $.twoup.page($(this).val());
    });

    $(window).bind("hashchange", function() {
      $("#story-progress-slider").val($.twoup.page());
      $("#story-page").text("Page " + $.twoup.page() + " of " + $.twoup.pages());
      $("#story-percent").text(Math.round(($.twoup.page() / $.twoup.pages()) * 100) + "%");
    }).trigger("hashchange");

    $(window).resize(function() {
      var progress_width = Math.min(1400, $(window).width());
      $("#story-progress").css({ "width": progress_width + "px", "margin-left": -(progress_width / 2) + "px" });
      $("#story-progress-slider").prop("max", $.twoup.pages()).css("width", progress_width - 400 + "px");
      $(window).trigger("hashchange");
    }).resize();
  }
});
