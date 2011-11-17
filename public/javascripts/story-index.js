window.onload = function() {
  var submit_func = function() {
    document.getElementById("search_form").submit();
  };
  document.getElementById("sort").onchange = submit_func;
  document.getElementById("sort_direction").onchange = submit_func;
};
