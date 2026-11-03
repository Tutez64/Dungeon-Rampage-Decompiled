package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.utils.MathUtil;
   import starling.utils.execute;
   
   internal class ConcretePotTexture extends ConcreteTexture
   {
      
      private static var sAsyncUploadEnabled:Boolean = false;
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sRectangle:Rectangle = new Rectangle();
      
      private static var sOrigin:Point = new Point();
      
      private var _textureReadyCallback:Function;
      
      public function ConcretePotTexture(base:flash.display3D.textures.Texture, format:String, width:int, height:int, mipMapping:Boolean, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean = false, scale:Number = 1)
      {
         super(base,format,width,height,mipMapping,premultipliedAlpha,optimizedForRenderTexture,scale);
         if(width != MathUtil.getNextPowerOfTwo(width))
         {
            throw new ArgumentError("width must be a power of two");
         }
         if(height != MathUtil.getNextPowerOfTwo(height))
         {
            throw new ArgumentError("height must be a power of two");
         }
      }
      
      internal static function get asyncUploadEnabled() : Boolean
      {
         return sAsyncUploadEnabled;
      }
      
      internal static function set asyncUploadEnabled(value:Boolean) : void
      {
         sAsyncUploadEnabled = value;
      }
      
      override public function dispose() : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         super.dispose();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
      }
      
      override public function uploadBitmapData(data:BitmapData, async:* = null) : void
      {
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:BitmapData = null;
         var _loc5_:int = 0;
         var _loc9_:Matrix = null;
         var _loc3_:BitmapData = null;
         var _loc8_:BitmapData = null;
         var _loc6_:Boolean = async is Function || async === true;
         if(async is Function)
         {
            _textureReadyCallback = async as Function;
         }
         if(data.width != nativeWidth || data.height != nativeHeight)
         {
            _loc8_ = new BitmapData(nativeWidth,nativeHeight,true,0);
            _loc8_.copyPixels(data,data.rect,sOrigin);
            data = _loc8_;
         }
         upload(data,0,_loc6_);
         if(mipMapping && data.width > 1 && data.height > 1)
         {
            _loc4_ = data.width >> 1;
            _loc7_ = data.height >> 1;
            _loc10_ = null;
            _loc5_ = 1;
            _loc9_ = sMatrix;
            _loc9_.setTo(0.5,0,0,0.5,0,0);
            while(_loc4_ >= 1 || _loc7_ >= 1)
            {
               _loc3_ = new BitmapData(Math.max(1,_loc4_),Math.max(1,_loc7_),true,0);
               if(_loc5_ == 1)
               {
                  _loc3_.draw(data,_loc9_,null,null,null,true);
               }
               else
               {
                  _loc3_.draw(_loc10_,_loc9_,null,null,null,true);
                  _loc10_.dispose();
               }
               _loc10_ = _loc3_;
               upload(_loc3_,_loc5_++,false);
               _loc4_ >>= 1;
               _loc7_ >>= 1;
            }
            if(_loc10_ != null)
            {
               _loc10_.dispose();
            }
         }
         if(_loc8_)
         {
            _loc8_.dispose();
         }
         setDataUploaded();
      }
      
      override public function get isPotTexture() : Boolean
      {
         return true;
      }
      
      override public function uploadAtfData(data:ByteArray, offset:int = 0, async:* = null) : void
      {
         var _loc4_:Boolean = async is Function || async === true;
         if(async is Function)
         {
            _textureReadyCallback = async as Function;
            base.addEventListener("textureReady",onTextureReady);
         }
         potBase.uploadCompressedTextureFromByteArray(data,offset,_loc4_);
         setDataUploaded();
      }
      
      private function upload(source:BitmapData, mipLevel:uint, isAsync:Boolean) : void
      {
         if(isAsync)
         {
            uploadAsync(source,mipLevel);
            base.addEventListener("textureReady",onTextureReady);
            base.addEventListener("error",onTextureReady);
         }
         else
         {
            potBase.uploadFromBitmapData(source,mipLevel);
         }
      }
      
      private function uploadAsync(source:BitmapData, mipLevel:uint) : void
      {
         if(sAsyncUploadEnabled)
         {
            try
            {
               base["uploadFromBitmapDataAsync"](source,mipLevel);
            }
            catch(error:Error)
            {
               if(!(error.errorID == 3708 || error.errorID == 1069))
               {
                  throw error;
               }
               sAsyncUploadEnabled = false;
            }
         }
         if(!sAsyncUploadEnabled)
         {
            setTimeout(base.dispatchEvent,1,new Event("textureReady"));
            potBase.uploadFromBitmapData(source);
         }
      }
      
      private function onTextureReady(event:Event) : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         base.removeEventListener("error",onTextureReady);
         execute(_textureReadyCallback,this,event as ErrorEvent);
         _textureReadyCallback = null;
      }
      
      private function get potBase() : flash.display3D.textures.Texture
      {
         return base as flash.display3D.textures.Texture;
      }
   }
}

