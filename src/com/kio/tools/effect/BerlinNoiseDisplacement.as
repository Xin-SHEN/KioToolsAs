package com.kio.tools.effect
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	
	public class BerlinNoiseDisplacement extends Sprite
	{
		public var container:Bitmap;
		public var rSeed:int;
		public var offsetArray:Array;
		public var moveArray:Array;
		public var img_mc:MovieClip;
		public var dMap:BitmapData;
		public var dFilter:DisplacementMapFilter;
		
		private var mc:DisplayObject;
		
		public function BerlinNoiseDisplacement(mc:DisplayObject,width:Number=800,height:Number=600, xSpeed:Number=1, ySpeed:Number=-1)
		{
			this.mc = mc;
			
			img_mc = new MovieClip();
			this.addChild(img_mc);
			img_mc.addChild(mc);
			this.img_mc.addEventListener(flash.events.Event.ENTER_FRAME, this.onFrameHandler);
			
			this.dFilter = new DisplacementMapFilter();
			this.rSeed = Math.random() * 1000;
			this.offsetArray = new Array(new Point(0, 0));
			this.moveArray = new Array(new Point(0, 0));
			this.moveArray[0].x = xSpeed;
			this.moveArray[0].y = ySpeed;
			
			this.dMap = new BitmapData(width, height, false, 8421504);
			this.container = new Bitmap(this.dMap);
			this.updateMap();
			this.dFilter.mapBitmap = this.dMap;
			this.dFilter.mapPoint = new Point();
			this.dFilter.scaleX = 30;//this.powerX.value;
			this.dFilter.scaleY = 30;//this.powerY.value;
			this.dFilter.componentX = 1;
			this.dFilter.componentY = 1;
			this.dFilter.mode = "color";
			this.dFilter.color = 0;
			this.dFilter.alpha = 0;
			this.img_mc.filters = [this.dFilter];
		}
		
		public function updateMap():void
		{
			this.dMap.perlinNoise(60,60,/*this.pSizeX.value, this.pSizeY.value,*/ 1, this.rSeed, true, true, 1, true, this.offsetArray);
			this.dFilter.mapBitmap = this.dMap;
			this.img_mc.filters = [this.dFilter];
		}	
		
		protected function onFrameHandler(event:Event):void
		{
			var i:int = 0;
			while (i < this.offsetArray.length)
			{
				
				this.offsetArray[i].x = this.offsetArray[i].x + this.moveArray[i].x;
				this.offsetArray[i].y = this.offsetArray[i].y + this.moveArray[i].y;
				i++;
			}
			this.updateMap();
		}
	}
}