'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    versions_map = {}
    $scope.versions = []
    $scope.start = null
    $scope.stop = null
    $scope.top_by = 'lines'


    $scope.$watchCollection '[start, stop]', (values) ->
      return if not ($scope.start and $scope.stop)
      $scope.start_bound = $scope.versions.indexOf($scope.stop)
      $scope.stop_bound = -($scope.versions.length - $scope.versions.indexOf($scope.start) - 1)
      update_graphs()


    $http.get('/versions').success (query) ->
      versions_map[version['name']] = version['id'] for version in query['result']
      $scope.versions = (version['name'] for version in query['result'])
      $scope.start = query['result'][0].name
      $scope.stop = query['result'][query['result'].length - 1].name

      $scope.$watch 'top_by', (value) ->
        update_top_graphs()


    req = (route, args...) ->
      route += '/' + versions_map[$scope.start]
      route += '/' + versions_map[$scope.stop]
      for arg in args
        route += '/' + arg
      route


    update_graphs = ->
      for element in document.querySelectorAll('svg')
        element.classList.add('loading')

      update_top_graphs()

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


    update_top_graphs = ->
      value = $scope.top_by

      $http.get(req('/authors/by_'+ value, 10)).success (query) ->
        $scope.top_authors = [{key: "Top Authors", values: query['result']}]

      $http.get(req('/companies/by_' + value, 10)).success (query) ->
        $scope.top_companies = [{key: "Top Companies", values: query['result']}]
