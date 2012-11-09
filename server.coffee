if process.env.REDISTOGO_URL
  rtg = require('url').parse process.env.REDISTOGO_URL
  redis = require('redis').createClient rtg.port, rtg.hostname
  redis.auth rtg.auth.split(':')[1]
else
  redis = require('redis').createClient()

express = require 'express'
app = express()

passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy

app.use express.cookieParser()
app.use express.bodyParser()
app.use express.cookieSession { secret: process.env.COOKIE_SECRET }
app.use passport.initialize()
app.use passport.session()
app.use express.static __dirname + '/static'

passport.use new TwitterStrategy(
  consumerKey: process.env.TWITTER_CONSUMER_KEY
  consumerSecret: process.env.TWITTER_CONSUMER_SECRET
  callbackURL: 'http://127.0.0.1:3000/auth/twitter/callback',
  (token, tokenSecret, profile, done) ->
    User.findOrCreate
      twitterId: profile.id,
      (err, user) -> done err, user
)

#app.get '/', (req, rsp) ->
#  rsp.send 'Hello, World!'

app.get '/auth/twitter', passport.authenticate 'twitter'

app.get '/auth/twitter/callback', passport.authenticate('twitter',
  failureRedirect: '/'
), (req, res) ->
  console.log req
  console.log redis
  res.redirect '/'

port = process.env.PORT || 3000
app.listen port