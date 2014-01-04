(function() {
  'use strict';
  angular.module('likevisuApp').directive('lineChart', function($parse) {
    return {
      restrict: "E",
      replace: false,
      scope: {
        data: "=data"
      },
      link: function(scope, element, attrs) {
        return nv.addGraph(function() {
          var chart, svg;
          chart = nv.models.lineChart().x(function(d, i) {
            return i;
          }).y(function(d) {
            return d.count;
          }).useInteractiveGuideline(true).showLegend(false).interpolate(attrs.interpolate);
          chart.yAxis.tickFormat(d3.format("n")).showMaxMin(false);
          chart.xAxis.tickFormat(function(d) {
            return scope.versions[d];
          }).showMaxMin(false);
          svg = d3.select(element[0]).append('svg').attr("height", 300);
          nv.utils.windowResize(chart.update);
          return scope.$watch('data', function(data) {
            var d;
            if (data) {
              if (data[0]) {
                scope.versions = (function() {
                  var _i, _len, _ref, _results;
                  _ref = data[0].values;
                  _results = [];
                  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                    d = _ref[_i];
                    _results.push(d.version);
                  }
                  return _results;
                })();
              }
              return svg.datum(data).call(chart).classed('loading', false);
            }
          });
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=line_chart.js.map
*/