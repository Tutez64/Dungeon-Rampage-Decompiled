package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.textures.RectangleTexture;
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.utils.execute;
   
   internal class ConcreteRectangleTexture extends ConcreteTexture
   {
      
      private static var sAsyncUploadEnabled:Boolean = false;
      
      private var _textureReadyCallback:Function;
      
      public function ConcreteRectangleTexture(base:RectangleTexture, format:String, width:int, height:int, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean = false, scale:Number = 1)
      {
         super(base,format,width,height,false,premultipliedAlpha,optimizedForRenderTexture,scale);
      }
      
      internal static function get asyncUploadEnabled() : Boolean
      {
         return sAsyncUploadEnabled;
      }
      
      internal static function set asyncUploadEnabled(value:Boolean) : void
      {
         sAsyncUploadEnabled = value;
      }
      
      override public function uploadBitmapData(data:BitmapData, async:* = null) : void
      {
         if(async is Function)
         {
            _textureReadyCallback = async as Function;
         }
         upload(data,async != null);
         setDataUploaded();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createRectangleTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
      }
      
      private function get rectBase() : RectangleTexture
      {
         return base as RectangleTexture;
      }
      
      private function upload(source:BitmapData, isAsync:Boolean) : void
      {
         if(isAsync)
         {
            uploadAsync(source);
            base.addEventListener("textureReady",onTextureReady);
            base.addEventListener("error",onTextureReady);
         }
         else
         {
            rectBase.uploadFromBitmapData(source);
         }
      }
      
      private function uploadAsync(source:BitmapData) : void
      {
         if(sAsyncUploadEnabled)
         {
            try
            {
               base["uploadFromBitmapDataAsync"](source);
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
            rectBase.uploadFromBitmapData(source);
         }
      }
      
      private function onTextureReady(event:Event) : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         base.removeEventListener("error",onTextureReady);
         execute(_textureReadyCallback,this,event as ErrorEvent);
         _textureReadyCallback = null;
      }
   }
}

