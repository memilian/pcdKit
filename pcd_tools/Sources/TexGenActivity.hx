package ;

import builders.NoiseMapBuilderSphereByRow;
import builders.NoiseMapBuilderPlaneByRow;
import builders.IRowBuilder;
import libnoise.Utils;
import libnoise.builder.NoiseMap;
import libnoise.builder.NoiseMapBuilderPlane;
import libnoise.builder.NoiseMapBuilder;
import kha.Color;
import kha.graphics4.TextureFormat;
import kha.Image;
import activity.MessageQueue;
import libnoise.ModuleBase;
import activity.CallMe;

class TexGenActivity {

    var sum = 0;
    public var mq : MessageQueue<TexGenMessage>;

    var noiseMapBuilder : NoiseMapBuilderByRow;
    var noiseMap : NoiseMap;

    var module : ModuleBase;
    var gradient : Gradient;
    var size : Int;
    var radius : Int;
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
                    if(options.planetShape){
                        var builder = new NoiseMapBuilderSphereByRow();
                        builder.sourceModule = this.module;
                        builder.setDestSize(size, size);
                        builder.setBounds(-90,90,-180,180);
                        this.noiseMapBuilder = cast builder;
                    }else{
                        var builder = new NoiseMapBuilderPlaneByRow();
                        builder.sourceModule = this.module;
                        builder.setDestSize(size, size);
                        builder.setBounds(0,0,256,256);
                        builder.isSeamlessEnabled = true;
                        this.noiseMapBuilder = cast builder;
                    }
                    noiseMap = new NoiseMap(size,size);
                    noiseMapBuilder.destNoiseMap = noiseMap;

                    texture = tex;//kha.Image.createRenderTarget(dim, dim, TextureFormat.RGBA32, NoDepthAndStencil, 8);
                    CallMe.later(process);
                case Result(_):
            }
        };
    }

    public function process():Void {
        try{

            noiseMapBuilder.callback = function(row){
                var g = texture.g2;
                if(noiseMapBuilder.curRow == 0)
                    g.begin(true, options.backgroundColor);
                else
                    g.begin(false);

                for(x in 0...size){
                    var value = Utils.Clampf(noiseMap.getValue(x,row), -1,1) / 2 + 0.5;
                    var color = gradient.getColor(value);
                    g.color = color;
                    g.drawRect(x, row, 1, 1);
                }
                g.end();
            }
            if(!noiseMapBuilder.buildNext()){
                //if(currRow %2 == 0)
                    CallMe.soon(process);
               // else{
                 //   CallMe.immediately(process);
               // }
            }
                /*if(currRow++ < size){
                if(currRow %2 == 0)
                    CallMe.soon(process);
                else{
                    CallMe.immediately(process);
                }*/

                /*
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
                    var value:Float = thx.Floats.clamp(module.getValue(x, y, z), -1, 1) / 2 + 0.5;
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
            }*/
        }catch(ex : Dynamic){
            trace(ex);
        }
    }
}

enum TexGenMessage{
    Generate(moduleBase : ModuleBase, options : RendererOptions, texture : Image);
    Result(texture : Image);
}
