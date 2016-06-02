package;

import modules.CircleWrap;
import modules.CircleWrap;
import libnoise.operator.Displace;
import libnoise.operator.Translate;
import libnoise.generator.Cylinder;
import libnoise.generator.Sphere;
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
		PcdUtils.khaColorFromArray([1,2,3,1]); //fix broken @keep
		the = this;
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);

		PcdKit.events = untyped eventAggregator;
		PcdKit.events.subscribe('code-changed', this.oncodechanged);
		PcdKit.events.subscribe('refresh', function(){this.onoptionschanged(ProjectManager.currentModule);});
		PcdKit.events.subscribe('options-changed', this.onoptionschanged);
		this.editorLoaded();
		parser = new Parser();
		interp = new Interp();
		setupInterp();

		Scheduler.addFrameTask(this.updateTexture,1);
		Activity.create(function(){texGenActivity = new TexGenActivity(mq);});
		var projects = ProjectManager.getProjects();
		if(projects.length > 0)
			ProjectManager.loadProject(projects[0]);
	}

	public function editorLoaded():Void {
		untyped this.editor = window.editor;
		//editor.getSession().on('change', oncodechanged);
		// editor.completers.push({
		// 	getCompletions: function(editor, session, pos, prefix, callback) {
		// 		var candidates = [];
		// 		for(key in interp.variables.keys()){
		// 			candidates.push({value:key, score: 100, meta:"libnoise", caption:'yaaaay'});
		// 		}
		// 		callback(null, candidates);
		// 	},
		// 	getDocTooltip: function(item) {
		// 		if(item.meta=='libnoise')
		// 		item.docHTML = '<b>${item.value}</b><hr></hr>${item.caption}';
    	// 	}
		// });
	}

	var module : ModuleBase;
	var texture : kha.Image;

	public function setupInterp():Void {
		module = new Billow(0.003, 1.0, 0.5, 8,  123, HIGH);

		interp.variables.set("HIGH", QualityMode.HIGH);
		interp.variables.set("MEDIUM", QualityMode.MEDIUM);
		interp.variables.set("LOW", QualityMode.LOW);

		interp.variables.set("Billow", libnoise.generator.Billow);
		interp.variables.set("Perlin", libnoise.generator.Perlin);
		interp.variables.set("RidgedMultifractal", libnoise.generator.RidgedMultifractal);
		interp.variables.set("Voronoi", Voronoi);
		interp.variables.set("Sphere", Sphere);
		interp.variables.set("Cylinder", Cylinder);
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
		interp.variables.set("Displace", Displace);
		interp.variables.set("Translate", Translate);
		interp.variables.set("Exponent", libnoise.operator.Exponent);
		interp.variables.set("Power", libnoise.operator.Power);
		interp.variables.set("Rotate", libnoise.operator.Rotate);
   

		interp.variables.set("_scaleNormedValue", function(value, newmin, newmax){
			return value * newmax + newmin;
		});
	}

	var textureDirty = false;
	public function generateTexture():Void {

		var options = ProjectManager.currentModule.options;

		if(texture != null && (texture.width != options.size || texture.height != options.size)){
			texture.unload();
			texture = kha.Image.createRenderTarget(options.size, options.size, TextureFormat.RGBA32, NoDepthAndStencil, 8);
		}
		else if(texture == null)
			texture = kha.Image.createRenderTarget(options.size, options.size, TextureFormat.RGBA32, NoDepthAndStencil, 8);

		mq.sender.send(Generate(module, options, texture));
		textureDirty = true;
	}

	var debounce = 0.3;
	var lastChange = 0.0;
	var codeDirty = false;
	public function oncodechanged(infos):Void {
		var module = ProjectManager.currentProject.getModuleNamed(infos.module.name);
		if(module == null) return;
		module.code = infos.code;
		ProjectManager.currentProject.save();
		lastChange = Scheduler.realTime();
		codeDirty = true;
	}

	public function onoptionschanged(module):Void {
		if(module == null) return;
		ProjectManager.currentProject.save();
		lastChange = Scheduler.realTime();
		codeDirty = true;
	}

	public function updateTexture():Void {
		if(!codeDirty || Scheduler.realTime()-lastChange < debounce) return;
		codeDirty = false;
		var code = ProjectManager.currentModule.code;
		try{
			var expr = parser.parseString(code);
			interp.execute(expr);
			module = interp.variables.get('module');
			if(module != null)
				generateTexture();
			PcdKit.events.publish('console-message',{
				message:'ok',
				type:'info'
			});
		}catch(ex : Dynamic){
			PcdKit.events.publish('console-message',{
				message:ex,
				type:'error'
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
