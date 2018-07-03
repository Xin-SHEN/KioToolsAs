package com.kio.tools.udp
{
	import flash.display.Stage;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class UDPInitializationBackup
	{				
		private var stage:Stage;
		private var	localIP:String;
		private var	localPort:Number;
		private var	targetIP:String;
		private var	targetPort:Number;	
		private var datagramSocket:DatagramSocket;
		private var udpBlocking:Boolean = false;
		private var blockingTimer:Timer;		
		private var	blockingPeriod:Number;
		
		/**
		 * 	初始化 UDP
		 */
		public function UDPInitializationBackup(   stage:Stage,
											 localIP:String, 
											 localPort:Number, 
											 targetIP:String, 
											 targetPort:Number,
											 blockingPeriod:Number = 0)
		{
			this.stage = stage;
			//读取IP和端口
			this.localIP = localIP;
			this.localPort = localPort;
			this.targetIP = targetIP;
			this.targetPort = targetPort;	
			this.blockingPeriod = blockingPeriod;
			
			//Create the socket
			datagramSocket = new DatagramSocket();
			datagramSocket.addEventListener( DatagramSocketDataEvent.DATA, socketDataReceived );
			//Bind the socket to the local network interface and port
			datagramSocket.bind( localPort, localIP );
			//Listen for incoming datagrams
			datagramSocket.receive();
//			//Create a message in a ByteArray
//			var data:ByteArray = new ByteArray();
//			data.writeUTFBytes("AIR SAY HELLO.");
//			//Send the datagram message
//			datagramSocket.send( data, 0, 0, targetIP, targetPort);
			
			if(blockingPeriod>0){
				// UDP 处理间隔
				blockingTimer = new Timer(blockingPeriod);	
				//myTimer.start();
				blockingTimer.addEventListener(TimerEvent.TIMER, blockingUDPMsg);
			}
			/**
			 * 	 AIR应用窗口关闭,UDP通信关闭
			 */
			//this.stage.nativeWindow.addEventListener(flash.events.Event.CLOSE, UDPInitialization.onClose);
			
		}
		
		/**
		 * 	UDP发送
		 */
		public function sendUDPdata(msg:String):void{
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(msg);
			//Send the datagram message
			datagramSocket.send( data, 0, 0, targetIP, targetPort);
		}
		
		/**
		 * 	UDP发送2
		 */
		public function sendUDPdataWithIpPort(msg:String, ip:String, port:Number):void{
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(msg);
			//Send the datagram message
			datagramSocket.send( data, 0, 0, ip, port);
		}
		
		/**
		 * 	UDP通信信息丢弃（处理间隔）
		 */
		private function blockingUDPMsg(event:TimerEvent):void
		{
			blockingTimer.stop();
			udpBlocking = false;
		}
		
		/**
		 * 	UDP处理
		 */
		private function socketDataReceived(event:DatagramSocketDataEvent):void
		{
			trace(event.srcAddress);
			trace(event.srcPort);
			// readUTFBytes 等价于 toString();	
			if(blockingPeriod>0){
				if(!udpBlocking){	 
					udpBlocking = true;
					blockingTimer.start();					
					this.stage.dispatchEvent(new UDPReceivedDataEvent(UDPReceivedDataEvent.UDP_DATA, event.data.toString()));	
				}
			}else
				this.stage.dispatchEvent(new UDPReceivedDataEvent(UDPReceivedDataEvent.UDP_DATA, event.data.toString()));				
		}
		
		/**
		 * 	 AIR应用窗口关闭处理
		 */
		public function onClose(evt:Event):void
		{
			datagramSocket.close();
		}
	}
}