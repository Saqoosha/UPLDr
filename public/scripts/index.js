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
    var NO_PASSWORD, button, client, current, dropZone, updateCopyInfo;
    new Background();
    $(document).on('drop dragover', function(e) {
      return e.preventDefault();
    });
    dropZone = $('.circle').css({
      cursor: 'pointer'
    });
    $('#fileupload').fileupload({
      dropZone: dropZone,
      dataType: 'json',
      drop: function(e, data) {
        if (data.files.length !== 1) {
          e.preventDefault();
          dropZone.transition({
            scale: 1.0
          }, 100);
          return alert('Only accept a single file at one time.');
        }
      },
      add: function(e, data) {
        dropZone.css({
          cursor: 'auto'
        }).off().transition({
          scale: 1.0
        }, 100);
        $('#filename').text(data.files[0].name);
        return $('#selectfile').fadeOut(200, function() {
          return $('#progress').fadeIn(200, function() {
            return data.submit();
          });
        });
      },
      progressall: function(e, data) {
        var p;
        p = data.loaded / data.total * 100;
        $('#percent').text(Math.round(p) + '%');
        return $('.mask').transition({
          height: (100 - p) + '%'
        }, 100, 'ease-in-out');
      },
      done: function(e, data) {
        return $('#progress').fadeOut(200, function() {
          history.pushState('', '', '/' + data.result.id);
          $('.download-link').attr('href', location.href).text(location.href);
          $('#password').text(data.result.password);
          updateCopyInfo();
          return $('#result').fadeIn(200);
        });
      }
    }).hide();
    dropZone.on('dragenter', function(e) {
      return dropZone.transition({
        scale: 1.05
      }, 100);
    });
    dropZone.on('dragleave', function(e) {
      return dropZone.transition({
        scale: 1.0
      }, 100);
    });
    dropZone.on('click', function(e) {
      if (e.target.id !== 'fileupload') {
        return $('#fileupload').trigger('click');
      }
    });
    NO_PASSWORD = '- none -';
    updateCopyInfo = function() {
      var password, text;
      text = $('.download-link').text() + "\n";
      password = $('#password').text();
      if (password !== NO_PASSWORD) {
        text += "Password: " + password + "\n";
      }
      return $('#copy-button').attr('data-clipboard-text', text);
    };
    ZeroClipboard.config({
      moviePath: '/scripts/ZeroClipboard.swf'
    });
    button = $('#copy-button').hide();
    client = new ZeroClipboard(button);
    client.on('load', function() {
      return button.show();
    });
    $('#password').popover({
      container: 'body',
      html: true,
      content: $('#password-popout').remove().on('click', 'button', function(e) {
        var i, password, _i;
        switch ($(this).text()) {
          case 'No password':
            password = '';
            break;
          case 'Generate new':
            password = '';
            for (i = _i = 0; _i < 4; i = ++_i) {
              password += ((Math.random() * 36) | 0).toString(36);
            }
            break;
          default:
            return;
        }
        return $.post('/set', {
          password: password
        }, function(result, success) {
          if (success === 'success' && result.success === true) {
            $('#password').text(password || NO_PASSWORD).popover('hide');
            return updateCopyInfo();
          }
        });
      })
    });
    $('#expiration').popover({
      container: 'body',
      html: true,
      content: $('#expiration-popout').remove().on('click', 'button', function(e) {
        var expire, t;
        t = $(this).text();
        switch (t) {
          case '3 hours':
            expire = 3;
            break;
          case '6 hours':
            expire = 6;
            break;
          case '12 hours':
            expire = 12;
            break;
          case '1 day':
            expire = 24;
            break;
          case '3 days':
            expire = 3 * 24;
            break;
          case '1 week':
            expire = 7 * 24;
            break;
          default:
            return;
        }
        return $.post('/set', {
          expire: expire
        }, function(result, success) {
          if (success === 'success' && result.success === true) {
            return $('#expiration').text(t).popover('hide');
          }
        });
      })
    });
    current = null;
    return $('#password, #expiration').on('show.bs.popover', function() {
      if (current) {
        current.popover('hide');
      }
      return current = $(this);
    }).on('hide.bs.popover', function() {
      return current = null;
    });
  });

}).call(this);
