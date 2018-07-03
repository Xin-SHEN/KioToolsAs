package com.kio.tools.display
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.display.ContentDisplay;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	public class PptContainer extends Sprite
	{
		//ppt
		private var pptContainer:Sprite;
		private var ppts:Vector.<ContentDisplay>;
		private var pptCursor:Number;
		
		private var directory:File;
		private var dedicatedFolder:String  = "pptDefault";
		private var containerWidth:Number;
		private var containerHeight:Number;
		private var pptList:Array;
		private var _pptName:Vector.<String>;
		private var contentList:Array;
		private var queue:LoaderMax;
		private var showByDefault:Boolean;
		private var autoPlayByDefault:Boolean;
		private var myAutoPlayTimer:Timer;
		private var largePicRollingInterval:Number;
		private var isLoopable:Boolean;
		
		/**
		 * PPT 模块</br> 
		 * 将读取【我的文档/KIO/项目名/目标子文件夹】的所有图片文件(Jpg,Png)
		 * 使用步骤：</br> 
		 * 1. 实例化，构造函数带英文项目文件夹名以便读取系统我的文档下的制定文件夹。</br> 
		 * 2. 公共函数三个：</br> 
		 * 		a. 开关</br> 
		 * 		b. 上一页</br> 
		 * 		c. 下一页</br> 
		 * @param docDirectory 项目文件夹名，如"project" 
		 * @param dedicatedFolder 目标子文件夹名，如"pptDefault"
		 * @param width 显示宽度，如 1920
		 * @param height 显示高度，如 1080
		 * @param showByDefault 是否默认显示
		 * 
		 */
		public function PptContainer(docDirectory:String, dedicatedFolder:String = "pptDefault", 
									 containerWidth:Number=1920, containerHeight:Number=1080, 
									 showByDefault:Boolean = false , 
									 autoPlayByDefault:Boolean=false, 
									 largePicRollingInterval:Number=3000,
									 isLoopable:Boolean = false)
		{
			directory = File.documentsDirectory.resolvePath("KIO/"+docDirectory+"/");
			directory.createDirectory();
			
			if(dedicatedFolder)
				this.dedicatedFolder = dedicatedFolder;
			this.containerWidth = containerWidth;
			this.containerHeight = containerHeight;
			this.showByDefault = showByDefault;
			this.autoPlayByDefault = autoPlayByDefault;
			this.largePicRollingInterval = largePicRollingInterval;
			this.isLoopable = isLoopable;
			
			//获取根文件夹列表
			pptList = directory.getDirectoryListing();
			//获取文件夹名称列表
			pptName = getDirectoryNameList();			
			
			addEventListener(Event.ADDED_TO_STAGE, init);			
		}
		
		/**
		 * 检查是否都是文件夹,剔除非文件夹，获取各PPT文件夹名称列表
		 */
		private function getDirectoryNameList():Vector.<String>
		{
			if(!pptList.length)
				return null;
			
			for(var i:int=pptList.length-1;i>=0;i--)
				if(!(pptList[i] as File).isDirectory)
					pptList.splice(i,1);
			
			var tempArr:Vector.<String> = new Vector.<String>();
			for(var k:int=0;k<pptList.length;k++){
				var tempPath:String = (pptList[k] as File).nativePath;
				tempArr[k]= tempPath.replace(directory.nativePath+"\\","");
			}
			
			return tempArr;
		}
		
		protected function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,init);
			
			var tempFolder:File = directory.resolvePath(dedicatedFolder);
			tempFolder.createDirectory();
			contentList = tempFolder.getDirectoryListing();
			
			if(contentList.length){
				contentList.sort(orderFileNumeric);
				loadPPT();
			}else
				this.dispatchEvent(new Event("pptReady",true));
			
			if(!largePicRollingInterval)
				largePicRollingInterval=3000;			
			myAutoPlayTimer = new Timer(largePicRollingInterval,0);
			myAutoPlayTimer.addEventListener(TimerEvent.TIMER, onTime);
			
		}
		
		protected function onTime(event:TimerEvent):void
		{
			pptNext();
		}
		
		/**
		 * 模块重新初始化
		 */
		public function reinitialize(selectedFolderName:String = "pptDefault"):void{
			this.dedicatedFolder = selectedFolderName;
			//获取根文件夹列表
			pptList = directory.getDirectoryListing();
			//获取文件夹名称列表
			pptName = getDirectoryNameList();
			//获取目标文件夹文件列表
			contentList =  directory.resolvePath(dedicatedFolder).getDirectoryListing();
			contentList.sort(orderFileNumeric);
			loadPPT();
		}
			
		/**
		 * 方法::按文件数字排序（文件名必须为数字，扩展名不处理）
		 */
		private function orderFileNumeric(a, b):int 
		{ 
//			var navPath:String = File.documentsDirectory.resolvePath("KIO/SIP/").nativePath+"\\";
			var navPath:String = directory.nativePath +"\\"; 
			var filePath1:String = (a as File).nativePath;
			var filePath2:String = (b as File).nativePath;
			
			var fileName1:String = filePath1.replace(navPath+dedicatedFolder+"\\","");
			var fileName2:String = filePath2.replace(navPath+dedicatedFolder+"\\","");
			
			var fileNameSplitArray1:Array = fileName1.split(/\./);
			if(fileNameSplitArray1.length!=2)
				throw new Error("文件名错误。");
			else
			{
				var fileIndex1:Number = parseInt(fileNameSplitArray1[0]);
			}
			
			var fileNameSplitArray2:Array = fileName2.split(/\./);
			if(fileNameSplitArray2.length!=2)
				throw new Error("文件名错误。");
			else
			{
				var fileIndex2:Number = parseInt(fileNameSplitArray2[0]);
			}
			
			
			if (fileIndex1 < fileIndex2) 
			{ 
				return -1; 
			} 
			else if (fileIndex1 > fileIndex2) 
			{ 
				return 1; 
			} 
			else 
			{ 
				return 0; 
			} 
		} 
		
		
		/**
		 * 读取ppt图片
		 */
		private function loadPPT():void
		{
			if(queue)
				queue.unload();
			queue = new LoaderMax({name:"pptQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
			
//			trace("新顺序");
			for (var i:uint = 0; i < contentList.length; i++) {
//				trace(list[i].nativePath);
				queue.append( new ImageLoader( contentList[i].nativePath, {name:"pptBeta"+i, width:this.containerWidth, height:this.containerHeight, scaleMode:"stretch"}) );
			}
			queue.load();	
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		private function progressHandler(event:LoaderEvent):void {
//			trace("progress: " + event.target.progress);
		}
		
		/**
		 * ppt内容初始化
		 */
		private function completeHandler(event:LoaderEvent):void {
			trace(event.target + " is complete!");
			
			pptContainer = new Sprite();
			ppts = new Vector.<ContentDisplay>();
			for(var i:int=0;i<contentList.length;i++){
				ppts.push(LoaderMax.getContent("pptBeta"+i));
				pptContainer.addChild(ppts[i]);
			}
			
			this.addChild(pptContainer);
			pptContainer.visible = false;
			pptCursor = 0;
			
			this.dispatchEvent(new Event("pptReady",true));
			if(showByDefault)
				switchPpt(true);
			if(this.autoPlayByDefault)
				autoPlay(true);
		}
		
		
		/**
		 * 开关PPT
		 */
		public function switchPpt(on:Boolean):void
		{
			if(ppts){
				if(on){
					//PPT
					pptCursor = 0;
					switchPptPage(pptCursor);
					pptContainer.visible = true;
				}else{
					pptContainer.visible = false;
				}
			}
		}
		
		/**
		 * 	PPT下一页
		 */
		public function pptNext():void{
			if(ppts){
				pptCursor++;
				if(pptCursor>=ppts.length){
					pptCursor= this.isLoopable ? 0 : ppts.length-1;
				}else{
					switchPptPage(pptCursor);
				}
			}
		}
		
		/**
		 * 	PPT上一页
		 */
		public function pptBack():void{
			if(ppts){
				pptCursor--;
				if(pptCursor<0){
					pptCursor=0;
				}else{
					switchPptPage(pptCursor);
				}
			}
		}
		
		/**
		 *  切换PPT页码
		 */
		private function switchPptPage(index:Number):void{
			if(ppts){
				for(var i:int=0;i<ppts.length;i++){
					ppts[i].visible = i==index ? true : false;
				}
			}
		}
		
		/**
		 * 切换是否要自动循环播放
		 */
		public function autoPlay(on:Boolean):void{
			if(on)
				myAutoPlayTimer.start();
			else
				myAutoPlayTimer.reset();
		}

		public function get pptName():Vector.<String>
		{
			return _pptName;
		}

		public function set pptName(value:Vector.<String>):void
		{
			_pptName = value;
		}

	}
}