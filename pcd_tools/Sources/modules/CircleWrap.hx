package modules;

import libnoise.ModuleBase;

class CircleWrap extends ModuleBase{

    var d : Float;
    var PI = 3.14159;
    var DEG_TO_RAD = 0.017;

    public function new(inp : ModuleBase, diam : Float) {
        super(1);
        set(0,inp);
        this.d = diam;
    }

    override public function getValue(x : Float, y : Float, z : Float):Float {
        var innerR = 256;
        var outerR = 512;
        var TWO_PI = 2 * PI;
        var u = TWO_PI * x/d;
        var v = TWO_PI * z/d;
        var _x = Math.cos(u) * (innerR * Math.cos(v) + outerR);
        var _y = Math.sin(u) * (innerR * Math.sin(v) + outerR);
        var _z = innerR * Math.sin(u);
        return get(0).getValue(_x, _y, _z);
//        return get(0).getValue(Math.cos(2*PI*x/256)*xRad, Math.sin(2*PI*y/256)*yRad,z);
    }
}
