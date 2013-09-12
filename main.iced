express = require 'express'
uuid = require 'node-uuid'
moment = require 'moment'

REVEAL_Ts = 60
ALIVE_Ts = 180

db = {}

app = express()
appRoot = (dir) -> __dirname + dir
app.use express.static appRoot '/static'
app.use express.errorHandler()

app.set 'views', appRoot '/views'
app.set 'view engine', 'jade'

app.all '/', (req, res) ->
  return res.render 'index', {}

app.post '/create', (req, res) ->
  id = uuid.v1()
  time = moment()
  rand = Math.random()
  db[id] = {time, rand}
  console.log "+++ #{id} @ #{time.valueOf()}"

  setTimeout ->
    delete db[id]
    console.log "--- #{id}"
  , ALIVE_Ts*1000

  return res.redirect "/d/#{id}"

app.get '/d/:id', (req, res) ->
  {id} = req.params
  if !id? or id not of db
    console.log "404 #{id}"
    return res.send 404, 'dice not found'
  {time, rand} = db[id]
  remain_Ts = REVEAL_Ts - moment().diff(time, 'seconds')
  if remain_Ts > 0
    console.log "200 #{id} ? #{remain_Ts}"
    return res.render 'dice', {
      reveal: false
      remain_Ts
    }
  else
    console.log "200 #{id} = #{rand}"
    return res.render 'dice', {
      reveal: true
      rand: rand.toString()
    }

port = parseInt(process.argv.pop(), 10) || 8000
app.listen port
console.log "### roll-dice server listening on port #{port}"
