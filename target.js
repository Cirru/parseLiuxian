var url = 'docview.cnodejs.net/projects/parseLiuxian/libs/libs.js?js';
if (exports) {
    console.log('begin');
    http = require('http');
    url = url;
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