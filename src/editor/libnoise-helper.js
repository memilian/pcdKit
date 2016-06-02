import {singleton} from 'aurelia-framework';

@singleton()
export class LibnoiseHelper{
    
    elements;
    
    constructor() {
        this.elements = new Map();
        this.elements.set('Perlin', {constructor: "Perlin(frequency : Float, lacunarity : Float, persistence : Float, octaves : Int, seed : Int, quality : QualityMode)", doc:'toto', snippet:"Perlin(${1:0.03}, ${2:1.0}, ${3:0.25}, ${4:8},${5:123}, ${6:HIGH});"});
        this.elements.set('Sphere', {constructor: "Sphere(frequency : Float)", snippet:"Sphere(${1:0.1});"});
        this.elements.set('Cylinder', {constructor: "Cylinder(frequency : Float)", snippet:"Cylinder(${1:0.1});"});
        this.elements.set('Billow', {constructor: "Billow(frequency : Float, lacunarity : Float, persistence : Float, octaves : Int, seed : Int, quality : QualityMode)", snippet:"Billow(${1:0.03}, ${2:1.0}, ${3:0.25}, ${4:8},${5:123}, ${6:HIGH});"});
        this.elements.set('Const', {constructor: "Const(value : Int)", snippet:"Const(${1:0.5});"});
        this.elements.set('RidgedMultifractal', {constructor: "RidgedMultifractal(frequency : Float, lacunarity : Float, octaves : Int, seed : Int, quality : QualityMode)", snippet:"RidgedMultifractal(${1:0.03}, ${2:1.0},${4:2},${5:123}, ${6:HIGH});"});
        this.elements.set('Voronoi', {constructor: "Voronoi(frequency : Float, displacement : Float, seed : Int, distance : Bool)", snippet:"Voronoi(${1:0.03},${2:1}, ${3:123},${4:true});"});
        this.elements.set('Turbulence', {constructor: "Turbulence(power : Float, input : ModuleBase, ?distortX : Perlin, ?distortY : Perlin, ?distortZ : Perlin)", snippet:"Turbulence(${1:0.3},${2:module});"});
        this.elements.set('Translate', {constructor: "Translate(dx : Float, dy : Float, dz : Float, input : ModuleBase)", snippet:"Translate(${1:1},${1:1},${1:1},${2:module});"});
        this.elements.set('Scale', {constructor: "Scale(sx = 1.0, sy = 1.0, sz = 1.0, input : ModuleBase)", snippet:"Scale(${1:1},${1:1},${1:1},${2:module});"});
        this.elements.set('ScaleBias', {constructor: "ScaleBias(scale = 1.0, bias = 0.0, input : ModuleBase)", snippet:"ScaleBias(${1:1.0}, ${2:0.5},${3:module});"});
        this.elements.set('Select', {constructor: "Select(min = -1.0, max = 1.0, fallOff = 0.0, inputA : ModuleBase, inputB : ModuleBase, controller : ModuleBase)", snippet:"Select(${1:-1.0}, ${2:0.0}, ${3:0.5}, ${4:module1}, ${5:module2}, ${6:module3});"});
        this.elements.set('Subtract', {constructor: "Subtract(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Subtract(${1:module1}, ${2:module2});"});
        this.elements.set('Add', {constructor: "Add(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Add(${1:module1}, ${2:module2});"});
        this.elements.set('Min', {constructor: "Min(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Min(${1:module1}, ${2:module2});"});
        this.elements.set('Max', {constructor: "Max(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Max(${1:module1}, ${2:module2});"});
        this.elements.set('Multiply', {constructor: "Multiply(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Multiply(${1:module1}, ${2:module2});"});
        this.elements.set('Power', {constructor: "Power(lhs : ModuleBase, rhs : ModuleBase)", snippet:"Power(${1:module1}, ${2:module2});"});
        this.elements.set('Rotate', {constructor: "Rotate(rx = 0.0, ry = 0.0, rz = 0.0, input : ModuleBase)", snippet:"Clamp(${1:1.0}, ${2:0.0},${3:0.0}, ${4:module1});"});
        this.elements.set('Abs', {constructor: "Abs(module : ModuleBase)", snippet:"Abs(${1:module1});"});
        this.elements.set('Invert', {constructor: "Invert(module : ModuleBase)", snippet:"Invert(${1:module1});"});
        this.elements.set('Exponent', {constructor: "Exponent(exponent : Float, input : ModuleBase)", snippet:"Exponent(${1:3.0}, ${2:module1});"});
        this.elements.set('Displace', {constructor: "Displace(input : ModuleBase, x : ModuleBase, y : ModuleBase, z : ModuleBase)", snippet:"(${1:inputModule}, ${2:moduleX}, ${3:moduleY}, ${4:moduleZ});"});
        this.elements.set('Blend', {constructor: "Blend(rhs : ModuleBase, lhs : ModuleBase, controller : ModuleBase)", snippet:"Blend(${1:module1}, ${2:module2}, ${3:moduleController});"});
        this.elements.set('Clamp', {constructor: "Clamp(min : Float, max : Float, input : ModuleBase)", snippet:"Clamp(${2:0.0}, ${2:1.0}, ${3:module1});"});
    }
    
    getTooltip(identifier){
        let elm = this.elements.get(identifier);
        if(!elm) return "";
        return elm.constructor;
    }
    
    getCompleter(){
        let elements = this.elements;
        return {
			getCompletions: function(editor, session, pos, prefix, callback) {
                let candidates = [];
				for(let [key, value] of elements){
					candidates.push({value:key, score: 100, meta:"libnoise", doc:value.doc || ""});
				}
				callback(null, candidates);
			},
			getDocTooltip: function(item) {
				if(item.meta=='libnoise')
				item.docHTML = '<b>'+item.value+'</b><hr></hr>'+item.doc;
    		}
		}
    }
    
    getSnippets(){
        let snippets = [];
        for(let [k,v] of this.elements){
            snippets.push({
                content: v.snippet,
                tabTrigger: k
            });
        }
        return snippets;
    }
}