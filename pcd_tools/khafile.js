var project = new Project('New Project');
project.addAssets('Assets/**');
project.addSources('Sources');
project.addLibrary('activity');
project.addLibrary('thx.core');
project.addLibrary('thx.unit');
project.addLibrary('libnoise');
project.addLibrary('hscript');
project.addLibrary('compiletime');
project.addParameter('-lib activity');
project.addParameter('-dce no');
project.addDefine('shallow-expose');
return project;
