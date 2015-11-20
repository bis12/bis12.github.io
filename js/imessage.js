var punchcard = function(args) {
    var el = d3.select(args.bindto);
    var margin = {top: 30, right: 30, bottom: 20, left: 50};
    var width = el[0][0].offsetWidth - margin.left - margin.right;
    var height = width * (1/1.6) - margin.top - margin.bottom;

    var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    var svg = el.append('svg')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .append('g')
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var x = d3.scale.linear().domain([0, 24]).range([0, width]);
    var y = d3.scale.linear().domain([0, 6]).range([0, height]);

    xAxis = d3.svg.axis().ticks(6).scale(x).orient('top').tickFormat( function(d) { return d + ':00' });
    yAxis = d3.svg.axis().ticks(7).scale(y).orient('left').tickFormat( function(d, i) { return days[i]; });

    svg.append('g').attr("class", "x axis").call(xAxis).selectAll('text').attr("dy", "-.6em");
    svg.append('g').attr("class", "y axis").call(yAxis);


    for (var i in days) {
        svg.append('g')
           .attr("transform", "translate(0," + y(i) + ")")
           .attr("class", "x axis")
           .call(d3.svg.axis().scale(x).ticks(24).tickFormat(''));
    }

    d3.text(args.data, function(error, text) {
        if (error) return console.warn(error);
        var data = d3.csv.parseRows(text)

        svg.append('g')
           .selectAll('g')
           .data(data)
           .enter()
           .append('g')
           .selectAll('g')
           .data( function(d,i,j) { return d; } )
           .enter()
           .append('circle')
           .attr('fill', '#333')
           .attr('class','hover')
           .attr('title', function(d,i,j) { return d })
           .attr('cy', function(d,i,j) { return y(j) })
           .attr('cx', function(d,i,j) { return x(i + 1) })
           .attr('r', function(d,i,j) { return +d * 0.015 });
    });
}

$(document).ready(function() {

    // Plot of people in chat room
    c3.generate({
        bindto: '#imessage-fig1>div',
        data: {
            url: '/data/talkers.json',
            type: 'spline',
            mimeType: 'json'
        },
        axis: {
            x: {
                label: 'Days since Brian was in chat'
            },
            y: {
                label: 'Messages per day',
            }
        },
        grid: {
            x: {
                lines: [
                    {value: 4, text: 'Some holiday with candy'},
                    {value: 11, text: 'Talking about food?'},
                    {value: 15, text: 'Someone gets a new cable box?'}
                ]
            }
        }
    });

    // Plot of everyone I've talked to
    c3.generate({
        bindto: '#imessage-fig2>div',
        data: {
            url: '/data/all_talkers.json',
            type: 'spline',
            mimeType: 'json'
        },
        axis: {
            x: {
                label: 'Weeks since Brian had iPhone'
            },
            y: {
                label: 'Messages per week',
            }
        }
    });

    // Punchcard for text times
    punchcard({
        bindto: '#imessage-fig3>div',
        data: '/data/punchcard.csv'
    });
});
