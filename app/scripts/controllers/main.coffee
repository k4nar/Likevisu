'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.top_authors = []
    $scope.top_committers = []
    $scope.commits_by_date = {}
    $scope.commits_evolution = []
    $scope.authors_evolution = []

    $http.get('/commits/top_authors').success (res) ->
      $scope.top_authors = [res]


    $http.get('/commits/by_date').success (res) ->
      $scope.commits_by_date = res

    # $http.get('/commits/evolution').success (res) ->
    #   $scope.commits_evolution = [{key: "Commit evolution", values: res}]

    # $http.get('/commits/authors_evolution').success (res) ->
    #   $scope.authors_evolution = [{key: "Authors evolution", values: res}]
