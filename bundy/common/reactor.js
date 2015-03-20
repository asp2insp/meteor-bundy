getComposite = function(keyPath) {
  var obj = Session.get(_.first(keyPath))
  _.forEach(_.rest(keyPath), function(key) {
    obj = obj != undefined ? obj[key] : undefined;
  });
  return obj
}


setComposite = function(keyPath, value) {
  var rootObj = Session.get(_.first(keyPath)) || {};
  var obj = rootObj;
  var trimmedArray = _.rest(_.initial(keyPath));
  _.forEach(trimmedArray, function(key, i, keyPath) {
    if (obj[key] == undefined) {
      // Check for an array key
      if (i < keyPath.length - 1 && keyPath[i+1].match(/\d+/))
        obj[key] = [];
      else
        obj[key] = {};
    }
    obj = obj[key];
  });
  obj[_.last(keyPath)] = value;
  Session.set(_.first(keyPath), rootObj);
}

prefix = function(el, keyPath) {
  keyPath = keyPath || [];
  if (el != undefined) {
    return [el].concat(keyPath)
  }
  return keyPath
}