package com.kio.tools.event
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class ControlEvent extends Event
	{
		public static const CTRL:String = "ctrl";
		public static const INFO:String = "info";
		public static const TAP_SOUND:String = "tap_sound";
		public var cursor:Vector3D = new Vector3D(0,0,0);
		
		public function ControlEvent(type:String, cursor:Vector3D=null, bubbles:Boolean=true)
		{
			this.cursor = cursor;
			super(type, bubbles);
		}
	}
}