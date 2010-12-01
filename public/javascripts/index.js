var update_stories = function()
{
  $("#items .tag_list").each(function()
  {
    var div = $(this);
    div.click(function(event)
    {
      div.next().show().find(".input").focus();
      div.hide();
    });

    div.next().hide();
  });
};

$(update_stories);

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

  $("#stories .colorbox").colorbox({ width: 590, height: 390 });
});