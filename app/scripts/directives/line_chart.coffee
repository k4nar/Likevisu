'use strict'

angular.module('likevisuApp')
  .directive 'lineChart', ($parse) ->
    restrict: "E"
    replace: false
    scope:
      data: "=data"

    link: (scope, element, attrs) ->
      format = d3.time.format("%Y-%m-%d")

      nv.addGraph ->
        chart = nv.models.lineChart()
          .x((d) -> d3.time.format.iso.parse(d.date))
          .y((d) -> d.count)

        chart.yAxis
          .tickFormat(d3.format("n"))

        chart
          .xAxis.tickFormat((d) -> format(new Date(d)))

        svg = d3.select(element[0])
          .append('svg')
          .attr("height", 300)

        nv.utils.windowResize chart.update

        scope.$watch 'data', (data) ->
          svg
            .datum(data)
            .call(chart)
