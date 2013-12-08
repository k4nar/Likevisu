'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.top_authors = []
    $scope.commits_by_date = {}
    $scope.diffs = []

    $http.get('/commits/top_authors').success (query) ->
      $scope.top_authors = [{key: "Top Authors", values: query['result']}]

    $http.get('/commits/by_date').success (res) ->
      $scope.commits_by_date = res

    $http.get('/commits/diffs').success (query) ->
      result = query['result']

      $scope.diffs = [
        {key: "Additions", values: (date: v.date, count: v.additions for v in result), area: true, color: 'green'},
        {key: "Deletions", values: (date: v.date, count: -v.deletions for v in result), area: true, color: 'red'},
      ]
      console.log query['result']
