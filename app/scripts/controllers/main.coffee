'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.top_authors_by_commits = []
    $scope.top_authors_by_lines = []
    $scope.top_companies_by_commits = []
    $scope.top_companies_by_lines = []
    $scope.commits_by_date = {}
    $scope.diffs = []
    $scope.commits_evolution = []
    $scope.authors_evolution = []

    $http.get('/commits/top_authors_by_commits').success (query) ->
      $scope.top_authors_by_commits = [{key: "Top Authors by Commits", values: query['result']}]

    $http.get('/commits/top_authors_by_lines').success (query) ->
      $scope.top_authors_by_lines = [{key: "Top Authors by lines added", values: query['result']}]

    $http.get('/commits/top_companies_by_commits').success (query) ->
      $scope.top_companies_by_commits = [{key: "Top Companies by Commits", values: query['result']}]

    $http.get('/commits/top_companies_by_lines').success (query) ->
      $scope.top_companies_by_lines = [{key: "Top Companies by lines added", values: query['result']}]

    $http.get('/commits/by_date').success (res) ->
      $scope.commits_by_date = res

    $http.get('/commits/diffs').success (query) ->
      result = query['result']

      $scope.diffs = [
        {key: "Additions", values: (version: v.version, count: v.additions for v in result when v.version), area: true, color: 'green'},
        {key: "Deletions", values: (version: v.version, count: -v.deletions for v in result when v.version), area: true, color: 'red'},
      ]

    $http.get('/commits/evolution').success (query) ->
      $scope.commits_evolution = [
        {key: "Commits", values: query['result']},
      ]

    $http.get('/commits/authors_evolution').success (query) ->
      $scope.authors_evolution = [
        {key: "Authors", values: query['result']},
      ]
