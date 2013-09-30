var color = d3.scale.linear().domain([0, 10]).range(["hsl(300, 100%, 50%)",  "hsl(120, 100%, 50%)"]).interpolate(d3.interpolateHsl);

var svg = d3.select("body").append("svg");

svg.selectAll('rect.color-table')
   .data(d3.range(10))
   .enter()
   .append('rect')
   .attr('class', 'color-table')
   .attr('width', 10)
   .attr('height', 10)
   .attr('x', function(d){ return 15*d })
   .attr('y', 0)
   .attr('fill', function(d){ return color(d) })
   .each(function(d){ return d });

d3.csv("rev_path.csv", function(data){
  var revs = d3.set(data.map(function(d){ return d.rev })).values();
  var paths = d3.set(data.map(function(d){ return d.path })).values();
  var max_size = d3.max(data.map(function(d){ return d.size*1 }));

  var margin = {top: 15, right: 10, bottom: 10, left: 50},
      font_size = 5,
      eps = 10,
      width =  (window.innerWidth || documentElement.clientWidth || getElementsByTagName('body')[0].clientWidth) - margin.left - margin.right,
      height = font_size*paths.length - margin.top - margin.bottom;

  var xScale = d3.scale.ordinal().domain(revs).rangeBands([0, width]);

  var left_side = {};
  data.forEach(function(obj){
    var x = xScale(obj.rev);
    if(!left_side[obj.path] || (x < left_side[obj.path])){
      left_side[obj.path] = x;
    }
  });

  // pathの表示順序
  if(getParam('order') == 'created_at'){
    paths = _.sortBy(paths, function(path){ return left_side[path] });
  }else{
    paths = paths.sort();
  }

  var yScale = d3.scale.ordinal().domain(paths).rangeBands([0, height]);

  svg.attr("width", width + margin.left + margin.right)
     .attr("height", height + margin.top + margin.bottom);

  var base = svg.append("g")
                .attr("transform", "translate(" + margin.left + ", " + margin.top + ")");

  var xAxis = d3.svg.axis()
                .scale(xScale)
                .orient("top")
                .ticks(0);

  var yAxis = d3.svg.axis()
                .scale(yScale)
                .orient("left")
                .ticks(0);

  base.selectAll("rect.git-history")
      .data(data)
      .enter()
      .append("rect")
      .attr("width", width / revs.length )
      .attr("height", height / paths.length )
      .attr("title", function(d){ return d.size + " byte (" + d.rev + " | " + d.path + ")" })
      .attr("fill", function(d){
        return color(Math.floor(Math.LOG10E * Math.log(d.size)));
      })
      .attr("x", function(d, i){ return xScale(d.rev) })
      .attr("y", function(d, i){ return yScale(d.path) });

  base.selectAll("text.label")
      .data(paths)
      .enter()
      .append("text")
      .attr("text-anchor", "start")
      .attr("font-size", font_size)
      .attr("fill", function(path){ return "black" })
      .attr("x", function(path, i){ return - margin.left })
      .attr("y", function(path, i){ return yScale(path) + font_size/2 + 1 })
      .text(function(d){ return d });
});
