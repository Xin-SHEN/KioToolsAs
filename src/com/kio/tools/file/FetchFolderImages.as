package com.kio.tools.file
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.display.ContentDisplay;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;

	public class FetchFolderImages extends Sprite
	{						
		private var sequenceName:String;
		public var images:Vector.<ContentDisplay>;

		private var directory:File;
		private var folderList:Array;
		private var imagePathArr:Array;
		private var imageArr:Array;
		
		/**
		 * 	根据目录名，提取子目录和子目录下的所有图片文件
		 */
		public function FetchFolderImages(folderName:String,sequenceName:String,width:Number = 1920, height:Number=1080,scaleMode:String = "stretch"):void
		{
			this.sequenceName = sequenceName;
			
			directory = File.documentsDirectory.resolvePath("KIO/"+folderName+"/");
			directory.createDirectory();
			
			//获取图片文件夹列表
			folderList = directory.getDirectoryListing();
			//folderList.sort(orderFileNumeric);
			
			//获取图片路径列表
			imagePathArr = filterImage(folderList);	
			trace(imagePathArr);
			
			//获取图片ContentDisplay列表
			imageArr = loadImage(imagePathArr,sequenceName,width,height,scaleMode);
			
			//return imagePathArr;
		}
		
		/**
		 * 	根据目录名，提取子目录和子目录下的所有图片文件
		 */
		public function FetchImages(folderName:String,sequenceName:String,width:Number = 1920, height:Number=1080,scaleMode:String = "stretch"):void
		{
			this.sequenceName = sequenceName;
			
			directory = File.documentsDirectory.resolvePath("KIO/"+folderName+"/");
			directory.createDirectory();
			
			//获取图片文件夹列表
			folderList = directory.getDirectoryListing();
			folderList.sort(orderFileNumeric);
			
			//获取图片路径列表
			imagePathArr = filterImage(folderList);	
			trace(imagePathArr);
			
			//获取图片ContentDisplay列表
			imageArr = loadImage(imagePathArr,sequenceName,width,height,scaleMode);
			
			//return imagePathArr;
		}
		
		
		/**
		 * 过滤出图片文件
		 */
		private function filterImage(folderList:Array):Array{
						
			var arr:Array = [];
			for(var i:int=0;i<folderList.length;i++){
				if((folderList[i] as File).extension =="jpg"
					||(folderList[i] as File).extension=="JPG"
					||(folderList[i] as File).extension=="png"
					||(folderList[i] as File).extension=="PNG"){					
					arr.push((folderList[i] as File).nativePath);							
				}
			}
			return arr;
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
			
			var fileName1:String = filePath1.replace(navPath,"");
			var fileName2:String = filePath2.replace(navPath,"");
			
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
		 * 加载图片文件
		 */
		private function loadImage(imagePathArr:Array, sequenceName:String, widthArg:Number, heightArg:Number,scaleModeArg:String):Array
		{
			var queue:LoaderMax = new LoaderMax({onComplete:onLoadComplete});
			for (var i:int = 0; i < imagePathArr.length; i++) {
				queue.append( new ImageLoader( imagePathArr[i], {name:sequenceName+i, width:widthArg, height:heightArg, scaleMode:scaleModeArg}) );
			}
			queue.load();
			return null;
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("error occured with " + event.target + ": " + event.text);
		}
		
		private function progressHandler(event:LoaderEvent):void {
			//			trace("progress: " + event.target.progress);
		}
		
		private function onLoadComplete(e:Event = null):void{
			this.images = new Vector.<ContentDisplay>();
			for(var i:int=0;i<imagePathArr.length;i++)
				images.push(LoaderMax.getContent(sequenceName+i));
			this.dispatchEvent(new Event(this.sequenceName+"Ready",true));
		}
		
	}
}