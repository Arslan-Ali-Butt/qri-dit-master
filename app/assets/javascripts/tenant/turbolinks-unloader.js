// courtesy of https://gist.github.com/jbourassa/6529382
var Unloader = (function() {
  var handlers = [];
 
  var runNative = function() {
    return findMessage();
  };
 
  var findMessage = function() {
    var message;
    for(var i = 0; i < handlers.length; i++) {
      message = handlers[i]();
 
      if(message) break;
    }
    return message;
  };
 
  var runTurboLinks = function(e) {
    var message = findMessage(),
        confirmResult;
    if(message) {
      confirmResult = confirm(message);
      if(confirmResult) {
        handlers = [];
      }
      return confirmResult;
    }
    else {
      handlers = [];
      return true;
    }
  };
 
  var clearOnce = function() {
    once = [];
  };
 
  var Unloader = {
    init: function() {
      this.destroy();

      window.onbeforeunload = runNative;
      $(window).on('page:before-change', runTurboLinks);
    },
    register: function(fn) {
      handlers.push(fn);
    },
    unregister: function(fn) {
      for(var i = 0; i < handlers.length; i++) {
        if(handlers[i] == fn) {
          handlers.splice(i, 1);
        }
      }
    },
    destroy: function() {
      window.onbeforeunload = undefined;
      $(window).off('page:before-change');
    }
  };
 
  return Unloader;
})();

