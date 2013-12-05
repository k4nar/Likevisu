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

  per_day: (req, res) ->
    Commit.aggregate()
      .group(
        _id:   {$add: [{$dayOfYear: "$date"}, {$multiply: [400, {$year: "$date"}]}]},
        count: {$sum: 1},
        first: {$min: "$date"}
      ).exec (err, result) ->
        dates = {}

        for v in result
          date = moment(v.first).format("YYYY-MM-DD")
          dates[date] = v.count

        res.json dates

  evolution: (req, res) ->
    Commit.aggregate()
      .group(
        _id:   {$add: [{$dayOfYear: "$date"}, {$multiply: [400, {$year: "$date"}]}]},
        count: {$sum: 1},
        first: {$min: "$date"}
      )
      .sort(first: 1)
      .exec (err, result) ->
        dates = Array(result.length)

        acc = 0
        for v, i in result
          dates[i] = {date: v.first, count: acc + v.count}
          acc += v.count

        res.json dates


  authors_evolution: (req, res) ->
    Commit.aggregate()
      .group(
        _id:   "$author",
        first: {$min: "$date"}
      )
      .sort(first: 1)
      .exec (err, result) ->
        dates = Array(result.length)

        acc = 0
        for v, i in result
          dates[i] = {date: v.first, count: acc + 1}
          acc += 1

        res.json dates
