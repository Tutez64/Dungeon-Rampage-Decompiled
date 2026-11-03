package starling.styles
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.Mesh;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.rendering.*;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   
   use namespace starling_internal;
   
   public class MeshStyle extends EventDispatcher
   {
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshEffect.VERTEX_FORMAT;
      
      private static var sPoint:Point = new Point();
      
      private var _type:Class;
      
      private var _target:Mesh;
      
      private var _texture:Texture;
      
      private var _textureSmoothing:String;
      
      private var _textureRepeat:Boolean;
      
      private var _textureRoot:ConcreteTexture;
      
      private var _vertexData:VertexData;
      
      private var _indexData:IndexData;
      
      public function MeshStyle()
      {
         super();
         _textureSmoothing = Starling.currentDefaultTextureSmoothing;
         _type = Object(this).constructor as Class;
      }
      
      public function copyFrom(meshStyle:MeshStyle) : void
      {
         _texture = meshStyle._texture;
         _textureRoot = meshStyle._textureRoot;
         _textureRepeat = meshStyle._textureRepeat;
         _textureSmoothing = meshStyle._textureSmoothing;
      }
      
      public function clone() : MeshStyle
      {
         var _loc1_:MeshStyle = new _type();
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function createEffect() : MeshEffect
      {
         return new MeshEffect();
      }
      
      public function updateEffect(effect:MeshEffect, state:RenderState) : void
      {
         effect.texture = _texture;
         effect.textureRepeat = _textureRepeat;
         effect.textureSmoothing = _textureSmoothing;
         effect.mvpMatrix3D = state.mvpMatrix3D;
         effect.alpha = state.alpha;
         effect.tinted = _vertexData.tinted;
      }
      
      public function canBatchWith(meshStyle:MeshStyle) : Boolean
      {
         var _loc2_:Texture = null;
         if(_type == meshStyle._type)
         {
            _loc2_ = meshStyle._texture;
            if(_texture == null && _loc2_ == null)
            {
               return true;
            }
            if(_texture && _loc2_)
            {
               return _textureRoot == meshStyle._textureRoot && _textureSmoothing == meshStyle._textureSmoothing && _textureRepeat == meshStyle._textureRepeat;
            }
            return false;
         }
         return false;
      }
      
      public function batchVertexData(targetStyle:MeshStyle, targetVertexID:int = 0, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void
      {
         _vertexData.copyTo(targetStyle._vertexData,targetVertexID,matrix,vertexID,numVertices);
      }
      
      public function batchIndexData(targetStyle:MeshStyle, targetIndexID:int = 0, offset:int = 0, indexID:int = 0, numIndices:int = -1) : void
      {
         _indexData.copyTo(targetStyle._indexData,targetIndexID,offset,indexID,numIndices);
      }
      
      protected function setRequiresRedraw() : void
      {
         if(_target)
         {
            _target.setRequiresRedraw();
         }
      }
      
      protected function setVertexDataChanged() : void
      {
         if(_target)
         {
            _target.setVertexDataChanged();
         }
      }
      
      protected function setIndexDataChanged() : void
      {
         if(_target)
         {
            _target.setIndexDataChanged();
         }
      }
      
      protected function onTargetAssigned(target:Mesh) : void
      {
      }
      
      override public function addEventListener(type:String, listener:Function) : void
      {
         if(type == "enterFrame" && _target)
         {
            _target.addEventListener("enterFrame",onEnterFrame);
         }
         super.addEventListener(type,listener);
      }
      
      override public function removeEventListener(type:String, listener:Function) : void
      {
         if(type == "enterFrame" && _target)
         {
            _target.removeEventListener(type,onEnterFrame);
         }
         super.removeEventListener(type,listener);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         dispatchEvent(event);
      }
      
      starling_internal function setTarget(target:Mesh = null, vertexData:VertexData = null, indexData:IndexData = null) : void
      {
         if(_target != target)
         {
            if(_target)
            {
               _target.removeEventListener("enterFrame",onEnterFrame);
            }
            if(vertexData)
            {
               vertexData.format = vertexFormat;
            }
            _target = target;
            _vertexData = vertexData;
            _indexData = indexData;
            if(target)
            {
               if(hasEventListener("enterFrame"))
               {
                  target.addEventListener("enterFrame",onEnterFrame);
               }
               onTargetAssigned(target);
            }
         }
      }
      
      public function getVertexPosition(vertexID:int, out:Point = null) : Point
      {
         return _vertexData.getPoint(vertexID,"position",out);
      }
      
      public function setVertexPosition(vertexID:int, x:Number, y:Number) : void
      {
         _vertexData.setPoint(vertexID,"position",x,y);
         setVertexDataChanged();
      }
      
      public function getVertexAlpha(vertexID:int) : Number
      {
         return _vertexData.getAlpha(vertexID);
      }
      
      public function setVertexAlpha(vertexID:int, alpha:Number) : void
      {
         _vertexData.setAlpha(vertexID,"color",alpha);
         setVertexDataChanged();
      }
      
      public function getVertexColor(vertexID:int) : uint
      {
         return _vertexData.getColor(vertexID);
      }
      
      public function setVertexColor(vertexID:int, color:uint) : void
      {
         _vertexData.setColor(vertexID,"color",color);
         setVertexDataChanged();
      }
      
      public function getTexCoords(vertexID:int, out:Point = null) : Point
      {
         if(_texture)
         {
            return _texture.getTexCoords(_vertexData,vertexID,"texCoords",out);
         }
         return _vertexData.getPoint(vertexID,"texCoords",out);
      }
      
      public function setTexCoords(vertexID:int, u:Number, v:Number) : void
      {
         if(_texture)
         {
            _texture.setTexCoords(_vertexData,vertexID,"texCoords",u,v);
         }
         else
         {
            _vertexData.setPoint(vertexID,"texCoords",u,v);
         }
         setVertexDataChanged();
      }
      
      protected function get vertexData() : VertexData
      {
         return _vertexData;
      }
      
      protected function get indexData() : IndexData
      {
         return _indexData;
      }
      
      public function get type() : Class
      {
         return _type;
      }
      
      public function get color() : uint
      {
         if(_vertexData.numVertices > 0)
         {
            return _vertexData.getColor(0);
         }
         return 0;
      }
      
      public function set color(value:uint) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = _vertexData.numVertices;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _vertexData.setColor(_loc3_,"color",value);
            _loc3_++;
         }
         if(value == 16777215 && _vertexData.tinted)
         {
            _vertexData.updateTinted();
         }
         setVertexDataChanged();
      }
      
      public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      public function get texture() : Texture
      {
         return _texture;
      }
      
      public function set texture(value:Texture) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(value != _texture)
         {
            if(value)
            {
               _loc2_ = int(_vertexData ? _vertexData.numVertices : 0);
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  getTexCoords(_loc3_,sPoint);
                  value.setTexCoords(_vertexData,_loc3_,"texCoords",sPoint.x,sPoint.y);
                  _loc3_++;
               }
               setVertexDataChanged();
            }
            else
            {
               setRequiresRedraw();
            }
            _texture = value;
            _textureRoot = value ? value.root : null;
         }
      }
      
      public function get textureSmoothing() : String
      {
         return _textureSmoothing;
      }
      
      public function set textureSmoothing(value:String) : void
      {
         if(value != _textureSmoothing)
         {
            _textureSmoothing = value;
            setRequiresRedraw();
         }
      }
      
      public function get textureRepeat() : Boolean
      {
         return _textureRepeat;
      }
      
      public function set textureRepeat(value:Boolean) : void
      {
         _textureRepeat = value;
      }
      
      public function get target() : Mesh
      {
         return _target;
      }
   }
}

