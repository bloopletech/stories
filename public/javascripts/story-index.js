window.onload = function() {
  var submit_func = function() {
    document.getElementById("search_form").submit();
  };
  document.getElementById("sort").onchange = submit_func;
  document.getElementById("sort_direction").onchange = submit_func;
};

$(function() {
  $("#search_form").keydown(function(event)
  {
    if(event.keyCode == 32 || event.keyCode == 8 || event.keyCode == 37 || event.keyCode == 39) event.stopPropagation();
  });
});
