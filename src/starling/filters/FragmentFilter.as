package starling.filters
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.rendering.FilterEffect;
   import starling.rendering.IndexData;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.textures.Texture;
   import starling.utils.ContextRestoreRegistry;
   import starling.utils.MatrixUtil;
   import starling.utils.Padding;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   
   use namespace starling_internal;
   
   public class FragmentFilter extends EventDispatcher
   {
      
      private static var sRestoreRegistry:ContextRestoreRegistry = new ContextRestoreRegistry(0,restoreFilter);
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private var _quad:FilterQuad;
      
      private var _target:DisplayObject;
      
      private var _effect:FilterEffect;
      
      private var _vertexData:VertexData;
      
      private var _indexData:IndexData;
      
      private var _padding:Padding;
      
      private var _helper:FilterHelper;
      
      private var _resolution:Number;
      
      private var _antiAliasing:int;
      
      private var _textureFormat:String;
      
      private var _textureSmoothing:String;
      
      private var _alwaysDrawToBackBuffer:Boolean;
      
      private var _maintainResolutionAcrossPasses:Boolean;
      
      private var _cacheRequested:Boolean;
      
      private var _cached:Boolean;
      
      private var _restoreList:Dictionary;
      
      public function FragmentFilter()
      {
         super();
         _resolution = 1;
         _textureFormat = "bgra";
         _textureSmoothing = Starling.currentDefaultTextureSmoothing;
         _restoreList = sRestoreRegistry.add(this,Starling.current.stage3D);
      }
      
      private static function restoreFilter(filter:FragmentFilter, event:Object) : void
      {
         filter.onContextCreated(event);
      }
      
      public function dispose() : void
      {
         delete _restoreList[this];
         if(_helper)
         {
            _helper.dispose();
         }
         if(_effect)
         {
            _effect.dispose();
         }
         if(_quad)
         {
            _quad.dispose();
         }
         _effect = null;
         _quad = null;
      }
      
      private function onContextCreated(event:Object) : void
      {
         setRequiresRedraw();
      }
      
      public function render(painter:Painter) : void
      {
         if(_target == null)
         {
            throw new IllegalOperationError("Cannot render filter without target");
         }
         if(_target.is3D)
         {
            _cached = _cacheRequested = false;
         }
         if(!_cached || _cacheRequested)
         {
            renderPasses(painter,_cacheRequested);
            _cacheRequested = false;
         }
         else if(_quad.visible)
         {
            _quad.render(painter);
         }
      }
      
      private function renderPasses(painter:Painter, forCache:Boolean) : void
      {
         var _loc4_:Rectangle = null;
         var _loc3_:Texture = null;
         if(_helper == null)
         {
            _helper = new FilterHelper(_textureFormat);
         }
         if(_quad == null)
         {
            _quad = new FilterQuad(_textureSmoothing);
         }
         else
         {
            _helper.putTexture(_quad.texture);
            _quad.texture = null;
         }
         var _loc11_:Rectangle = Pool.getRectangle();
         var _loc10_:Boolean = false;
         var _loc12_:Number = _resolution;
         var _loc6_:DisplayObject = _target.stage || _target.parent;
         var _loc7_:Boolean = _loc6_ is Stage;
         var _loc8_:Stage = Starling.current.stage;
         if(!forCache && (_alwaysDrawToBackBuffer || _target.requiresRedraw))
         {
            _loc10_ = painter.state.alpha == 1 && (!_maintainResolutionAcrossPasses || _resolution == 1);
            painter.excludeFromCache(_target);
         }
         if(_target == Starling.current.root)
         {
            _loc8_.getStageBounds(_target,_loc11_);
         }
         else
         {
            _target.getBounds(_loc6_,_loc11_);
            if(!forCache && _loc7_)
            {
               _loc4_ = _loc8_.getStageBounds(null,Pool.getRectangle());
               RectangleUtil.intersect(_loc11_,_loc4_,_loc11_);
               Pool.putRectangle(_loc4_);
            }
         }
         _quad.visible = !_loc11_.isEmpty();
         if(!_quad.visible)
         {
            Pool.putRectangle(_loc11_);
            return;
         }
         if(_padding)
         {
            RectangleUtil.extend(_loc11_,_padding.left,_padding.right,_padding.top,_padding.bottom);
         }
         RectangleUtil.extendToWholePixels(_loc11_,Starling.contentScaleFactor);
         _helper.textureScale = Starling.contentScaleFactor * _resolution;
         _helper.projectionMatrix3D = painter.state.projectionMatrix3D;
         _helper.renderTarget = painter.state.renderTarget;
         _helper.clipRect = painter.state.clipRect;
         _helper.targetBounds = _loc11_;
         _helper.target = _target;
         _helper.start(numPasses,_loc10_);
         _quad.setBounds(_loc11_);
         _resolution = 1;
         var _loc9_:Boolean = painter.cacheEnabled;
         var _loc5_:Texture = _helper.getTexture();
         painter.cacheEnabled = false;
         painter.pushState();
         painter.state.alpha = 1;
         painter.state.clipRect = null;
         painter.state.setRenderTarget(_loc5_,true,_antiAliasing);
         painter.state.setProjectionMatrix(_loc11_.x,_loc11_.y,_loc5_.root.width,_loc5_.root.height,_loc8_.stageWidth,_loc8_.stageHeight,_loc8_.cameraPosition);
         _target.render(painter);
         painter.finishMeshBatch();
         painter.state.setModelviewMatricesToIdentity();
         _loc3_ = process(painter,_helper,_loc5_);
         painter.popState();
         painter.cacheEnabled = _loc9_;
         if(_loc3_)
         {
            painter.pushState();
            if(_target.is3D)
            {
               painter.state.setModelviewMatricesToIdentity();
            }
            else
            {
               _quad.moveVertices(_loc6_,_target);
            }
            _quad.texture = _loc3_;
            _quad.render(painter);
            painter.finishMeshBatch();
            painter.popState();
         }
         _helper.target = null;
         _helper.putTexture(_loc5_);
         _resolution = _loc12_;
         Pool.putRectangle(_loc11_);
      }
      
      public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture
      {
         var _loc8_:Matrix3D = null;
         var _loc10_:Texture = null;
         var _loc9_:FilterEffect = this.effect;
         var _loc7_:Texture = helper.getTexture(_resolution);
         var _loc11_:Rectangle = null;
         if(_loc7_)
         {
            _loc10_ = _loc7_;
            _loc8_ = MatrixUtil.createPerspectiveProjectionMatrix(0,0,_loc7_.root.width / _resolution,_loc7_.root.height / _resolution,0,0,null,sMatrix3D);
         }
         else
         {
            _loc11_ = helper.targetBounds;
            _loc10_ = (helper as FilterHelper).renderTarget;
            _loc8_ = (helper as FilterHelper).projectionMatrix3D;
            _loc9_.textureSmoothing = _textureSmoothing;
            painter.state.clipRect = (helper as FilterHelper).clipRect;
            painter.state.projectionMatrix3D.copyFrom(_loc8_);
         }
         painter.state.renderTarget = _loc10_;
         painter.prepareToDraw();
         painter.drawCount += 1;
         input0.setupVertexPositions(vertexData,0,"position",_loc11_);
         input0.setupTextureCoordinates(vertexData);
         _loc9_.texture = input0;
         _loc9_.mvpMatrix3D = _loc8_;
         _loc9_.uploadVertexData(vertexData);
         _loc9_.uploadIndexData(indexData);
         _loc9_.render(0,indexData.numTriangles);
         return _loc7_;
      }
      
      protected function createEffect() : FilterEffect
      {
         return new FilterEffect();
      }
      
      public function cache() : void
      {
         _cached = _cacheRequested = true;
         setRequiresRedraw();
      }
      
      public function clearCache() : void
      {
         _cached = _cacheRequested = false;
         setRequiresRedraw();
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
      
      protected function get effect() : FilterEffect
      {
         if(_effect == null)
         {
            _effect = createEffect();
         }
         return _effect;
      }
      
      protected function get vertexData() : VertexData
      {
         if(_vertexData == null)
         {
            _vertexData = new VertexData(effect.vertexFormat,4);
         }
         return _vertexData;
      }
      
      protected function get indexData() : IndexData
      {
         if(_indexData == null)
         {
            _indexData = new IndexData(6);
            _indexData.addQuad(0,1,2,3);
         }
         return _indexData;
      }
      
      protected function setRequiresRedraw() : void
      {
         dispatchEventWith("change");
         if(_target)
         {
            _target.setRequiresRedraw();
         }
         if(_cached)
         {
            _cacheRequested = true;
         }
      }
      
      public function get numPasses() : int
      {
         return 1;
      }
      
      protected function onTargetAssigned(target:DisplayObject) : void
      {
      }
      
      public function get padding() : Padding
      {
         if(_padding == null)
         {
            _padding = new Padding();
            _padding.addEventListener("change",setRequiresRedraw);
         }
         return _padding;
      }
      
      public function set padding(value:Padding) : void
      {
         padding.copyFrom(value);
      }
      
      public function get isCached() : Boolean
      {
         return _cached;
      }
      
      public function get resolution() : Number
      {
         return _resolution;
      }
      
      public function set resolution(value:Number) : void
      {
         if(value != _resolution)
         {
            if(value <= 0)
            {
               throw new ArgumentError("resolution must be > 0");
            }
            _resolution = value;
            setRequiresRedraw();
         }
      }
      
      protected function get maintainResolutionAcrossPasses() : Boolean
      {
         return _maintainResolutionAcrossPasses;
      }
      
      protected function set maintainResolutionAcrossPasses(value:Boolean) : void
      {
         _maintainResolutionAcrossPasses = value;
      }
      
      public function get antiAliasing() : int
      {
         return _antiAliasing;
      }
      
      public function set antiAliasing(value:int) : void
      {
         if(value != _antiAliasing)
         {
            _antiAliasing = value;
            setRequiresRedraw();
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
            if(_quad)
            {
               _quad.textureSmoothing = value;
            }
            setRequiresRedraw();
         }
      }
      
      public function get textureFormat() : String
      {
         return _textureFormat;
      }
      
      public function set textureFormat(value:String) : void
      {
         if(value != _textureFormat)
         {
            _textureFormat = value;
            if(_helper)
            {
               _helper.textureFormat = value;
            }
            setRequiresRedraw();
         }
      }
      
      public function get alwaysDrawToBackBuffer() : Boolean
      {
         return _alwaysDrawToBackBuffer;
      }
      
      public function set alwaysDrawToBackBuffer(value:Boolean) : void
      {
         _alwaysDrawToBackBuffer = value;
      }
      
      starling_internal function setTarget(target:DisplayObject) : void
      {
         var _loc2_:DisplayObject = null;
         if(target != _target)
         {
            _loc2_ = _target;
            _target = target;
            if(target == null)
            {
               if(_helper)
               {
                  _helper.purge();
               }
               if(_effect)
               {
                  _effect.purgeBuffers();
               }
               if(_quad)
               {
                  _quad.disposeTexture();
               }
            }
            if(_loc2_)
            {
               _loc2_.filter = null;
               _loc2_.removeEventListener("enterFrame",onEnterFrame);
            }
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
   }
}

import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.Texture;

class FilterQuad extends Mesh
{
   
   private static var sMatrix:Matrix = new Matrix();
   
   public function FilterQuad(smoothing:String)
   {
      var _loc2_:VertexData = new VertexData(null,4);
      _loc2_.numVertices = 4;
      var _loc3_:IndexData = new IndexData(6);
      _loc3_.addQuad(0,1,2,3);
      super(_loc2_,_loc3_);
      textureSmoothing = smoothing;
      pixelSnapping = false;
   }
   
   override public function dispose() : void
   {
      disposeTexture();
      super.dispose();
   }
   
   public function disposeTexture() : void
   {
      if(texture)
      {
         texture.dispose();
         texture = null;
      }
   }
   
   public function moveVertices(sourceSpace:DisplayObject, targetSpace:DisplayObject) : void
   {
      if(targetSpace.is3D)
      {
         throw new Error("cannot move vertices into 3D space");
      }
      if(sourceSpace != targetSpace)
      {
         targetSpace.getTransformationMatrix(sourceSpace,sMatrix).invert();
         vertexData.transformPoints("position",sMatrix);
      }
   }
   
   public function setBounds(bounds:Rectangle) : void
   {
      var _loc2_:VertexData = this.vertexData;
      var _loc3_:String = "position";
      _loc2_.setPoint(0,_loc3_,bounds.x,bounds.y);
      _loc2_.setPoint(1,_loc3_,bounds.right,bounds.y);
      _loc2_.setPoint(2,_loc3_,bounds.x,bounds.bottom);
      _loc2_.setPoint(3,_loc3_,bounds.right,bounds.bottom);
   }
   
   override public function set texture(value:Texture) : void
   {
      super.texture = value;
      if(value)
      {
         value.setupTextureCoordinates(vertexData);
      }
   }
}
