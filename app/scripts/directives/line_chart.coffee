'use strict'

angular.module('likevisuApp')
  .directive 'lineChart', ($parse) ->
    restrict: "E"
    replace: false
    scope:
      data: "=data"

    link: (scope, element, attrs) ->
      nv.addGraph ->
        chart = nv.models.lineChart()
          .x((d, i) -> i)
          .y((d) -> d.count)
          .useInteractiveGuideline(true)
          .interpolate('monotone')

        chart.yAxis
          .tickFormat(d3.format("n"))

        chart.xAxis
          .tickFormat((d) -> scope.versions[d])
          .showMaxMin(false)

        svg = d3.select(element[0])
          .append('svg')
          .attr("height", 300)

        nv.utils.windowResize chart.update

        scope.$watch 'data', (data) ->
          scope.versions = (d.version for d in data[0].values) if data[0]

          svg
            .datum(data)
            .call(chart)
