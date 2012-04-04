var a = [1, 2, 3, 4, 5];
var a = 4;
if (a > 3) {
    console['log'](true);
} else if (a > 0) {
    console['log']('still positive');
} else {
    console['log'](false);
};
while (a > 0) {
    console['log'](a);
    var a = a - 1;
};
var x = function f(a) {
        return (a + 1);
    };
var ll = function f(data) {
        console['log'](data);
    };
ll(3);
var x = {
    a: 2,
    c: ll
};
x['c']('output: ');
ll('failed to make it in 404**404 times'.replace(3, 4).substr(1, 2));
'failed' ['substr'](1, 2);
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
                    var liuxian = {};
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