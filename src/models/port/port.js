// Generated by CoffeeScript 1.10.0
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define('Port', ['Geography', 'Base'], function(Geography, Base) {
    var Port;
    return Port = (function(superClass) {
      extend(Port, superClass);

      function Port(coord, nodeId, name) {
        this.coord = coord;
        this.nodeId = nodeId;
        this.name = name;
        Port.__super__.constructor.call(this);
        return;
      }

      Port.prototype.draw = function() {
        var portCoord, radius;
        if (this.name) {
          portCoord = app.coordinateToView(this.coord);
          if (this.name) {
            app.ctx.fillStyle = 'red';
            radius = 5;
          } else {
            app.ctx.fillStyle = 'black';
            radius = 3;
          }
          app.ctx.beginPath();
          app.ctx.arc(portCoord.x, portCoord.y, radius * app.state.zoom, 0, 2 * Math.PI, false);
          app.ctx.fill();
          app.ctx.fillText(this.nodeId, portCoord.x + 10, portCoord.y + 10);
          return;
        }
      };

      return Port;

    })(Geography);
  });

}).call(this);
