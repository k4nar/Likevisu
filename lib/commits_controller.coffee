mongoose = require("mongoose")
Commit = mongoose.model('Commit')

top = (field, cb) ->
  Commit.aggregate()
        .group(_id: '$' + field, count: {$sum: 1})
        .sort(count: -1)
        .limit(10)
        .exec (err, res) ->
          for item in res
            item.name = item._id
            delete item._id
          cb res

module.exports =
  top_authors: (req, res) ->
    top 'author', (list) ->
      res.json list

  top_committers: (req, res) ->
    top 'committer', (list) ->
      res.json list
