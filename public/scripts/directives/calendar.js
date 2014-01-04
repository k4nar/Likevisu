(function() {
  angular.module('likevisuApp').directive('calendar', function($parse) {
    return {
      restrict: "E",
      replace: false,
      scope: {
        data: "=data",
        boundaries: "=boundaries"
      },
      link: function(scope, element, attrs) {
        var cellSize, color, day, format, monthPath, week;
        cellSize = 10;
        day = function(d) {
          return (d.getDay() + 6) % 7;
        };
        week = d3.time.format("%W");
        format = d3.time.format("%Y-%m-%d");
        monthPath = function(t0) {
          var d0, d1, t1, w0, w1;
          t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0);
          d0 = +day(t0);
          w0 = +week(t0);
          d1 = +day(t1);
          w1 = +week(t1);
          return "M" + (w0 + 1) * cellSize + "," + d0 * cellSize + "H" + w0 * cellSize + "V" + 7 * cellSize + "H" + w1 * cellSize + "V" + (d1 + 1) * cellSize + "H" + (w1 + 1) * cellSize + "V" + 0 + "H" + (w0 + 1) * cellSize + "Z";
        };
        color = d3.scale.quantize().domain([20, 400]).range(colorbrewer.Greens[9]);
        return scope.$watch('boundaries', function(boundaries) {
          var g, rect, start, stop, svg;
          if (!boundaries) {
            return;
          }
          element.children().remove();
          start = boundaries[0];
          stop = boundaries[1];
          svg = d3.select(element[0]).append("svg").attr("height", (stop - start + 1) * 80).attr("width", 570);
          g = svg.selectAll("g").data(d3.range(start, stop + 1)).enter().append("g").attr("transform", function(d, i) {
            return "translate(20, " + i * 80 + ")";
          });
          g.append("text").attr("transform", "translate(-6," + cellSize * 3.5 + ")rotate(-90)").style("text-anchor", "middle").text(function(d) {
            return d;
          });
          rect = g.selectAll(".day").data(function(d) {
            return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1));
          }).enter().append("rect").attr("class", "day").attr("width", cellSize).attr("height", cellSize).attr("x", function(d) {
            return week(d) * cellSize;
          }).attr("y", function(d) {
            return day(d) * cellSize;
          }).style("fill", "none").style("stroke", "#eee").datum(format);
          rect.append("title").text(function(d) {
            return d;
          });
          g.selectAll(".month").data(function(d) {
            return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1));
          }).enter().append("path").attr("class", "month").style("fill", "none").style("stroke", "#ccc").style("stroke-width", "1px").attr("d", monthPath);
          return scope.$watch('data', function(data) {
            if (!data) {
              return;
            }
            svg.classed('loading', false);
            return rect.filter(function(d) {
              return d in data;
            }).style("fill", function(d) {
              return color(data[d]);
            }).select("title").text(function(d) {
              return d + ": " + data[d] + " commits";
            });
          });
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=calendar.js.map
*/