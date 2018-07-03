package com.kio.tools.udp
{
	import flash.events.Event;
	
	public class UDPReceivedDataEvent extends Event
	{		
		public static const UDP_DATA:String = "udp_data";
		public var data:String;
		public var srcAddress:String;
		public var srcPort:Number;
		
		public function UDPReceivedDataEvent(type:String, data:String, srcAddress:String = null, srcPort:Number = NaN ,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
			this.srcAddress = srcAddress;
			this.srcPort = srcPort;
		}

	}
}