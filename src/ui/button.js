// Generated by CoffeeScript 1.10.0
(function() {
  define('Button', ['App'], function(app) {
    var Button;
    return Button = (function() {
      function Button(id, position, text, action, styles, active) {
        this.id = id;
        this.text = text;
        this.action = action;
        this.styles = styles;
        this.active = active;
        this.h = position.h;
        this.w = position.w;
        this.x = position.x;
        this.y = position.y;
      }

      Button.prototype.draw = function() {
        this.style = this.active ? this.styles.active : this.styles.inactive;
        app.ctx.lineWidth = this.style.lw;
        app.ctx.fillStyle = this.style.fill;
        app.ctx.font = 'bold 8pt Calibri';
        app.ctx.fillRect(this.x, this.y - this.style.lw, this.w, this.h);
        app.ctx.strokeRect(this.x, this.y - this.style.lw, this.w, this.h);
        app.ctx.fillStyle = this.style.text;
        app.ctx.fillText(this.text(), this.x + 8, this.y + 16);
      };

      Button.prototype.isClicked = function() {
        var mouseX, mouseY;
        if (this.action && app.state.controls.mouseClicked) {
          mouseX = app.state.controls.mousePosition.x;
          mouseY = app.state.controls.mousePosition.y;
          if (mouseX > this.x && mouseX < this.x + this.w && mouseY > this.y && mouseY < this.y + this.h) {
            this.action();
          }
        }
      };

      Button.prototype.activate = function() {
        this.active = true;
      };

      Button.prototype.deactivate = function() {
        this.active = false;
      };

      return Button;

    })();
  });

}).call(this);
