
###
Module dependencies.
###
CONFIG = require('config')
express = require('express')
http = require('http')
path = require('path')
fs = require('fs')
formidable = require('formidable')
crypto = require('crypto')
log4js = require('log4js')

app = express()
logger = log4js.getLogger()

UPLOAD_DIR = path.join(__dirname, 'tmp')
SALT = Math.random().toString()
CLEANUP_INTERVAL = 3600 # 1 hour


# all environments
app.set 'port', process.env.PORT or 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'
# app.use express.favicon()
# app.use express.logger("dev")
app.use log4js.connectLogger(logger, level: log4js.levels.INFO)
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.urlencoded()
# app.use express.session secret: Math.random().toString()
app.use express.cookieSession(secret: Math.random().toString(), cookie: maxAge: 3600 * 1000)
app.use app.router
app.use express.static(path.join(__dirname, 'public'))

# development only
app.configure 'development', ->
  logger.setLevel(log4js.levels.DEBUG)
  app.use express.errorHandler()
  app.locals.pretty = true


# store all uploaded file info into this var
allFiles = {}


# need auth?
auth = []
if CONFIG.auth?.enabled
  auth.push express.basicAuth(CONFIG.auth.user, CONFIG.auth.password)


# route definitions
app.get '/', auth, (req, res) ->
  req.session = null
  res.render 'index'


app.post '/upload', auth, (req, res) ->
  form = new formidable.IncomingForm()
  form.uploadDir = UPLOAD_DIR
  form.parse req, (err, fields, files) ->
    throw err if err
    info = files.hoge
    now = Date.now()
    id = path.basename(info.path).substr(0, 6)
    password = path.basename(info.path).substr(16, 4)
    allFiles[id] =
      size: info.size
      path: info.path
      name: info.name
      type: info.type
      created: now
      timeout: now + 3 * 60 * 60 * 1000 # default 3 hours
      password: hashPassword(password)
    req.session.fileId = id
    logger.debug('uploaded', allFiles[id])
    res.json(id: id, password: password)


hashPassword = (original) ->
  sha1 = crypto.createHash('sha1')
  sha1.update(original + SALT, 'ascii')
  return sha1.digest('hex')

checkPassword = (original, challenge) ->
  return original is hashPassword(challenge)

download = (res, info) ->
  res.set('Content-Disposition', "attachment; filename*=UTF-8''#{encodeURIComponent(info.name)}")
  res.sendfile(info.path)


app.get /\/([a-f0-9]{6})$/, (req, res) ->
  id = req.params[0]
  info = allFiles[id]
  if not info
    res.status 404
    res.render 'error', title: 'Not found'
    return

  if Date.now() > info.timeout
    res.status 406
    res.render 'error', title: 'Expired', message: 'Please contact to owner to re-upload if needed.'
  else if info.password
    if checkPassword(info.password, req.query.p)
      download(res, info)
    else
      res.render 'password', id: id
  else
    if req.query.p
      download(res, info)
    else
      res.render 'download', url: "/#{id}?p=;)", download: info.name


app.post /\/([a-f0-9]{6})$/, (req, res) ->
  info = allFiles[req.body.id]
  if not info
    res.status 404
    res.render 'error', title: 'Not found'
    return

  if Date.now() > info.timeout
    res.status 406
    res.render 'error', title: 'Expired', message: 'Please contact to owner to re-upload if needed.'
    return

  if not info.password or checkPassword(info.password, req.body.password)
    res.render 'download', url: "/#{req.body.id}?p=#{req.body.password}", download: info.name
  else
    res.render 'password', id: req.body.id, error: true


app.post '/set', auth, (req, res) ->
  info = allFiles[req.session.fileId]
  if not info
    res.json(400, success: false, message: 'Bad request')
    return

  if req.body.hasOwnProperty('password')
    if req.body.password
      info.password = hashPassword(req.body.password)
    else
      delete info.password
    res.json(success: true)
    return

  expire = parseInt(req.body.expire)
  if 3 <= expire <= 7 * 24
    info.timeout = info.created + expire * 3600 * 1000
    res.json(success: true)
    return

  res.json(400, success: false)


# app.get "/p", (req, res) ->
#   res.render "password", id: 123123, error: false
# app.get "/pp", (req, res) ->
#   res.render "error", title: "Expired", message: "Please contact to owner to re-upload if needed."
# app.get "/q", (req, res) ->
#   res.render 'download'



# periodically cleanup expired files
setInterval ->
  now = Date.now()
  for info in allFiles
    if info.timeout < now and info.path
      logger.debug('remove', info)
      fs.unlinkSync(info.path)
      delete info.path
, CLEANUP_INTERVAL * 1000


# clear all uploaded files on startup
for file in fs.readdirSync(UPLOAD_DIR)
  fs.unlinkSync(path.join(UPLOAD_DIR, file))


# start server
http.createServer(app).listen app.get('port'), ->
  logger.info("Express server listening on port #{app.get("port")}")


