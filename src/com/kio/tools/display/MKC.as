package com.kio.tools.display
{
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	public class MKC extends NativeWindow
	{		
		public function MKC(initOptions:NativeWindowInitOptions=null)
		{
			var navWinInitOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			navWinInitOptions.systemChrome = NativeWindowSystemChrome.NONE;
			navWinInitOptions.resizable = true;
			navWinInitOptions.maximizable = false;
			navWinInitOptions.minimizable = false;
			navWinInitOptions.transparent = true;
			navWinInitOptions.type = NativeWindowType.LIGHTWEIGHT;
			
			super(navWinInitOptions);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			this.activate();
			this.alwaysInFront = true;			
			this.bounds = new Rectangle(0,0,516,291);
			this.x = Screen.mainScreen.visibleBounds.width/2 - 516/2 ;
			this.y = Screen.mainScreen.visibleBounds.height/2 - 291/2 ;
			trace(this.x);
			trace(this.y);
			
//			var logo:MovieClip = new MKCLOGO();
			var logo:MovieClip = new KIOLOGO();
			this.stage.addChild(logo);
			
			setTimeout( dispose, 5000);
		}
		
		private function dispose():void
		{
//			this.close();
			this.visible = false;
		}
	}
}