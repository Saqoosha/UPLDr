$ ->
  $(document).on 'drop dragover', (e) -> e.preventDefault()

  dropZone = $('.circle').css(cursor: 'pointer')
  $('#fileupload').fileupload
    dropZone: dropZone
    dataType: 'json'
    drop: (e, data) ->
      if data.files.length isnt 1
        e.preventDefault()
        dropZone.transition(scale: 1.0, 100)
        alert('Only accept a single file at one time.')
    add: (e, data) ->
      dropZone.css(cursor: 'auto').off().transition(scale: 1.0, 100)
      $('#filename').text(data.files[0].name)
      $('#selectfile').fadeOut 200, ->
        $('#progress').fadeIn 200, ->
          data.submit()
    progressall: (e, data) ->
      p = data.loaded / data.total * 100
      $('#percent').text(Math.round(p) + '%')
      $('.mask').transition(height: (100 - p) + '%', 100, 'ease-in-out')
    done: (e, data) ->
      # console.log(data.result)
      $('#progress').fadeOut 200, ->
        history.pushState('', '', '/' + data.result.id)
        $('.download-link').attr('href', location.href).text(location.href)
        $('#password').text(data.result.password)
        updateCopyInfo()
        $('#result').fadeIn 200
  .hide()

  dropZone.on 'dragenter', (e) -> dropZone.transition(scale: 1.05, 100)
  dropZone.on 'dragleave', (e) -> dropZone.transition(scale: 1.0, 100)
  dropZone.on 'click', (e) -> $('#fileupload').trigger('click') if e.target.id isnt 'fileupload'

  NO_PASSWORD = '- none -'
  updateCopyInfo = ->
    text = $('.download-link').text() + "\n"
    password = $('#password').text()
    if password isnt NO_PASSWORD
      text += "Password: #{password}\n"
    $('#copy-button').attr('data-clipboard-text', text)

  ZeroClipboard.config(moviePath: '/scripts/ZeroClipboard.swf')
  button = $('#copy-button').hide()
  client = new ZeroClipboard(button)
  client.on 'load', -> button.show()

  $('#password').popover
    container: 'body'
    html: true
    content: $('#password-popout').remove().on 'click', 'button', (e) ->
      switch $(this).text()
        when 'No password'
          password = ''
        when 'Generate new'
          password = ''
          for i in [0...4]
            password += ((Math.random() * 36) | 0).toString(36)
        else
          return
      $.post '/set', password: password, (result, success) ->
        if success is 'success' and result.success is true
          $('#password').text(password or NO_PASSWORD).popover('hide')
          updateCopyInfo()

  $('#expiration').popover
    container: 'body'
    html: true
    content: $('#expiration-popout').remove().on 'click', 'button', (e) ->
      t = $(this).text()
      switch t
        when '3 hours' then expire = 3
        when '6 hours' then expire = 6
        when '12 hours' then expire = 12
        when '1 day' then expire = 24
        when '3 days' then expire = 3 * 24
        when '1 week' then expire = 7 * 24
        else return
      $.post '/set', expire: expire, (result, success) ->
        if success is 'success' and result.success is true
          $('#expiration').text(t).popover('hide')

  current = null
  $('#password, #expiration').on 'show.bs.popover', ->
    if current then current.popover('hide')
    current = $(this)
  .on 'hide.bs.popover', ->
    current = null

