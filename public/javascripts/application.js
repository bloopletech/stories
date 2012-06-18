$(function() {
  $("#success a").click(function(e) {
    $("#success").remove();
    e.preventDefault();
  });
});
