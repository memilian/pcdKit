package ;

class RendererOptions {
    public var planetShape : Bool = true;
    public var atmosphere : Bool = true;
    public var seamless : Bool = false;
    public var atmosphereColor : kha.Color = 0xffffff;
    public var backgroundColor : kha.Color = 0x00ffaa;
    public var size : Int = 128;
    public var gradient : Gradient = GradientPresets.grayScale();

    public function new() {
    }
}
