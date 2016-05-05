/**
 * Created by memilian on 02/05/16.
 */
import {inject, singleton} from 'aurelia-framework';
import {EventAggregator} from 'aurelia-event-aggregator';

@singleton()
@inject(EventAggregator)
export class Khanvas{

    time=0;
    khanvas;

    constructor(eva){
        window.eventAggregator = eva;
        this.eva = eva;
        this.time = Date.now();
        this.khanvas = document.createElement('canvas');
        this.khanvas.setAttribute('id', 'khanvas');
        this.khanvas.width = 500;
        this.khanvas.height = 500;
    }

    attached(){
        this.container.appendChild(this.khanvas);
        this.khanvas.style.opacity='1';
        System.import("resources/kha").then(res => {
            this.eva.publish('khanvas-attached');
        });
        console.log(this.time);
    }
    detached(){
        //trick to always keep the same context
        document.body.appendChild(this.khanvas);
        this.khanvas.style.opacity='0';
    }
}