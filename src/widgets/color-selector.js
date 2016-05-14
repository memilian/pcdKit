/**
 * Created by memilian on 07/05/16.
 */

import {inject, bindable, bindingMode, computedFrom} from 'aurelia-framework';

@inject(Element)
export class ColorSelectorCustomElement{
    @bindable({ defaultBindingMode: bindingMode.twoWay }) color = [255,255,255,255];
    @computedFrom('color') get colorString(){
        return this.color === undefined ? 'white' : this.getStringColor(this.color);
    };

    width=400;
    height=256;
    active = false;

    mouseX=0;
    mouseY=0;

    constructor(element){
        this.element = element;
    }

    attached() {
        if (this.color === undefined || this.color === null){
            this.color = [255, 255, 255, 255];
        }
        this.container.remove();
        document.body.appendChild(this.container);
        this.mainCanvas.onmousedown = function(evt){
            this.pickColor(evt);
            this.mainCanvas.onmousemove = this.pickColor.bind(this);
            this.mainCanvas.onmouseup = this.mainCanvas.onblur = function(){
                this.mainCanvas.onmousemove = null;
            }.bind(this);
        }.bind(this);
    }

    detached(){
        this.container.remove();
    }

    pickColor(evt){
        if(this.cachedGradient !== null) {
            let x = Math.max(Math.min(this.mainCanvas.width,  evt.offsetX), 0);
            let y = Math.max(Math.min(this.mainCanvas.height-1, evt.offsetY), 0);
            this.mouseX = x;
            this.mouseY = y;
            let idx = 4 * (x + this.mainCanvas.width * y);
            let d = this.cachedGradient.data;
            this.color = [d[idx], d[idx+1], d[idx+2], d[idx+3]];
            this.dispatchChange();
        }
        this.updateCanvas();
    }

    click(){
        this.active = ! this.active;
        if(this.active)
            this.updateCanvas();
    }

    dispatchChange(){
        let evt = document.createEvent('HTMLEvents');
        evt.initEvent('change', false, true);
        this.element.dispatchEvent(evt);
    }

    cachedGradient = null;
    updateCanvas(){
        let ctx = this.mainCanvas.getContext('2d');
        let canvas = this.mainCanvas;
        if(this.cachedGradient === null) {
            ctx.rect(0, 0, canvas.width, canvas.height);
            let grd = ctx.createLinearGradient(0, 0, canvas.width, 0);
            grd.addColorStop(0,     'rgb(255,0,0)');
            grd.addColorStop(0.165, 'rgb(255,0,255)');
            grd.addColorStop(0.33,  'rgb(0,0,255)');
            grd.addColorStop(0.495, 'rgb(0,255,255)');
            grd.addColorStop(0.67,  'rgb(0,255,0)');
            grd.addColorStop(0.845, 'rgb(255,255,0)');
            grd.addColorStop(1,     'rgb(255,0,0)');
            ctx.fillStyle = grd;
            ctx.fill();
            let agrd = ctx.createLinearGradient(0,0,0,canvas.height);
            agrd.addColorStop(0,    'rgba(255,255,255,1)');
            agrd.addColorStop(0.5,  'rgba(255,255,255,0)');
            agrd.addColorStop(1,    'rgba(0,0,0,1)');
            ctx.fillStyle = agrd;
            ctx.fill();
            this.cachedGradient = ctx.getImageData(0,0,canvas.width,canvas.height);
        }else{
            ctx.putImageData(this.cachedGradient,0,0);
        }

        ctx.fillStyle = 'black';
        let rad = 5;
        ctx.fillRect(this.mouseX, 0, 1, this.mouseY-rad);
        ctx.fillRect(this.mouseX, this.mouseY+rad, 1, canvas.height);
        ctx.fillRect(0, this.mouseY, this.mouseX-rad, 1);
        ctx.fillRect(this.mouseX+rad, this.mouseY, canvas.width, 1);

        let ac = this.alphaCanvas;
        let act = ac.getContext('2d');
        let g = act.createLinearGradient(0,0,0,ac.height);
        g.addColorStop(0, this.getStringColor(this.color));
        g.addColorStop(1, this.getStringColor([this.color[0], this.color[1], this.color[2], 0]));
        act.fillStyle = g;
        act.clearRect(0,0,ac.width, ac.height);
        act.fillRect(0,0,ac.width, ac.height);
    }

    getStringColor(col) {
        return 'rgba('+col[0]+','+col[1]+','+col[2]+','+col[3]/255+')';
    }
}
