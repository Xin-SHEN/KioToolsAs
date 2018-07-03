/** 
 * 
 * 		苏州美康创智能系统有限公司
 *  
 * 		Copyright (c)  
 * 		
 * 		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * 		EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * 		OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * 		IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * 		INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * 		NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * 		PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * 		WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * 		ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * 		POSSIBILITY OF SUCH DAMAGE.	
 * 
 * 
 * 		Author:			美康创多媒体软件开发部
 * 		Fichier : 		
 * 		Derniere MàJ : 	2012/10/22
 * 		Descrition :	产品注册模块
 * 		Dépend de :		com.kio.tools.encryption.ProductEncryption
 * 						com.kio.tools.encryption.XORAlgorithm
 * 						com.kio.tools.encryption.Base64					
 * 						
 * 		A Regler :		
 * 
 * 
 * 
 **/

package com.kio.tools.productRegistration
{	
	
	import com.kio.tools.encryption.Base64;
	import com.kio.tools.encryption.IXORAlgorithm;
	import com.kio.tools.encryption.ProductEncryption;
	import com.kio.tools.encryption.XORAlgorithmFactory;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	public class ProductRegistration extends Sprite
	{		
		public static const FREE_BOOT:String = "free_boot";
		public static const REGISTRATION_CHECK:String = "registration_check";
		
		/**
		 * 		@path 路径
		 * 		@enforceBoot 是否强制启动
		 * 		@args
		 * 
		 * 		处理第三方进程字符串
		 * 		路径|零或一|第三方进程参数组|随机字符串
		 */
		public static function encodeThirdPartyProcessString(xoralgorithm:IXORAlgorithm, path:String, enforceBoot:String, args:Array = null):String{
			var regCheck:Number;
			var argsStr:String = "";
			
			switch(enforceBoot){
				case FREE_BOOT:
					regCheck = 0;
					break;
				case REGISTRATION_CHECK:
					regCheck = 1;
					break;					
			}
			
			if(args)
				for(var i:int=0;i<args.length;i++)
					argsStr += "\"" + args[i] + "\" ";
			var plaintext:String = path + "|" +  Number(regCheck) + "|" + argsStr + "|" + xoralgorithm.randomString();
			return Base64.encode( xoralgorithm.code(plaintext) ) ;
		}
		
		private var xoralgorithmFactory:XORAlgorithmFactory;
		public var xoralgorithm:IXORAlgorithm = null;
		private var process:NativeProcess;		
		private var datagramSocket:DatagramSocket;	
		private var product:String;
		private var path:String = "mandatory/InitComponent";
		private static const LOCALIP:String = "127.0.0.1";
		private var localPort:int = 55555;		
		private var trail:Number;
		private var processArgs:Vector.<String> = new Vector.<String>();	
		private var thirdPartyProcess:Vector.<String> = null;
				
		public function ProductRegistration(){
			xoralgorithmFactory = new XORAlgorithmFactory(initXORAlgorithm);
			//xoralgorithm = xoralgorithmFactory.getInstance();
		}
		
		private function initXORAlgorithm(event:Event):void{
			xoralgorithm = xoralgorithmFactory.getInstance();
			dispatchEvent(new Event("AlgorithmReady",true));
		}
		
		public function productRegExecute(product:String, 
											localport:Number, 
											trail:Number,
											thirdPartyProcess:Vector.<String> = null ,
											path:String="mandatory/InitComponent"):void
		{		
			this.product = product;
			this.localPort = localport;
			this.trail = trail;
			this.path = path;
			this.thirdPartyProcess = thirdPartyProcess;
						
			intiNativeProcess();
			initUDP();
			initTF();		
		}
		
		private function initTF():void
		{
			var tf:TextField = new TextField();
			var tformat:TextFormat = new TextFormat("Arial",44);
			tf.setTextFormat(tformat);
			tf.width = 800;
			tf.x = 100;
			tf.y = 100;
			tf.defaultTextFormat = tformat;
			tf.text = "尚未注册，如有问题，请联系软件供应商。";
			this.addChild(tf);
		}
		
		/**
		 * 	启动本地进程
		 */	
		public function intiNativeProcess():void
		{
			var applicationDirectory:String = File.applicationDirectory.nativePath;
			var registrationToolPath:String = applicationDirectory + "\\mandatory\\InitCore.exe";

			
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var file:File = File.applicationDirectory.resolvePath(path);
			nativeProcessStartupInfo.executable = file;			
			processArgs.push(ProductEncryption.getEncryptedProductPortPathXORBase64Encoded(product, localPort,registrationToolPath, trail, xoralgorithm));
			if(thirdPartyProcess){
				for(var i:int=0;i<thirdPartyProcess.length;i++)
					processArgs.push(thirdPartyProcess[i]);
			}				
			nativeProcessStartupInfo.arguments = processArgs;
			process = new NativeProcess();
			process.start(nativeProcessStartupInfo);	
		}
	
		/**
		 * 	UDP通信
		 */	
		private function initUDP():void{
			/**
			 * 	UDP通信初始化
			 */			
			datagramSocket = new DatagramSocket();
			datagramSocket.addEventListener( DatagramSocketDataEvent.DATA, socketDataReceived );
			datagramSocket.bind( localPort, LOCALIP );
			datagramSocket.receive();
			
			/**
			 * 	 AIR应用窗口关闭,UDP通信关闭
			 */
			//this.stage.nativeWindow.addEventListener(flash.events.Event.CLOSE,onClose);
		}
		
		/**
		 * 	发送UDP
		 */
		public function socketDataSend(msg:String, targetPort:Number, targetIP:String="127.0.0.1" ):void{
						//Create a message in a ByteArray
						var data:ByteArray = new ByteArray();
						data.writeUTFBytes(msg);
						//Send the datagram message
						datagramSocket.send( data, 0, 0, targetIP, targetPort);
		}		
		
		/**
		 * 	外部通信接受控制执行
		 */
		private function socketDataReceived( event:DatagramSocketDataEvent ):void
		{
			/**
			 * 	readUTFBytes 等价于 toString();
			 */			
			var receivedPlaintext:String = ProductEncryption.getDecryptedProductPortPathXORBase64Decoded(event.data.toString(), xoralgorithm);
			this.stage.dispatchEvent(new Event((getKeyState(receivedPlaintext) ? "Registed" : "Unregisted"),true));
		}
		
		/**
		 *	 返回数据解析  产品名|监听端口号|是否注册|随机字符串
		 */
		private function getKeyState(plaintext:String):Boolean{
			var results:Array = plaintext.split(/\|/);
			
			if(results.length!=4)
				return false;
			else
			{
				var result:Boolean = (results[2] == 0) ? false : true;
				return result;
			}
		}
				
		/**
		 * 	 AIR应用窗口关闭处理
		 */
		public function onClose():void{
			datagramSocket.close();
			process.exit();
		}
		
	}
}