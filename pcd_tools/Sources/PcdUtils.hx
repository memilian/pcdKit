package ;

@:expose
@:keepInit
@:keep
class PcdUtils {
    public function new():Void {
        
    }

    public static function khaColorFromArray(cols : Array<Int>){
        return kha.Color.fromBytes(cols[0], cols[1], cols[2], cols[3]);
    }

    public static function khaColorToArray(col : kha.Color){
        return [col.Rb, col.Gb, col.Bb, col.Ab];
    }

    public static function colArrayToCss(col : Array<Int>){
        return 'rgba(${col[0]}, ${col[1]}, ${col[2]}, ${col[3]/255})';
    }

    public static function khaColorToCss(col : kha.Color){
        return 'rgba(${col.Rb}, ${col.Gb}, ${col.Bb}, ${col.Ab});';
    }

    public static  function lerpColor(colA : kha.Color, colB : kha.Color, ratio : Float){
        var res = kha.Color.White;
        var ir = 1-ratio;
        res.R = ir * colA.R + ratio * colB.R;
        res.G = ir * colA.G + ratio * colB.G;
        res.B = ir * colA.B + ratio * colB.B;
        res.A = ir * colA.A + ratio * colB.A;
        return res;
    }
}
