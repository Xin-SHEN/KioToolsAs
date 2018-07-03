package com.kio.tools.event
{
	import flash.events.Event;
	
	public class SequencedEvent extends Event
	{
		public var index:Number;
		public static const TRIGGERED:String = "triggered";
		
		public function SequencedEvent(type:String, index:Number,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles = true);
			this.index = index;
		}
	}
}