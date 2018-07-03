package com.kio.tools.udp
{
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class UDP_Initialization_v2
	{				
		private var stage:Stage;
		private var	localIP:String;
		private var	localPort:Number;	
		private var datagramSocket:DatagramSocket;
		private var udpBlocking:Boolean = false;
		private var blockingTimer:Timer;		
		private var	blockingPeriod:Number;
		
		/**
		 * 	初始化 UDP
		 */
		public function UDP_Initialization_v2(  stage:Stage,
											 	localIP:String, 
											 	localPort:Number, 
											 	blockingPeriod:Number = 0)
		{
			this.stage = stage;
			//读取IP和端口
			this.localIP = localIP;
			this.localPort = localPort;	
			this.blockingPeriod = blockingPeriod;
			
			//Create the socket
			datagramSocket = new DatagramSocket();
			datagramSocket.addEventListener( DatagramSocketDataEvent.DATA, socketDataReceived );
			//Bind the socket to the local network interface and port
			datagramSocket.bind( localPort, localIP );
			//Listen for incoming datagrams
			datagramSocket.receive();
			
			if(blockingPeriod>0){
				// UDP 处理间隔
				blockingTimer = new Timer(blockingPeriod);	
				//myTimer.start();
				blockingTimer.addEventListener(TimerEvent.TIMER, blockingUDPMsg);
			}
			/**
			 * 	 AIR应用窗口关闭,UDP通信关闭
			 */
			this.stage.nativeWindow.addEventListener(flash.events.Event.CLOSE, this.onClose);
//			NativeApplication.nativeApplication.addEventListener(Event.EXITING, this.onClose);
		}
		
		/**
		 * 	UDP发送
		 */
		public function sendUDPdata(targetIP:String, targetPort:Number, msg:String):void{
			var data:ByteArray = new ByteArray();
			data.writeUTFBytes(msg);
			//Send the datagram message
			datagramSocket.send( data, 0, 0, targetIP, targetPort);
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
		 * 	UDP接受处理
		 */
		private function socketDataReceived(event:DatagramSocketDataEvent):void
		{
			trace("Received message from " + event.srcAddress + " | " + event.srcPort + " | " + event.data.toString());
			// readUTFBytes 等价于 toString();	
			if(blockingPeriod>0){
				if(!udpBlocking){	 
					udpBlocking = true;
					blockingTimer.start();					
					this.stage.dispatchEvent(new UDPReceivedDataEvent(UDPReceivedDataEvent.UDP_DATA, event.data.toString(), event.srcAddress, event.srcPort));	
//					sendUDPdata(event.srcAddress, event.srcPort, "KIO AIR UDP Module Received Message : " + event.data.toString());
				}
			}else{
				this.stage.dispatchEvent(new UDPReceivedDataEvent(UDPReceivedDataEvent.UDP_DATA, event.data.toString(), event.srcAddress, event.srcPort));		
//				sendUDPdata(event.srcAddress, event.srcPort, "KIO AIR UDP Module Received Message : " + event.data.toString());
			}
		}
		
		/**
		 * 	 AIR应用窗口关闭处理
		 */
		public function onClose(evt:Event=null):void
		{
			datagramSocket.close();
//			NativeApplication.nativeApplication.exit();
		}
	}
}