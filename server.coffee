if process.env.REDISTOGO_URL
  rtg = require('url').parse process.env.REDISTOGO_URL
  redis = require('redis').createClient rtg.port, rtg.hostname
  redis.auth rtg.auth.split(':')[1]
else
  redis = require('redis').createClient()

express = require 'express'
app = express()

passport = require 'passport'

app.use express.cookieParser()
app.use express.bodyParser()
app.use express.cookieSession { secret: process.env.secret }
app.use passport.initialize()
app.use passport.session()
app.use express.static __dirname + '/static'

#app.get '/', (req, rsp) ->
#  rsp.send 'Hello, World!'

port = process.env.PORT || 3000
app.listen port