exports.views =
  by_author:
    map: (commit) ->
      emit commit.author, commit
