$("#wrapper > h1, #wrapper > h2, #wrapper > h3, #wrapper > h4, #wrapper > h5, #wrapper > h6, #wrapper > p, #wrapper > blockquote").live("click", function() {
    var str = "";
    var $this = $(this);

    $.each($this.contents(), function() {
      var $this = $(this);
      if($this.is("b"))
        str += "*" + $this.text() + "*";
      else if($this.is("i"))
        str += "_" + $this.text() + "_";
      else
        str += $this.text();
    });

    for(var i = 1; i <= 6; i++) {
      if($this.is("h" + i)) {
        heading_str = "";
        for(var j = 1; j <= i; j++) heading_str += "#";
        str = heading_str + " " + str;
        break;
      }
    }

    var height = $this.height();
    $this.replaceWith("<textarea style='height: " + height + "px;'>" + str + "</textarea><input type='button' class='story-save' value='Save'>");
  });
