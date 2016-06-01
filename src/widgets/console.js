import {EventAggregator} from 'aurelia-event-aggregator';
import {inject} from'aurelia-framework';

@inject(EventAggregator)
export class Console{
    
    //event subscriptions
    subs=[];
    
    //lines=[];
    //lineStates=[];
    message="";
    //info || error
    messageType="info";
    
    constructor(eva){
        this.events = eva;
    }
    
    attached(){
        this.subs.push(this.events.subscribe('console-message', function(msg){
            //this.lines.push(err);
            //this.lineStates.push(false);
            this.message = msg.message;
            this.messageType=msg.type;
        }.bind(this)));
    }
    
    detached(){
        for(let sub of subs)
            sub.dispose();
    }
    
    
    
    
}