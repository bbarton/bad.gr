if process.env.REDISTOGO_URL
  rtg = require('url').parse process.env.REDISTOGO_URL
  require('redis').createClient rtg.port, rtg.hostname
  redis.auth rtg.auth.split(':')[1]
else
  redis = require('redis').createClient()

express = require 'express'
app = express()
passport = require 'passport'

app.use express.cookieParser()
app.use express.bodyParser()
app.use express.cookieSession()
app.use passport.initialize()
app.use passport.session()
app.use express.static 'public'

app.get '/', (req, rsp) ->
  rsp.send 'Hello, World!'

app.listen 3000
console.log 'Listening on port 3000'