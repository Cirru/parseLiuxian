1 + 2;
console['log']("hello world");
var a = 3;
console['log'](a = 1 + 2 + 2 + 3);
var b = [1, 2, 4, [1, 2, 4]];
console['log']({
    a: 3,
    b: '33'
});
var ss = true;

function aa(a, b) {
    console['log'](true);
};
if (4 > 3) {
    console['log']("4>3");
} else if (4 > 5) {
    console['log']("4>5");
} else {
    console['log']('else');
};
a = 5;
while (a > 3) {
    console['log'](3);
    a = a - 1;
};
for (var _i in [1, 2, 444]) {
    a = [1, 2, 444][_i];
    delete _i;
    console['log'](a);
};
console['log']('\nmore testing');
console['log'](3, [2]);
var a = {
    a: 2,
    make_0obj: 3,
    func: function a(b) {
        return (b + 1);
    }
};
console['log'](a['func'](3));
console['log'](a['make_0obj']);
a.a(b).a();
[1, 2]['call']('2');