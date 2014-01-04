(function() {
  'use strict';
  angular.module('likevisuApp').directive('topChart', function($parse) {
    return {
      restrict: "E",
      replace: false,
      scope: {
        data: "=data"
      },
      link: function(scope, element, attrs) {
        return nv.addGraph(function() {
          var chart, svg;
          chart = nv.models.multiBarHorizontalChart().x(function(d) {
            return d.name || "Unknown";
          }).y(function(d) {
            return d.count;
          }).margin({
            top: 30,
            right: 20,
            bottom: 50,
            left: 175
          }).showValues(true).tooltips(false).showLegend(false).showControls(false).valueFormat(d3.format("n"));
          chart.yAxis.tickFormat(d3.format("n"));
          svg = d3.select(element[0]).append('svg').attr("height", 300);
          nv.utils.windowResize(chart.update);
          return scope.$watch('data', function(data) {
            if (data) {
              return svg.datum(data).call(chart).classed('loading', false);
            }
          });
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=top_chart.js.map
*/