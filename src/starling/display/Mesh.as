package starling.display
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.starling_internal;
   import starling.geom.Polygon;
   import starling.rendering.IndexData;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.rendering.VertexDataFormat;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   import starling.utils.MeshUtil;
   
   use namespace starling_internal;
   
   public class Mesh extends DisplayObject
   {
      
      private static var sDefaultStyleFactory:Function = null;
      
      private static var sDefaultStyle:Class = MeshStyle;
      
      internal var _style:MeshStyle;
      
      internal var _vertexData:VertexData;
      
      internal var _indexData:IndexData;
      
      internal var _pixelSnapping:Boolean;
      
      public function Mesh(vertexData:VertexData, indexData:IndexData, style:MeshStyle = null)
      {
         super();
         if(vertexData == null)
         {
            throw new ArgumentError("VertexData must not be null");
         }
         if(indexData == null)
         {
            throw new ArgumentError("IndexData must not be null");
         }
         _vertexData = vertexData;
         _indexData = indexData;
         setStyle(style,false);
      }
      
      public static function createDefaultStyle(instance:Mesh = null) : MeshStyle
      {
         var _loc2_:MeshStyle = null;
         if(sDefaultStyleFactory != null)
         {
            if(sDefaultStyleFactory.length == 0)
            {
               _loc2_ = sDefaultStyleFactory();
            }
            else
            {
               _loc2_ = sDefaultStyleFactory(instance);
            }
         }
         if(_loc2_ == null)
         {
            _loc2_ = new sDefaultStyle() as MeshStyle;
         }
         return _loc2_;
      }
      
      public static function get defaultStyle() : Class
      {
         return sDefaultStyle;
      }
      
      public static function set defaultStyle(value:Class) : void
      {
         sDefaultStyle = value;
      }
      
      public static function get defaultStyleFactory() : Function
      {
         return sDefaultStyleFactory;
      }
      
      public static function set defaultStyleFactory(value:Function) : void
      {
         sDefaultStyleFactory = value;
      }
      
      public static function fromPolygon(polygon:Polygon, style:MeshStyle = null) : Mesh
      {
         var _loc3_:VertexData = new VertexData(null,polygon.numVertices);
         var _loc4_:IndexData = new IndexData(polygon.numTriangles);
         polygon.copyToVertexData(_loc3_);
         polygon.triangulate(_loc4_);
         return new Mesh(_loc3_,_loc4_,style);
      }
      
      override public function dispose() : void
      {
         _vertexData.clear();
         _indexData.clear();
         super.dispose();
      }
      
      override public function hitTest(localPoint:Point) : DisplayObject
      {
         if(!visible || !touchable || !hitTestMask(localPoint))
         {
            return null;
         }
         return MeshUtil.containsPoint(_vertexData,_indexData,localPoint) ? this : null;
      }
      
      override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         return MeshUtil.calculateBounds(_vertexData,this,targetSpace,out);
      }
      
      override public function render(painter:Painter) : void
      {
         if(_pixelSnapping)
         {
            MatrixUtil.snapToPixels(painter.state.modelviewMatrix,painter.pixelSize);
         }
         painter.batchMesh(this);
      }
      
      public function setStyle(meshStyle:MeshStyle = null, mergeWithPredecessor:Boolean = true) : void
      {
         if(meshStyle == null)
         {
            meshStyle = createDefaultStyle(this);
         }
         else
         {
            if(meshStyle == _style)
            {
               return;
            }
            if(meshStyle.target)
            {
               meshStyle.target.setStyle();
            }
         }
         if(_style)
         {
            if(mergeWithPredecessor)
            {
               meshStyle.copyFrom(_style);
            }
            _style.setTarget();
         }
         _style = meshStyle;
         _style.setTarget(this,_vertexData,_indexData);
         setRequiresRedraw();
      }
      
      public function setVertexDataChanged() : void
      {
         setRequiresRedraw();
      }
      
      public function setIndexDataChanged() : void
      {
         setRequiresRedraw();
      }
      
      public function getVertexPosition(vertexID:int, out:Point = null) : Point
      {
         return _style.getVertexPosition(vertexID,out);
      }
      
      public function setVertexPosition(vertexID:int, x:Number, y:Number) : void
      {
         _style.setVertexPosition(vertexID,x,y);
      }
      
      public function getVertexAlpha(vertexID:int) : Number
      {
         return _style.getVertexAlpha(vertexID);
      }
      
      public function setVertexAlpha(vertexID:int, alpha:Number) : void
      {
         _style.setVertexAlpha(vertexID,alpha);
      }
      
      public function getVertexColor(vertexID:int) : uint
      {
         return _style.getVertexColor(vertexID);
      }
      
      public function setVertexColor(vertexID:int, color:uint) : void
      {
         _style.setVertexColor(vertexID,color);
      }
      
      public function getTexCoords(vertexID:int, out:Point = null) : Point
      {
         return _style.getTexCoords(vertexID,out);
      }
      
      public function setTexCoords(vertexID:int, u:Number, v:Number) : void
      {
         _style.setTexCoords(vertexID,u,v);
      }
      
      protected function get vertexData() : VertexData
      {
         return _vertexData;
      }
      
      protected function get indexData() : IndexData
      {
         return _indexData;
      }
      
      public function get style() : MeshStyle
      {
         return _style;
      }
      
      public function set style(value:MeshStyle) : void
      {
         setStyle(value);
      }
      
      public function get texture() : Texture
      {
         return _style.texture;
      }
      
      public function set texture(value:Texture) : void
      {
         _style.texture = value;
      }
      
      public function get color() : uint
      {
         return _style.color;
      }
      
      public function set color(value:uint) : void
      {
         _style.color = value;
      }
      
      public function get textureSmoothing() : String
      {
         return _style.textureSmoothing;
      }
      
      public function set textureSmoothing(value:String) : void
      {
         _style.textureSmoothing = value;
      }
      
      public function get textureRepeat() : Boolean
      {
         return _style.textureRepeat;
      }
      
      public function set textureRepeat(value:Boolean) : void
      {
         _style.textureRepeat = value;
      }
      
      public function get pixelSnapping() : Boolean
      {
         return _pixelSnapping;
      }
      
      public function set pixelSnapping(value:Boolean) : void
      {
         _pixelSnapping = value;
      }
      
      public function get numVertices() : int
      {
         return _vertexData.numVertices;
      }
      
      public function get numIndices() : int
      {
         return _indexData.numIndices;
      }
      
      public function get numTriangles() : int
      {
         return _indexData.numTriangles;
      }
      
      public function get vertexFormat() : VertexDataFormat
      {
         return _style.vertexFormat;
      }
   }
}

