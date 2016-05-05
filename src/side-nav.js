/**
 * Created by memilian on 03/05/16.
 */

import { inject } from 'aurelia-framework';
import { MdToastService } from 'aurelia-materialize-bridge';
import { EventAggregator } from 'aurelia-event-aggregator';
import {Modal} from 'widgets/modal';

@inject(MdToastService, EventAggregator, Modal)
export class SideNav{

    loadedProject = null;
    newName = "New Project";
    newModuleName = "New Module";

    constructor(toaster, events, modal){
        this.toaster = toaster;
        this.events = events;
        this.modal = modal;
    }

    newProject(){
        ProjectManager.createProject(this.newName);
        this.newName = 'New Project';
    }

    deleteProject(name){
        ProjectManager.deleteProject(name);
        this.loadedProject = null;
    }

    newModule(){
        let module = new Module(this.newModuleName);
        this.loadedProject.modules.push(module);
        this.loadedProject.save();
        this.newModuleName = 'New Module';
    }

    deleteModule(module){
        this.modal.trigger({
            header : "Warning",
            content: "Really delete module "+module.name+" ? It will be lost forever ..."
        }, function() {
            if (module !== null) {
                this.loadedProject.modules.splice(this.loadedProject.modules.indexOf(module), 1);
                this.loadedProject.save();
            }
        }.bind(this));
    }

    loadModule(module){
        this.events.publish('module-loaded', module);
    }

    loadProject(name){
        let proj = ProjectManager.loadProject(name);
        if(proj === {}) proj = null;
        if(proj !== null)
            this.toaster.show(proj.name+' loaded', 2000);
        else
            this.toaster.show('Could not load '+proj.name,2000);
        this.loadedProject = proj;
    }

    get projects(){
        try {
            return ProjectManager.getProjects();
        }catch(ex){
            return [];
        }
    }
}