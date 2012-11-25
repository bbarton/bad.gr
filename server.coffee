if process.env.REDISTOGO_URL
  rtg = require('url').parse process.env.REDISTOGO_URL
  redis = require('redis').createClient rtg.port, rtg.hostname
  redis.auth rtg.auth.split(':')[1]
else
  redis = require('redis').createClient()

express = require 'express'
twitter = require 'twitter'
app = express()

passport = require 'passport'
TwitterStrategy = require('passport-twitter').Strategy

app.use express.cookieParser()
app.use express.bodyParser()
app.use express.cookieSession { secret: process.env.COOKIE_SECRET }
app.use passport.initialize()
app.use passport.session()
app.use express.static __dirname + '/static'

fetchUser = (id, callback) -> redis.hgetall 'user:' + id, (err, user) -> callback user || { id: null }

app.use (req, res, next) ->
  cookies = req.cookies['connect.sess']
  if cookies
    cookie_slice = cookies.substring(4,cookies.length).match(/(.*})\./)[1]
    json = JSON.parse(cookie_slice)
    req.session.oauth_twitter = json['oauth:twitter'] if json['oauth:twitter']
  next()

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) -> redis.hgetall 'user:' + id, (err, user) -> done err, user

passport.use new TwitterStrategy(
  consumerKey: process.env.TWITTER_CONSUMER_KEY
  consumerSecret: process.env.TWITTER_CONSUMER_SECRET
  callbackURL: 'http://127.0.0.1:3000/auth/twitter/callback',
  (token, tokenSecret, profile, done) ->
    redis.get 'twitter:' + profile.id, (err, uid) ->
      if uid
        redis.hgetall 'user:' + uid, (err, user) -> done err, user
      else
        redis.incr 'users', (err, num) ->
          redis.set 'twitter:' + profile.id, num
          redis.hset 'user:' + num, 'twitter', profile.id
          redis.hset 'user:' + num, 'id', num
          redis.hgetall 'user:' + num, (err, user) -> done err, user
)

app.get '/user', (req, res) -> fetchUser req.session.passport.user, (user) -> res.json user

app.get '/auth/twitter', passport.authenticate 'twitter'

app.get '/auth/twitter/callback', passport.authenticate('twitter', { failureRedirect: '/' }), (req, res) ->
  redis.hset 'user:' + req.user.id, 'oauth:twitter_key',    req.session['oauth_twitter'].oauth_token
  redis.hset 'user:' + req.user.id, 'oauth:twitter_secret', req.session['oauth_twitter'].oauth_token_secret
  res.redirect '/'

app.get '/post', (req, res) ->
  fetchUser req.session.passport.user, (user) ->
    if user.id
      twit = new twitter {
        consumer_key: process.env.TWITTER_CONSUMER_KEY
        consumer_secret: process.env.TWITTER_CONSUMER_SECRET
        access_token_key: user['oauth:twitter_key']
        access_token_secret: user['oauth:twitter_secret']
      }
      twit.updateStatus req.params.message, (rsp) -> console.log rsp
      res.json { success: true }
    else
      res.json { success: false }

port = process.env.PORT || 3000
app.listen port