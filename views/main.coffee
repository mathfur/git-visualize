margin = {top: 15, right: 10, bottom: 10, left: 50}
font_size = 10
eps = 10

color = d3.scale.linear().domain([0, 10]).range(["hsl(300, 100%, 50%)",  "hsl(120, 100%, 50%)"]).interpolate(d3.interpolateHsl)

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

sample_rev = "v0.99~900"

d3.csv "/rev_path_list.csv?revision="+sample_rev, (rev_paths) ->
  d3.csv "/dictionary_orderd_paths.csv?revision="+sample_rev, (ordered_paths) ->
    revs = _.uniq(rev_paths.map((d) -> d.rev ))
    paths = _.uniq(rev_paths.map((d) -> d.path ))
    max_size = d3.max(rev_paths.map((d) -> d.size*1 ))

    width  = windowWidt() - margin.left - margin.right
    height = font_size*paths.length - margin.top - margin.bottom

    # xScale, yScale definition =============================================
    paths = _.sortBy(paths, (path)-> ordered_paths.indexOf(path))

    xScale = d3.scale.ordinal().domain(revs).rangeBands([0, width])
    yScale = d3.scale.ordinal().domain(paths).rangeBands([0, height])

    # width, height definition ==============================================
    svg.attr("width", width + margin.left + margin.right)
       .attr("height", height + margin.top + margin.bottom)

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

    base.selectAll("rect.git-history")
        .data(rev_paths)
        .enter()
        .append("rect")
        .attr("class", "git-history")
        .attr("width", width / revs.length )
        .attr("height", height / paths.length )
        .attr("title", (d) -> d.size + " byte (" + d.rev + " | " + d.path + ")" )
        .attr("fill", (d) -> color(Math.floor(Math.LOG10E * Math.log(d.size))))
        .attr("x", (d, i) -> xScale(d.rev) )
        .attr("y", (d, i) -> yScale(d.path) )

    base.selectAll("text.label")
        .data(paths)
        .enter()
        .append("text")
        .attr("text-anchor", "start")
        .attr("font-size", font_size)
        .attr("fill", (path)-> "black" )
        .attr("x", (path, i)-> - margin.left )
        .attr("y", (path, i)-> yScale(path) + font_size/2 + 1 )
        .text((d) -> d )
