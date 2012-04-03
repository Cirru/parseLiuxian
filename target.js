1 + 2;
console.log("hello world");
var a = 3;
console.log(a = 1 + 2 + 2 + 3);
var b = [1, 2, 4, [1, 2, 4]];
console.log({
    a: 3,
    b: '33'
});
var ss = true;

function aa(a, b) {
    console.log(true);
};
if (4 > 3) {
    console.log("4>3");
} else if (4 > 5) {
    console.log("4>5");
} else {
    console.log('else');
};
a = 5;
while (a > 3) {
    console.log(3);
    a = a - 1;
};
for (var _i = 0; _i < [1, 2, 3].length; _i++) {
    a = [1, 2, 3][_i];
    delete _i;
    console.log(a);
};
console.log('fabonaci test');
var f = function n(a) {
        if (a < 2) {
            return (1);
        } else {
            return (f(a - 1) + f(a - 2));
        };
    };
console.log(f(10));