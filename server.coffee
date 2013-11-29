# Module dependencies.
express = require("express")
fs = require("fs")
path = require("path")
cradle = require("cradle")
app = express()

# Express Configuration
app.configure ->
  app.use express.logger("dev")
  app.use express.json()
  app.use express.urlencoded()
  app.use express.methodOverride()
  app.use app.router

app.configure "development", ->
  app.use express.static(path.join(__dirname, ".tmp"))
  app.use express.static(path.join(__dirname, "app"))
  app.use express.errorHandler()

app.configure "production", ->
  app.use express.favicon(path.join(__dirname, "public/favicon.ico"))
  app.use express.static(path.join(__dirname, "public"))

db = new(cradle.Connection)().database('commits')

fs.readdir './lib/designs', (err, files) ->
  for file in files
    file = file.slice 0, -7 # strip the .coffee
    views = require('./lib/designs/' + file).views
    db.save('_design/' + file, views)

# Start server
port = process.env.PORT or 3000
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", port, app.get("env")
