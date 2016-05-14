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
    public var gradients (default, null): Array<Gradient> = [];

    public function new(name : String) {
        this.name = name;
        this.date = Date.now();
        this.gradients.push(GradientPresets.grayScale());
        this.gradients.push(GradientPresets.earthLike());
    }

    public function save():Void {
        this.date = Date.now();
        ProjectManager.saveProject(this);
    }

    private inline function getUniqueNameIn(name, array : Array<INamedItem>){
        var i = 1;
        var reg = new EReg("[^A-Z0-9-]", "gi");
        name = reg.replace(name, '_');
        var newName = name;
        var ok = false;
        while(!ok){
            ok = true;
            for(item in array){
                if(item.name == newName){
                    ok = false;
                    newName = name+'_$i';
                    i++;
                }
            }
        }
        return newName;
    }

    public function getUniqueModuleName(name : String):String {
        return getUniqueNameIn(name, cast modules);
    }

    public function getUniqueGradientName(name : String):String {
        return getUniqueNameIn(name, cast gradients);
    }

    public function getModuleNamed(name : String):Module {
        for(module in modules){
            if(module.name == name) return module;
        }
        return null;
    }

    public function getGradientNamed(name : String):Gradient {
        for(gradient in gradients){
            if(gradient.name == name) return gradient;
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
