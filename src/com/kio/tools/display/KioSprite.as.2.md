package com.kio.tools.display
{
	import com.kio.tools.localStore.LocalStore;
	import com.kio.tools.udp.UDPReceivedDataEvent;
	import com.kio.tools.udp.UDP_Initialization_v2;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.setTimeout;
	
	/**
	 * 	KioSprite 
	 * 	功能：
	 * 	----------- 
	 * 	UDP通信；
	 * 	系统托盘；
	 * 	窗口调整；
	 * 	本机加密储存；
	 *  授权处理；
	 * 
	 */
	public class KioSprite extends Sprite
	{
		public static const NATIVE_WINDOW_BORDER_LEFT:Number = 9;
		public static const NATIVE_WINDOW_BORDER_TOP:Number = 36;
		
		[Embed(source="../assets/icons/48.png")]
		private static const TrayIcon:Class;
		private var udpInit:UDP_Initialization_v2;
		private var productName:String;
		private var localPort:Number;
		private var blockingPeriod:Number;
		private var allowWindowExit:Boolean;
		private var laterInitUDP:Boolean = false;
		
		private var onRepositioning:Boolean = false;
		private var command1:NativeMenuItem;				
		private var showMouse:NativeMenuItem;
		private var hideMouse:NativeMenuItem;
		private var hideWindow:NativeMenuItem;
		private var showWindow:NativeMenuItem;
		private var windowFullscreen:NativeMenuItem;
		private var windowNormal:NativeMenuItem;
		private var repositionWindow:NativeMenuItem;
		private var lockPositionWindow:NativeMenuItem ;
		private var exitCommand:NativeMenuItem ;			
		private var companyTitle:NativeMenuItem ;
		
		private var securityLevel:Number = 1;
		private var factory:EncryptionFactory;
		private var iXinSpirit:IXinSpirit = null;
		private var watermark:Sprite = new Sprite();
		
		/**
		 * 	@param productName 产品名
		 * 	@param localUdpPort UDP本地端口	
		 *  @param blockingPeriod UDP阻断间隔
		 * 	@param allowWindowExit 允许应用完全退出
		 * 	@param MKCLOGO 启动LOGO
		 * 	@param laterInitUDP UDP初始化是否滞后
		 * 
		 */
		public function KioSprite(productName:String ,localUdpPort:Number = 55555, blockingPeriod:Number = 0, allowWindowExit:Boolean = true, MKCLOGO:Boolean = true, laterInitUDP:Boolean = false, securityLevel:Number = 2)
		{
			if(MKCLOGO){
//				this.stage.nativeWindow.visible = false;
				var myLOGO:MKC = new MKC();				
				setTimeout(showYourself,4000);
			}
			this.productName = productName;
			this.localPort = localUdpPort;
			this.blockingPeriod = blockingPeriod;
			this.allowWindowExit = allowWindowExit;
			this.laterInitUDP = laterInitUDP;
			this.securityLevel = securityLevel;
			super();
			if(stage) 
				init();
			else
				this.addEventListener(Event.ADDED_TO_STAGE,init);
			
			//授权验证
			this.stage.addEventListener("AUTHORIZATION_SUCCEEDED",auth_succeeded);
			this.stage.addEventListener("AUTHORIZATION_FAILED",auth_failed);
			makeSpirit();
		}
		
		protected function auth_failed(event:Event):void
		{
			trace("Auth failed handled");
			this.watermark = new Sprite();
			this.stage.addChild(watermark);
			for(var i:int=0;i<this.stage.stageWidth%350+1;i++){
				for(var j:int=0;j<this.stage.stage.stageHeight%200+1;j++){
					var w:MovieClip = new KIOLOGO();
					w.x = -73 + i*350;
					w.y = -47 + j*200;
					this.watermark.addChild(w);
				}
			}
		}
		
		protected function auth_succeeded(event:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		/**
		 * 	授权验证步骤一
		 */
		private function makeSpirit(e:Event=null):void{
			if(LocalStore.getLocalData("DoYouHaveAPrueSoul")){			
				factory = new EncryptionFactory(spiritCompleteHandler);
			}else{
				this.stage.dispatchEvent(new Event("AUTHORIZATION_FAILED",true));
				trace("AUTHORIZATION FAILED.");
			}
		}
		
		/**
		 * 	授权验证步骤二
		 */
		private function spiritCompleteHandler(e:Event=null):void{
			iXinSpirit = factory.getInstance();
			testify();
		}
		
		/**
		 * 	授权验证步骤三
		 */
		private function testify():void
		{
			var code:String;
			switch(securityLevel){
				case 2:
					setTimeout(defaultSecurity,60000);
					break;
				
				case 1:
					code = iXinSpirit.getCriticalCode();
					if(code==LocalStore.getLocalData("DoYouHaveAPrueSoul")){
						this.stage.dispatchEvent(new Event("AUTHORIZATION_SUCCEEDED",true));
						trace("AUTHORIZATION SUCCEEDED.");
						this.watermark.visible = false;
					}else{
						this.stage.dispatchEvent(new Event("AUTHORIZATION_FAILED",true));
						trace("AUTHORIZATION FAILED.");
					}
					break;
				
				case 0:
					code = iXinSpirit.getCriticalCodeII();	
					if(code==LocalStore.getLocalData("DoYouHaveAPrueSoul")){
						this.stage.dispatchEvent(new Event("AUTHORIZATION_SUCCEEDED",true));
						trace("AUTHORIZATION SUCCEEDED.");
						this.watermark.visible = false;
					}else{
						this.stage.dispatchEvent(new Event("AUTHORIZATION_FAILED",true));
						trace("AUTHORIZATION FAILED.");
					}
					break;
			}
			
			
		}
		
		/**
		 * 测试授权处理
		 */
		private function defaultSecurity():void
		{
			var code:String = iXinSpirit.getCriticalCode();
			if(code==LocalStore.getLocalData("DoYouHaveAPrueSoul")){
				this.stage.dispatchEvent(new Event("AUTHORIZATION_SUCCEEDED",true));
				trace("AUTHORIZATION SUCCEEDED.");
				this.watermark.visible = false;
			}else{
				this.stage.dispatchEvent(new Event("AUTHORIZATION_FAILED",true));
				trace("AUTHORIZATION FAILED.");
			}
		}		
		
		private function showYourself():void
		{
			this.stage.nativeWindow.visible = true;
		}
		
		private function init(evt:Event=null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
			trace("StageNativeWindowIsSupported::"+ NativeWindow.isSupported);
			trace("ScreenQuantity::" + Screen.screens.length);
			
			//窗体位置
			if(LocalStore.getLocalData("nativeWindowPositionX")){
				this.stage.nativeWindow.x = parseFloat(LocalStore.getLocalData("nativeWindowPositionX"));
				this.stage.nativeWindow.y = parseFloat(LocalStore.getLocalData("nativeWindowPositionY"));
			}
			
			//鼠标隐藏
			if(LocalStore.getLocalData("mouseVisible")=="show")
				Mouse.show();
			else if(LocalStore.getLocalData("mouseVisible")=="hide")
				Mouse.hide();
			
			//窗体全屏
			if(LocalStore.getLocalData("nativeWindowMaximized") == "true")
				stage.displayState = StageDisplayState.FULL_SCREEN;
			else if(LocalStore.getLocalData("nativeWindowMaximized")=="false")
				stage.displayState = StageDisplayState.NORMAL;
			
			if(!laterInitUDP)		
				initUDP();
			
			
			initTray();
		}
		
		public function initUDP(localPort:Number=NaN,blockingPeriod:Number=NaN):void
		{
			trace("Initializing UDP...");
			if(localPort)
				this.localPort = localPort;
			if(blockingPeriod)
				this.blockingPeriod = blockingPeriod;
			udpInit = new UDP_Initialization_v2(this.stage,  	//当前舞台
				"0.0.0.0", 	//本地IP地址
				this.localPort,	//本地端口号
				this.blockingPeriod
			);
			
			//	 AIR应用窗口关闭,UDP通信关闭
			if(allowWindowExit)
				NativeApplication.nativeApplication.autoExit = true;
//				this.stage.nativeWindow.addEventListener( Event.EXITING, udpInit.onClose);
			else
				NativeApplication.nativeApplication.autoExit = false;
//			NativeApplication.nativeApplication.autoExit = true;
//			this.stage.nativeWindow.addEventListener( Event.EXITING, this.onClose);
//			this.stage.nativeWindow.addEventListener( Event.CLOSE, this.onClose);
			
			//	设置侦听器，当收到UDP数据时处理
			this.stage.addEventListener(UDPReceivedDataEvent.UDP_DATA, socketDataReceived);
			this.stage.addEventListener(UDPReceivedDataEvent.UDP_DATA, autoriztionReceived);
			
		}
		
		
//		private function onClose(evt:Event):void{			
//			NativeApplication.nativeApplication.exit();
//		}
		
		
		private function initTray():void
		{
			trace("Initializing Tray...");
			
			/**
			 * 	初始化托盘
			 */
			var iconMenu:NativeMenu = new NativeMenu();
			NativeApplication.nativeApplication.icon.bitmaps = [new TrayIcon().bitmapData];
			
			command1 = iconMenu.addItem(new NativeMenuItem(">> "+productName+" <<"));		
			showMouse = iconMenu.addItem(new NativeMenuItem("显示鼠标"));
			hideMouse = iconMenu.addItem(new NativeMenuItem("隐藏鼠标"));
			showWindow = iconMenu.addItem(new NativeMenuItem("显示窗体"));
			hideWindow = iconMenu.addItem(new NativeMenuItem("隐藏窗体"));
			windowFullscreen = iconMenu.addItem(new NativeMenuItem("窗体全屏"));
			windowNormal = iconMenu.addItem(new NativeMenuItem("窗体窗口化"));
			repositionWindow = iconMenu.addItem(new NativeMenuItem("窗体重定位>使用方向键"));
			lockPositionWindow = iconMenu.addItem(new NativeMenuItem("保存窗体位置>锁定方向键"));
			exitCommand = iconMenu.addItem(new NativeMenuItem("退出"));			
			companyTitle = iconMenu.addItem(new NativeMenuItem("苏州科奥美康创智能科技有限公司"));
			
			windowFullscreen.addEventListener(Event.SELECT, makeWindowFullscreen);
			windowNormal.addEventListener(Event.SELECT, makeWindowNormal);
			repositionWindow.addEventListener(Event.SELECT, repositionNativeWindow);
			lockPositionWindow.addEventListener(Event.SELECT, lockPositionNativeWindow);
			showMouse.addEventListener(Event.SELECT, btnShowMouseHandler);	
			hideMouse.addEventListener(Event.SELECT, btnHideMouseHandler);	
			showWindow.addEventListener(Event.SELECT, btnShowWindowHandler);	
			hideWindow.addEventListener(Event.SELECT, btnHideWindowHandler);	
			exitCommand.addEventListener(Event.SELECT, btnExitClick);	
			
			/**
			 * 	Tray for Windows
			 */
			if (NativeApplication.supportsSystemTrayIcon) {
				var systray:SystemTrayIcon =
					NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systray.tooltip = productName;
				systray.menu = iconMenu;
			}
			
			/**
			 *  Dock for iOS
			 */
			if (NativeApplication.supportsDockIcon){
				var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dock.menu = iconMenu;
			}
			
			//侦听键盘事件
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			
			//  窗体变化侦听
			this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
		}	
		
		/**
		 * 右键处理
		 */
		protected function onRightClick(event:MouseEvent):void
		{
			trace("RIGHT CLICK.");
		}
		
		/**
		 * 隐藏窗体
		 */
		protected function btnHideWindowHandler(event:Event):void
		{
			this.stage.nativeWindow.visible =false;
		}
		
		/**
		 * 显示窗体
		 */
		protected function btnShowWindowHandler(event:Event):void
		{
			this.stage.nativeWindow.visible =true;
			this.stage.nativeWindow.alwaysInFront = true;
			this.stage.nativeWindow.activate();
//			this.stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		/**
		 * 	窗体窗口化
		 */
		protected function makeWindowNormal(event:Event):void
		{
			stage.displayState = StageDisplayState.NORMAL;
			LocalStore.setLocalData("nativeWindowMaximized", "false");
		}
		
		/**
		 * 	窗体全屏
		 */
		protected function makeWindowFullscreen(event:Event):void
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			LocalStore.setLocalData("nativeWindowMaximized", "true");
		}
		
		/**
		 * 窗体全屏侦听处理
		 */
		protected function fullScreenHandler(event:FullScreenEvent):void
		{
			if(event.fullScreen){
				repositionWindow.enabled = false;
				lockPositionWindow.enabled = false;
			}
			else{				
				repositionWindow.enabled = true;
				lockPositionWindow.enabled = true;
			}
				
		}
		
		/**
		 *  系统托盘退出按钮处理 | 窗口重定位
		 */
		protected function repositionNativeWindow(event:Event):void
		{
			stage.nativeWindow.activate();
//			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKey);
			onRepositioning = true;
		}
		
		/**
		 *  系统托盘退出按钮处理 | 关闭窗口重定位
		 */
		protected function lockPositionNativeWindow(event:Event):void
		{
//			stage.removeEventListener(KeyboardEvent.KEY_DOWN,onKey);
			onRepositioning = false;		
			stage.nativeWindow.activate();
			LocalStore.setLocalData("nativeWindowPositionX", this.stage.nativeWindow.x.toString());
			LocalStore.setLocalData("nativeWindowPositionY", this.stage.nativeWindow.y.toString());
		}
		
		/**
		 *  窗口重定位 | 按键处理
		 */
		private function onKey(event:KeyboardEvent):void{ 
			trace("KeyPressed"); 
				switch(event.keyCode){ 
					case Keyboard.LEFT : 
						if(onRepositioning)
							moveLeft(); 
						break; 
					case Keyboard.RIGHT : 
						if(onRepositioning)
							moveRight(); 
						break; 
					case Keyboard.UP : 
						if(onRepositioning)
							moveUp(); 
						break; 
					case Keyboard.DOWN : 
						if(onRepositioning)
							moveDown(); 
						break; 
					case Keyboard.ESCAPE:
//						this.stage.nativeWindow.visible = false;
						if(allowWindowExit)
							NativeApplication.nativeApplication.exit();
						break;	
					case Keyboard.F1:
						this.stage.nativeWindow.visible = false;
						break;
					case Keyboard.F2:
						this.stage.nativeWindow.visible = true;
						break;
					case Keyboard.F3:
						this.stage.nativeWindow.visible = true;
						stage.displayState = StageDisplayState.FULL_SCREEN;
						break;
				}    
		}  
		
		private function moveDown():void
		{
			stage.nativeWindow.y++;
		}
		
		private function moveUp():void
		{
			stage.nativeWindow.y--;
		}
		
		private function moveRight():void
		{
			stage.nativeWindow.x++;
		}
		
		private function moveLeft():void
		{
			stage.nativeWindow.x--;
		}
		
		
		
		/**
		 *  系统托盘退出按钮处理 | 显示鼠标
		 */
		private function btnShowMouseHandler(event:Event):void {
			Mouse.show();
			LocalStore.setLocalData("mouseVisible", "show");
		}
		
		/**
		 *  系统托盘退出按钮处理 | 隐藏鼠标
		 */
		private function btnHideMouseHandler(event:Event):void {
			Mouse.hide();
			LocalStore.setLocalData("mouseVisible", "hide");
		}
		
		/**
		 *  系统托盘退出按钮处理 | 退出
		 */
		private function btnExitClick(event:Event):void {
			NativeApplication.nativeApplication.icon.bitmaps = [];
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * 系统托盘按钮管理
		 */
		private function manageIcon():void{
//			if(Mouse.hi)
//			showWindow.
		}
		
		/**
		 *	UDP接受处理</br>
		 * 	默认处理: </br>
		 * 	switch(evt.data){ </br>
				case "windowActivate":	</br>
					this.stage.nativeWindow.orderToFront();		</br>		
					this.stage.nativeWindow.activate();</br>
					break;</br>
				case "windowAlwaysInFront":</br>
					this.stage.nativeWindow.alwaysInFront = true;</br>
					break;</br>
				case "windowAlwaysInFrontOff":</br>
					this.stage.nativeWindow.alwaysInFront = false;</br>
					break;</br>
			}</br>
			var data:String = evt.data;</br>
			var pattern1:RegExp = /Index\d/;</br>
			if(pattern1.test(data)){</br>
			 	Index = Number(data.replace(/Index/,""));	</br>
				return;</br>
			}</br>
		 */		
		protected function socketDataReceived(evt:UDPReceivedDataEvent):void
		{
			trace("received:"+evt.data);
			
//			var data:String = evt.data;
//			var pattern1:RegExp = /Index\d/;
//			if(pattern1.test(data)){
//			Index = Number(data.replace(/Index/,""));		
//				return;
//			}			
			
			switch(evt.data){
				case "windowActivate":	
					this.stage.nativeWindow.orderToFront();				
					this.stage.nativeWindow.activate();
					break;
				case "windowAlwaysInFront":
					this.stage.nativeWindow.alwaysInFront = true;
					break;
				case "windowAlwaysInFrontOff":
					this.stage.nativeWindow.alwaysInFront = false;
					break;
				case "nativeWindow|hide":
					this.stage.nativeWindow.visible = false;
					break;
				case "nativeWindow|show":
					this.stage.nativeWindow.visible = true;
					break;
			}
		}
		
		
		protected function autoriztionReceived(evt:UDPReceivedDataEvent):void
		{		
			var data:String = evt.data;
			var pattern1:RegExp = /purify\|/;
			if(pattern1.test(data)){
				var soul:String = data.replace(/purify\|/,"");	
				LocalStore.setLocalData("DoYouHaveAPrueSoul",soul);
				trace("Priority Critically Alternated...");
				testify();
				return;
			}
		}
		
		
		/**
		 * 	UDP发送处理
		 */
		protected function sendUdpMessage(ip:String, port:Number, msg:String):void{
			udpInit.sendUDPdata(ip, port, msg);
		}
	}
}