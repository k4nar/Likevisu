mongoose = require("mongoose")
moment = require("moment")
Commit = mongoose.model('Commit')

top = (field, cb) ->
  Commit.aggregate()
        .group(_id: '$' + field, count: {$sum: 1})
        .sort(count: -1)
        .limit(10)
        .project(name: "$id", count: 1)
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

  commits_per_day: (req, res) ->
    Commit.aggregate()
      .group(_id: {$add: [{$dayOfYear: "$date"}, {$multiply: [400, {$year: "$date"}]}]}, count: {$sum: 1}, first: {$min: "$date"})
      .exec (err, result) ->
        dates = {}

        for v in result
          date = moment(v.first).format("YYYY-MM-DD")
          dates[date] = v.count

        res.json dates
