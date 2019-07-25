var formidable = require('formidable'),
    http = require('http'),
    util = require('util');

http.createServer(function(req, res) {
  if (req.url == '/upload' && req.method.toLowerCase() == 'post') {
    // parse a file upload
    var form = new formidable.IncomingForm();
    form.keepExtensions = true;
    form.hash = 'sha1';

    form.parse(req, function(err, fields, files) {
      res.writeHead(200, {'content-type': 'text/json'});
      res.write('{"receivedUpload":"ok"}\n');
      //res.end(util.inspect({fields: fields, files: files}));
      res.end('\n ');
    });

    return;
  }

  // show a file upload form
  res.writeHead(200, {'content-type': 'text/html'});
  res.end(
    '<a href=example.com></a>'
  );
}).listen(8080);
