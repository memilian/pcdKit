package ;

import js.RegExp;
import haxe.ds.StringMap;
import Lambda;
using Lambda;

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

    public function getUniqueModuleName(name):String {
        var i = 1;
        var reg = new EReg("[^A-Z0-9-]", "gi");
        name = reg.replace(name, '_');
        var newName = name;
        var ok = false;
        while(!ok){
            ok = true;
            for(module in modules){
                if(module.name == newName){
                    ok = false;
                    newName = name+'_$i';
                    i++;
                }
            }
        }
        return newName;
    }

    public function getModuleNamed(name : String):Module {
        for(module in modules){
            if(module.name == name) return module;
        }
        return null;
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
