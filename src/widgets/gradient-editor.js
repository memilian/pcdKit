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
    handleH=25;
    points=[];

    constructor(eva){
        this.eva = eva;
        this.eva.subscribe('gradient-loaded', this.onload.bind(this));
    }

    onload(gradient){
        this.points = [];
        this.colors = {};
        for(let pt of gradient.values){
            this.colors[pt._0] = PcdUtils.khaColorToArray(pt._1);
            this.points.push({
                value:pt._0,
                color:PcdUtils.khaColorToArray(pt._1),
                y:(this.height-this.height*pt._0-this.handleH),
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
                this.movePoint(evt, point);
            }.bind(this)
        });
    }

    movePoint(evt, point){
        console.log(evt,point);
        let dy = evt.dy;
        let newY = Math.min(this.height-this.handleH,Math.max(-this.handleH,point.y+dy));
        point.value = Math.floor(1000*(1-(newY+this.handleH)/this.height))/1000;
        point.oPt._0 = point.value;
        point.y = (this.height-this.height*point.oPt._0-this.handleH);
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