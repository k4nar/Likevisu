# Module dependencies.
express = require("express")
path = require("path")
mongoose = require("mongoose")
git = require("nodegit")
app = express()
db = mongoose.connect('mongodb://127.0.0.1/likevisu')

models = require("./lib/models")

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

if process.env.PROCESS_COMMITS
  git.Repo.open "/home/yannick/linux/.git", (error, repo) ->
    repo.getMaster (error, branch) ->
      walker = repo.createRevWalk()

      batch_size = 1000
      batch = Array(batch_size)
      count = 0

      walker.walk branch.oid(), (error, commit) ->
        if (count && count % batch_size == 0) || !commit
          console.log count
          models.Commit.create(batch)

        return if !commit

        author = commit.author()
        committer = commit.committer()

        batch[count % batch_size] =
          _id: commit.sha()
          author: author.name().toString().trim() if author
          committer: committer.name().toString().trim() if committer
          date: commit.date()
          parents: (parent.sha() for parent in commit.parents())

        count++

# Start server
port = process.env.PORT or 3000
app.listen port, ->
  console.log "Express server listening on port %d in %s mode", port, app.get("env")
