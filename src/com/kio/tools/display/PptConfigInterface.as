package com.kio.tools.display
{
	import com.kio.tools.event.ControlEvent;
	import com.kio.tools.localStore.LocalStore;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PptConfigInterface extends Sprite
	{		
//		[Embed(source="PPT_Template.jpg")]
//		private var PptConfigBackground:Class;	
//		[Embed(source="DefaultSelection.png")]
//		private var DefaultSelection:Class;
		
		private var folderNameList:Vector.<String>;
		private var configBg:MovieClip;
		private var configDefaultIcon:MovieClip;
		private var configShowingPageCursor:Number=0;
		private var configCurrentCursor:Point;
		private var configCurrentCursorBackup:Point;
		private var configDefaultCursor:Point= new Point(0,0);
		private var tfArr:Vector.<Vector.<TextField>>;
		private var tFormatDefault:TextFormat;
		private var tFormatHighlight:TextFormat;
		
		private const DEFAULT_SEL_POS_X:Number = 600;
		private const POSITION_X:Number = 770;
		private const POSITION_Y:Number = 330;
		private const SPACING_Y:Number = 71;
		
		public function PptConfigInterface(folderNameList:Vector.<String>)
		{
			this.folderNameList = folderNameList;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{			
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//背景
			configBg = new PPT_template();
			this.addChild(configBg);
			//列表
			initTextFormat();
			injectNameList();
			//收藏图标
			configDefaultIcon = new DefaultSelection();
			this.addChild(configDefaultIcon);
			configDefaultIcon.x = DEFAULT_SEL_POS_X;
			configDefaultIcon.y = POSITION_Y - 7;
			//取得已设定的默认文件夹
			getDefaultFolder();			
			updateDefaultIcon();
			configCurrentCursor = configDefaultCursor;
			updateCurrentCursor();
		}
				
		/**
		 * 初始化字体
		 */
		private function initTextFormat():void
		{
			tFormatDefault = new TextFormat();
			tFormatDefault.color = 0x8290a4;
			tFormatDefault.font = "黑体";
			tFormatDefault.size = 22;
			tFormatDefault.bold = true;
			
			tFormatHighlight = new TextFormat();
			tFormatHighlight.color = 0xffffff;
			tFormatHighlight.font = "黑体";
			tFormatHighlight.size = 22;
			tFormatHighlight.bold = true;
		}
		
		/**
		 * 导入文件夹列表
		 */
		private function injectNameList():void
		{						
			tfArr = new Vector.<Vector.<TextField>>();
			var tempCursorA:Number = -1;
			var tempCursorB:Number = 0;
			if(folderNameList){
				for(var i:int=0;i<folderNameList.length;i++){
					if(tempCursorB==0){
						tempCursorA++;
						tfArr.push(new Vector.<TextField>());
					}
					
					tfArr[tempCursorA].push(createTextField(folderNameList[i])); //生成TextField
					this.addChild(tfArr[tempCursorA][tempCursorB]);	//加入舞台
					tfArr[tempCursorA][tempCursorB].x = POSITION_X;
					tfArr[tempCursorA][tempCursorB].y = POSITION_Y + SPACING_Y * tempCursorB;
					tfArr[tempCursorA][tempCursorB].visible = tempCursorA==0 ? true : false; 
					tfArr[tempCursorA][tempCursorB].addEventListener(MouseEvent.CLICK, onItemClick);
					
					tempCursorB++;
					if(tempCursorB>=9)
						tempCursorB=0;
				}
			}
			trace("folderNameList-Length::"+folderNameList.length);
			trace("folderNameList-PageNum::"+tfArr.length);
			
		}		
		
		private function onItemClick(evt:MouseEvent):void{
			var index:Number = tfArr[configShowingPageCursor].indexOf( evt.target );
			this.dispatchEvent(new ControlEvent(ControlEvent.CTRL,new Vector3D(index,0,0),true));
		}
		
		private function createTextField(str:String):TextField{
			var tf:TextField = new TextField();
			tf.width = 1000;
			tf.text = str;
			tf.defaultTextFormat = tFormatDefault;
			tf.setTextFormat(tFormatDefault);
			tf.selectable = false;
			return tf;
		}
		
		/**
		 * 切换页码
		 */
		private function showPage(cursorA:Number):void{
			for(var i:int=0;i<tfArr.length;i++)
				for(var k:int=0;k<tfArr[i].length;k++)
					tfArr[i][k].visible = i==cursorA ? true : false; 
		}
		
		/**
		 * 选择项目
		 */
		public function selectItem(index:Number):void{
			configCurrentCursor.x = configShowingPageCursor;
			configCurrentCursor.y = index;
			configCurrentCursorBackup = configCurrentCursor.clone();
			updateCurrentCursor();
		}
		
		/**
		 * 下一页
		 */
		public function pageNext():void{
			if(configShowingPageCursor+1<tfArr.length)
				configShowingPageCursor++;
			showPage(configShowingPageCursor);
		}
		
		/**
		 * 上一页
		 */
		public function pageBack():void{
			if(configShowingPageCursor-1>=0)
				configShowingPageCursor--;
			showPage(configShowingPageCursor);
		}
		
		/**
		 * 设置默认
		 */
		public function setDefaultFolder():void{
			this.configDefaultCursor = this.configCurrentCursor;
			LocalStore.setLocalData("PptDefaultFolderX", configDefaultCursor.x.toString());
			LocalStore.setLocalData("PptDefaultFolderY", configDefaultCursor.y.toString());
			LocalStore.setLocalData("PptDefaultFolderName", this.tfArr[configDefaultCursor.x][configDefaultCursor.y].text);
			updateDefaultIcon();
		}
		
		/**
		 * 获取默认
		 */
		public function getDefaultFolder():void{
			if(LocalStore.getLocalData("PptDefaultFolderX")){
				configDefaultCursor.x = parseFloat(LocalStore.getLocalData("PptDefaultFolderX"));
				configDefaultCursor.y = parseFloat(LocalStore.getLocalData("PptDefaultFolderY"));
			}
		}
		
		/**
		 * 保存并退出
		 */
		public function settingsSave():void{
		}
		
		/**
		 * 不保存退出
		 */
		public function settingsCancel():void{			
			configCurrentCursor = configCurrentCursorBackup.clone();
			updateCurrentCursor();
		}
		
		/**
		 * 更新【设为默认】图标
		 */
		public function updateDefaultIcon():void{
			if(configShowingPageCursor==configDefaultCursor.x){
				configDefaultIcon.y = POSITION_Y - 7 + this.SPACING_Y * configDefaultCursor.y;
				configDefaultIcon.visible = true;
			}
			else 
				configDefaultIcon.visible = false;				
		}
			
		/**
		 * 更新【当前选中】图示
		 */
		private function updateCurrentCursor():void
		{
			for(var i:int=0;i<tfArr.length;i++)
				for(var k:int=0;k<tfArr[i].length;k++)
					if(i==configCurrentCursor.x && k==configCurrentCursor.y)
						tfArr[i][k].setTextFormat(tFormatHighlight);
					else
						tfArr[i][k].setTextFormat(tFormatDefault);
			
			if(configCurrentCursor.x<tfArr.length)
				if(configCurrentCursor.y<tfArr[configCurrentCursor.x].length)
					LocalStore.setLocalData("PptSelectedFolderName",tfArr[configCurrentCursor.x][configCurrentCursor.y].text);
		}
		
		/**
		 * 模块重新初始化
		 */
		public function reinitialize(folderNameList:Vector.<String>):void{
			this.folderNameList = folderNameList;
			injectNameList();
			getDefaultFolder();			
			updateDefaultIcon();
			configCurrentCursor = configDefaultCursor;
			updateCurrentCursor();
		}
		
		/**
		 * 外部获得当前默认文件夹名称
		 */
		public static function getDefaultFolderName():String{
			return LocalStore.getLocalData("PptDefaultFolderName");
		}
	}
}