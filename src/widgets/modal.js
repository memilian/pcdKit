/**
 * Created by memilian on 05/05/16.
 */
import {singleton} from 'aurelia-framework';

@singleton()
export class Modal{

    header="Header";
    content="Content";
    okText="Yes";
    nokText="No";

    okCb = null;
    nokCb = null;

    trigger(opts, okCb, nokCb){
        this.header = opts.header || this.header;
        this.content = opts.content || this.content;
        this.okText = opts.okText || this.okText;
        this.nokText = opts.nokText || this.nokText;
        this.okCb = okCb || null;
        this.nokCb = nokCb || null;
        this.btn.click();
    }

    agree(){
        if(this.okCb !== null)
            this.okCb();
    }

    disagree(){
        if(this.nokCb !== null)
            this.nokCb();
    }
}