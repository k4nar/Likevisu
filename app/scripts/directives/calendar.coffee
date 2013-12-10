angular.module('likevisuApp')
  .directive 'calendar', ($parse) ->
    restrict: "E"
    replace: false
    scope:
      data: "=data"
      boundaries: "=boundaries"
    link: (scope, element, attrs) ->
      cellSize = 10

      day = (d) -> (d.getDay() + 6) % 7
      week = d3.time.format("%W")
      format = d3.time.format("%Y-%m-%d")

      monthPath = (t0) ->
        t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0)
        d0 = +day(t0)
        w0 = +week(t0)
        d1 = +day(t1)
        w1 = +week(t1)
        "M" + (w0 + 1) * cellSize +
          "," + d0 * cellSize + "H" + w0 * cellSize +
          "V" + 7 * cellSize + "H" + w1 * cellSize +
          "V" + (d1 + 1) * cellSize +
          "H" + (w1 + 1) * cellSize +
          "V" + 0 +
          "H" + (w0 + 1) * cellSize +
          "Z"

      color = d3.scale
        .quantize()
        .domain([20, 400])
        .range(colorbrewer.Greens[9])

      scope.$watch 'boundaries', (boundaries) ->
        return if not boundaries

        start = boundaries[0]
        stop = boundaries[1]

        svg = d3.select(element[0])
          .selectAll("svg")
          .data(d3.range(start, stop + 1))
          .enter()
          .append("svg")
          .attr("width", 551)
          .attr("height", 72)
          .append("g")
          .attr("transform", "translate(20, 1)")

        svg.append("text")
          .attr("transform", "translate(-6," + cellSize * 3.5 + ")rotate(-90)")
          .style("text-anchor", "middle")
          .text((d) -> d)

        rect = svg.selectAll(".day")
          .data((d) ->
            d3.time.days new Date(d, 0, 1), new Date(d + 1, 0, 1)
          )
          .enter()
          .append("rect")
          .attr("class", "day")
          .attr("width", cellSize)
          .attr("height", cellSize)
          .attr("x", (d) -> week(d) * cellSize)
          .attr("y", (d) -> day(d) * cellSize)
          .style("fill", "#fff")
          .style("stroke", "#eee")
          .datum(format)

        rect.append("title").text (d) -> d

        svg.selectAll(".month")
          .data((d) ->
            d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1))
          )
          .enter()
          .append("path")
          .attr("class", "month")
          .style("fill", "none")
          .style("stroke", "#ccc")
          .style("stroke-width", "1px")
          .attr("d", monthPath)

        scope.$watch 'data', (data) ->
          return if not data

          rect.filter((d) -> d of data)
            .style("fill", (d) -> color(data[d]))
            .select("title")
            .text((d) -> d + ": " + data[d])
