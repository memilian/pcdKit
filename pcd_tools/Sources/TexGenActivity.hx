package ;

import kha.Color;
import kha.graphics4.TextureFormat;
import kha.Image;
import activity.MessageQueue;
import libnoise.ModuleBase;
import activity.CallMe;

class TexGenActivity {

    var sum = 0;
    public var mq : MessageQueue<TexGenMessage>;

    var module : ModuleBase;
    var gradient : Gradient;
    var radius : Int;
    var totalRows : Int;
    var currRow : Int;
    public var texture(default, null) : Image;

    public function new(mq : MessageQueue<TexGenMessage>) {
        this.mq = mq;
        mq.receiver.receive = function(msg : TexGenMessage){
            switch(msg){
                case Generate(mod,grad,rad, tex) :
                    this.module = mod;
                    this.gradient = grad;
                    this.radius = rad;
                    this.currRow = 0;
                    this.totalRows = 2*rad;
                    var dim: Int = cast Math.ceil(2 * radius);
                    texture = tex;//kha.Image.createRenderTarget(dim, dim, TextureFormat.RGBA32, NoDepthAndStencil, 8);
                    CallMe.later(process);
                case Result(_):
            }
        };
    }

    public function process():Void {
        try{
            var dim: Int = cast Math.ceil(2 * radius);
            var g = texture.g2;
            if(currRow == 0)
                g.begin(true, Color.fromBytes(255,255,255,0));
            else
                g.begin(false);
            var radSq = radius * radius;

            var b = currRow;
            for (a in 0...dim) {
                var as = a - radius;
                var bs = b - radius;
                var pSq = (as * as + bs * bs); //squared pixel distance to center
                if (pSq > radSq) {
                    g.color = Color.fromBytes(0,0,0,0);
                    g.drawRect(a, b, 1, 1);
                    g.end();
                    continue;
                }

                var opacity = 1.;
                var opacityTransition = 0.05 * radSq;
                if (pSq > radSq - opacityTransition) {
                    opacity = (radSq - pSq) / opacityTransition;
                }

                var x = as;
                var z = bs;
                var y = Math.sqrt(radius * radius - as * as - bs * bs);//rad * Math.cos(theta);
                var value:Float = thx.Floats.clamp(module.getValue(x, y, z), -1, 1) / 2 + 0.5;
                var color = gradient.getColor(value);
                color.A = opacity;
                g.color = color;
                g.drawRect(a, b, 1, 1);
            }
            g.end();

            if(currRow++ < totalRows){
                if(currRow %2 == 0)
                    CallMe.soon(process);
                else{
                    CallMe.immediately(process);
                }
            }
        }catch(ex : Dynamic){
            trace(ex);
        }
    }
}

enum TexGenMessage{
    Generate(moduleBase : ModuleBase, gradient : Gradient, radius : Int, texture : Image);
    Result(texture : Image);
}
