'use strict'

angular.module('likevisuApp')
  .controller 'MainCtrl', ($scope, $http, cornercouch) ->
    $scope.server = cornercouch("http://localhost:5984", "JSONP")
    $scope.db = $scope.server.getDB("commits")

