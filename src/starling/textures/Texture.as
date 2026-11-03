package starling.textures
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.textures.RectangleTexture;
   import flash.display3D.textures.Texture;
   import flash.display3D.textures.TextureBase;
   import flash.display3D.textures.VideoTexture;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.Camera;
   import flash.net.NetStream;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.errors.MissingContextError;
   import starling.errors.NotSupportedError;
   import starling.rendering.VertexData;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.SystemUtil;
   import starling.utils.execute;
   
   public class Texture
   {
      
      private static var sDefaultOptions:TextureOptions = new TextureOptions();
      
      private static var sRectangle:Rectangle = new Rectangle();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sPoint:Point = new Point();
      
      public function Texture()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.textures::Texture")
         {
            throw new AbstractClassError();
         }
      }
      
      public static function fromData(data:Object, options:TextureOptions = null) : starling.textures.Texture
      {
         if(data is Bitmap)
         {
            data = (data as Bitmap).bitmapData;
         }
         if(options == null)
         {
            options = sDefaultOptions;
         }
         if(data is Class)
         {
            return fromEmbeddedAsset(data as Class,options.mipMapping,options.optimizeForRenderToTexture,options.scale,options.format,options.forcePotTexture);
         }
         if(data is BitmapData)
         {
            return fromBitmapData(data as BitmapData,options.mipMapping,options.optimizeForRenderToTexture,options.scale,options.format,options.forcePotTexture,options.onReady);
         }
         if(data is ByteArray)
         {
            return fromAtfData(data as ByteArray,options.scale,options.mipMapping,options.onReady);
         }
         throw new ArgumentError("Unsupported \'data\' type: " + getQualifiedClassName(data));
      }
      
      public static function fromTextureBase(base:TextureBase, width:int, height:int, options:TextureOptions = null) : ConcreteTexture
      {
         if(options == null)
         {
            options = sDefaultOptions;
         }
         if(base is flash.display3D.textures.Texture)
         {
            return new ConcretePotTexture(base as flash.display3D.textures.Texture,options.format,width,height,options.mipMapping,options.premultipliedAlpha,options.optimizeForRenderToTexture,options.scale);
         }
         if(base is RectangleTexture)
         {
            return new ConcreteRectangleTexture(base as RectangleTexture,options.format,width,height,options.premultipliedAlpha,options.optimizeForRenderToTexture,options.scale);
         }
         if(base is VideoTexture)
         {
            return new ConcreteVideoTexture(base as VideoTexture,options.scale);
         }
         throw new ArgumentError("Unsupported \'base\' type: " + getQualifiedClassName(base));
      }
      
      public static function fromEmbeddedAsset(assetClass:Class, mipMapping:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture
      {
         var texture:starling.textures.Texture;
         var asset:Object = new assetClass();
         if(asset is Bitmap)
         {
            texture = starling.textures.Texture.fromBitmap(asset as Bitmap,mipMapping,optimizeForRenderToTexture,scale,format,forcePotTexture);
            texture.root.onRestore = function():void
            {
               texture.root.uploadBitmap(new assetClass());
            };
         }
         else if(asset is BitmapData)
         {
            texture = starling.textures.Texture.fromBitmapData(asset as BitmapData,mipMapping,optimizeForRenderToTexture,scale,format,forcePotTexture);
            texture.root.onRestore = function():void
            {
               texture.root.uploadBitmapData(new assetClass());
            };
         }
         else
         {
            if(!(asset is ByteArray))
            {
               throw new ArgumentError("Invalid asset type: " + getQualifiedClassName(asset));
            }
            texture = starling.textures.Texture.fromAtfData(asset as ByteArray,scale,mipMapping,null);
            texture.root.onRestore = function():void
            {
               texture.root.uploadAtfData(new assetClass());
            };
         }
         asset = null;
         return texture;
      }
      
      public static function fromBitmap(bitmap:Bitmap, generateMipMaps:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false, async:Function = null) : starling.textures.Texture
      {
         return fromBitmapData(bitmap.bitmapData,generateMipMaps,optimizeForRenderToTexture,scale,format,forcePotTexture,async);
      }
      
      public static function fromBitmapData(data:BitmapData, generateMipMaps:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = 1, format:String = "bgra", forcePotTexture:Boolean = false, async:Function = null) : starling.textures.Texture
      {
         var texture:starling.textures.Texture = starling.textures.Texture.empty(data.width / scale,data.height / scale,true,generateMipMaps,optimizeForRenderToTexture,scale,format,forcePotTexture);
         texture.root.uploadBitmapData(data,async != null ? function():void
         {
            execute(async,texture);
         } : null);
         texture.root.onRestore = function():void
         {
            texture.root.uploadBitmapData(data);
         };
         return texture;
      }
      
      public static function fromAtfData(data:ByteArray, scale:Number = 1, useMipMaps:Boolean = true, async:Function = null, premultipliedAlpha:Boolean = false) : starling.textures.Texture
      {
         var atfData:AtfData;
         var nativeTexture:flash.display3D.textures.Texture;
         var concreteTexture:ConcreteTexture;
         var context:Context3D = Starling.context;
         if(context == null)
         {
            throw new MissingContextError();
         }
         atfData = new AtfData(data);
         nativeTexture = context.createTexture(atfData.width,atfData.height,atfData.format,false);
         concreteTexture = new ConcretePotTexture(nativeTexture,atfData.format,atfData.width,atfData.height,useMipMaps && atfData.numTextures > 1,premultipliedAlpha,false,scale);
         concreteTexture.uploadAtfData(data,0,async);
         concreteTexture.onRestore = function():void
         {
            concreteTexture.uploadAtfData(data,0);
         };
         return concreteTexture;
      }
      
      public static function fromNetStream(stream:NetStream, scale:Number = 1, onComplete:Function = null) : starling.textures.Texture
      {
         if(stream.client == stream && !("onMetaData" in stream))
         {
            stream.client = {"onMetaData":function(param1:Object):void
            {
            }};
         }
         return fromVideoAttachment("NetStream",stream,scale,onComplete);
      }
      
      public static function fromCamera(camera:Camera, scale:Number = 1, onComplete:Function = null) : starling.textures.Texture
      {
         return fromVideoAttachment("Camera",camera,scale,onComplete);
      }
      
      private static function fromVideoAttachment(type:String, attachment:Object, scale:Number, onComplete:Function) : starling.textures.Texture
      {
         var context:Context3D;
         var base:VideoTexture;
         var texture:ConcreteTexture;
         if(!SystemUtil.supportsVideoTexture)
         {
            throw new NotSupportedError("Video Textures are not supported on this platform");
         }
         context = Starling.context;
         if(context == null)
         {
            throw new MissingContextError();
         }
         base = context.createVideoTexture();
         texture = new ConcreteVideoTexture(base,scale);
         texture.attachVideo(type,attachment,onComplete);
         texture.onRestore = function():void
         {
            texture.root.attachVideo(type,attachment);
         };
         return texture;
      }
      
      public static function fromColor(width:Number, height:Number, color:uint = 16777215, alpha:Number = 1, optimizeForRenderToTexture:Boolean = false, scale:Number = -1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture
      {
         var texture:starling.textures.Texture = starling.textures.Texture.empty(width,height,true,false,optimizeForRenderToTexture,scale,format,forcePotTexture);
         texture.root.clear(color,alpha);
         texture.root.onRestore = function():void
         {
            texture.root.clear(color,alpha);
         };
         return texture;
      }
      
      public static function empty(width:Number, height:Number, premultipliedAlpha:Boolean = true, mipMapping:Boolean = false, optimizeForRenderToTexture:Boolean = false, scale:Number = -1, format:String = "bgra", forcePotTexture:Boolean = false) : starling.textures.Texture
      {
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc13_:TextureBase = null;
         var _loc14_:ConcreteTexture = null;
         if(scale <= 0)
         {
            scale = Starling.contentScaleFactor;
         }
         var _loc15_:Context3D = Starling.context;
         if(_loc15_ == null)
         {
            throw new MissingContextError();
         }
         var _loc16_:Number = width * scale;
         var _loc9_:Number = height * scale;
         var _loc12_:Boolean = !forcePotTexture && !mipMapping && Starling.current.profile != "baselineConstrained" && format.indexOf("compressed") == -1;
         if(_loc12_)
         {
            _loc10_ = Math.ceil(_loc16_ - 1e-9);
            _loc11_ = Math.ceil(_loc9_ - 1e-9);
            _loc13_ = _loc15_.createRectangleTexture(_loc10_,_loc11_,format,optimizeForRenderToTexture);
            _loc14_ = new ConcreteRectangleTexture(_loc13_ as RectangleTexture,format,_loc10_,_loc11_,premultipliedAlpha,optimizeForRenderToTexture,scale);
         }
         else
         {
            _loc10_ = MathUtil.getNextPowerOfTwo(_loc16_);
            _loc11_ = MathUtil.getNextPowerOfTwo(_loc9_);
            _loc13_ = _loc15_.createTexture(_loc10_,_loc11_,format,optimizeForRenderToTexture);
            _loc14_ = new ConcretePotTexture(_loc13_ as flash.display3D.textures.Texture,format,_loc10_,_loc11_,mipMapping,premultipliedAlpha,optimizeForRenderToTexture,scale);
         }
         _loc14_.onRestore = _loc14_.clear;
         if(_loc10_ - _loc16_ < 0.001 && _loc11_ - _loc9_ < 0.001)
         {
            return _loc14_;
         }
         return new SubTexture(_loc14_,new Rectangle(0,0,width,height),true);
      }
      
      public static function fromTexture(texture:starling.textures.Texture, region:Rectangle = null, frame:Rectangle = null, rotated:Boolean = false, scaleModifier:Number = 1) : starling.textures.Texture
      {
         return new SubTexture(texture,region,false,frame,rotated,scaleModifier);
      }
      
      public static function get maxSize() : int
      {
         return getMaxSize();
      }
      
      public static function getMaxSize(textureFormat:String = "bgra") : int
      {
         var _loc5_:Starling = Starling.current;
         var _loc3_:Context3D = _loc5_.context;
         var _loc2_:String = _loc5_ ? _loc5_.profile : "baseline";
         var _loc4_:Boolean = textureFormat == "compressed" || textureFormat == "compressedAlpha";
         if(_loc2_ == "baseline" || _loc2_ == "baselineConstrained")
         {
            return 2048;
         }
         if(!_loc4_ && _loc3_ && "supports8kTexture" in _loc3_ && _loc3_["supports8kTexture"])
         {
            return 8192;
         }
         return 4096;
      }
      
      public static function get asyncBitmapUploadEnabled() : Boolean
      {
         return ConcreteRectangleTexture.asyncUploadEnabled;
      }
      
      public static function set asyncBitmapUploadEnabled(value:Boolean) : void
      {
         ConcreteRectangleTexture.asyncUploadEnabled = value;
         ConcretePotTexture.asyncUploadEnabled = value;
      }
      
      public function dispose() : void
      {
      }
      
      public function setupVertexPositions(vertexData:VertexData, vertexID:int = 0, attrName:String = "position", bounds:Rectangle = null) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Rectangle = this.frame;
         var _loc7_:Number = this.width;
         var _loc9_:Number = this.height;
         if(_loc8_)
         {
            sRectangle.setTo(-_loc8_.x,-_loc8_.y,_loc7_,_loc9_);
         }
         else
         {
            sRectangle.setTo(0,0,_loc7_,_loc9_);
         }
         vertexData.setPoint(vertexID,attrName,sRectangle.left,sRectangle.top);
         vertexData.setPoint(vertexID + 1,attrName,sRectangle.right,sRectangle.top);
         vertexData.setPoint(vertexID + 2,attrName,sRectangle.left,sRectangle.bottom);
         vertexData.setPoint(vertexID + 3,attrName,sRectangle.right,sRectangle.bottom);
         if(bounds)
         {
            _loc5_ = bounds.width / frameWidth;
            _loc6_ = bounds.height / frameHeight;
            if(_loc5_ != 1 || _loc6_ != 1 || bounds.x != 0 || bounds.y != 0)
            {
               sMatrix.identity();
               sMatrix.scale(_loc5_,_loc6_);
               sMatrix.translate(bounds.x,bounds.y);
               vertexData.transformPoints(attrName,sMatrix,vertexID,4);
            }
         }
      }
      
      public function setupTextureCoordinates(vertexData:VertexData, vertexID:int = 0, attrName:String = "texCoords") : void
      {
         setTexCoords(vertexData,vertexID,attrName,0,0);
         setTexCoords(vertexData,vertexID + 1,attrName,1,0);
         setTexCoords(vertexData,vertexID + 2,attrName,0,1);
         setTexCoords(vertexData,vertexID + 3,attrName,1,1);
      }
      
      public function localToGlobal(u:Number, v:Number, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         if(this == root)
         {
            out.setTo(u,v);
         }
         else
         {
            MatrixUtil.transformCoords(transformationMatrixToRoot,u,v,out);
         }
         return out;
      }
      
      public function globalToLocal(u:Number, v:Number, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         if(this == root)
         {
            out.setTo(u,v);
         }
         else
         {
            sMatrix.identity();
            sMatrix.copyFrom(transformationMatrixToRoot);
            sMatrix.invert();
            MatrixUtil.transformCoords(sMatrix,u,v,out);
         }
         return out;
      }
      
      public function setTexCoords(vertexData:VertexData, vertexID:int, attrName:String, u:Number, v:Number) : void
      {
         localToGlobal(u,v,sPoint);
         vertexData.setPoint(vertexID,attrName,sPoint.x,sPoint.y);
      }
      
      public function getTexCoords(vertexData:VertexData, vertexID:int, attrName:String = "texCoords", out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         vertexData.getPoint(vertexID,attrName,out);
         return globalToLocal(out.x,out.y,out);
      }
      
      public function get frame() : Rectangle
      {
         return null;
      }
      
      public function get frameWidth() : Number
      {
         return frame ? frame.width : width;
      }
      
      public function get frameHeight() : Number
      {
         return frame ? frame.height : height;
      }
      
      public function get width() : Number
      {
         return 0;
      }
      
      public function get height() : Number
      {
         return 0;
      }
      
      public function get nativeWidth() : Number
      {
         return 0;
      }
      
      public function get nativeHeight() : Number
      {
         return 0;
      }
      
      public function get scale() : Number
      {
         return 1;
      }
      
      public function get base() : TextureBase
      {
         return null;
      }
      
      public function get root() : ConcreteTexture
      {
         return null;
      }
      
      public function get format() : String
      {
         return "bgra";
      }
      
      public function get mipMapping() : Boolean
      {
         return false;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return false;
      }
      
      public function get transformationMatrix() : Matrix
      {
         return null;
      }
      
      public function get transformationMatrixToRoot() : Matrix
      {
         return null;
      }
   }
}

