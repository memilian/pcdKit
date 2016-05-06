package ;

@:expose
class Module {

    @:isVar public var code(default, set) : String = "module = new Const(0);";

    public function set_code(value : String){
        lastEdit = Date.now();
        return code=value;
    }
    public var name(default, null) : String;
    public var thumbnail(default, null) : String = "";
    public var lastEdit(default, null) : Date;

    public function new(name : String) {
        this.name = name;
        lastEdit = Date.now();
    }
}
