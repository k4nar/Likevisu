(function() {
  'use strict';
  var __slice = [].slice;

  angular.module('likevisuApp').controller('MainCtrl', function($scope, $http) {
    var req, update_graphs, update_top_graphs, versions_map;
    versions_map = {};
    $scope.versions = [];
    $scope.start = null;
    $scope.stop = null;
    $scope.top_by = 'lines';
    $scope.$watchCollection('[start, stop]', function(values) {
      if (!($scope.start && $scope.stop)) {
        return;
      }
      $scope.start_bound = $scope.versions.indexOf($scope.stop);
      $scope.stop_bound = -($scope.versions.length - $scope.versions.indexOf($scope.start) - 1);
      return update_graphs();
    });
    $http.get('/versions').success(function(query) {
      var version, _i, _len, _ref;
      _ref = query['result'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        version = _ref[_i];
        versions_map[version['name']] = version['id'];
      }
      $scope.versions = (function() {
        var _j, _len1, _ref1, _results;
        _ref1 = query['result'];
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          version = _ref1[_j];
          _results.push(version['name']);
        }
        return _results;
      })();
      $scope.start = query['result'][0].name;
      $scope.stop = query['result'][query['result'].length - 1].name;
      return $scope.$watch('top_by', function(value) {
        return update_top_graphs();
      });
    });
    req = function() {
      var arg, args, route, _i, _len;
      route = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      route += '/' + versions_map[$scope.start];
      route += '/' + versions_map[$scope.stop];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        route += '/' + arg;
      }
      return route;
    };
    update_graphs = function() {
      var element, _i, _len, _ref;
      _ref = document.querySelectorAll('svg');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        element.classList.add('loading');
      }
      update_top_graphs();
      $http.get(req('/commits/by_date')).success(function(query) {
        $scope.commits_by_date_boundaries = [query['start'], query['stop']];
        return $scope.commits_by_date = query['dates'];
      });
      $http.get(req('/commits/diffs')).success(function(query) {
        var result, v;
        result = query['result'];
        return $scope.diffs = [
          {
            key: "Additions",
            values: (function() {
              var _j, _len1, _results;
              _results = [];
              for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
                v = result[_j];
                if (v.version) {
                  _results.push({
                    version: v.version,
                    count: v.additions
                  });
                }
              }
              return _results;
            })(),
            area: true,
            color: 'green'
          }, {
            key: "Deletions",
            values: (function() {
              var _j, _len1, _results;
              _results = [];
              for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
                v = result[_j];
                if (v.version) {
                  _results.push({
                    version: v.version,
                    count: -v.deletions
                  });
                }
              }
              return _results;
            })(),
            area: true,
            color: 'red'
          }
        ];
      });
      $http.get(req('/commits/evolution')).success(function(query) {
        return $scope.commits_evolution = [
          {
            key: "Commits",
            values: query['result']
          }
        ];
      });
      return $http.get(req('/authors/evolution')).success(function(query) {
        return $scope.authors_evolution = [
          {
            key: "Authors",
            values: query['result']
          }
        ];
      });
    };
    return update_top_graphs = function() {
      var value;
      value = $scope.top_by;
      $http.get(req('/authors/by_' + value, 10)).success(function(query) {
        return $scope.top_authors = [
          {
            key: "Top Authors",
            values: query['result']
          }
        ];
      });
      return $http.get(req('/companies/by_' + value, 10)).success(function(query) {
        return $scope.top_companies = [
          {
            key: "Top Companies",
            values: query['result']
          }
        ];
      });
    };
  });

}).call(this);

/*
//@ sourceMappingURL=main.js.map
*/