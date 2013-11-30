mongoose = require('mongoose')

commit = new mongoose.Schema
  _id: type: String, index: true, required: true
  author: String, index: true
  committer: String, index: true
  date: Date, index: true
  message: String
  parents: [String]

module.exports = mongoose.model('Commit', commit)
