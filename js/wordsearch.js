$(document).ready(function() {

    // Frequency of words by length
    c3.generate({
        bindto: '#wordsearch-fig2>div',
        data: {
            url: '/data/wordsearch.json',
            type: 'bar',
            mimeType: 'json'
        },
        axis: {
            x: {
                label: 'Length of word'
            },
            y: {
                label: 'Frequency of words of that length',
            }
        }
    });
});
