package com.kio.tools.localStore
{
	import flash.data.EncryptedLocalStore;
	import flash.utils.ByteArray;

	/**
	 * 	LocalStore 自定义工具类，方便本地储存
	 * 	使用 AIR 自带 EncryptedLocalStore 类
	 * 
	 */
	public class LocalStore
	{
		public function LocalStore()
		{
			throw new Error("功能性类不可实例化");
		}
		
		/**
		 *  储存本地数据
		 * 	@param	变量名
		 * 	@param	变量值
		 */
		public static function setLocalData(dataName:String, dataContent:String):void
		{
			var dataBytes:ByteArray = new ByteArray();
			dataBytes.writeUTFBytes(dataContent);
			if(dataBytes.length)
			{
				EncryptedLocalStore.setItem(dataName, dataBytes);
			}
		}
		
		/**
		 *  读取本地数据
		 * 	@param	变量名
		 * 	@return 变量值
		 * 
		 */
		public static function getLocalData(dataName:String):String
		{
			if(EncryptedLocalStore.getItem(dataName)){
				var dataBytes:ByteArray = EncryptedLocalStore.getItem(dataName);
				if(dataBytes != null)
					return dataBytes.readUTFBytes(dataBytes.length);		
				else 
					return null;
			}else{
				return null;
			}
		}
		
	}
}