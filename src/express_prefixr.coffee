express = require 'express'
CSSDocument = require './css_document'
logfmt = require 'logfmt'

app = express()

app.use(express.static("#{__dirname}/../public"))

app.use logfmt.requestLogger()
app.use express.json()
app.use express.urlencoded()

app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'jade'

app.get '/', (req, res) ->
  res.render 'index',
    host: req.headers.host

app.post '/api/processor', (req, res) ->
  css = null
  response =
    status: null
    result: null
  try
    css = new CSSDocument req.body.css
  catch ex
    console.log("Error: #{ex}")
    if ex.name? and ex.name is 'ParsingException'
      response.status = "error"
      response.result = ex.message

  unless response.status?
    css.parseDocument()
    css.rebuildDocument()
    response.status = "success"
    response.result = css.rebuildCSS()

  res.setHeader('Content-Type', 'application/json');
  res.send JSON.stringify(response)

port = Number(process.env.PORT or 3000)
app.listen port, ->
  console.log("Listening on #{port}")
