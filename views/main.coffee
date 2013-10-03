margin = {top: 15, right: 10, bottom: 10, left: 15}
font_size = 10
eps = 10

color = d3.scale.linear().domain([0, 10]).range(["hsl(240, 100%, 90%)",  "hsl(240, 100%, 50%)"]).interpolate(d3.interpolateHsl)

svg = d3.select("div#base").append("svg")
git_table = null

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

drawTable = (rev_path_pairs, ordered_revs, ordered_paths, rev_order, path_order) ->
  revs = _.uniq(rev_path_pairs.map((d) -> d.rev ))
  paths = _.uniq(rev_path_pairs.map((d) -> d.path ))
  max_size = d3.max(rev_path_pairs.map((d) -> d.size*1 ))
  color.domain([0, max_size])

  # size definition =============================================
  widthOuter = (windowWidth() - 50)
  heightOuter = font_size*paths.length
  width  = widthOuter - margin.left - margin.right
  height = heightOuter - margin.top - margin.bottom

  # xScale, yScale definition =============================================
  xScale = d3.scale.ordinal().rangeBands([0, width])
  yScale = d3.scale.ordinal().rangeBands([0, height])

  switch rev_order
    when 'created_at'
      xScale.domain(_.sortBy(revs, (rev)-> ordered_revs.indexOf(rev)))
    when 'normal'
      xScale.domain(revs.sort())
    when 'none'
      xScale.domain(revs)
    else
      alert "Need rev_order=('none', 'created_at' or 'normal') to URL query"
      return

  switch path_order
    when 'created_at'
      yScale.domain(_.sortBy(paths, (path)-> ordered_paths.indexOf(path)))
    when 'normal'
      yScale.domain(paths.sort())
    when 'none'
      yScale.domain(paths)
    else
      alert "Need path_order=('none', 'created_at' or 'normal') to URL query"
      return

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
      .attr(
        "text-anchor": "start"
        "font-size": font_size
        "fill": (path)-> "black"
        "x": (path, i)-> 0
        "y": (path, i)-> yScale(path) + font_size/2 + 1
      )
      .text((d)-> d )
      .each((d)-> label_width = Math.max(label_width, @getBBox().width))

  git_table = base.selectAll("rect.git-table")
                  .data(rev_path_pairs)
                  .enter()
                  .append("rect")

  git_table.attr(
              "class": "git-table"
              "width": width / revs.length
              "height": height / paths.length
              "fill": (d)-> color(d.size)
              "title": (d) -> d.size + " byte (" + d.rev + " | " + d.path + ")"
              "x": (d, i)-> label_width + xScale(d.rev)
              "y": (d, i) -> yScale(d.path)
            )

getRevPathPairs = (range, func)->
  d3.csv("/rev_path_list.csv?revision=" + escape(range), func)

getRevs = (range, func)->
  d3.csv("/revs.csv?revision=" + escape(range), (ds)-> func(_.pluck(ds, 'rev')))

getPaths = (range, func)->
  d3.csv("/dictionary_orderd_paths.csv?revision=" + escape(range), (ds)-> func(_.pluck(ds, 'path')))

# button =====================================
d3.select("#colorize").on 'click', ()->
  git_table.attr("fill": (d)-> color(d.size) )

start_loc = (getParam('start_loc') || 954)*1
start_revision = getParam('revision')
step = getParam('step') || 1

all_rev_path_pairs = []
current_loc = start_loc
d3.select("#step").on 'click', ()->
  range = start_revision + "~" + current_loc*step + ".." + start_revision + "~" + (current_loc-1)*step
  all_range = start_revision + "~" + start_loc*step + ".." + start_revision + "~" + (current_loc-1)*step
  getRevs all_range, (ordered_revs)->
    getPaths all_range, (ordered_paths)->
       getRevPathPairs range, (new_rev_path_pairs)->
         all_rev_path_pairs = _.uniq(all_rev_path_pairs.concat(new_rev_path_pairs))
         drawTable(all_rev_path_pairs, ordered_revs, ordered_paths, getParam('rev_order'), getParam('path_order'))
  current_loc -= 1

# =============================================
