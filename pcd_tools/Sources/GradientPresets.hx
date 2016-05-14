package ;
import kha.Color;
class GradientPresets {
    public static function grayScale():Gradient {
        var grad = new Gradient("grayscale");
        grad.add(0, Color.Black);
        grad.add(1, Color.White);
        return grad;
    }

    public static function earthLike():Gradient {
        var grad = new Gradient("earth like");
        grad.add(0, Color.fromBytes(0,0,128,255));
        grad.add(0.4, Color.fromBytes(128,128,255,255));
        grad.add(0.5, Color.fromBytes(200,200,10,255));
        grad.add(0.501, Color.fromBytes(200,200,10,255));
        grad.add(0.512051, Color.fromBytes(10,128,10,255));
        grad.add(0.8, Color.fromBytes(255,200,128,255));
        grad.add(0.9, Color.fromBytes(96,96,96,255));
        grad.add(1.0, Color.fromBytes(255,255,255,255));
        return grad;
    }
}
