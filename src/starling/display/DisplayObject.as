package starling.display
{
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.system.Capabilities;
   import flash.ui.Mouse;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.rendering.BatchToken;
   import starling.rendering.Painter;
   import starling.utils.Color;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   import starling.utils.execute;
   
   use namespace starling_internal;
   
   public class DisplayObject extends EventDispatcher
   {
      
      private static var sMaskWarningShown:Boolean = false;
      
      private static var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private static var sHelperPoint3D:Vector3D = new Vector3D();
      
      private static var sHelperPointAlt3D:Vector3D = new Vector3D();
      
      private static var sHelperRect:Rectangle = new Rectangle();
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperMatrixAlt:Matrix = new Matrix();
      
      private static var sHelperMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sHelperMatrixAlt3D:Matrix3D = new Matrix3D();
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _pivotX:Number;
      
      private var _pivotY:Number;
      
      private var _scaleX:Number;
      
      private var _scaleY:Number;
      
      private var _skewX:Number;
      
      private var _skewY:Number;
      
      private var _rotation:Number;
      
      private var _alpha:Number;
      
      private var _visible:Boolean;
      
      private var _touchable:Boolean;
      
      private var _blendMode:String;
      
      private var _name:String;
      
      private var _useHandCursor:Boolean;
      
      private var _transformationMatrix:Matrix;
      
      private var _transformationMatrix3D:Matrix3D;
      
      private var _transformationChanged:Boolean;
      
      private var _is3D:Boolean;
      
      private var _maskee:DisplayObject;
      
      private var _maskInverted:Boolean = false;
      
      internal var _parent:DisplayObjectContainer;
      
      internal var _lastParentOrSelfChangeFrameID:uint;
      
      internal var _lastChildChangeFrameID:uint;
      
      internal var _tokenFrameID:uint;
      
      internal var _pushToken:BatchToken = new BatchToken();
      
      internal var _popToken:BatchToken = new BatchToken();
      
      internal var _hasVisibleArea:Boolean;
      
      internal var _filter:FragmentFilter;
      
      internal var _mask:DisplayObject;
      
      public function DisplayObject()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObject")
         {
            throw new AbstractClassError();
         }
         _x = _y = _pivotX = _pivotY = _rotation = _skewX = _skewY = 0;
         _scaleX = _scaleY = _alpha = 1;
         _visible = _touchable = _hasVisibleArea = true;
         _blendMode = "auto";
         _transformationMatrix = new Matrix();
      }
      
      private static function findCommonParent(object1:DisplayObject, object2:DisplayObject) : DisplayObject
      {
         var _loc3_:DisplayObject = object1;
         while(_loc3_)
         {
            sAncestors[sAncestors.length] = _loc3_;
            _loc3_ = _loc3_._parent;
         }
         _loc3_ = object2;
         while(_loc3_ && sAncestors.indexOf(_loc3_) == -1)
         {
            _loc3_ = _loc3_._parent;
         }
         sAncestors.length = 0;
         if(_loc3_)
         {
            return _loc3_;
         }
         throw new ArgumentError("Object not connected to target");
      }
      
      public function dispose() : void
      {
         if(_filter)
         {
            _filter.dispose();
         }
         if(_mask)
         {
            _mask.dispose();
         }
         removeEventListeners();
         mask = null;
      }
      
      public function removeFromParent(dispose:Boolean = false) : void
      {
         if(_parent)
         {
            _parent.removeChild(this,dispose);
         }
         else if(dispose)
         {
            this.dispose();
         }
      }
      
      public function getTransformationMatrix(targetSpace:DisplayObject, out:Matrix = null) : Matrix
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         if(out)
         {
            out.identity();
         }
         else
         {
            out = new Matrix();
         }
         if(targetSpace == this)
         {
            return out;
         }
         if(targetSpace == _parent || targetSpace == null && _parent == null)
         {
            out.copyFrom(transformationMatrix);
            return out;
         }
         if(targetSpace == null || targetSpace == base)
         {
            _loc4_ = this;
            while(_loc4_ != targetSpace)
            {
               out.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_._parent;
            }
            return out;
         }
         if(targetSpace._parent == this)
         {
            targetSpace.getTransformationMatrix(this,out);
            out.invert();
            return out;
         }
         _loc3_ = findCommonParent(this,targetSpace);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            out.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_._parent;
         }
         if(_loc3_ == targetSpace)
         {
            return out;
         }
         sHelperMatrix.identity();
         _loc4_ = targetSpace;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix.concat(_loc4_.transformationMatrix);
            _loc4_ = _loc4_._parent;
         }
         sHelperMatrix.invert();
         out.concat(sHelperMatrix);
         return out;
      }
      
      public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         throw new AbstractMethodError();
      }
      
      public function hitTest(localPoint:Point) : DisplayObject
      {
         if(!_visible || !_touchable)
         {
            return null;
         }
         if(_mask && !hitTestMask(localPoint))
         {
            return null;
         }
         if(getBounds(this,sHelperRect).containsPoint(localPoint))
         {
            return this;
         }
         return null;
      }
      
      public function hitTestMask(localPoint:Point) : Boolean
      {
         var _loc2_:Point = null;
         var _loc3_:Boolean = false;
         if(_mask)
         {
            if(_mask.stage)
            {
               getTransformationMatrix(_mask,sHelperMatrixAlt);
            }
            else
            {
               sHelperMatrixAlt.copyFrom(_mask.transformationMatrix);
               sHelperMatrixAlt.invert();
            }
            _loc2_ = Pool.getPoint();
            MatrixUtil.transformPoint(sHelperMatrixAlt,localPoint,_loc2_);
            _loc3_ = _mask.hitTest(_loc2_) != null;
            Pool.putPoint(_loc2_);
            return _maskInverted ? !_loc3_ : _loc3_;
         }
         return true;
      }
      
      public function localToGlobal(localPoint:Point, out:Point = null) : Point
      {
         if(is3D)
         {
            sHelperPoint3D.setTo(localPoint.x,localPoint.y,0);
            return local3DToGlobal(sHelperPoint3D,out);
         }
         getTransformationMatrix(base,sHelperMatrixAlt);
         return MatrixUtil.transformPoint(sHelperMatrixAlt,localPoint,out);
      }
      
      public function globalToLocal(globalPoint:Point, out:Point = null) : Point
      {
         if(is3D)
         {
            globalToLocal3D(globalPoint,sHelperPoint3D);
            stage.getCameraPosition(this,sHelperPointAlt3D);
            return MathUtil.intersectLineWithXYPlane(sHelperPointAlt3D,sHelperPoint3D,out);
         }
         getTransformationMatrix(base,sHelperMatrixAlt);
         sHelperMatrixAlt.invert();
         return MatrixUtil.transformPoint(sHelperMatrixAlt,globalPoint,out);
      }
      
      public function render(painter:Painter) : void
      {
         throw new AbstractMethodError();
      }
      
      public function alignPivot(horizontalAlign:String = "center", verticalAlign:String = "center") : void
      {
         var _loc3_:Rectangle = getBounds(this,sHelperRect);
         if(horizontalAlign == "left")
         {
            pivotX = _loc3_.x;
         }
         else if(horizontalAlign == "center")
         {
            pivotX = _loc3_.x + _loc3_.width / 2;
         }
         else
         {
            if(horizontalAlign != "right")
            {
               throw new ArgumentError("Invalid horizontal alignment: " + horizontalAlign);
            }
            pivotX = _loc3_.x + _loc3_.width;
         }
         if(verticalAlign == "top")
         {
            pivotY = _loc3_.y;
         }
         else if(verticalAlign == "center")
         {
            pivotY = _loc3_.y + _loc3_.height / 2;
         }
         else
         {
            if(verticalAlign != "bottom")
            {
               throw new ArgumentError("Invalid vertical alignment: " + verticalAlign);
            }
            pivotY = _loc3_.y + _loc3_.height;
         }
      }
      
      public function drawToBitmapData(out:BitmapData = null, color:uint = 0, alpha:Number = 0) : BitmapData
      {
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc20_:Rectangle = null;
         var _loc9_:Number = NaN;
         var _loc14_:Painter = Starling.painter;
         var _loc17_:Stage = Starling.current.stage;
         var _loc6_:Rectangle = Starling.current.viewPort;
         var _loc4_:Number = _loc17_.stageWidth;
         var _loc19_:Number = _loc17_.stageHeight;
         var _loc15_:Number = _loc6_.width / _loc4_;
         var _loc16_:Number = _loc6_.height / _loc19_;
         var _loc18_:Number = _loc14_.backBufferScaleFactor;
         var _loc7_:Number = _loc15_ * _loc18_;
         var _loc5_:Number = _loc16_ * _loc18_;
         if(this is Stage)
         {
            _loc11_ = _loc6_.x < 0 ? -_loc6_.x / _loc15_ : 0;
            _loc12_ = _loc6_.y < 0 ? -_loc6_.y / _loc16_ : 0;
            if(!out)
            {
               out = new BitmapData(_loc14_.backBufferWidth * _loc18_,_loc14_.backBufferHeight * _loc18_);
            }
         }
         else
         {
            _loc20_ = getBounds(_parent,sHelperRect);
            _loc11_ = _loc20_.x;
            _loc12_ = _loc20_.y;
            if(!out)
            {
               out = new BitmapData(Math.ceil(_loc20_.width * _loc7_),Math.ceil(_loc20_.height * _loc5_));
            }
         }
         color = Color.multiply(color,alpha);
         _loc14_.pushState();
         _loc14_.setupContextDefaults();
         _loc14_.state.renderTarget = null;
         _loc14_.state.setModelviewMatricesToIdentity();
         _loc14_.setStateTo(transformationMatrix);
         var _loc10_:Number = _loc12_;
         var _loc13_:Number = _loc14_.backBufferWidth / _loc15_;
         var _loc21_:Number = _loc14_.backBufferHeight / _loc16_;
         var _loc22_:Point = Pool.getPoint(0,0);
         var _loc8_:Rectangle = Pool.getRectangle(0,0,_loc14_.backBufferWidth * _loc18_,_loc14_.backBufferHeight * _loc18_);
         while(_loc22_.y < out.height)
         {
            _loc9_ = _loc11_;
            _loc22_.x = 0;
            while(_loc22_.x < out.width)
            {
               _loc14_.clear(color,alpha);
               _loc14_.state.setProjectionMatrix(_loc9_,_loc10_,_loc13_,_loc21_,_loc4_,_loc19_,_loc17_.cameraPosition);
               if(_mask)
               {
                  _loc14_.drawMask(mask,this);
               }
               if(_filter)
               {
                  _filter.render(_loc14_);
               }
               else
               {
                  render(_loc14_);
               }
               if(_mask)
               {
                  _loc14_.eraseMask(mask,this);
               }
               _loc14_.finishMeshBatch();
               execute(_loc14_.context.drawToBitmapData,out,_loc8_,_loc22_);
               _loc9_ += _loc13_;
               _loc22_.x += _loc13_ * _loc7_;
            }
            _loc10_ += _loc21_;
            _loc22_.y += _loc21_ * _loc5_;
         }
         _loc14_.popState();
         Pool.putRectangle(_loc8_);
         Pool.putPoint(_loc22_);
         return out;
      }
      
      public function getTransformationMatrix3D(targetSpace:DisplayObject, out:Matrix3D = null) : Matrix3D
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         if(out)
         {
            out.identity();
         }
         else
         {
            out = new Matrix3D();
         }
         if(targetSpace == this)
         {
            return out;
         }
         if(targetSpace == _parent || targetSpace == null && _parent == null)
         {
            out.copyFrom(transformationMatrix3D);
            return out;
         }
         if(targetSpace == null || targetSpace == base)
         {
            _loc4_ = this;
            while(_loc4_ != targetSpace)
            {
               out.append(_loc4_.transformationMatrix3D);
               _loc4_ = _loc4_._parent;
            }
            return out;
         }
         if(targetSpace._parent == this)
         {
            targetSpace.getTransformationMatrix3D(this,out);
            out.invert();
            return out;
         }
         _loc3_ = findCommonParent(this,targetSpace);
         _loc4_ = this;
         while(_loc4_ != _loc3_)
         {
            out.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_._parent;
         }
         if(_loc3_ == targetSpace)
         {
            return out;
         }
         sHelperMatrix3D.identity();
         _loc4_ = targetSpace;
         while(_loc4_ != _loc3_)
         {
            sHelperMatrix3D.append(_loc4_.transformationMatrix3D);
            _loc4_ = _loc4_._parent;
         }
         sHelperMatrix3D.invert();
         out.append(sHelperMatrix3D);
         return out;
      }
      
      public function local3DToGlobal(localPoint:Vector3D, out:Point = null) : Point
      {
         var _loc3_:Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         MatrixUtil.transformPoint3D(sHelperMatrixAlt3D,localPoint,sHelperPoint3D);
         return MathUtil.intersectLineWithXYPlane(_loc3_.cameraPosition,sHelperPoint3D,out);
      }
      
      public function globalToLocal3D(globalPoint:Point, out:Vector3D = null) : Vector3D
      {
         var _loc3_:Stage = this.stage;
         if(_loc3_ == null)
         {
            throw new IllegalOperationError("Object not connected to stage");
         }
         getTransformationMatrix3D(_loc3_,sHelperMatrixAlt3D);
         sHelperMatrixAlt3D.invert();
         return MatrixUtil.transformCoords3D(sHelperMatrixAlt3D,globalPoint.x,globalPoint.y,0,out);
      }
      
      starling_internal function setParent(value:DisplayObjectContainer) : void
      {
         var _loc2_:DisplayObject = value;
         while(_loc2_ != this && _loc2_ != null)
         {
            _loc2_ = _loc2_._parent;
         }
         if(_loc2_ == this)
         {
            throw new ArgumentError("An object cannot be added as a child to itself or one of its children (or children\'s children, etc.)");
         }
         _parent = value;
      }
      
      internal function setIs3D(value:Boolean) : void
      {
         _is3D = value;
      }
      
      internal function get isMask() : Boolean
      {
         return _maskee != null;
      }
      
      public function setRequiresRedraw() : void
      {
         var _loc1_:DisplayObject = _parent || _maskee;
         var _loc2_:int = int(Starling.frameID);
         _lastParentOrSelfChangeFrameID = _loc2_;
         _hasVisibleArea = _alpha != 0 && _visible && _maskee == null && _scaleX != 0 && _scaleY != 0;
         while(_loc1_ && _loc1_._lastChildChangeFrameID != _loc2_)
         {
            _loc1_._lastChildChangeFrameID = _loc2_;
            _loc1_ = _loc1_._parent || _loc1_._maskee;
         }
      }
      
      public function get requiresRedraw() : Boolean
      {
         var _loc1_:uint = Starling.frameID;
         return _lastParentOrSelfChangeFrameID == _loc1_ || _lastChildChangeFrameID == _loc1_;
      }
      
      starling_internal function excludeFromCache() : void
      {
         var _loc2_:DisplayObject = this;
         var _loc1_:Number = 4294967295;
         while(_loc2_ && _loc2_._tokenFrameID != _loc1_)
         {
            _loc2_._tokenFrameID = _loc1_;
            _loc2_ = _loc2_._parent;
         }
      }
      
      starling_internal function setTransformationChanged() : void
      {
         _transformationChanged = true;
         setRequiresRedraw();
      }
      
      starling_internal function updateTransformationMatrices(x:Number, y:Number, pivotX:Number, pivotY:Number, scaleX:Number, scaleY:Number, skewX:Number, skewY:Number, rotation:Number, out:Matrix, out3D:Matrix3D) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         if(skewX == 0 && skewY == 0)
         {
            if(rotation == 0)
            {
               out.setTo(scaleX,0,0,scaleY,x - pivotX * scaleX,y - pivotY * scaleY);
            }
            else
            {
               _loc18_ = Math.cos(rotation);
               _loc19_ = Math.sin(rotation);
               _loc12_ = scaleX * _loc18_;
               _loc13_ = scaleX * _loc19_;
               _loc14_ = scaleY * -_loc19_;
               _loc15_ = scaleY * _loc18_;
               _loc16_ = x - pivotX * _loc12_ - pivotY * _loc14_;
               _loc17_ = y - pivotX * _loc13_ - pivotY * _loc15_;
               out.setTo(_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_);
            }
         }
         else
         {
            out.identity();
            out.scale(scaleX,scaleY);
            MatrixUtil.skew(out,skewX,skewY);
            out.rotate(rotation);
            out.translate(x,y);
            if(pivotX != 0 || pivotY != 0)
            {
               out.tx = x - out.a * pivotX - out.c * pivotY;
               out.ty = y - out.b * pivotX - out.d * pivotY;
            }
         }
         if(out3D)
         {
            MatrixUtil.convertTo3D(out,out3D);
         }
      }
      
      override public function dispatchEvent(event:Event) : void
      {
         if(event.type == "removedFromStage" && stage == null)
         {
            return;
         }
         super.dispatchEvent(event);
      }
      
      override public function addEventListener(type:String, listener:Function) : void
      {
         if(type == "enterFrame" && !hasEventListener(type))
         {
            addEventListener("addedToStage",addEnterFrameListenerToStage);
            addEventListener("removedFromStage",removeEnterFrameListenerFromStage);
            if(this.stage)
            {
               addEnterFrameListenerToStage();
            }
         }
         super.addEventListener(type,listener);
      }
      
      override public function removeEventListener(type:String, listener:Function) : void
      {
         super.removeEventListener(type,listener);
         if(type == "enterFrame" && !hasEventListener(type))
         {
            removeEventListener("addedToStage",addEnterFrameListenerToStage);
            removeEventListener("removedFromStage",removeEnterFrameListenerFromStage);
            removeEnterFrameListenerFromStage();
         }
      }
      
      override public function removeEventListeners(type:String = null) : void
      {
         if((type == null || type == "enterFrame") && hasEventListener("enterFrame"))
         {
            removeEventListener("addedToStage",addEnterFrameListenerToStage);
            removeEventListener("removedFromStage",removeEnterFrameListenerFromStage);
            removeEnterFrameListenerFromStage();
         }
         super.removeEventListeners(type);
      }
      
      private function addEnterFrameListenerToStage() : void
      {
         Starling.current.stage.addEnterFrameListener(this);
      }
      
      private function removeEnterFrameListenerFromStage() : void
      {
         Starling.current.stage.removeEnterFrameListener(this);
      }
      
      public function get transformationMatrix() : Matrix
      {
         if(_transformationChanged)
         {
            _transformationChanged = false;
            if(_transformationMatrix3D == null && _is3D)
            {
               _transformationMatrix3D = new Matrix3D();
            }
            updateTransformationMatrices(_x,_y,_pivotX,_pivotY,_scaleX,_scaleY,_skewX,_skewY,_rotation,_transformationMatrix,_transformationMatrix3D);
         }
         return _transformationMatrix;
      }
      
      public function set transformationMatrix(matrix:Matrix) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = 0.7853981633974483;
         setRequiresRedraw();
         _transformationChanged = false;
         _transformationMatrix.copyFrom(matrix);
         _pivotX = _pivotY = 0;
         _x = matrix.tx;
         _y = matrix.ty;
         _skewX = Math.atan(-matrix.c / matrix.d);
         _skewY = Math.atan(matrix.b / matrix.a);
         if(_skewX != _skewX)
         {
            _skewX = 0;
         }
         if(_skewY != _skewY)
         {
            _skewY = 0;
         }
         _scaleY = _skewX > -0.7853981633974483 && _skewX < 0.7853981633974483 ? matrix.d / Math.cos(_skewX) : -matrix.c / Math.sin(_skewX);
         _scaleX = _skewY > -0.7853981633974483 && _skewY < 0.7853981633974483 ? matrix.a / Math.cos(_skewY) : matrix.b / Math.sin(_skewY);
         if(MathUtil.isEquivalent(_skewX,_skewY))
         {
            _rotation = _skewX;
            _skewX = _skewY = 0;
         }
         else
         {
            _rotation = 0;
         }
      }
      
      public function get transformationMatrix3D() : Matrix3D
      {
         if(_transformationMatrix3D == null)
         {
            _transformationMatrix3D = MatrixUtil.convertTo3D(_transformationMatrix);
         }
         if(_transformationChanged)
         {
            _transformationChanged = false;
            updateTransformationMatrices(_x,_y,_pivotX,_pivotY,_scaleX,_scaleY,_skewX,_skewY,_rotation,_transformationMatrix,_transformationMatrix3D);
         }
         return _transformationMatrix3D;
      }
      
      public function get is3D() : Boolean
      {
         return _is3D;
      }
      
      public function get useHandCursor() : Boolean
      {
         return _useHandCursor;
      }
      
      public function set useHandCursor(value:Boolean) : void
      {
         if(value == _useHandCursor)
         {
            return;
         }
         _useHandCursor = value;
         if(_useHandCursor)
         {
            addEventListener("touch",onTouch);
         }
         else
         {
            removeEventListener("touch",onTouch);
         }
      }
      
      private function onTouch(event:TouchEvent) : void
      {
         Mouse.cursor = event.interactsWith(this) ? "button" : "auto";
      }
      
      public function get bounds() : Rectangle
      {
         return getBounds(_parent);
      }
      
      public function get width() : Number
      {
         return getBounds(_parent,sHelperRect).width;
      }
      
      public function set width(value:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Boolean = _scaleX != _scaleX;
         var _loc3_:Boolean = _scaleX < 1e-8 && _scaleX > -1e-8;
         if(_loc3_ || _loc4_)
         {
            scaleX = 1;
            _loc2_ = width;
         }
         else
         {
            _loc2_ = Math.abs(width / _scaleX);
         }
         if(_loc2_)
         {
            scaleX = value / _loc2_;
         }
      }
      
      public function get height() : Number
      {
         return getBounds(_parent,sHelperRect).height;
      }
      
      public function set height(value:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Boolean = _scaleY != _scaleY;
         var _loc3_:Boolean = _scaleY < 1e-8 && _scaleY > -1e-8;
         if(_loc3_ || _loc4_)
         {
            scaleY = 1;
            _loc2_ = height;
         }
         else
         {
            _loc2_ = Math.abs(height / _scaleY);
         }
         if(_loc2_)
         {
            scaleY = value / _loc2_;
         }
      }
      
      public function get x() : Number
      {
         return _x;
      }
      
      public function set x(value:Number) : void
      {
         if(_x != value)
         {
            _x = value;
            setTransformationChanged();
         }
      }
      
      public function get y() : Number
      {
         return _y;
      }
      
      public function set y(value:Number) : void
      {
         if(_y != value)
         {
            _y = value;
            setTransformationChanged();
         }
      }
      
      public function get pivotX() : Number
      {
         return _pivotX;
      }
      
      public function set pivotX(value:Number) : void
      {
         if(_pivotX != value)
         {
            _pivotX = value;
            setTransformationChanged();
         }
      }
      
      public function get pivotY() : Number
      {
         return _pivotY;
      }
      
      public function set pivotY(value:Number) : void
      {
         if(_pivotY != value)
         {
            _pivotY = value;
            setTransformationChanged();
         }
      }
      
      public function get scaleX() : Number
      {
         return _scaleX;
      }
      
      public function set scaleX(value:Number) : void
      {
         if(_scaleX != value)
         {
            _scaleX = value;
            setTransformationChanged();
         }
      }
      
      public function get scaleY() : Number
      {
         return _scaleY;
      }
      
      public function set scaleY(value:Number) : void
      {
         if(_scaleY != value)
         {
            _scaleY = value;
            setTransformationChanged();
         }
      }
      
      public function get scale() : Number
      {
         return scaleX;
      }
      
      public function set scale(value:Number) : void
      {
         scaleX = scaleY = value;
      }
      
      public function get skewX() : Number
      {
         return _skewX;
      }
      
      public function set skewX(value:Number) : void
      {
         value = MathUtil.normalizeAngle(value);
         if(_skewX != value)
         {
            _skewX = value;
            setTransformationChanged();
         }
      }
      
      public function get skewY() : Number
      {
         return _skewY;
      }
      
      public function set skewY(value:Number) : void
      {
         value = MathUtil.normalizeAngle(value);
         if(_skewY != value)
         {
            _skewY = value;
            setTransformationChanged();
         }
      }
      
      public function get rotation() : Number
      {
         return _rotation;
      }
      
      public function set rotation(value:Number) : void
      {
         value = MathUtil.normalizeAngle(value);
         if(_rotation != value)
         {
            _rotation = value;
            setTransformationChanged();
         }
      }
      
      internal function get isRotated() : Boolean
      {
         return _rotation != 0 || _skewX != 0 || _skewY != 0;
      }
      
      public function get alpha() : Number
      {
         return _alpha;
      }
      
      public function set alpha(value:Number) : void
      {
         if(value != _alpha)
         {
            _alpha = value < 0 ? 0 : (value > 1 ? 1 : value);
            setRequiresRedraw();
         }
      }
      
      public function get visible() : Boolean
      {
         return _visible;
      }
      
      public function set visible(value:Boolean) : void
      {
         if(value != _visible)
         {
            _visible = value;
            setRequiresRedraw();
         }
      }
      
      public function get touchable() : Boolean
      {
         return _touchable;
      }
      
      public function set touchable(value:Boolean) : void
      {
         _touchable = value;
      }
      
      public function get blendMode() : String
      {
         return _blendMode;
      }
      
      public function set blendMode(value:String) : void
      {
         if(value != _blendMode)
         {
            _blendMode = value;
            setRequiresRedraw();
         }
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function set name(value:String) : void
      {
         _name = value;
      }
      
      public function get filter() : FragmentFilter
      {
         return _filter;
      }
      
      public function set filter(value:FragmentFilter) : void
      {
         if(value != _filter)
         {
            if(_filter)
            {
               _filter.setTarget(null);
            }
            if(value)
            {
               value.setTarget(this);
            }
            _filter = value;
            setRequiresRedraw();
         }
      }
      
      public function get mask() : DisplayObject
      {
         return _mask;
      }
      
      public function set mask(value:DisplayObject) : void
      {
         if(_mask != value)
         {
            if(!sMaskWarningShown)
            {
               if(SystemUtil.supportsDepthAndStencil)
               {
               }
               sMaskWarningShown = true;
            }
            if(_mask)
            {
               _mask._maskee = null;
            }
            if(value)
            {
               value._maskee = this;
               value._hasVisibleArea = false;
            }
            _mask = value;
            setRequiresRedraw();
         }
      }
      
      public function get maskInverted() : Boolean
      {
         return _maskInverted;
      }
      
      public function set maskInverted(value:Boolean) : void
      {
         if(value != _maskInverted)
         {
            _maskInverted = value;
            setRequiresRedraw();
         }
      }
      
      public function get parent() : DisplayObjectContainer
      {
         return _parent;
      }
      
      public function get base() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_._parent)
         {
            _loc1_ = _loc1_._parent;
         }
         return _loc1_;
      }
      
      public function get root() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_._parent)
         {
            if(_loc1_._parent is Stage)
            {
               return _loc1_;
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }
      
      public function get stage() : Stage
      {
         return this.base as Stage;
      }
   }
}

