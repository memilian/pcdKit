package ;
import kha.Storage;

@:expose
class ProjectManager {

    public static var currentProject(default, null) : Project;
    public static var currentModule(default, null) : Module;

    public static function __init__():Void {
        untyped eventAggregator.subscribe('module-loaded', function(module){
            ProjectManager.currentModule = module;
        });
    }

    public static function getProjects() : Array<String>{
        var projects = Storage.defaultFile().readObject();
        if(projects == null){
            projects = [];
            Storage.defaultFile().writeObject(projects);
        }
        return projects;
    }

    public static function loadProject(name : String) {
        var project : Project =cast Storage.namedFile(name).readObject();
        PcdKit.events.publish('project-loaded', project);
        currentModule = project.getLastModule();
        currentProject = project;
        if(currentModule != null)
            PcdKit.events.publish('module-loaded', currentModule);
        return project;
    }

    public static function createProject(name : String):Project {
        var projects = getProjects();
        var i = 1;
        var newName = name;
        while(projects.indexOf(newName) != -1){
            newName = name+'_$i';
            i++;
        }
        var proj = new Project(newName);
        projects.push(newName);
        Storage.defaultFile().writeObject(projects);
        Storage.namedFile(newName).writeObject(proj);
        return proj;
    }

    public static function saveProject(project:Project):Void {
        Storage.namedFile(project.name).writeObject(project);
        trace('project saved');
    }

    public static function deleteProject(name : String):Void {
        Storage.namedFile(name).writeObject({});
        var projects = getProjects();
        if(projects.indexOf(name) > -1){
            projects.splice(projects.indexOf(name),1);
            Storage.defaultFile().writeObject(projects);
        }
    }
}
