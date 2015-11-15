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
});
