(function() {
  var Background,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Background = (function() {
    function Background() {
      this.resize = __bind(this.resize, this);
      this.paper = Snap(innerWidth, innerHeight).attr({
        "class": 'dots'
      });
      this.rect = this.paper.rect(0, 0, innerWidth, innerHeight);
      $(window).on('resize', this.resize);
      this.resize();
    }

    Background.prototype.resize = function() {
      var c, g, hw, r, w, _ref;
      this.paper.attr({
        width: innerWidth,
        height: innerHeight
      });
      if ((_ref = this.pat) != null) {
        _ref.remove();
      }
      g = this.paper.g().attr({
        "class": 'base'
      });
      w = Math.max(innerWidth, innerHeight) / 14;
      this.step = w;
      hw = w * 0.5;
      r = w * 0.2;
      g.add(this.paper.circle(hw, 0, r));
      g.add(this.paper.circle(0, hw, r));
      g.add(this.paper.circle(w, hw, r));
      g.add(c = this.paper.circle(hw, w, r));
      this.pat = g.pattern(0, 0, w, w);
      return this.rect.attr({
        fill: this.pat,
        width: innerWidth,
        height: innerHeight
      });
    };

    return Background;

  })();

  $(function() {
    return new Background();
  });

}).call(this);
