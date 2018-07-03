package com.kio.tools.display
{
	import com.kio.tools.display.PptContainer;
	import com.kio.tools.event.ControlEvent;
	import com.kio.tools.localStore.LocalStore;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class PptModule extends Sprite
	{		
		//config
		private var xmlConfig:XML;
		private var pptModulePosition:Point;
		private var showByDefault:Boolean;
		private var autoPlayByDefault:Boolean;
		private var isLoopable:Boolean;
		
		//display
		private var myPptConfigInterface:PptConfigInterface;
		private var myPptContainer:PptContainer;
		private var pptOutsideSwitch:PptOutsideSwitch;
		private var controlPanel:Sprite;
		private var pptNextIcon:Next;
		private var pptBackIcon:Back;
		private var settingIcon:Setting;
		private var returnIcon:Replay;
		private var controlConfigPanel:Sprite;
		private var pptCtrlNextIcon:Next;
		private var pptCtrlBackIcon:Back;
		private var pptCtrlReturnIcon:Replay;
		
		//control
		private var _x1:Number, _x2:Number, _t1:uint,_t2:uint;
		
		public function PptModule(xmlConfig,
								  showByDefault:Boolean = false , 
								  autoPlayByDefault:Boolean=false, 
								  isLoopable:Boolean = false)
		{
			this.xmlConfig = xmlConfig;
			this.showByDefault = showByDefault;
			this.autoPlayByDefault = autoPlayByDefault;
			this.isLoopable = isLoopable;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			myPptContainer = new PptContainer(	xmlConfig.storageURL[0],PptConfigInterface.getDefaultFolderName(),
												xmlConfig.PptModuleWidth[0],xmlConfig.PptModuleHeight[0],
												showByDefault,
												autoPlayByDefault,xmlConfig.PicRollingInterval[0],
												isLoopable);
			
			pptModulePosition = new Point(parseFloat(xmlConfig.PptModulePositionX[0]),parseFloat(xmlConfig.PptModulePositionY[0]));
			
			
			//ppt 主体内容
			this.addChild(myPptContainer);
			myPptContainer.x = pptModulePosition.x;
			myPptContainer.y = pptModulePosition.y;	
			
			//ppt 设置
			myPptConfigInterface = new PptConfigInterface(myPptContainer.pptName);
			this.addChild(myPptConfigInterface);
			myPptConfigInterface.visible = false;
			
			addListeners();
		}
		
		/**
		 * 更改设置界面分辨率
		 */
		public function setConfigInterfaceResolution(width:Number,height:Number):void{
			myPptConfigInterface.scaleX = width / 1920;
			myPptConfigInterface.scaleY = height / 1080;
		}
		
		/**
		 * 添加滑动监听器
		 */
		private function addListeners():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler, false, 0, true);
			this.addEventListener(ControlEvent.CTRL, onVisualControl);
		}
		
		protected function onVisualControl(evt:ControlEvent):void
		{
			selectItem(evt.cursor.x);
//			reinitialzePptContainer();
			this.switchPpt(true);
			this.switchSettings(false);
			this.controlConfigPanel.visible = false;
			this.controlPanel.visible = true;
			this.pptOutsideSwitch.visible = false;
		}
		private function _mouseDownHandler(event:MouseEvent):void {
			_x1 = _x2 = this.mouseX;
			_t1 = _t2 = getTimer();
			this.stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler, false, 0, true);
			this.addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
		}
		
		private function _enterFrameHandler(event:Event):void {
			_x2 = _x1;
			_t2 = _t1;
			_x1 = this.mouseX;
			_t1 = getTimer();
		}
		private function _mouseUpHandler(event:MouseEvent):void {
			this.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
			var elapsedTime:Number = (getTimer() - _t2) / 1000;
			var xVelocity:Number = (this.mouseX - _x2) / elapsedTime;
			//we make sure that the velocity is at least 20 pixels per second in either direction in order to advance. Otherwise, look at the position of the _container and if it's more than halfway into the next/previous panel, tween there.
			if ( xVelocity > 20 ) {
				this.pptBack();
			} else if (xVelocity < -20 ) {
				this.pptNext();
			}
		}
		
		/**
		 * 添加外部PPT开启按钮
		 */
		public function addPptSwitchOutside(x:Number=0, y:Number=0):void{
			controlPanel = new Sprite();
			this.addChild(controlPanel);
			controlPanel.visible = false;
						
			pptNextIcon = new Next();
			pptBackIcon = new Back();
			settingIcon = new Setting();
			returnIcon = new Replay();
			pptBackIcon.x = x;
			pptNextIcon.x = pptBackIcon.x + 70;
			settingIcon.x = pptBackIcon.x + 70*2;
			returnIcon.x = pptBackIcon.x + 70*3;
			pptNextIcon.y = pptBackIcon.y = settingIcon.y = returnIcon.y = y;
			controlPanel.addChild(pptNextIcon);
			controlPanel.addChild(pptBackIcon);
			controlPanel.addChild(settingIcon);
			controlPanel.addChild(returnIcon);
			pptNextIcon.addEventListener(MouseEvent.CLICK, pptNext);
			pptBackIcon.addEventListener(MouseEvent.CLICK, pptBack);
			settingIcon.addEventListener(MouseEvent.CLICK, onSetting);
			returnIcon.addEventListener(MouseEvent.CLICK, onReturn);
			
			controlConfigPanel = new Sprite();
			this.addChild(controlConfigPanel);
			controlConfigPanel.visible = false;
			
			pptCtrlBackIcon = new Back();
			pptCtrlNextIcon = new Next();
			pptCtrlReturnIcon = new Replay();
			pptCtrlBackIcon.x = x;
			pptCtrlNextIcon.x = pptCtrlBackIcon.x + 70;
			pptCtrlReturnIcon.x = pptCtrlBackIcon.x + 70*2;
			pptCtrlBackIcon.y = pptCtrlNextIcon.y = pptCtrlReturnIcon.y = y;
			controlConfigPanel.addChild(pptCtrlBackIcon);
			controlConfigPanel.addChild(pptCtrlNextIcon);
			controlConfigPanel.addChild(pptCtrlReturnIcon);
			pptCtrlNextIcon.addEventListener(MouseEvent.CLICK, pageNext);
			pptCtrlBackIcon.addEventListener(MouseEvent.CLICK, pageBack);
			pptCtrlReturnIcon.addEventListener(MouseEvent.CLICK, onCtrlReturn);
			
			myPptContainer.switchPpt(false);
			pptOutsideSwitch = new PptOutsideSwitch();
			pptOutsideSwitch.x = x;
			pptOutsideSwitch.y = y;
			this.addChild(pptOutsideSwitch);
			pptOutsideSwitch.addEventListener(MouseEvent.CLICK, onOutsideClick);			
		}
		
		/**
		 * 退出配置
		 */
		protected function onCtrlReturn(event:MouseEvent):void
		{
			switchSettings(false);	
			this.controlConfigPanel.visible = false;
			this.controlPanel.visible = true;
			this.pptOutsideSwitch.visible = false;
		}
		/**
		 * 退出PPT
		 */
		protected function onReturn(event:MouseEvent):void
		{						
			this.switchSettings(false);	
			this.controlConfigPanel.visible = false;
			this.controlPanel.visible = false;
			this.pptOutsideSwitch.visible = true;
			this.switchPpt(false);
			
			this.dispatchEvent(new Event("pptOff",true));
		}
		
		/**
		 * 开启配置页面
		 */
		protected function onSetting(event:MouseEvent):void
		{
			this.switchSettings(true);	
			this.controlConfigPanel.visible = true;
			this.controlPanel.visible = false;
			this.pptOutsideSwitch.visible = false;
		}
		
		/**
		 * 外部可视PPT模块
		 * 
		 */
		protected function onOutsideClick(event:MouseEvent):void
		{			
			this.dispatchEvent(new Event("pptOn",true));
			this.switchPpt(true);
			this.switchSettings(false);	
			this.controlConfigPanel.visible = false;
			this.controlPanel.visible = true;
			this.pptOutsideSwitch.visible = false;
		}		
		
		/**
		 * 开关PPT
		 */
		public function switchPpt(on:Boolean):void
		{
			myPptContainer.switchPpt(on);
		}
		
		/**
		 * 保存并退出
		 */
		public function settingsSave():void{
			switchSettings(false);
		}
		
		/**
		 * 不保存退出
		 */
		public function settingsCancel():void{
			myPptConfigInterface.settingsCancel();
			switchSettings(false);
		}
		
		/**
		 * 开关设置界面
		 */
		public function switchSettings(on:Boolean):void{
			if(on){
				myPptContainer.switchPpt(false);
				myPptConfigInterface.visible = true;
				myPptConfigInterface.updateDefaultIcon();
				if(this.controlPanel){
					this.controlPanel.visible = true;
					this.pptOutsideSwitch.visible = false;
				}
			}else{
				myPptContainer.switchPpt(true);
				myPptConfigInterface.visible = false;
				if(this.controlPanel){
					this.controlPanel.visible = false;
					this.pptOutsideSwitch.visible = false;
				}
			}
		}
		
		/**
		 * 设置选择
		 */
		public function selectItem(index:Number):void{
			myPptConfigInterface.selectItem(index);
		}
		
		/**
		 * 	PPT下一页
		 */
		public function pptNext(evt:Event = null):void{
			myPptContainer.pptNext();
		}
		
		/**
		 * 	PPT上一页
		 */
		public function pptBack(evt:Event = null):void{
			myPptContainer.pptBack();
		}
		
		/**
		 *  切换PPT页码
		 */
		private function switchPptPage(index:Number):void{
			myPptContainer.switchPpt(index);
		}
		
		/**
		 * 切换是否要自动循环播放
		 */
		public function autoPlay(on:Boolean):void{
			myPptContainer.autoPlay(on);
		}
		
		/**
		 * 设置下一页
		 */
		public function pageNext(evt:MouseEvent = null):void{
			myPptConfigInterface.pageNext();
		}
		
		/**
		 * 设置上一页
		 */
		public function pageBack(evt:MouseEvent = null):void{
			myPptConfigInterface.pageBack();
		}
		
		/**
		 * 设置默认
		 */
		public function setDefault():void{
			myPptConfigInterface.setDefaultFolder();
		}
		
		/**
		 * 获取默认
		 */
		public function getDefault():void{
			myPptConfigInterface.getDefaultFolder();
		}
		
		/**
		 * 模块重新初始化
		 */
		public function reinitialize():void{
			myPptContainer.reinitialize(PptConfigInterface.getDefaultFolderName());
			myPptConfigInterface.reinitialize(myPptContainer.pptName);
		}
		
		/**
		 * 重新初始化pptContainer
		 */
		public function reinitialzePptContainer():void{
			myPptContainer.reinitialize(LocalStore.getLocalData("PptSelectedFolderName"));
		}
	}
}