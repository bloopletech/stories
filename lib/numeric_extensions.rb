#Sources from http://pullmonkey.com/2008/1/31/rounding-to-the-nearest-number-in-ruby/
class Numeric
  def round_up(nearest = 10)
    self % nearest == 0 ? self : self + nearest - (self % nearest)
  end
  def round_down(nearest = 10)
    self % nearest == 0 ? self : self - (self % nearest)
  end

  def round_nearest(nearest = 10)
    up = round_up(nearest)
    down = round_down(nearest)
    (up - self) < (self - down) ? up : down
  end
end