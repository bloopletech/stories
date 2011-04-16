$(function()
{
  $("#sort, #sort_direction").delayedObserver(1.0, function()
  {
    $('#search_form').submit();
  });

  $("#tag_cloud_link").click(function(event)
  {
    event.preventDefault();
  });
  
  $("#tag_cloud_link").mouseenter(function(event)
  {
    $("#tag_cloud").show();
  });

  $("#tag_cloud").mouseleave(function(event)
  {
    $("#tag_cloud").hide();
  });

  $("#stories .colorbox.more-info").colorbox({ width: 590, height: 390 });
  $(".colorbox.edit").colorbox({ width: 855, height: 570, iframe: true });  
  $("#stories_export").colorbox({ width: 250, height: 200, iframe: true });
});