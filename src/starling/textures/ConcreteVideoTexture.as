package starling.textures
{
   import flash.display3D.textures.TextureBase;
   import flash.display3D.textures.VideoTexture;
   import flash.events.Event;
   import starling.core.Starling;
   import starling.utils.execute;
   
   internal class ConcreteVideoTexture extends ConcreteTexture
   {
      
      private var _textureReadyCallback:Function;
      
      private var _disposed:Boolean;
      
      public function ConcreteVideoTexture(base:VideoTexture, scale:Number = 1)
      {
         super(base,"bgra",base.videoWidth,base.videoHeight,false,false,false,scale);
      }
      
      override public function dispose() : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         if(!_disposed)
         {
            videoBase.attachCamera(null);
            videoBase.attachNetStream(null);
            _disposed = true;
         }
         super.dispose();
      }
      
      override protected function createBase() : TextureBase
      {
         return Starling.context.createVideoTexture();
      }
      
      override internal function attachVideo(type:String, attachment:Object, onComplete:Function = null) : void
      {
         _textureReadyCallback = onComplete;
         base["attach" + type](attachment);
         base.addEventListener("textureReady",onTextureReady);
         setDataUploaded();
      }
      
      private function onTextureReady(event:Event) : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         execute(_textureReadyCallback,this);
         _textureReadyCallback = null;
      }
      
      override public function get nativeWidth() : Number
      {
         return videoBase.videoWidth;
      }
      
      override public function get nativeHeight() : Number
      {
         return videoBase.videoHeight;
      }
      
      override public function get width() : Number
      {
         return nativeWidth / scale;
      }
      
      override public function get height() : Number
      {
         return nativeHeight / scale;
      }
      
      private function get videoBase() : VideoTexture
      {
         return base as VideoTexture;
      }
   }
}

