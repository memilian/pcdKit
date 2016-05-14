/**
 * Created by memilian on 07/05/16.
 */

export class ParseIntValueConverter{
    fromView(value){
        var res = parseInt(value);
        return isNaN(res) ? 0 : res;
    }
}