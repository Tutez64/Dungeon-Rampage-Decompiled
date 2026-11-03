package starling.textures
{
   import flash.display3D.textures.TextureBase;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import starling.core.starling_internal;
   
   use namespace starling_internal;
   
   public class SubTexture extends Texture
   {
      
      private static const E:Number = 0.000001;
      
      private var _parent:Texture;
      
      private var _ownsParent:Boolean;
      
      private var _region:Rectangle;
      
      private var _frame:Rectangle;
      
      private var _rotated:Boolean;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _scale:Number;
      
      private var _transformationMatrix:Matrix;
      
      private var _transformationMatrixToRoot:Matrix;
      
      public function SubTexture(parent:Texture, region:Rectangle = null, ownsParent:Boolean = false, frame:Rectangle = null, rotated:Boolean = false, scaleModifier:Number = 1)
      {
         super();
         starling_internal::setTo(parent,region,ownsParent,frame,rotated,scaleModifier);
      }
      
      starling_internal function setTo(parent:Texture, region:Rectangle = null, ownsParent:Boolean = false, frame:Rectangle = null, rotated:Boolean = false, scaleModifier:Number = 1) : void
      {
         if(_region == null)
         {
            _region = new Rectangle();
         }
         if(region)
         {
            _region.copyFrom(region);
         }
         else
         {
            _region.setTo(0,0,parent.width,parent.height);
         }
         if(frame)
         {
            if(_frame)
            {
               _frame.copyFrom(frame);
            }
            else
            {
               _frame = frame.clone();
            }
         }
         else
         {
            _frame = null;
         }
         _parent = parent;
         _ownsParent = ownsParent;
         _rotated = rotated;
         _width = (rotated ? _region.height : _region.width) / scaleModifier;
         _height = (rotated ? _region.width : _region.height) / scaleModifier;
         _scale = _parent.scale * scaleModifier;
         if(Capabilities.isDebugger && _frame && (_frame.x > 0 || _frame.y > 0 || _frame.right + 0.000001 < _width || _frame.bottom + 0.000001 < _height))
         {
         }
         updateMatrices();
      }
      
      private function updateMatrices() : void
      {
         if(_transformationMatrix)
         {
            _transformationMatrix.identity();
         }
         else
         {
            _transformationMatrix = new Matrix();
         }
         if(_transformationMatrixToRoot)
         {
            _transformationMatrixToRoot.identity();
         }
         else
         {
            _transformationMatrixToRoot = new Matrix();
         }
         if(_rotated)
         {
            _transformationMatrix.translate(0,-1);
            _transformationMatrix.rotate(3.141592653589793 / 2);
         }
         _transformationMatrix.scale(_region.width / _parent.width,_region.height / _parent.height);
         _transformationMatrix.translate(_region.x / _parent.width,_region.y / _parent.height);
         var _loc1_:SubTexture = this;
         while(_loc1_)
         {
            _transformationMatrixToRoot.concat(_loc1_._transformationMatrix);
            _loc1_ = _loc1_.parent as SubTexture;
         }
      }
      
      override public function dispose() : void
      {
         if(_ownsParent)
         {
            _parent.dispose();
         }
         super.dispose();
      }
      
      public function get parent() : Texture
      {
         return _parent;
      }
      
      public function get ownsParent() : Boolean
      {
         return _ownsParent;
      }
      
      public function get rotated() : Boolean
      {
         return _rotated;
      }
      
      public function get region() : Rectangle
      {
         return _region;
      }
      
      override public function get transformationMatrix() : Matrix
      {
         return _transformationMatrix;
      }
      
      override public function get transformationMatrixToRoot() : Matrix
      {
         return _transformationMatrixToRoot;
      }
      
      override public function get base() : TextureBase
      {
         return _parent.base;
      }
      
      override public function get root() : ConcreteTexture
      {
         return _parent.root;
      }
      
      override public function get format() : String
      {
         return _parent.format;
      }
      
      override public function get width() : Number
      {
         return _width;
      }
      
      override public function get height() : Number
      {
         return _height;
      }
      
      override public function get nativeWidth() : Number
      {
         return _width * _scale;
      }
      
      override public function get nativeHeight() : Number
      {
         return _height * _scale;
      }
      
      override public function get mipMapping() : Boolean
      {
         return _parent.mipMapping;
      }
      
      override public function get premultipliedAlpha() : Boolean
      {
         return _parent.premultipliedAlpha;
      }
      
      override public function get scale() : Number
      {
         return _scale;
      }
      
      override public function get frame() : Rectangle
      {
         return _frame;
      }
   }
}

