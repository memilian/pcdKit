import {LibnoiseHelper} from 'editor/libnoise-helper';
let event;

export class TokenTooltip {
   
    token = {};
    visible=false;
    text="";
    x=0;
    y=0;
    isOpen=false;
    width=100;
    height=50;
    maxWidth=200;
    maxHeight=50;
    lastT=0;
        
    constructor(editor) {
        this.helper= new LibnoiseHelper();
        let self = this;
        ace.config.loadModule('ace/lib/event', (_event) =>{
            event=_event;
            if (editor.tokenTooltip)
                return;
            editor.tokenTooltip = self;
            self.editor = editor;

            self.update = self.update.bind(self);
            self.onMouseMove = self.onMouseMove.bind(self);
            self.onMouseOut = self.onMouseOut.bind(self);
            event.addListener(editor.renderer.scroller, "mousemove", self.onMouseMove);
            event.addListener(editor.renderer.content, "mouseout", self.onMouseOut);
        });
    } 


    
    update() {
        this.$timer = null;
        
        var r = this.editor.renderer;
        if (this.lastT - (r.timeStamp || 0) > 1000) {
            r.rect = null;
            r.timeStamp = this.lastT;
            this.maxHeight = window.innerHeight;
            this.maxWidth = window.innerWidth;
        }

        var canvasPos = r.rect || (r.rect = r.scroller.getBoundingClientRect());
        var offset = (this._x + r.scrollLeft - canvasPos.left - r.$padding) / r.characterWidth;
        var row = Math.floor((this._y + r.scrollTop - canvasPos.top) / r.lineHeight);
        var col = Math.round(offset);

        var screenPos = {row: row, column: col, side: offset - col > 0 ? 1 : -1};
        var session = this.editor.session;
        var docPos = session.screenToDocumentPosition(screenPos.row, screenPos.column);
        var token = session.getTokenAt(docPos.row, docPos.column);

        // if (!token && !session.getLine(docPos.row)) {
        //     token = {
        //         type: "",
        //         value: "",
        //         state: session.bgTokenizer.getState(0)
        //     };
        // }
        if (!token || token.type !== 'identifier') {
            this.visible = false;
            return;
        }

        var tokenText = this.helper.getTooltip(token.value);

        if (this.text != tokenText) {
            this.text = tokenText;
        }

        this.visible=this.text.length > 0;
    }
    
    onMouseMove(e) {
        this._x = e.clientX;
        this._y = e.clientY;
        this.setPosition(this._x, this._y);
        if (this.isOpen) {
            this.lastT = e.timeStamp;
        }
        if (!this.$timer)
            this.$timer = setTimeout(this.update, 100);
    }

    onMouseOut(e) {
        if (e && e.currentTarget.contains(e.relatedTarget))
            return;
        this.visible=false;
        this.editor.session.removeMarker(this.marker);
        this.$timer = clearTimeout(this.$timer);
    }

    setPosition(x, y) {
        this.x = x + 10;
        this.y = y - 50;
    }

    destroy() {
        this.onMouseOut();
        event.removeListener(this.editor.renderer.scroller, "mousemove", this.onMouseMove);
        event.removeListener(this.editor.renderer.content, "mouseout", this.onMouseOut);
        delete this.editor.tokenTooltip;
    }

}