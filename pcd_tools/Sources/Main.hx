package;

import kha.System;

class Main {
	public static function main() {
		untyped window.kha = Main.main;
		untyped window.kha_system = kha.SystemImpl;
		System.init({ title:"Project", width:1024, height:768 }, function () {
			new PcdKit();
		});
	}
}
