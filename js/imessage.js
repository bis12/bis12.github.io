$(document).ready(function() {
    var chart = c3.generate({
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
                max: 60
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
});
