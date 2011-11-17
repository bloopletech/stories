function nearBottomOfPage() {
  return scrollDistanceFromBottom() < vheight();
}

function scrollDistanceFromBottom() {
  return pheight() - (window.pageYOffset + self.innerHeight);
}

function pheight() {
  return $("body").height();
}

function vheight() {
  return $(window).height();
}

var scroll_lock = false;
var last_page = false;
var current_page = 1;

function checkScroll() {
  if(!last_page && !scroll_lock && nearBottomOfPage()) {
    scroll_lock = true;

    var href = location.href;
    if(location.search == "" && href.substr(-1, 1) != "?") href += "?";
    href += "&page=" + current_page;
 
    $.get(href, function(data) {
      scroll_lock = false;
      console.log(data);
      eval(data);
    });
  }
}

$(function() {
  setInterval("checkScroll()", 250);
});
