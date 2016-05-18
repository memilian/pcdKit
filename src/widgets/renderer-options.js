/**
 * Created by memilian on 07/05/16.
 */

import {singleton,inject} from 'aurelia-framework';
import {EventAggregator} from 'aurelia-event-aggregator';

@singleton()
@inject(EventAggregator)
export class RendererOptions{

    project = null;
    module=null;
    gradients=null;
    gradientName;
    color;
    backgroundColor;
    atmoColor;

    constructor(events){
        this.eva = events;
        this.eva.subscribe('module-loaded', function(module){
            this.module = module;
            setTimeout(function() {
                this.selectGradient.refresh();
                this.backgroundColor =  PcdUtils.khaColorToArray(this.module.options.backgroundColor);
                this.atmoColor =  PcdUtils.khaColorToArray(this.module.options.atmosphereColor);
            }.bind(this),100);
            if(module === null) return;
            this.gradientName = module.options.gradient == null ? 'grayscale' : module.options.gradient.name;
        }.bind(this));
        this.eva.subscribe('project-loaded', function(proj){
            this.project = proj;
            this.gradients = proj.gradients;
        }.bind(this));
        this.eva.subscribe('refresh', function(proj){
            this.selectGradient.refresh();
            this.module.options.gradient = ProjectManager.currentProject.getGradientNamed(this.gradientName);
        }.bind(this));

        this.eva.subscribe('gradient-changed', function(){
            this.selectGradient.refresh();
        }.bind(this));
    }

    notifyDelayedChanges(){
        setTimeout(function(){
            this.module.options.gradient = ProjectManager.currentProject.getGradientNamed(this.gradientName);
            this.module.options.backgroundColor = PcdUtils.khaColorFromArray(this.backgroundColor);
            this.module.options.atmosphereColor = PcdUtils.khaColorFromArray(this.atmoColor);
            this.notifyChanges();
        }.bind(this), 100);
    }

    notifyChanges(){
        this.eva.publish('options-changed', this.module);
    }

}
