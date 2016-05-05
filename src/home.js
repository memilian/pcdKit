//import {computedFrom} from 'aurelia-framework';
import 'jquery-ui-draggable';
import 'jquery-layout';

export class Home {

    constructor(){
    }

    attached(){
        window.layout = $('#main-layout-container').layout({
            defaults: {
                applyDefaultStyles: false,
                resizable: true,
                slidable: false
            },
            west:{
                minSize:300,
            },
            east:{
                size:400,
            }
        });
       /* split.Split([this.editor, this.canvas],{
            sizes:[45, 45],
            minSize:100,
            gutterSize:10,
            direction:'horizontal'
        });
        let snapper = new Snap({
            element: this.content,
            dragger:this.gutter,
            hyperextensible: false
        });
        window.snapper = snapper;
        window.split = split.Split;
        */
    }

    gutterClicked(){

    }
}
