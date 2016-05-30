/**
 * Created by memilian on 15/05/16.
 */

import {EventAggregator} from 'aurelia-event-aggregator';
import {inject} from 'aurelia-framework';
import interactjs from 'interactjs';

@inject(EventAggregator)
export class GradientEditor{

    colors={};
    gradient=null;
    height= 500;
    handleH=35;
    points=[];

    constructor(eva){
        this.eva = eva;
        this.eva.subscribe('gradient-loaded', this.onload.bind(this));
    }

    onload(gradient){
        this.points = [];
        this.colors = {};
        if(gradient == null) return;
        for(let pt of gradient.values){
            this.colors[pt._0] = PcdUtils.khaColorToArray(pt._1);
            this.points.push({
                value:pt._0,
                color:PcdUtils.khaColorToArray(pt._1),
                y:(this.height-this.height*pt._0-this.handleH/2),
                oPt:pt
            });
        }
        this.gradient = gradient;
        if(this.mainCanvas != null)
            this.updateCanvas();
    }

    setupDrag(elm, point){
        interactjs(elm).draggable({
            onmove:function(evt){
                this.movePoint(evt, point, elm);
            }.bind(this)
        });
    }

    removePoint(point){
        this.gradient.remove(point.value);
        this.eva.publish('gradient-loaded', this.gradient);
        this.eva.publish('refresh');
    }
    newPoint(val){
        if(val == null){
            val = 0.25;
        }
        this.gradient.add(val, PcdUtils.khaColorFromArray([255,255,255,255]));
        this.eva.publish('gradient-loaded', this.gradient);
        this.eva.publish('refresh');
    }

    movePoint(evt, point, elm){
        let colorSel = elm.querySelector('color-selector').au["color-selector"].viewModel;
        colorSel.suspendClick = true;
        let dy = evt.dy;
        let newY = Math.min(this.height-this.handleH/2,Math.max(-this.handleH/2,point.y+dy));
        point.value = Math.floor(1000*(1-(newY+this.handleH/2)/this.height))/1000;
        point.oPt._0 = point.value;
        point.y = (this.height-this.height*point.oPt._0-this.handleH/2);
        this.gradient.sort();
        this.updateValue(point);
    }

    updateCanvas(){
        let ctx = this.mainCanvas.getContext('2d');
        let grad = ctx.createLinearGradient(0,this.height,0,0);
        for(let pt of this.points){
            grad.addColorStop(pt.value, PcdUtils.colArrayToCss(pt.color));
        }
        ctx.fillStyle = grad;
        ctx.fillRect(0,0,this.mainCanvas.width, this.height);
    }

    updateValue(point){
        setTimeout(function() {
            point.oPt._1 = PcdUtils.khaColorFromArray(point.color);
            this.eva.publish('refresh');
            this.updateCanvas();
        }.bind(this),100);
    }

    back(){
        this.eva.publish('editor-mode', 'CODE');
    }
}