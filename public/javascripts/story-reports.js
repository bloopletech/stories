//Sourced from http://g.raphaeljs.com/piechart2.html
function pieify(div, title, keys, values)
{
  var r = Raphael(div, 370, 270);
  //r.g.txtattr.font = "12px 'Fontin Sans', Fontin-Sans, sans-serif";

  r.g.text(250, 20, title).attr({ "font-size": 20 });

  var pie = r.g.piechart(250, 150, 100, values,
  {
    legend: keys,
    legendpos: "west"
  });

  pie.hover(function()
  {
    this.sector.stop();
    this.sector.scale(1.1, 1.1, this.cx, this.cy);
    if(this.label)
    {
      this.label[0].stop();
      this.label[0].scale(1.5);
      this.label[1].attr({ "font-weight": 800 });
    }
  }, function()
  {
    this.sector.animate({ scale: [1, 1, this.cx, this.cy] }, 500, "bounce");
    if(this.label)
    {
      this.label[0].animate({ scale: 1 }, 500, "bounce");
      this.label[1].attr({ "font-weight": 400 });
    }
  });
}
