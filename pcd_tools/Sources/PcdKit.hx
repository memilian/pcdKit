package;

import kha.ScreenRotation;
import kha.Scaler;
import TexGenActivity.TexGenMessage;
import activity.MessageQueue;
import activity.Activity;
import libnoise.operator.Clamp;
import libnoise.operator.Abs;
import libnoise.operator.Invert;
import libnoise.operator.Turbulence;
import kha.Storage.LocalStorageFile;
import js.Browser;
import libnoise.generator.Const;
import libnoise.generator.Voronoi;
import libnoise.QualityMode;
import libnoise.operator.Multiply;
import libnoise.generator.Perlin;
import libnoise.generator.Billow;
import hscript.Parser;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Color;
import hscript.Interp;
import libnoise.operator.*;
import libnoise.generator.*;
import libnoise.ModuleBase;
import thx.Floats;
import kha.graphics4.TextureFormat;

class PcdKit {

	static public var events : Dynamic;
	static public var the(default, null) : PcdKit;

	public var parser : Parser;
	public var interp : Interp;

	var editor : Dynamic;

	var mq = new MessageQueue<TexGenMessage>();
	var texGenActivity : TexGenActivity;

	public function new() {
		the = this;
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		PcdKit.events = untyped eventAggregator;
		//PcdKit.events.subscribe('editor-attached', this.editorLoaded);
		PcdKit.events.subscribe('code-changed', this.oncodechanged);
		this.editorLoaded();
		parser = new Parser();
		interp = new Interp();
		gradient = earthGradient();
		setupInterp();

		Scheduler.addFrameTask(this.updateTexture,1);
		Activity.create(function(){texGenActivity = new TexGenActivity(mq);});
		ProjectManager.getProjects();
	}

	public function editorLoaded():Void {
		untyped this.editor = window.editor;
		//editor.getSession().on('change', oncodechanged);
		editor.completers.push({
			getCompletions: function(editor, session, pos, prefix, callback) {
				var candidates = [];
				for(key in interp.variables.keys()){
					candidates.push({value:key, score: 100, meta:"libnoise"});
				}
				callback(null, candidates);
			}
		});
	}

	var module : ModuleBase;
	var texture : kha.Image;

	var radius = 150;
	var gradient : Gradient;

	public function setupInterp():Void {
		var perlin = new Perlin(0.003, 1.0, 0.5, 8,  321, HIGH);
		module = new Billow(0.003, 1.0, 0.5, 8,  123, HIGH);

		interp.variables.set("HIGH", QualityMode.HIGH);
		interp.variables.set("MEDIUM", QualityMode.MEDIUM);
		interp.variables.set("LOW", QualityMode.LOW);

		interp.variables.set("Billow", libnoise.generator.Billow);
		interp.variables.set("Perlin", libnoise.generator.Perlin);
		interp.variables.set("RidgedMultifractal", libnoise.generator.RidgedMultifractal);
		interp.variables.set("Voronoi", Voronoi);
		interp.variables.set("Const", Const);

		interp.variables.set("Add", libnoise.operator.Add);
		interp.variables.set("Subtract", libnoise.operator.Subtract);
		interp.variables.set("Multiply", Multiply);
		interp.variables.set("Blend", libnoise.operator.Blend);
		interp.variables.set("Select", libnoise.operator.Select);
		interp.variables.set("Min", libnoise.operator.Min);
		interp.variables.set("Max", libnoise.operator.Max);
		interp.variables.set("Scale", libnoise.operator.Scale);
		interp.variables.set("ScaleBias", libnoise.operator.ScaleBias);
		interp.variables.set("Turbulence", Turbulence);
		interp.variables.set("Abs", Abs);
		interp.variables.set("Invert", Invert);
		interp.variables.set("Clamp", Clamp);

		interp.variables.set("_scaleNormedValue", function(value, newmin, newmax){
			return value * newmax + newmin;
		});
	}

	var textureDirty = false;
	public function generateTexture():Void {
		if(texture == null)
			texture = kha.Image.createRenderTarget(Math.ceil(2*radius), Math.ceil(2*radius), TextureFormat.RGBA32, NoDepthAndStencil, 8);
		mq.sender.send(Generate(module, gradient,radius, texture));
		textureDirty = true;
	}

	public function earthGradient():Gradient {
		var g = new Gradient();
		g.add(0, Color.fromBytes(0,0,128,255));
		g.add(0.4, Color.fromBytes(128,128,255,255));
		g.add(0.5, Color.fromBytes(200,200,10,255));
		g.add(0.501, Color.fromBytes(200,200,10,255));
		g.add(0.512051, Color.fromBytes(10,128,10,255));
		g.add(0.8, Color.fromBytes(255,200,128,255));
		g.add(0.9, Color.fromBytes(96,96,96,255));
		g.add(1.0, Color.fromBytes(255,255,255,255));
		return g;
	}

	var throttle = 0.3;
	var lastChange = 0.0;
	var codeDirty = false;
	public function oncodechanged(infos):Void {
		var module = ProjectManager.currentProject.getModuleNamed(infos.module.name);
		module.code = infos.code;
		ProjectManager.currentProject.save();
		lastChange = Scheduler.realTime();
		codeDirty = true;
	}

	public function updateTexture():Void {
		if(!codeDirty || Scheduler.realTime()-lastChange < throttle) return;
		codeDirty = false;
		var code = ProjectManager.currentModule.code;
		try{
			var expr = parser.parseString(code);
			interp.execute(expr);
			module = interp.variables.get('module');
			if(module != null)
				generateTexture();
		}catch(ex : Dynamic){
			PcdKit.events.publish('interp-error',{
				message:ex
			});
		}
	}

	function update(): Void {
		try{
		Activity.run(function(){
			if(textureDirty){
				textureDirty = false;
				texture = texGenActivity.texture;
			}
		});
		}catch(exception : Dynamic){
			trace(exception);

		}

	}

	function render(framebuffer: Framebuffer): Void {
		if(texture == null) return;

		var g = framebuffer.g2;
		g.begin(true, Color.White);
		Scaler.scale(texture,framebuffer, ScreenRotation.RotationNone);//g.drawImage(texture,100,100);
		g.end();
	}
}
