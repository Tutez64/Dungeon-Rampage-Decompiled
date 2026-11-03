package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.RectangleUtil;
   
   public class Quad extends Mesh
   {
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private var _bounds:Rectangle;
      
      public function Quad(width:Number, height:Number, color:uint = 16777215)
      {
         _bounds = new Rectangle(0,0,width,height);
         var _loc4_:VertexData = new VertexData(MeshStyle.VERTEX_FORMAT,4);
         var _loc5_:IndexData = new IndexData(6);
         super(_loc4_,_loc5_);
         if(width == 0 || height == 0)
         {
            throw new ArgumentError("Invalid size: width and height must not be zero");
         }
         setupVertices();
         this.color = color;
      }
      
      public static function fromTexture(texture:Texture) : Quad
      {
         var _loc2_:Quad = new Quad(100,100);
         _loc2_.texture = texture;
         _loc2_.readjustSize();
         return _loc2_;
      }
      
      protected function setupVertices() : void
      {
         var _loc1_:String = "position";
         var _loc5_:String = "texCoords";
         var _loc2_:Texture = style.texture;
         var _loc3_:VertexData = this.vertexData;
         var _loc4_:IndexData = this.indexData;
         _loc4_.numIndices = 0;
         _loc4_.addQuad(0,1,2,3);
         if(_loc3_.numVertices != 4)
         {
            _loc3_.numVertices = 4;
            _loc3_.trim();
         }
         if(_loc2_)
         {
            _loc2_.setupVertexPositions(_loc3_,0,"position",_bounds);
            _loc2_.setupTextureCoordinates(_loc3_,0,_loc5_);
         }
         else
         {
            _loc3_.setPoint(0,_loc1_,_bounds.left,_bounds.top);
            _loc3_.setPoint(1,_loc1_,_bounds.right,_bounds.top);
            _loc3_.setPoint(2,_loc1_,_bounds.left,_bounds.bottom);
            _loc3_.setPoint(3,_loc1_,_bounds.right,_bounds.bottom);
            _loc3_.setPoint(0,_loc5_,0,0);
            _loc3_.setPoint(1,_loc5_,1,0);
            _loc3_.setPoint(2,_loc5_,0,1);
            _loc3_.setPoint(3,_loc5_,1,1);
         }
         setRequiresRedraw();
      }
      
      override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(out == null)
         {
            out = new Rectangle();
         }
         if(targetSpace == this)
         {
            out.copyFrom(_bounds);
         }
         else if(targetSpace == parent && !isRotated)
         {
            _loc3_ = this.scaleX;
            _loc4_ = this.scaleY;
            out.setTo(x - pivotX * _loc3_,y - pivotY * _loc4_,_bounds.width * _loc3_,_bounds.height * _loc4_);
            if(_loc3_ < 0)
            {
               out.width *= -1;
               out.x -= out.width;
            }
            if(_loc4_ < 0)
            {
               out.height *= -1;
               out.y -= out.height;
            }
         }
         else if(is3D && stage)
         {
            stage.getCameraPosition(targetSpace,sPoint3D);
            getTransformationMatrix3D(targetSpace,sMatrix3D);
            RectangleUtil.getBoundsProjected(_bounds,sMatrix3D,sPoint3D,out);
         }
         else
         {
            getTransformationMatrix(targetSpace,sMatrix);
            RectangleUtil.getBounds(_bounds,sMatrix,out);
         }
         return out;
      }
      
      override public function hitTest(localPoint:Point) : DisplayObject
      {
         if(!visible || !touchable || !hitTestMask(localPoint))
         {
            return null;
         }
         if(_bounds.containsPoint(localPoint))
         {
            return this;
         }
         return null;
      }
      
      public function readjustSize(width:Number = -1, height:Number = -1) : void
      {
         if(width <= 0)
         {
            width = texture ? texture.frameWidth : _bounds.width;
         }
         if(height <= 0)
         {
            height = texture ? texture.frameHeight : _bounds.height;
         }
         if(width != _bounds.width || height != _bounds.height)
         {
            _bounds.setTo(0,0,width,height);
            setupVertices();
         }
      }
      
      override public function set texture(value:Texture) : void
      {
         if(value != texture)
         {
            super.texture = value;
            setupVertices();
         }
      }
   }
}

