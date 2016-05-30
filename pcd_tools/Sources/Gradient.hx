package ;

import thx.Arrays;
import thx.Tuple.Tuple2;
import kha.Color;

typedef ControlPoint = Tuple2<Float, Color>;

@:expose
class Gradient implements INamedItem{

    public var values:Array<ControlPoint> = [];
    public var name(default, null) : String = "gradient";

    public function new(name : String):Void {
        this.name = name;
    }

    public function add(index:Float, color:Color):Void {
        values.push(new ControlPoint(index, color));
        sort();
    }

    public function remove(index : Float){
        var i = 0;
        var ri = -1;
        for(val in values){
            if(val.left == index) ri = i;
            i++;
        }
        if(ri != -1){
        values.splice(ri,1);
        sort();
        }
    }

    public function sort(){
        values.sort(function(a, b) {
            return a.left > b.left ? 1 : a.left == b.left ? 0 : -1;
        });
    }

    public function getColor(val:Float):Color {
        var low:ControlPoint = null;
        var high:ControlPoint = null;
        var i = 0;
        for (item in values) {
            if (val <= item.left) {
                high = item;
                low = i == 0 ? item : values[i - 1];
                break;
            }
            i++;
        }
        if(high == null)
            return Color.Black;
        if(low.right == high.right)
            return low.right;

        var factor = scale(val, low.left, high.left, 0, 1);
        return Color.fromFloats(
            lerp(low.right.R, high.right.R, factor),
            lerp(low.right.G, high.right.G, factor),
            lerp(low.right.B, high.right.B, factor),
            lerp(low.right.A, high.right.A, factor)
        );
    }

    private function lerp(l:Float, r:Float, t:Float):Float {
        return (1 - t) * l + t * r;
    }

    private function scale(val:Float, min:Float, max:Float, toMin:Float, toMax:Float):Float {
        return toMin + (toMax - toMin) * ((val - min) / (max - min));
    }
}
