'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.top_authors = []
    $scope.top_committers = []

    $http.get('/commits/top_authors').success (top) ->
      $scope.top_authors = [{key: "Top Authors", values: top}]

    $http.get('/commits/top_committers').success (top) ->
      $scope.top_committers = [{key: "Top Committers", values: top}]
