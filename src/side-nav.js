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
    }

    newProject(){
        let proj = ProjectManager.createProject(this.newName);
        this.loadProject(proj.name);
        this.newName = 'New Project';
    }

    loadProject(name){
        if(this.loadedProject != null)
            this.loadedProject.save();
        let proj = ProjectManager.loadProject(name);
        if(proj === {}) proj = null;
        if(proj !== null)
            this.toaster.show(proj.name+' loaded', 1000);
        else
            this.toaster.show('Could not load '+proj.name,2000);
        this.loadedProject = proj;
        this.module = this.loadedProject.currentModule;
        this.curProjectName = name;
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
        this.curModuleName = module.name;
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
            }
        }.bind(this));
    }

    loadGradient(gradient){
        this.loadedProject.save();
        this.events.publish('gradient-loaded', gradient);
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