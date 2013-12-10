'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.versions = {}
    $scope.start = null
    $scope.stop = null

    $scope.$watchCollection '[start, stop]', (values) ->
      return if not ($scope.start and $scope.stop)
      update_graphs()

    $http.get('/versions').success (query) ->
      $scope.versions[version['name']] = version['id'] for version in query['result']
      $scope.start = query['result'][10].name
      $scope.stop = query['result'][20].name

      update_graphs()


    update_graphs = ->
      req = (route, args...) ->
        route += '/' + $scope.versions[$scope.start]
        route += '/' + $scope.versions[$scope.stop]
        for arg in args
          route += '/' + arg
        route

      $http.get(req('/authors/by_commits', 10)).success (query) ->
        $scope.top_authors_by_commits = [{key: "Top Authors by Commits", values: query['result']}]

      $http.get(req('/authors/by_lines', 10)).success (query) ->
        $scope.top_authors_by_lines = [{key: "Top Authors by lines added", values: query['result']}]

      $http.get(req('/companies/by_commits', 10)).success (query) ->
        $scope.top_companies_by_commits = [{key: "Top Companies by Commits", values: query['result']}]

      $http.get(req('/companies/by_lines', 10)).success (query) ->
        $scope.top_companies_by_lines = [{key: "Top Companies by lines added", values: query['result']}]

      $http.get(req('/commits/by_date')).success (query) ->
        $scope.commits_by_date_boundaries = [query['start'], query['stop']]
        $scope.commits_by_date = query['dates']

      $http.get(req('/commits/diffs')).success (query) ->
        result = query['result']

        $scope.diffs = [
          {key: "Additions", values: (version: v.version, count: v.additions for v in result when v.version), area: true, color: 'green'},
          {key: "Deletions", values: (version: v.version, count: -v.deletions for v in result when v.version), area: true, color: 'red'},
        ]

      $http.get(req('/commits/evolution')).success (query) ->
        $scope.commits_evolution = [
          {key: "Commits", values: query['result']},
        ]

      $http.get(req('/authors/evolution')).success (query) ->
        $scope.authors_evolution = [
          {key: "Authors", values: query['result']},
        ]
