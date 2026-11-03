package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.textures.TextureBase;
   import flash.media.Camera;
   import flash.net.NetStream;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.errors.NotSupportedError;
   import starling.rendering.Painter;
   import starling.utils.Color;
   import starling.utils.execute;
   
   use namespace starling_internal;
   
   public class ConcreteTexture extends Texture
   {
      
      private var _base:TextureBase;
      
      private var _format:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _mipMapping:Boolean;
      
      private var _premultipliedAlpha:Boolean;
      
      private var _optimizedForRenderTexture:Boolean;
      
      private var _scale:Number;
      
      private var _onRestore:Function;
      
      private var _dataUploaded:Boolean;
      
      public function ConcreteTexture(base:TextureBase, format:String, width:int, height:int, mipMapping:Boolean, premultipliedAlpha:Boolean, optimizedForRenderTexture:Boolean = false, scale:Number = 1)
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::ConcreteTexture")
         {
            throw new AbstractClassError();
         }
         _scale = scale <= 0 ? 1 : scale;
         _base = base;
         _format = format;
         _width = width;
         _height = height;
         _mipMapping = mipMapping;
         _premultipliedAlpha = premultipliedAlpha;
         _optimizedForRenderTexture = optimizedForRenderTexture;
         _onRestore = null;
         _dataUploaded = false;
      }
      
      override public function dispose() : void
      {
         if(_base)
         {
            _base.dispose();
         }
         this.onRestore = null;
         super.dispose();
      }
      
      public function uploadBitmap(bitmap:Bitmap, async:* = null) : void
      {
         uploadBitmapData(bitmap.bitmapData,async);
      }
      
      public function uploadBitmapData(data:BitmapData, async:* = null) : void
      {
         throw new NotSupportedError();
      }
      
      public function uploadAtfData(data:ByteArray, offset:int = 0, async:* = null) : void
      {
         throw new NotSupportedError();
      }
      
      public function attachNetStream(netStream:NetStream, onComplete:Function = null) : void
      {
         attachVideo("NetStream",netStream,onComplete);
      }
      
      public function attachCamera(camera:Camera, onComplete:Function = null) : void
      {
         attachVideo("Camera",camera,onComplete);
      }
      
      internal function attachVideo(type:String, attachment:Object, onComplete:Function = null) : void
      {
         throw new NotSupportedError();
      }
      
      private function onContextCreated() : void
      {
         _dataUploaded = false;
         _base = createBase();
         execute(_onRestore,this);
         if(!_dataUploaded)
         {
            clear();
         }
      }
      
      protected function createBase() : TextureBase
      {
         throw new AbstractMethodError();
      }
      
      starling_internal function recreateBase() : void
      {
         _base = createBase();
      }
      
      public function clear(color:uint = 0, alpha:Number = 0) : void
      {
         if(_premultipliedAlpha && alpha < 1)
         {
            color = Color.rgb(Color.getRed(color) * alpha,Color.getGreen(color) * alpha,Color.getBlue(color) * alpha);
         }
         var _loc3_:Painter = Starling.painter;
         _loc3_.pushState();
         _loc3_.state.renderTarget = this;
         try
         {
            _loc3_.clear(color,alpha);
         }
         catch(e:Error)
         {
         }
         _loc3_.popState();
         setDataUploaded();
      }
      
      protected function setDataUploaded() : void
      {
         _dataUploaded = true;
      }
      
      public function get optimizedForRenderTexture() : Boolean
      {
         return _optimizedForRenderTexture;
      }
      
      public function get isPotTexture() : Boolean
      {
         return false;
      }
      
      public function get onRestore() : Function
      {
         return _onRestore;
      }
      
      public function set onRestore(value:Function) : void
      {
         Starling.current.removeEventListener("context3DCreate",onContextCreated);
         if(value != null)
         {
            _onRestore = value;
            Starling.current.addEventListener("context3DCreate",onContextCreated);
         }
         else
         {
            _onRestore = null;
         }
      }
      
      override public function get base() : TextureBase
      {
         return _base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return this;
      }
      
      override public function get format() : String
      {
         return _format;
      }
      
      override public function get width() : Number
      {
         return _width / _scale;
      }
      
      override public function get height() : Number
      {
         return _height / _scale;
      }
      
      override public function get nativeWidth() : Number
      {
         return _width;
      }
      
      override public function get nativeHeight() : Number
      {
         return _height;
      }
      
      override public function get scale() : Number
      {
         return _scale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return _mipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return _premultipliedAlpha;
      }
   }
}

