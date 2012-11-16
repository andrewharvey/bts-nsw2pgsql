/* TODO
   highlight the mouse over station in all other tables
   colour transactions as linear scale
   include bar line next to transaciton number for visual
   background of each table indicitative of total tranactions for that table
   colour line by iconic line colour
   add rand numbers as col0
   search for station (with autocomplete dropdown) which scrolls each table with that station at the top
*/ 

function tabulate(data, header, select) {
  var table = d3.select(select).append("table").classed("table", true),
      thead = table.append("thead"),
      tbody = table.append("tbody");

  // append the header row
  thead.append("tr")
      .selectAll("th")
      .data(header)
      .enter()
      .append("th")
          .text(function(column) { return column; });

  // create a row for each object in the data
  var rows = tbody.selectAll("tr")
      .data(data)
      .enter()
      .append("tr")
      .on("mouseover", function() {
          d3.select(this).style("background-color", "aliceblue");
          // highlight this station on the map
          //mapHighlight(
          //  d3.select(this)
          //    .selectAll("td").data()[1]
          //  )
          }
        )
      .on("mouseout", function(){
          d3.select(this).style("background-color", "");
          // clear map highlights
          //mapHighlight(undefined);
          }
        );

  function lineColor(line) {
    line = line.toLowerCase().replace(" ", "-", "g");
    switch (line) {
      case "cdb":
        return "black";
      case "eastern-suburbs":
      case "illawarra":
        return "#0008C4";
      case "airport":
      case "east-hills":
        return "green";
      case "bankstown":
        return "orange";
      case "south":
        return "#15ACC0";
      case "olympic-park":
        return "grey";
      case "western":
        return "#B6B600";
      case "carlingford":
        return "darkblue";
      case "inner-west":
        return "lightpurple";
      case "northern-via-strathfield":
      case "northern-via-macquarie-park":
        return "red";
      case "north-shore":
        return "#B6B600";
      case "south-coast":
        return "#0008C4";
      case "southern-highlands":
        return "green";
      case "blue-mountains":
        return "#FFD600";
      case "central-coast":
      case "newcastle":
        return "red";
      case "hunter":
        return "purple";
    }
  }
  
  var maxValue = d3.max(
    data.map(
      function(d) {
        return parseFloat(d[2]);
      }
    )
  );
  
  var tdWidth = 92;

  // create a cell in each row for each column
  var cells = rows.selectAll("td")
      .data(function(d) { return d; })
      .enter()
      .append("td")
      .style("color", lineColor) // FIXME .classed can't be passed a function for name, so we can't just use classes. Actually just use .attr instead with name=class and value=your function which maps the name to the class name
      .text(function(d) { return d; });
//      .select(function(i) {return (i == 0) || undefined;})
/*        .append("svg")
          .attr("height", 10)
          .attr("width", function(d) { return tdWidth * d/145000; })
            .append("rect")
            .attr("class", "bar")
            .attr("height", 10)
            .attr("width", function(d) { return tdWidth * d/145000; });
            */
  return table;
}

var header = ["Rank", "Line", "Station", "Transactions"];

["in", "out", "total"].forEach(function (direction) {
  ["sunrise", "morning", "noon", "afternoon", "sunset", "24"].forEach(function (time) {
    var time_filename;
    switch (time) {
      case "sunrise":
        time_filename = "0200-0600";
        break;
      case "morning":
        time_filename = "0600-0930";
        break;
      case "noon":
        time_filename = "0930-1500";
        break;
      case "afternoon":
        time_filename = "1500-1830";
        break;
      case "sunset":
        time_filename = "1830-0200";
        break;
      case "24":
        time_filename = "total";
        break;
    }
    d3.text("csv/" + direction + "_2004_" + time_filename + ".csv", function(text) {
      var csv = d3.csv.parseRows(text);
      tabulate(csv, header, "#" + direction + "-" + time);
    });
  });
});
