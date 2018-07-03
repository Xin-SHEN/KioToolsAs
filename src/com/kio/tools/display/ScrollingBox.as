package com.kio.tools.display
{
	import com.greensock.BlitMask;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ScrollingBox extends Sprite
	{
		public var content:Sprite = new Sprite();
		public var bm:BlitMask;
		
		private var object:DisplayObject;
		private var maskWidth:Number;
		private var maskHeight:Number;
		
		public function ScrollingBox(object:DisplayObject, maskWidth:Number, maskHeight:Number)
		{
			this.object = object;
			this.maskWidth = maskWidth;
			this.maskHeight = maskHeight;
			setupContent();
			
			//setup BlitMask
			bm = new BlitMask(content, 0, 0, this.maskWidth, this.maskHeight, true);
			//			TweenLite.to(content, 30, {x:-300, onUpdate:bm.update});
		}
		
		private function setupContent():void {			
			addChild(content);
			content.addChild(object);
		}
	}
}