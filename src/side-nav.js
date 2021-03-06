/**
 * Created by memilian on 03/05/16.
 */

import { inject, singleton} from 'aurelia-framework';
import { MdToastService } from 'aurelia-materialize-bridge';
import { EventAggregator } from 'aurelia-event-aggregator';
import {Modal} from 'widgets/modal';

@singleton()
@inject(MdToastService, EventAggregator, Modal)
export class SideNav{

    loadedProject = null;
    newName = "New Project";
    newGradientName = "New Gradient";
    newModuleName = "New Module";

    curProjectName = "";
    curModuleName = "";
    curGradientName = "";

    constructor(toaster, events, modal){
        this.toaster = toaster;
        this.events = events;
        this.modal = modal;
        this.events.subscribe('project-loaded', this.onprojectloaded.bind(this));
        this.events.subscribe('module-loaded', this.onmoduleloaded.bind(this));
    }

    onprojectloaded(project){
        if(project === {}) project = null;
        if(project !== null)
            this.toaster.show(project.name+' loaded', 1000);
        else
            this.toaster.show('Could not load '+project.name,2000);
        this.loadedProject = project;
        this.module = this.loadedProject.currentModule;
        this.curProjectName = name;
    }

    onmoduleloaded(module){
        this.curModuleName = module.name;
        this.events.publish('editor-mode', "CODE");
    }

    newProject(){
        let proj = ProjectManager.createProject(this.newName);
        this.loadProject(proj.name);
        this.newName = 'New Project';
    }

    loadProject(name){
        if(this.loadedProject != null)
            this.loadedProject.save();
        ProjectManager.loadProject(name);
    }

    deleteProject(name){
        this.modal.trigger({
            header : "Warning",
            content: "Really delete project "+name+" ? It will be lost forever ..."
        }, function() {
            if (name !== null) {
                ProjectManager.deleteProject(name);
                this.loadedProject = null;
            }
        }.bind(this));
    }

    newModule(){
        this.newModuleName = this.loadedProject.getUniqueModuleName(this.newModuleName);
        let module = new Module(this.newModuleName);
        this.loadedProject.modules.push(module);
        this.newModuleName = 'New Module';
        this.loadModule(module);
    }

    deleteModule(module){
        this.modal.trigger({
            header : "Warning",
            content: "Really delete module "+module.name+" ? It will be lost forever ..."
        }, function() {
            if (module !== null) {
                this.loadedProject.modules.splice(this.loadedProject.modules.indexOf(module), 1);
                this.loadedProject.save();
                this.events.publish('module-loaded', null);
            }
        }.bind(this));
    }

    loadModule(module){
        this.loadedProject.save();
        this.events.publish('module-loaded', module);
    }

    newGradient(){
        this.newGradientName = this.loadedProject.getUniqueGradientName(this.newGradientName);
        let gradient = new Gradient(this.newGradientName);
        this.loadedProject.gradients.push(gradient);
        this.newGradientName = 'New Gradient';
        this.loadGradient(gradient);
    }

    deleteGradient(gradient){
        this.modal.trigger({
            header : "Warning",
            content: "Really delete gradient "+gradient.name+" ? It will be lost forever ..."
        }, function() {
            if (gradient !== null) {
                this.loadedProject.gradients.splice(this.loadedProject.gradients.indexOf(gradient), 1);
                this.loadedProject.save();
                this.events.publish('gradient-loaded', null);
                this.events.publish('gradient-changed', null);
            }
        }.bind(this));
    }

    loadGradient(gradient){
        this.loadedProject.save();
        this.events.publish('gradient-loaded', gradient);
        this.events.publish('gradient-changed', gradient);
        this.events.publish('editor-mode', "GRADIENT");
        this.curGradientName = gradient.name;
    }

    detached(){
        if(this.loadedProject!=null) {
            this.loadedProject.save();
        }
    }

    get projects(){
        try {
            return ProjectManager.getProjects();
        }catch(ex){
            return [];
        }
    }
}