express = require 'express'
app = express()

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