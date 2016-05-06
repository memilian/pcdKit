/**
 * Created by memilian on 27/04/16.
 */
import ace from 'ace';
import * as lang from '/jspm_packages/github/ajaxorg/ace-builds@1.2.3/ext-language_tools.js';
import {EventAggregator} from 'aurelia-event-aggregator';
import {inject} from 'aurelia-framework';

@inject(EventAggregator)
export class Editor{

    id="editor-1";

    constructor(eva){
        this.eva = eva;
        this.module = null;
    }

    attached(){
        var editor = ace.edit(this.id);
        window.editor = editor;
        window.langTools = ace.require('ace/ext/language_tools');
        editor.getSession().setUseWorker(false);
        editor.setTheme("ace/theme/monokai");
        editor.getSession().setMode("ace/mode/haxe");
        editor.setOptions({
            enableBasicAutocompletion: true,
            enableLiveAutocompletion: true
        });
        this.eva.publish('editor-attached');

        editor.getSession().on('change', function(){
            if(this.module == null) return;
            var code = editor.getSession().getDocument().$lines.join('\n');
            console.log('editor code changed');
            this.eva.publish('code-changed', {
                module: this.module,
                code : code
            });
        }.bind(this));

        this.eva.subscribe('module-loaded', function(module){
            console.log('module '+module.name+' loaded with code :'+module.code);
            if(module === undefined) module = null;
            this.module = module;
            editor.getSession().getDocument().setValue(module.code);
        }.bind(this));
    }


}