margin = {top: 15, right: 10, bottom: 10, left: 15}
font_size = 10
eps = 10

color = d3.scale.linear().domain([0, 100]).range(["hsl(300, 100%, 50%)",  "hsl(120, 100%, 50%)"]).interpolate(d3.interpolateHsl)

svg = d3.select("body").append("svg")

svg.selectAll('rect.color-table')
   .data(d3.range(10))
   .enter()
   .append('rect')
   .attr('class', 'color-table')
   .attr('width', 10)
   .attr('height', 10)
   .attr('x', (d) -> 15*d )
   .attr('y', 0)
   .attr('fill', (d) -> color(d) )
   .each((d) -> d )


drawTable = (rev_paths, ordered_paths, order) ->
  revs = _.uniq(rev_paths.map((d) -> d.rev ))
  paths = _.uniq(rev_paths.map((d) -> d.path ))
  max_size = d3.max(rev_paths.map((d) -> d.size*1 ))

  widthOuter = (windowWidth() - 50)
  heightOuter = font_size*paths.length
  width  = widthOuter - margin.left - margin.right
  height = heightOuter - margin.top - margin.bottom

  # xScale, yScale definition =============================================
  if order == 'created_at'
    paths = _.sortBy(paths, (path)-> ordered_paths.indexOf(path))
  else if order == 'normal'
    paths = paths.sort()
  else
    alert "Need order=('created_at' or 'normal') to URL query"
    return

  xScale = d3.scale.ordinal().domain(revs).rangeBands([0, width])
  yScale = d3.scale.ordinal().domain(paths).rangeBands([0, height])

  # width, height definition ==============================================
  svg.attr("width", widthOuter)
     .attr("height", heightOuter)

  base = svg.append("g")
            .attr("transform", "translate(" + margin.left + ", " + margin.top + ")")

  xAxis = d3.svg.axis()
                .scale(xScale)
                .orient("top")
                .ticks(0)

  yAxis = d3.svg.axis()
                .scale(yScale)
                .orient("left")
                .ticks(0)

  _.each(paths, (path, i) ->
    base.append("rect")
        .attr(
          "x": 0
          "y": yScale(path)
          "width": widthOuter
          "height": height / paths.length
          "fill": if (i % 2 == 0) then "#fff" else "#eee"
        ))

  label_width = 0
  base.selectAll("text.label")
      .data(paths)
      .enter()
      .append("text")
      .attr("text-anchor", "start")
      .attr("font-size", font_size)
      .attr("fill", (path)-> "black" )
      .attr("x", (path, i)-> 0 )
      .attr("y", (path, i)-> yScale(path) + font_size/2 + 1 )
      .text((d)-> d )
      .each((d)-> label_width = Math.max(label_width, @getBBox().width))

  base.selectAll("rect.git-history")
      .data(rev_paths)
      .enter()
      .append("rect")
      .attr("class", "git-history")
      .attr("width", width / revs.length )
      .attr("height", height / paths.length )
      .attr("title", (d) -> d.size + " byte (" + d.rev + " | " + d.path + ")" )
      .attr("fill", (d) -> color(d.size % 100))
      .attr("x", (d, i) -> label_width + xScale(d.rev) )
      .attr("y", (d, i) -> yScale(d.path) )

start_revision = getParam('revision')
unless start_revision
  alert "Need revision=(SHA1, branch or tag) to URL query"
else
  d3.csv "/rev_path_list.csv?revision="+start_revision, (rev_paths) ->
    d3.csv "/dictionary_orderd_paths.csv?revision="+start_revision, (ordered_paths) ->
      drawTable rev_paths, ordered_paths, getParam('order')
