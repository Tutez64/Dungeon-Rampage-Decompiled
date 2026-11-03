package starling.rendering
{
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.textures.TextureBase;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Mesh;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.MeshSubset;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   import starling.utils.RenderUtil;
   import starling.utils.SystemUtil;
   
   use namespace starling_internal;
   
   public class Painter
   {
      
      private static const PROGRAM_DATA_NAME:String = "starling.rendering.Painter.Programs";
      
      public static const DEFAULT_STENCIL_VALUE:uint = 127;
      
      private static var sSharedData:Dictionary = new Dictionary();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sClipRect:Rectangle = new Rectangle();
      
      private static var sBufferRect:Rectangle = new Rectangle();
      
      private static var sScissorRect:Rectangle = new Rectangle();
      
      private static var sMeshSubset:MeshSubset = new MeshSubset();
      
      private var _stage3D:Stage3D;
      
      private var _context:Context3D;
      
      private var _shareContext:Boolean;
      
      private var _drawCount:int;
      
      private var _frameID:uint;
      
      private var _pixelSize:Number;
      
      private var _enableErrorChecking:Boolean;
      
      private var _stencilReferenceValues:Dictionary;
      
      private var _clipRectStack:Vector.<Rectangle>;
      
      private var _batchCacheExclusions:Vector.<DisplayObject>;
      
      private var _batchTrimInterval:int = 250;
      
      private var _batchProcessor:BatchProcessor;
      
      private var _batchProcessorCurr:BatchProcessor;
      
      private var _batchProcessorPrev:BatchProcessor;
      
      private var _batchProcessorSpec:BatchProcessor;
      
      private var _actualRenderTarget:TextureBase;
      
      private var _actualRenderTargetOptions:uint;
      
      private var _actualCulling:String;
      
      private var _actualBlendMode:String;
      
      private var _actualDepthMask:Boolean;
      
      private var _actualDepthTest:String;
      
      private var _backBufferWidth:Number;
      
      private var _backBufferHeight:Number;
      
      private var _backBufferScaleFactor:Number;
      
      private var _state:RenderState;
      
      private var _stateStack:Vector.<RenderState>;
      
      private var _stateStackPos:int;
      
      private var _stateStackLength:int;
      
      public function Painter(stage3D:Stage3D)
      {
         super();
         _stage3D = stage3D;
         _stage3D.addEventListener("context3DCreate",onContextCreated,false,40,true);
         _context = _stage3D.context3D;
         _shareContext = _context && _context.driverInfo != "Disposed";
         _backBufferWidth = _context ? _context.backBufferWidth : 0;
         _backBufferHeight = _context ? _context.backBufferHeight : 0;
         _backBufferScaleFactor = _pixelSize = 1;
         _stencilReferenceValues = new Dictionary(true);
         _clipRectStack = new Vector.<Rectangle>(0);
         _batchProcessorCurr = new BatchProcessor(drawBatch);
         _batchProcessorPrev = new BatchProcessor(drawBatch);
         _batchProcessorSpec = new BatchProcessor(drawBatch);
         _batchProcessor = _batchProcessorCurr;
         _batchCacheExclusions = new Vector.<DisplayObject>();
         _state = new RenderState();
         _state.onDrawRequired = finishMeshBatch;
         _stateStack = new Vector.<RenderState>(0);
         _stateStackPos = -1;
         _stateStackLength = 0;
      }
      
      public function dispose() : void
      {
         _batchProcessorCurr.dispose();
         _batchProcessorPrev.dispose();
         _batchProcessorSpec.dispose();
         if(!_shareContext)
         {
            if(_context)
            {
               _context.dispose(false);
            }
            sSharedData = new Dictionary();
         }
      }
      
      public function requestContext3D(renderMode:String, profile:*) : void
      {
         RenderUtil.requestContext3D(_stage3D,renderMode,profile);
      }
      
      private function onContextCreated(event:Object) : void
      {
         _context = _stage3D.context3D;
         _context.enableErrorChecking = _enableErrorChecking;
      }
      
      public function configureBackBuffer(viewPort:Rectangle, contentScaleFactor:Number, antiAlias:int, enableDepthAndStencil:Boolean, supportBrowserZoom:Boolean = false) : void
      {
         if(!_shareContext)
         {
            if(enableDepthAndStencil)
            {
               enableDepthAndStencil = SystemUtil.supportsDepthAndStencil;
            }
            if(_context.profile == "baselineConstrained")
            {
               _context.configureBackBuffer(32,32,antiAlias,enableDepthAndStencil);
            }
            if(viewPort.width * contentScaleFactor > _context.maxBackBufferWidth || viewPort.height * contentScaleFactor > _context.maxBackBufferHeight)
            {
               contentScaleFactor = 1;
            }
            _stage3D.x = viewPort.x;
            _stage3D.y = viewPort.y;
            _context.configureBackBuffer(viewPort.width,viewPort.height,antiAlias,enableDepthAndStencil,contentScaleFactor != 1,supportBrowserZoom);
         }
         _backBufferWidth = viewPort.width;
         _backBufferHeight = viewPort.height;
         _backBufferScaleFactor = contentScaleFactor;
      }
      
      public function registerProgram(name:String, program:Program) : void
      {
         deleteProgram(name);
         programs[name] = program;
      }
      
      public function deleteProgram(name:String) : void
      {
         var _loc2_:Program = getProgram(name);
         if(_loc2_)
         {
            _loc2_.dispose();
            delete programs[name];
         }
      }
      
      public function getProgram(name:String) : Program
      {
         return programs[name] as Program;
      }
      
      public function hasProgram(name:String) : Boolean
      {
         return name in programs;
      }
      
      public function pushState(token:BatchToken = null) : void
      {
         _stateStackPos = _stateStackPos + 1;
         if(_stateStackLength < _stateStackPos + 1)
         {
            _stateStack[_stateStackLength++] = new RenderState();
         }
         if(token)
         {
            _batchProcessor.fillToken(token);
         }
         _stateStack[_stateStackPos].copyFrom(_state);
      }
      
      public function setStateTo(transformationMatrix:Matrix, alphaFactor:Number = 1, blendMode:String = "auto") : void
      {
         if(transformationMatrix)
         {
            MatrixUtil.prependMatrix(_state._modelviewMatrix,transformationMatrix);
         }
         if(alphaFactor != 1)
         {
            _state._alpha *= alphaFactor;
         }
         if(blendMode != "auto")
         {
            _state.blendMode = blendMode;
         }
      }
      
      public function popState(token:BatchToken = null) : void
      {
         if(_stateStackPos < 0)
         {
            throw new IllegalOperationError("Cannot pop empty state stack");
         }
         _state.copyFrom(_stateStack[_stateStackPos]);
         _stateStackPos = _stateStackPos - 1;
         if(token)
         {
            _batchProcessor.fillToken(token);
         }
      }
      
      public function restoreState() : void
      {
         if(_stateStackPos < 0)
         {
            throw new IllegalOperationError("Cannot restore from empty state stack");
         }
         _state.copyFrom(_stateStack[_stateStackPos]);
      }
      
      public function fillToken(token:BatchToken) : void
      {
         if(token)
         {
            _batchProcessor.fillToken(token);
         }
      }
      
      public function drawMask(mask:DisplayObject, maskee:DisplayObject = null) : void
      {
         if(_context == null)
         {
            return;
         }
         finishMeshBatch();
         if(isRectangularMask(mask,maskee,sMatrix))
         {
            mask.getBounds(mask,sClipRect);
            RectangleUtil.getBounds(sClipRect,sMatrix,sClipRect);
            pushClipRect(sClipRect);
         }
         else
         {
            if(maskee && maskee.maskInverted)
            {
               _context.setStencilActions("frontAndBack","always","decrementSaturate");
               renderMask(mask);
            }
            else
            {
               _context.setStencilActions("frontAndBack","equal","incrementSaturate");
               renderMask(mask);
               stencilReferenceValue = stencilReferenceValue + 1;
            }
            _context.setStencilActions("frontAndBack","equal");
         }
         excludeFromCache(maskee);
      }
      
      public function eraseMask(mask:DisplayObject, maskee:DisplayObject = null) : void
      {
         if(_context == null)
         {
            return;
         }
         finishMeshBatch();
         if(isRectangularMask(mask,maskee,sMatrix))
         {
            popClipRect();
         }
         else
         {
            if(maskee && maskee.maskInverted)
            {
               _context.setStencilActions("frontAndBack","always","incrementSaturate");
               renderMask(mask);
            }
            else
            {
               _context.setStencilActions("frontAndBack","equal","decrementSaturate");
               renderMask(mask);
               stencilReferenceValue = stencilReferenceValue - 1;
            }
            _context.setStencilActions("frontAndBack","equal");
         }
      }
      
      private function renderMask(mask:DisplayObject) : void
      {
         var _loc4_:Matrix = null;
         var _loc2_:Matrix3D = null;
         var _loc3_:Boolean = cacheEnabled;
         pushState();
         cacheEnabled = false;
         _state.alpha = 0;
         if(mask.stage)
         {
            _state.setModelviewMatricesToIdentity();
            if(mask.is3D)
            {
               _loc2_ = mask.getTransformationMatrix3D(null,sMatrix3D);
            }
            else
            {
               _loc4_ = mask.getTransformationMatrix(null,sMatrix);
            }
         }
         else if(mask.is3D)
         {
            _loc2_ = mask.transformationMatrix3D;
         }
         else
         {
            _loc4_ = mask.transformationMatrix;
         }
         if(_loc2_)
         {
            _state.transformModelviewMatrix3D(_loc2_);
         }
         else
         {
            _state.transformModelviewMatrix(_loc4_);
         }
         mask.render(this);
         finishMeshBatch();
         cacheEnabled = _loc3_;
         popState();
      }
      
      private function pushClipRect(clipRect:Rectangle) : void
      {
         var _loc2_:Vector.<Rectangle> = _clipRectStack;
         var _loc4_:uint = _loc2_.length;
         var _loc3_:Rectangle = Pool.getRectangle();
         if(_loc4_)
         {
            RectangleUtil.intersect(_loc2_[_loc4_ - 1],clipRect,_loc3_);
         }
         else
         {
            _loc3_.copyFrom(clipRect);
         }
         _loc2_[_loc4_] = _loc3_;
         _state.clipRect = _loc3_;
      }
      
      private function popClipRect() : void
      {
         var _loc1_:Vector.<Rectangle> = _clipRectStack;
         var _loc2_:uint = _loc1_.length;
         if(_loc2_ == 0)
         {
            throw new Error("Trying to pop from empty clip rectangle stack");
         }
         _loc2_--;
         Pool.putRectangle(_loc1_.pop());
         _state.clipRect = _loc2_ ? _loc1_[_loc2_ - 1] : null;
      }
      
      private function isRectangularMask(mask:DisplayObject, maskee:DisplayObject, out:Matrix) : Boolean
      {
         var _loc4_:Quad = mask as Quad;
         var _loc6_:Boolean = maskee && maskee.maskInverted;
         var _loc5_:Boolean = mask.is3D || maskee && maskee.is3D && mask.stage == null;
         if(_loc4_ && !_loc6_ && !_loc5_ && _loc4_.texture == null)
         {
            if(mask.stage)
            {
               mask.getTransformationMatrix(null,out);
            }
            else
            {
               out.copyFrom(mask.transformationMatrix);
               out.concat(_state.modelviewMatrix);
            }
            return MathUtil.isEquivalent(out.a,0) && MathUtil.isEquivalent(out.d,0) || MathUtil.isEquivalent(out.b,0) && MathUtil.isEquivalent(out.c,0);
         }
         return false;
      }
      
      public function batchMesh(mesh:Mesh, subset:MeshSubset = null) : void
      {
         _batchProcessor.addMesh(mesh,_state,subset);
      }
      
      public function finishMeshBatch() : void
      {
         _batchProcessor.finishBatch();
      }
      
      public function enableBatchTrimming(enabled:Boolean = true, interval:int = 250) : void
      {
         _batchTrimInterval = enabled ? interval : 0;
      }
      
      public function finishFrame() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_batchTrimInterval > 0)
         {
            _loc1_ = _batchTrimInterval | 1;
            _loc2_ = _batchTrimInterval * 1.5;
            if(_frameID % _loc1_ == 0)
            {
               _batchProcessorCurr.trim();
            }
            if(_frameID % _loc2_ == 0)
            {
               _batchProcessorSpec.trim();
            }
         }
         _batchProcessor.finishFrame();
         _batchProcessor = _batchProcessorSpec;
         processCacheExclusions();
      }
      
      private function processCacheExclusions() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_batchCacheExclusions.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _batchCacheExclusions[_loc2_].excludeFromCache();
            _loc2_++;
         }
         _batchCacheExclusions.length = 0;
      }
      
      public function setupContextDefaults() : void
      {
         _actualBlendMode = null;
         _actualCulling = null;
         _actualDepthMask = false;
         _actualDepthTest = null;
      }
      
      public function nextFrame() : void
      {
         _batchProcessor = swapBatchProcessors();
         _batchProcessor.clear();
         _batchProcessorSpec.clear();
         setupContextDefaults();
         stencilReferenceValue = 127;
         _clipRectStack.length = 0;
         _drawCount = 0;
         _stateStackPos = -1;
         _state.reset();
      }
      
      private function swapBatchProcessors() : BatchProcessor
      {
         var _loc1_:BatchProcessor = _batchProcessorPrev;
         _batchProcessorPrev = _batchProcessorCurr;
         return _batchProcessorCurr = _loc1_;
      }
      
      public function drawFromCache(startToken:BatchToken, endToken:BatchToken) : void
      {
         var _loc3_:MeshBatch = null;
         var _loc4_:int = 0;
         var _loc5_:MeshSubset = sMeshSubset;
         if(!startToken.equals(endToken))
         {
            if(!_batchProcessorPrev.frameFinished)
            {
               return;
            }
            pushState();
            _loc4_ = startToken.batchID;
            while(_loc4_ <= endToken.batchID)
            {
               _loc3_ = _batchProcessorPrev.getBatchAt(_loc4_);
               _loc5_.setTo();
               if(_loc4_ == startToken.batchID)
               {
                  _loc5_.vertexID = startToken.vertexID;
                  _loc5_.indexID = startToken.indexID;
                  _loc5_.numVertices = _loc3_.numVertices - _loc5_.vertexID;
                  _loc5_.numIndices = _loc3_.numIndices - _loc5_.indexID;
               }
               if(_loc4_ == endToken.batchID)
               {
                  _loc5_.numVertices = endToken.vertexID - _loc5_.vertexID;
                  _loc5_.numIndices = endToken.indexID - _loc5_.indexID;
               }
               if(_loc5_.numVertices)
               {
                  _state.alpha = 1;
                  _state.blendMode = _loc3_.blendMode;
                  _batchProcessor.addMesh(_loc3_,_state,_loc5_,true);
               }
               _loc4_++;
            }
            popState();
         }
      }
      
      public function excludeFromCache(object:DisplayObject) : void
      {
         if(object)
         {
            _batchCacheExclusions[_batchCacheExclusions.length] = object;
         }
      }
      
      private function drawBatch(meshBatch:MeshBatch) : void
      {
         pushState();
         state.blendMode = meshBatch.blendMode;
         state.modelviewMatrix.identity();
         state.alpha = 1;
         meshBatch.render(this);
         popState();
      }
      
      public function prepareToDraw() : void
      {
         applyBlendMode();
         applyRenderTarget();
         applyClipRect();
         applyCulling();
         applyDepthTest();
      }
      
      public function clear(rgb:uint = 0, alpha:Number = 0) : void
      {
         applyRenderTarget();
         stencilReferenceValue = 127;
         RenderUtil.clear(rgb,alpha,1,127);
      }
      
      public function present() : void
      {
         _state.renderTarget = null;
         _actualRenderTarget = null;
         _context.present();
      }
      
      private function applyBlendMode() : void
      {
         var _loc1_:String = _state.blendMode;
         if(_loc1_ != _actualBlendMode)
         {
            BlendMode.get(_state.blendMode).activate();
            _actualBlendMode = _loc1_;
         }
      }
      
      private function applyCulling() : void
      {
         var _loc1_:String = _state.culling;
         if(_loc1_ != _actualCulling)
         {
            _context.setCulling(_loc1_);
            _actualCulling = _loc1_;
         }
      }
      
      private function applyDepthTest() : void
      {
         var _loc1_:Boolean = _state.depthMask;
         var _loc2_:String = _state.depthTest;
         if(_loc1_ != _actualDepthMask || _loc2_ != _actualDepthTest)
         {
            _context.setDepthTest(_loc1_,_loc2_);
            _actualDepthMask = _loc1_;
            _actualDepthTest = _loc2_;
         }
      }
      
      private function applyRenderTarget() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Boolean = false;
         var _loc4_:TextureBase = _state.renderTargetBase;
         var _loc2_:uint = _state.renderTargetOptions;
         if(_loc4_ != _actualRenderTarget || _loc2_ != _actualRenderTargetOptions)
         {
            if(_loc4_)
            {
               _loc3_ = _state.renderTargetAntiAlias;
               _loc1_ = _state.renderTargetSupportsDepthAndStencil;
               _context.setRenderToTexture(_loc4_,_loc1_,_loc3_);
            }
            else
            {
               _context.setRenderToBackBuffer();
            }
            _context.setStencilReferenceValue(stencilReferenceValue);
            _actualRenderTargetOptions = _loc2_;
            _actualRenderTarget = _loc4_;
         }
      }
      
      private function applyClipRect() : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Matrix3D = null;
         var _loc2_:Texture = null;
         var _loc1_:Rectangle = _state.clipRect;
         if(_loc1_)
         {
            _loc4_ = _state.projectionMatrix3D;
            _loc2_ = _state.renderTarget;
            if(_loc2_)
            {
               _loc3_ = _loc2_.root.nativeWidth;
               _loc5_ = _loc2_.root.nativeHeight;
            }
            else
            {
               _loc3_ = _backBufferWidth;
               _loc5_ = _backBufferHeight;
            }
            MatrixUtil.transformCoords3D(_loc4_,_loc1_.x,_loc1_.y,0,sPoint3D);
            sPoint3D.project();
            sClipRect.x = (sPoint3D.x * 0.5 + 0.5) * _loc3_;
            sClipRect.y = (0.5 - sPoint3D.y * 0.5) * _loc5_;
            MatrixUtil.transformCoords3D(_loc4_,_loc1_.right,_loc1_.bottom,0,sPoint3D);
            sPoint3D.project();
            sClipRect.right = (sPoint3D.x * 0.5 + 0.5) * _loc3_;
            sClipRect.bottom = (0.5 - sPoint3D.y * 0.5) * _loc5_;
            sBufferRect.setTo(0,0,_loc3_,_loc5_);
            RectangleUtil.intersect(sClipRect,sBufferRect,sScissorRect);
            if(sScissorRect.width < 1 || sScissorRect.height < 1)
            {
               sScissorRect.setTo(0,0,1,1);
            }
            _context.setScissorRectangle(sScissorRect);
         }
         else
         {
            _context.setScissorRectangle(null);
         }
      }
      
      public function refreshBackBufferSize(scaleFactor:Number) : void
      {
         _backBufferWidth = _context.backBufferWidth;
         _backBufferHeight = _context.backBufferHeight;
         _backBufferScaleFactor = scaleFactor;
      }
      
      public function get drawCount() : int
      {
         return _drawCount;
      }
      
      public function set drawCount(value:int) : void
      {
         _drawCount = value;
      }
      
      public function get stencilReferenceValue() : uint
      {
         var _loc1_:Object = _state.renderTarget ? _state.renderTargetBase : this;
         if(_loc1_ in _stencilReferenceValues)
         {
            return _stencilReferenceValues[_loc1_];
         }
         return 127;
      }
      
      public function set stencilReferenceValue(value:uint) : void
      {
         var _loc2_:Object = _state.renderTarget ? _state.renderTargetBase : this;
         _stencilReferenceValues[_loc2_] = value;
         if(contextValid)
         {
            _context.setStencilReferenceValue(value);
         }
      }
      
      public function get cacheEnabled() : Boolean
      {
         return _batchProcessor == _batchProcessorCurr;
      }
      
      public function set cacheEnabled(value:Boolean) : void
      {
         if(value != cacheEnabled)
         {
            finishMeshBatch();
            if(value)
            {
               _batchProcessor = _batchProcessorCurr;
            }
            else
            {
               _batchProcessor = _batchProcessorSpec;
            }
         }
      }
      
      public function get state() : RenderState
      {
         return _state;
      }
      
      public function get stage3D() : Stage3D
      {
         return _stage3D;
      }
      
      public function get context() : Context3D
      {
         return _context;
      }
      
      public function set frameID(value:uint) : void
      {
         _frameID = value;
      }
      
      public function get frameID() : uint
      {
         return _batchProcessor == _batchProcessorCurr ? _frameID : 0;
      }
      
      public function get pixelSize() : Number
      {
         return _pixelSize;
      }
      
      public function set pixelSize(value:Number) : void
      {
         _pixelSize = value;
      }
      
      public function get shareContext() : Boolean
      {
         return _shareContext;
      }
      
      public function set shareContext(value:Boolean) : void
      {
         _shareContext = value;
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return _enableErrorChecking;
      }
      
      public function set enableErrorChecking(value:Boolean) : void
      {
         _enableErrorChecking = value;
         if(_context)
         {
            _context.enableErrorChecking = value;
         }
         if(value)
         {
         }
      }
      
      public function get backBufferWidth() : int
      {
         return _backBufferWidth;
      }
      
      public function get backBufferHeight() : int
      {
         return _backBufferHeight;
      }
      
      public function get backBufferScaleFactor() : Number
      {
         return _backBufferScaleFactor;
      }
      
      public function get contextValid() : Boolean
      {
         var _loc1_:String = null;
         if(_context)
         {
            _loc1_ = _context.driverInfo;
            return _loc1_ != null && _loc1_ != "" && _loc1_ != "Disposed";
         }
         return false;
      }
      
      public function get profile() : String
      {
         if(_context)
         {
            return _context.profile;
         }
         return null;
      }
      
      public function get sharedData() : Dictionary
      {
         var _loc1_:Dictionary = sSharedData[stage3D] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            sSharedData[stage3D] = _loc1_;
         }
         return _loc1_;
      }
      
      private function get programs() : Dictionary
      {
         var _loc1_:Dictionary = sharedData["starling.rendering.Painter.Programs"] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            sharedData["starling.rendering.Painter.Programs"] = _loc1_;
         }
         return _loc1_;
      }
   }
}

