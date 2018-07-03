package com.kio.tools.debuggerIO
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class DebuggerIO extends Sprite
	{
		private static const INPUT_TEXT_1:String = "Home";
		private static const INPUT_TEXT_2:String = "Part-1";
		private static const INPUT_TEXT_3:String = "Back";
		private static const INPUT_TEXT_4:String = "Next";
		//private static const INPUT_TEXT:String = "Home";
		
		private var _btn:Sprite = new Sprite();
		private var _btn2:Sprite = new Sprite();
		private var _btn3:Sprite = new Sprite();
		private var _btn4:Sprite = new Sprite();
		private var _tf_INPUT:TextField = new TextField();
		private var _tf_INPUT2:TextField = new TextField();
		private var _tf_INPUT3:TextField = new TextField();
		private var _tf_INPUT4:TextField = new TextField();
		private var _tf_OUTPUT:TextField = new TextField();
		
		public function DebuggerIO()
		{
			super();
				
			init();
			
		}
		
		private function init():void{
			this.graphics.beginFill(0xFFFFFF,1);
			this.graphics.drawRect(0,0,100,150);
			this.graphics.endFill();			
			
			_btn.graphics.beginFill(0x000000,1);
			_btn.graphics.drawRect(0,0,100,30)
			_btn.graphics.endFill();
			
			_btn2.graphics.beginFill(0x000000,1);
			_btn2.graphics.drawRect(0,0,100,30)
			_btn2.graphics.endFill();
			_btn2.y=30;
			
			_btn3.graphics.beginFill(0x000000,1);
			_btn3.graphics.drawRect(0,0,100,30)
			_btn3.graphics.endFill();
			_btn3.y=60;
			
			_btn4.graphics.beginFill(0x000000,1);
			_btn4.graphics.drawRect(0,0,100,30)
			_btn4.graphics.endFill();
			_btn4.y=90;
			
			var _textFormat:TextFormat = new TextFormat();
			_textFormat.color = 0xFFFFFF;
			//_textFormat.font = "Arial";
			_textFormat.size = 18;
			
			var _textFormat2:TextFormat = new TextFormat();
			_textFormat2.color = 0x000000;
			_textFormat2.size = 18;
			
			_tf_INPUT.text = INPUT_TEXT_1;
			_tf_INPUT.mouseEnabled = false;
			_tf_INPUT.setTextFormat(_textFormat);
			_tf_INPUT.defaultTextFormat = _textFormat;
			_tf_INPUT.cacheAsBitmap = true;
			
			_tf_INPUT2.text = INPUT_TEXT_2;
			_tf_INPUT2.y = 30;
			_tf_INPUT2.mouseEnabled = false;
			_tf_INPUT2.setTextFormat(_textFormat);
			_tf_INPUT2.defaultTextFormat = _textFormat;
			_tf_INPUT2.cacheAsBitmap = true;
			
			_tf_INPUT3.text = INPUT_TEXT_3;
			_tf_INPUT3.y = 60;
			_tf_INPUT3.mouseEnabled = false;
			_tf_INPUT3.setTextFormat(_textFormat);
			_tf_INPUT3.defaultTextFormat = _textFormat;
			_tf_INPUT3.cacheAsBitmap = true;
			
			_tf_INPUT4.text = INPUT_TEXT_4;
			_tf_INPUT4.y = 90;
			_tf_INPUT4.mouseEnabled = false;
			_tf_INPUT4.setTextFormat(_textFormat);
			_tf_INPUT4.defaultTextFormat = _textFormat;
			_tf_INPUT4.cacheAsBitmap = true;
			
			_tf_OUTPUT.text = "OUTPUT";
			_tf_OUTPUT.mouseEnabled = false;
			_tf_OUTPUT.setTextFormat(_textFormat2);
			_tf_OUTPUT.defaultTextFormat = _textFormat2;
			_tf_OUTPUT.y = 120;
			
			
			this.addChild(_btn);
			this.addChild(_btn2);
			this.addChild(_btn3);
			this.addChild(_btn4);
			this.addChild(_tf_INPUT);
			this.addChild(_tf_INPUT2);
			this.addChild(_tf_INPUT3);
			this.addChild(_tf_INPUT4);
			this.addChild(_tf_OUTPUT);
			_btn.addEventListener(MouseEvent.CLICK,onClick);
			_btn2.addEventListener(MouseEvent.CLICK,onClick2);
			_btn3.addEventListener(MouseEvent.CLICK,onClick3);
			_btn4.addEventListener(MouseEvent.CLICK,onClick4);
		}
		
		protected function onClick(event:MouseEvent):void
		{
			this.stage.dispatchEvent(new Event("DebuggerClick",true));
		}
		
		protected function onClick2(event:MouseEvent):void
		{
			this.stage.dispatchEvent(new Event("DebuggerClick2",true));
		}
		
		protected function onClick3(event:MouseEvent):void
		{
			this.stage.dispatchEvent(new Event("DebuggerClick3",true));
		}
		
		protected function onClick4(event:MouseEvent):void
		{
			this.stage.dispatchEvent(new Event("DebuggerClick4",true));
		}
		
		
	}
}