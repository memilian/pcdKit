/**
 * Created by memilian on 27/04/16.
 */
import ace from 'ace';
import * as lang from '/jspm_packages/github/ajaxorg/ace-builds@1.2.3/ext-language_tools.js';
import {EventAggregator} from 'aurelia-event-aggregator';
import {inject} from 'aurelia-framework';
import {TokenTooltip} from 'editor/token-tooltip';
import {LibnoiseHelper} from 'editor/libnoise-helper';

@inject(EventAggregator, LibnoiseHelper)
export class Editor{

    id="editor-1";
    tokenTooltip=null;
    
    constructor(eva, helper){
        this.eva = eva; 
        this.helper = helper;
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
            enableSnippets: true,
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
            if(module === undefined) module = null;
            this.module = module;
            editor.getSession().getDocument().setValue(module === null ? "" : module.code);
        }.bind(this));
        this.tokenTooltip = new TokenTooltip(editor);
        
        
        editor.completers.push(this.helper.getCompleter());
        
        var snippetManager = ace.require('ace/snippets').snippetManager; 
        snippetManager.register(this.helper.getSnippets(), "haxe"); 
        /*editor.getSession().selection.on('changeCursor', function(event){
            var cursor = editor.getSession().selection.getCursor();
            var line = editor.getSession().getLine(cursor.row);
            codeHelper.processLine(line, cursor.column);
        });*/
    }
}