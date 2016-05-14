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
    var size : Int;
    var radius : Int;
    var currRow : Int;
    var options : RendererOptions;
    public var texture(default, null) : Image;

    public function new(mq : MessageQueue<TexGenMessage>) {
        this.mq = mq;
        mq.receiver.receive = function(msg : TexGenMessage){
            switch(msg){
                case Generate(mod, options, tex) :
                    this.module = mod;
                    this.gradient = options.gradient;
                    this.size = options.size;
                    this.options = options;
                    this.radius = Math.ceil(size/2);
                    this.currRow = 0;
                    texture = tex;//kha.Image.createRenderTarget(dim, dim, TextureFormat.RGBA32, NoDepthAndStencil, 8);
                    CallMe.later(process);
                case Result(_):
            }
        };
    }

    public function process():Void {
        try{
            var g = texture.g2;
            if(currRow == 0)
                g.begin(true, options.backgroundColor);
            else
                g.begin(false);
            var radSq = radius * radius;
            var b = currRow;

            for (a in 0...size) {
                var as = a - radius;
                var bs = b - radius;
                var pSq = (as * as + bs * bs); //squared pixel distance to center
                if (options.planetShape && pSq > radSq) {
                    g.color = Color.fromBytes(0,0,0,0);
                    g.drawRect(a, b, 1, 1);
                    continue;
                }

                var x = as;
                var z = bs;
                var y = options.planetShape ? Math.sqrt(radius * radius - as * as - bs * bs) : 1;//rad * Math.cos(theta);
                var value:Float = thx.Floats.clamp(module.getValue(x, z, y), -1, 1) / 2 + 0.5;
                var color = gradient.getColor(value);

                var atmoRatio = 1.;
                var atmoSize = 0.05 * radSq;
                if (options.planetShape && options.atmosphere && pSq > radSq - 2 * atmoSize) {
                    if(pSq >= radSq - atmoSize) { //outer atmosphere
                        atmoRatio = (radSq - pSq) / atmoSize;
                        color = PcdUtils.lerpColor(options.backgroundColor, options.atmosphereColor, atmoRatio);
                    }else { //inner atmosphere
                        atmoRatio = (radSq - pSq - atmoSize) / atmoSize;
                        color = PcdUtils.lerpColor(options.atmosphereColor, color, atmoRatio);
                    }
                }


                g.color = color;
                g.drawRect(a, b, 1, 1);
            }
            g.end();

            if(currRow++ < size){
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
    Generate(moduleBase : ModuleBase, options : RendererOptions, texture : Image);
    Result(texture : Image);
}
