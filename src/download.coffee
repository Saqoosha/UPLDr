class Background


  constructor: ->
    @paper = Snap(innerWidth, innerHeight).attr(class: 'dots')
    @rect = @paper.rect(0, 0, innerWidth, innerHeight)
    $(window).on('resize', @resize)
    @resize()


  resize: =>
    @paper.attr(width: innerWidth, height: innerHeight)

    @pat?.remove()

    g = @paper.g().attr(class: 'base')
    w = Math.max(innerWidth, innerHeight) / 14
    @step = w
    hw = w * 0.5
    r = w * 0.2
    g.add(@paper.circle(hw, 0, r))
    g.add(@paper.circle(0, hw, r))
    g.add(@paper.circle(w, hw, r))
    g.add(c = @paper.circle(hw, w, r))
    @pat = g.pattern(0, 0, w, w)
    @rect.attr(fill: @pat, width: innerWidth, height: innerHeight)

$ ->
  new Background()

  