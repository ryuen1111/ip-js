@IP = {
  channels: 4

  contrast: (src, rangeMin, rangeMax) ->
    width = src.width
    height = src.height
    data = src.data

    dst = @createImageData(width, height)

    min = 1.0
    max = 0.0

    for y in [0...height]
      for x in [0...width]
        addr = (y * width * @channels) + x * @channels
        hsv = @RGB2HSV(data[addr]/255.0, data[addr+1]/255.0, data[addr+2]/255.0)
        min = Math.min(hsv['v'], min)
        max = Math.max(hsv['v'], max)

    b = min
    a = (rangeMax - rangeMin) / (max - min)

    for y in [0...height]
      for x in [0...width]
        addr = (y * width * @channels) + x * @channels
        hsv = @RGB2HSV(data[addr]/255.0, data[addr+1]/255.0, data[addr+2]/255.0)
        hsv['v'] = a * (hsv['v'] - b)
        rgb = @HSV2RGB(hsv['h'], hsv['s'], hsv['v'])
        dst.data[addr] = rgb['r'] * 255
        dst.data[addr+1] = rgb['g'] * 255
        dst.data[addr+2] = rgb['b'] * 255
        dst.data[addr+3] = data[addr+3]
    dst

  RGB2HSV: (r, g, b) ->
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = max - min
    if h > 0.0
      switch max
        when r
          h = (g - b) / h
          h += 6.0 if h < 0.0
        when g
          h = 2.0 + (b - r) / h
        else
          h = 4.0 + (r - g) / h
    h /= 6.0
    s = if max == 0.0 then max - min else (max - min) / max
    return {h: h, s: s, v: max}


  HSV2RGB: (h, s, v) ->
    r = v
    g = v
    b = v
    if s > 0.0
      h *= 6.0
      i = Math.floor(h)
      f = h - i
      switch i
        when 0
          g *= 1.0 - s * (1.0 - f)
          b *= 1.0 - s
        when 1
          r *= 1.0 - s * f
          b *= 1.0 - s
        when 2
          r *= 1.0 - s
          b *= 1.0 - s * (1.0 - f)
        when 3
          r *= 1.0 - s
          g *= 1.0 - s * f
        when 4
          r *= 1.0 - s * (1.0 - f)
          g *= 1.0 - s
        when 5
          g *= 1.0 - s
          b *= 1.0 - s * f
        else
          g *= 1.0 - s * (1.0 - f)
          b *= 1.0 - s
    return {r: r, g: g, b: b}

  changeSaturation: (src, color, range, coefficient) ->
    width = src.width
    height = src.height
    data = src.data
    targetHue = @colorToHue(color)
    th_u = targetHue + range
    th_d = targetHue - range

    dst = @createImageData(width, height)
    for y in [0...height]
      for x in [0...width]
        addr = (y * width * @channels) + x * @channels
        hsv = @RGB2HSV(data[addr]/255.0, data[addr+1]/255.0, data[addr+2]/255.0)
        if th_d <= hsv['h'] <= th_u
          hsv['s'] *= coefficient
          rgb = @HSV2RGB(hsv['h'], hsv['s'], hsv['v'])
          dst.data[addr] = rgb['r'] * 255
          dst.data[addr+1] = rgb['g'] * 255
          dst.data[addr+2] = rgb['b'] * 255
          dst.data[addr+3] = data[addr+3]
        else
          dst.data[addr] = data[addr]
          dst.data[addr+1] = data[addr+1]
          dst.data[addr+2] = data[addr+2]
          dst.data[addr+3] = data[addr+3]
    dst

  colorToHue: (color) ->
    switch color
      when 'red'
        hue = 0.0 / 360.0
      when 'orange'
        hue = 30.0 / 360.0
      when 'yellow'
        hue = 60.0 / 360.0
      when 'light-green'
        hue = 90.0 / 360.0
      when 'green'
        hue = 120.0 / 360.0
      when 'cyan'
        hue = 180.0 / 360.0
      when 'blue'
        hue = 210.0 / 360.0
      when 'purple'
        hue = 240.0 / 360.0
      when 'pink'
        hue = 300.0 / 360.0
      when 'magenta'
        hue = 330.0 / 360.0
    return hue


  execConvolution: (src, filter) ->
    size = Math.sqrt(filter.length)
    if size % 2 == 0
      return null

    width = src.width
    height = src.height
    data = src.data
    dst = @createImageData(width, height)
    margin = Math.floor(size / 2)
    for y in [margin...(height-margin)]
      for x in [margin...(width-margin)]
        addr = (y * width * @channels) + x * @channels
        r = 0.0
        g = 0.0
        b = 0.0
        for j in [(-margin)..(margin)]
          for i in [(-margin)..(margin)]
            filterAddr = ((j + margin) * size) + margin + i
            targetAddr = addr + (j * width * @channels) + i * @channels
            r += filter[filterAddr] * data[targetAddr]
            g += filter[filterAddr] * data[targetAddr+1]
            b += filter[filterAddr] * data[targetAddr+2]
        dst.data[addr] = r
        dst.data[addr+1] = g
        dst.data[addr+2] = b
        dst.data[addr+3] = data[addr+3]
    dst

  createImageData: (width, height) ->
    canvas = document.createElement('canvas')
    ctx = canvas.getContext('2d')
    return ctx.createImageData(width, height)
}
