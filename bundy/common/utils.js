flatKeys = function(obj, arr, pre) {
  arr = arr || [];
  pre = pre || '';
  lodash.forEach(obj, function(n, key) {
    if (arr.indexOf(pre+key) == -1) {
      arr.push(pre + key);
      if (n instanceof Object) {
        flatKeys(n, arr, pre + key + '.');
      }
    }
  });
  return arr;
}