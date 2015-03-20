flatKeys = function(obj, arr, pre) {
  var arr = arr || [];
  var pre = pre || [];
  lodash.forEach(obj, function(n, key) {
    var keyPath = _.cloneDeep(pre);
    keyPath.push(key);
    if (arr.indexOf(keyPath) == -1) {
      arr.push(keyPath);
      if (n instanceof Object) {
        flatKeys(n, arr, keyPath);
      }
    }
  });
  return arr;
}