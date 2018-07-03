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
 * 		Fichier : 		tools.ProductEncryption
 * 		Derniere MàJ : 	2012/10/22
 * 		Descrition :	产品注册获取加密算法
 * 		Dépend de :		com.kio.tools.EncryptAlgorithm						
 * 
 * 		A Regler :		getEncryptProductPort() 获得【产品名+端口号+随机字符串】加密；
 * 						getEncryptProductPortPath() 获得【产品名+端口号+路径+随机字符串】加密；
 * 
 * 
 **/

package com.kio.tools.encryption
{
	import com.kio.tools.encryption.IXORAlgorithm;

	public class ProductEncryption
	{		
		/**
		 * 		Product + Port + 随机参数  -XOR算法
		 */
		public static function getEncryptProductPortXOR(product:String, port:Number, xoralgorithm:IXORAlgorithm):String{
			var combinedStr:String = product +"|"+ port +"|"+ xoralgorithm.randomString();
			return xoralgorithm.code(combinedStr);
		}
		
		/**
		 * 		Product + Port + Path + 随机参数  -XOR算法
		 */
		public static function getEncryptProductPortPathXOR(product:String, prot:Number, path:String, xoralgorithm:IXORAlgorithm):String{
			var combinedStr:String = product +"|"+ prot +"|"+ path +"|"+ xoralgorithm.randomString();
			return xoralgorithm.code(combinedStr);
		}
		
		/**
		 * 		Product + Port + Path + 预授权天数 + 随机字符串 -XOR算法 -Base64编码
		 */
		public static function getEncryptedProductPortPathXORBase64Encoded(product:String, prot:Number, path:String, trail:Number, xoralgorithm:IXORAlgorithm):String{
			return Base64.encode(xoralgorithm.code(product +"|"+ prot +"|"+ path +"|"+ trail +"|"+ xoralgorithm.randomString()));
		}
		
		/**
		 * 		获得 Product + Port + 是否注册 + 随机字符串 -XOR算法 -Base64反编码
		 */
		public static function getDecryptedProductPortPathXORBase64Decoded(cyphertext:String, xoralgorithm:IXORAlgorithm):String{
			return xoralgorithm.code(Base64.decode(cyphertext));
		}
	}
}