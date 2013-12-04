'use strict'

angular.module('likevisuApp')
  .directive 'topChart', ($parse) ->
    restrict: "E"
    replace: false
    scope:
      data: "=data"

    link: (scope, element, attrs) ->
      scope.$watch 'data', (data) ->
        if scope.svg
          scope.svg
            .datum(data)
            .call(scope.chart)
        else
          nv.addGraph ->
            chart = nv.models.multiBarHorizontalChart()
              .x((d) -> d.name)
              .y((d) -> d.count)
              .margin(top: 30, right: 20, bottom: 50, left: 175)
              .showValues(true)
              .tooltips(false)
              .showControls(false)

            svg = d3.select(element[0]).append('svg')

            svg.attr("height", 300)

            svg
              .datum(data)
              .transition()
              .duration(500)
              .call(chart)

            chart.valueFormat d3.format("n")
            chart.yAxis.tickFormat d3.format("n")
            nv.utils.windowResize chart.update

            scope.chart = chart
            scope.svg = svg
            chart
