function getComposite(keyPath) {
  var obj = Session.get(_.first(keyPath))
  _.forEach(_.rest(keyPath), function(key) {
    obj = obj != undefined ? obj[key] : undefined;
  });
  return obj
}


function setComposite(keyPath, value) {
  var rootObj = Session.get(_.first(keyPath)) || {};
  var obj = rootObj;
  var trimmedArray = _.rest(_.initial(keyPath));
  _.forEach(trimmedArray, function(key, i, keyPath) {
    if (obj[key] == undefined) {
      // Check for an array key
      if i < keyPath.length - 1 and keyPath[i+1].match(/\d+/)
        obj[key] = [];
      else
        obj[key] = {};
    }
    obj = obj[key];
  });
  obj[_.last(keyPath)] = value;
  Session.set(_.first(keyPath), rootObj);
}

