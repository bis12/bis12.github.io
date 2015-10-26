#!bin/phantomjs/phantomjs
var fs = require('fs');
var page = require('webpage').create();
page.paperSize = {
  width: '8.5in',
  height: '11in',
  margin: {
    top: '0.5in',
    left: '0.5in'
  }
};
page.open(fs.workingDirectory + '/resume.html', function() {
  page.render('brian_stack.pdf', {format: 'pdf', quality: '100'});
  phantom.exit();
});

