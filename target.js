var url = 'docview.cnodejs.net/projects/parseLiuxian/libs/libs.js?js';
url = url;
if ((typeof exports) != 'undefined') {
    http = require('http');
    image = url.match(/^(http(s)?:(\/\/)?)?([^/]+)(\/.+)$/);
    if ((typeof image) != 'undefined') {
        var options = {};
        options.host = image[4];
        options.path = image[5];
        var handler = function(res) {
                var data = '';
                res.on('data', function(piece) {
                    data += piece;
                });
                res.on('end', function() {
                    liuxian = {};
                    eval(data);
                    var x = liuxian;
                    var a = 2;
                    console['log'](a);
                });
            }
        var http = require('http');
        http.request(options, handler).end();
    }
}
if ((typeof window) != 'undefined') {
    // cross-domain http request hard for me...
};