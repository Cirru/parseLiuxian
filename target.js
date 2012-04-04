if (exports) {
    console.log('begin');
    http = require('http');
    url = 'http://docview.cnodejs.net/learning/coffee/snippets/test_lib/libs.js?js';
    image = url.match(/^(http(s)?:(\/\/)?)?([^/]+)(\/.+)$/);
    if (image) {
        console.log(image);
        var options = {};
        options.host = image[4];
        options.path = image[5];
        var handler = function(res) {
                var data = '';
                res.on('data', function(piece) {
                    data += piece;
                    console.log('data\n');
                })
                res.on('end', function() {
                    liuxian = {};
                    eval(data);
                    var x = liuxian;
                    x['f1']();
                    x['f2'](3);
                })
            }
        console.log('end');
        if (require) {
            var http = require('http');
            http.request(options, handler).end();
        }
    }
};

/* the file at remote writess this:
var f1, f2;

f1 = function() {
  return console.log('this is f1');
};

f2 = function(x) {
  return console.log("here fs with" + x);
};

liuxian.f1 = f1;

liuxian.f2 = f2;
*/