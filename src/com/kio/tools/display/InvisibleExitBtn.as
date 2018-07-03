package com.kio.tools.display
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class InvisibleExitBtn extends Sprite
	{
		private var btnAlpha:Number;
		private var sideLength:Number;
		
		public function InvisibleExitBtn(btnAlpha:Number = 0, sideLength:Number=70)
		{
			this.btnAlpha = btnAlpha;
			this.sideLength = sideLength;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(evt:Event):void{
			this.graphics.beginFill(0x000000,btnAlpha);
			this.graphics.drawRect(0,0,sideLength,sideLength);
			this.graphics.endFill();
			this.addEventListener(MouseEvent.CLICK, onExitBtnClick);
		}
		
		private function onExitBtnClick(evt:MouseEvent):void{
			NativeApplication.nativeApplication.exit();
		}
	}
}