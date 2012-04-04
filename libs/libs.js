var f1, f2;

f1 = function() {
  return console.log('this is f1');
};

f2 = function(x) {
  return console.log("here fs with" + x);
};

liuxian.f1 = f1;

liuxian.f2 = f2;
