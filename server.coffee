# Module dependencies.
express = require("express")
path = require("path")
app = express()

# Controllers
api = require("./lib/controllers/api")

# Express Configuration
app.configure ->
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.configure "development", ->
  app.use express.static(path.join(__dirname, ".tmp"))
  app.use express.static(path.join(__dirname, "app"))
  app.use express.errorHandler()

app.configure "production", ->
  app.use express.favicon(path.join(__dirname, "public/favicon.ico"))
  app.use express.static(path.join(__dirname, "public"))


# Routes
app.get "/api/awesomeThings", api.awesomeThings

# Start server
port = process.env.PORT or 3000
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", port, app.get("env")
