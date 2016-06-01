//import {computedFrom} from 'aurelia-framework';
import 'jquery-ui-draggable';
import 'jquery-layout';
import 'jquery-layout/source/stable/plugins/jquery.layout.state';
import {EventAggregator} from 'aurelia-event-aggregator';
import {inject} from 'aurelia-framework';

@inject(EventAggregator)
export class Home {

    editorMode="CODE";

    constructor(eva){
        this.eva = eva;
        this.eva.subscribe('editor-mode', function(mode){
            this.editorMode = mode;
        }.bind(this));
    }

    attached(){
        function customSaveState (Instance, state, options, name) {
            var state_JSON = JSON.stringify(Instance.readState());
            localStorage.setItem(state.container.id, state_JSON);
        }
        function customLoadState (Instance, state, options, name) {
            var savedState=JSON.parse(localStorage.getItem(state.container.id));
            Instance.loadState( savedState, false );
        }

        this.layout = $('#main-layout-container').layout({
            onload:customLoadState,
            onunload:customSaveState,
            stateManagement: {
                enabled: true,
                autoSave:false,
                autoLoad:false
            },
            defaults: {
                applyDefaultStyles: false,
                resizable: true,
                slidable: false
            },
            west:{
                size:300,
                resizable: false
            },
            center:{
                minWidth:300
            },
            east:{
                size:400,
                minSize:300,
                closable:false
            }
        });

        this.rendererLayout = $('#renderer-layout-container').layout({
            onload:customLoadState,
            onunload:customSaveState,
            stateManagement: {
                enabled: true,
                autoSave:false,
                autoLoad:false
            },
            defaults: {
                applyDefaultStyles: false,
                resizable: true,
                slidable: false
            },
            north:{
                paneSelector:'.render-layout-north',
                size:200
            },
            center:{
                paneSelector:'.render-layout-center',
                size:400,
                minSize:300,
                minHeight:300,
                closable:false
            }
        });
        /*
        this.codeLayout = $('#code-layout-container').layout({
            onload:customLoadState,
            onunload:customSaveState,
            stateManagement: {
                enabled: true,
                autoSave:false,
                autoLoad:false
            },
            defaults: {
                applyDefaultStyles: false,
                resizable: true,
                slidable: false
            },
            south:{
                paneSelector:'.code-layout-south',
                size:100
            },
            center:{
                paneSelector:'.code-layout-center',
                minSize:300,
                minHeight:300,
                closable:false
            }
        });*/
        $(window).trigger('resize');
        this
    }

    detached(){
        this.rendererLayout.destroy();
        this.layout.destroy();
    }
}
