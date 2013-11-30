mongoose = require('mongoose')
ObjectId = mongoose.Schema.ObjectId

commit = new mongoose.Schema
  _id: type: String, index: true, required: true
  author: type: String, index: true
  committer: type: String, index: true
  date: type: Date, index: true
  message: String
  parents: [type: ObjectId, ref: 'Contributor']

module.exports =
  Commit: mongoose.model('Commit', commit)
