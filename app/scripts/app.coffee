'use strict'

angular.module('likevisuApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'nvd3ChartDirectives'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .otherwise
        redirectTo: '/'
