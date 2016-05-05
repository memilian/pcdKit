package ;

@:expose
class Project {

    public var name (default, null): String;
    public var date (default, null): Date;
    public var modules (default, null): Array<Module> = [];

    public function new(name : String) {
        this.name = name;
        this.date = Date.now();
    }

    public function save():Void {
        this.date = Date.now();
        ProjectManager.saveProject(this);
    }

    public function getLastModule(): Module {
        var mostRecent : Module = null;
        var higherStamp : Float = 0;
        for(mod in modules){
            if(mod.lastEdit.getTime() > higherStamp){
                higherStamp = mod.lastEdit.getTime();
                mostRecent = mod;
            }
        }
        return mostRecent;
    }

}
