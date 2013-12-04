'use strict'

angular.module('likevisuApp')
  .directive 'topChart', ($parse) ->
    restrict: "E"
    replace: false
    scope:
      data: "=data"

    link: (scope, element, attrs) ->
      nv.addGraph ->
        chart = nv.models.multiBarHorizontalChart()
          .x((d) -> d.name)
          .y((d) -> d.count)
          .margin(top: 30, right: 20, bottom: 50, left: 175)
          .showValues(true)
          .tooltips(false)
          .showControls(false)
          .valueFormat(d3.format("n"))

        chart.yAxis
          .tickFormat(d3.format("n"))

        svg = d3.select(element[0])
          .append('svg')
          .attr("height", 300)

        nv.utils.windowResize chart.update

        scope.$watch 'data', (data) ->
          svg
            .datum(data)
            .call(chart)
