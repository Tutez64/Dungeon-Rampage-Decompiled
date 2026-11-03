package Actor
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   
   public class ChatBalloonOverlay
   {
      
      private static const sBalloons:Dictionary = new Dictionary(true);
      
      private var mWorld:DisplayObjectContainer;
      
      private var mFadeLayer:DisplayObject;
      
      private var mLayer:Sprite;
      
      private const mActive:Dictionary = new Dictionary();
      
      private const mOrder:Vector.<ChatBalloon> = new Vector.<ChatBalloon>(0);
      
      private const mMatrix:Matrix = new Matrix();
      
      private const mInverse:Matrix = new Matrix();
      
      private const mColor:ColorTransform = new ColorTransform();
      
      private const mFilters:Array = [];
      
      private var mFadeFilter:ColorMatrixFilter;
      
      private var mFadeAlpha:Number = -1;
      
      private var mFadeColor:uint;
      
      private var mFrame:uint = 0;
      
      public function ChatBalloonOverlay(world:DisplayObjectContainer, designSpace:DisplayObjectContainer, fadeLayer:DisplayObject = null)
      {
         super();
         mWorld = world;
         mFadeLayer = fadeLayer;
         mLayer = new Sprite();
         mLayer.name = "ChatBalloonOverlay";
         mLayer.mouseEnabled = mLayer.mouseChildren = false;
         var _loc4_:DisplayObject = world;
         while(_loc4_.parent != null && _loc4_.parent != designSpace)
         {
            _loc4_ = _loc4_.parent;
         }
         designSpace.addChildAt(mLayer,_loc4_.parent == designSpace ? designSpace.getChildIndex(_loc4_) + 1 : 0);
      }
      
      internal static function register(balloon:ChatBalloon) : void
      {
         balloon.cutRegistered = true;
         visibilityChanged(balloon);
      }
      
      internal static function visibilityChanged(balloon:ChatBalloon) : void
      {
         if(balloon.visible)
         {
            sBalloons[balloon] = true;
         }
         else
         {
            delete sBalloons[balloon];
            if(balloon.cutOverlay != null)
            {
               balloon.cutOverlay.restore(balloon);
            }
         }
      }
      
      internal static function unregister(balloon:ChatBalloon) : void
      {
         if(balloon.cutOverlay != null)
         {
            balloon.cutOverlay.restore(balloon);
         }
         delete sBalloons[balloon];
         balloon.cutRegistered = false;
      }
      
      private static function compareBalloons(a:ChatBalloon, b:ChatBalloon) : Number
      {
         return compareDisplayOrder(a,b);
      }
      
      private static function compareDisplayOrder(a:DisplayObject, b:DisplayObject) : Number
      {
         var _loc4_:DisplayObject = null;
         if(a == b)
         {
            return 0;
         }
         var _loc5_:DisplayObject = a;
         var _loc6_:DisplayObject = b;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         _loc4_ = _loc5_;
         while(_loc4_ != null)
         {
            _loc7_++;
            _loc4_ = _loc4_.parent;
         }
         _loc4_ = _loc6_;
         while(_loc4_ != null)
         {
            _loc3_++;
            _loc4_ = _loc4_.parent;
         }
         while(_loc7_ > _loc3_)
         {
            _loc5_ = _loc5_.parent;
            _loc7_--;
         }
         while(_loc3_ > _loc7_)
         {
            _loc6_ = _loc6_.parent;
            _loc3_--;
         }
         while(_loc5_.parent != _loc6_.parent)
         {
            _loc5_ = _loc5_.parent;
            _loc6_ = _loc6_.parent;
         }
         return _loc5_.parent.getChildIndex(_loc5_) - _loc6_.parent.getChildIndex(_loc6_);
      }
      
      public function update(enabled:Boolean, fadeAlpha:Number = 0, fadeColor:uint = 0) : void
      {
         var _loc4_:ChatBalloon = null;
         var _loc12_:Boolean = false;
         var _loc5_:DisplayObject = null;
         var _loc8_:Sprite = null;
         var _loc11_:Number = NaN;
         var _loc14_:ChatOverlayState = null;
         var _loc6_:int = 0;
         if(mLayer == null)
         {
            return;
         }
         if(!enabled || mWorld.stage == null || mLayer.stage != mWorld.stage)
         {
            clear();
            return;
         }
         var _loc7_:Boolean = false;
         var _loc18_:int = 0;
         var _loc17_:Dictionary = sBalloons;
         for(var _loc10_:Object in _loc17_)
         {
            _loc7_ = true;
         }
         if(!_loc7_)
         {
            clear();
            return;
         }
         mInverse.copyFrom(mLayer.transform.matrix);
         var _loc16_:Number = mInverse.a * mInverse.d - mInverse.b * mInverse.c;
         if(_loc16_ == 0 || !isFinite(_loc16_))
         {
            clear();
            return;
         }
         mInverse.invert();
         mFrame = mFrame + 1;
         mOrder.length = 0;
         for(var _loc15_:Object in sBalloons)
         {
            _loc4_ = ChatBalloon(_loc15_);
            if(!(!_loc4_.visible || !mWorld.contains(_loc4_)))
            {
               _loc12_ = true;
               mMatrix.identity();
               mColor.redMultiplier = mColor.greenMultiplier = mColor.blueMultiplier = mColor.alphaMultiplier = 1;
               mColor.redOffset = mColor.greenOffset = mColor.blueOffset = mColor.alphaOffset = 0;
               mFilters.length = 0;
               _loc5_ = _loc4_;
               while(_loc5_ != mLayer.parent)
               {
                  if(_loc5_ == null || !(_loc5_ is ActorNametag ? ActorNametag(_loc5_).shownOnScreen : _loc5_.visible) || _loc5_.alpha <= 0)
                  {
                     _loc12_ = false;
                     break;
                  }
                  mMatrix.concat(_loc5_.transform.matrix);
                  mColor.concat(_loc5_.transform.colorTransform);
                  for each(var _loc9_:BitmapFilter in _loc5_.filters)
                  {
                     mFilters.push(_loc9_);
                  }
                  _loc5_ = _loc5_.parent;
               }
               if(_loc12_)
               {
                  if(_loc4_.cutOverlay != null && _loc4_.cutOverlay != this)
                  {
                     _loc4_.cutOverlay.restore(_loc4_);
                  }
                  _loc8_ = _loc4_.renderContent;
                  mMatrix.concat(mInverse);
                  if(_loc8_.parent != mLayer)
                  {
                     mLayer.addChild(_loc8_);
                  }
                  if(fadeAlpha > 0 && mFadeLayer != null && mWorld.contains(mFadeLayer) && compareDisplayOrder(_loc4_,mFadeLayer) < 0)
                  {
                     if(mFadeFilter == null || fadeAlpha != mFadeAlpha || fadeColor != mFadeColor)
                     {
                        mFadeAlpha = fadeAlpha;
                        mFadeColor = fadeColor;
                        _loc11_ = Math.min(1,fadeAlpha);
                        var _loc13_:Number = 1 - _loc11_;
                        mFadeFilter = new ColorMatrixFilter([_loc13_,0,0,0,(fadeColor >> 16 & 0xFF) * _loc11_,0,_loc13_,0,0,(fadeColor >> 8 & 0xFF) * _loc11_,0,0,_loc13_,0,(fadeColor & 0xFF) * _loc11_,0,0,0,1,0]);
                     }
                     mFilters.push(mFadeFilter);
                  }
                  _loc14_ = mActive[_loc4_] as ChatOverlayState;
                  if(_loc14_ == null)
                  {
                     mActive[_loc4_] = _loc14_ = new ChatOverlayState();
                  }
                  _loc14_.apply(_loc8_,mMatrix,mColor,mFilters);
                  _loc14_.frame = mFrame;
                  _loc4_.cutOverlay = this;
                  mOrder.push(_loc4_);
               }
            }
         }
         for(_loc15_ in mActive)
         {
            if(ChatOverlayState(mActive[_loc15_]).frame != mFrame)
            {
               restore(ChatBalloon(_loc15_));
            }
         }
         _loc6_ = 1;
         while(_loc6_ < mOrder.length)
         {
            if(compareBalloons(mOrder[_loc6_ - 1],mOrder[_loc6_]) > 0)
            {
               mOrder.sort(compareBalloons);
               break;
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < mOrder.length)
         {
            if(mLayer.getChildAt(_loc6_) != mOrder[_loc6_].renderContent)
            {
               mLayer.setChildIndex(mOrder[_loc6_].renderContent,_loc6_);
            }
            _loc6_++;
         }
         mOrder.length = 0;
      }
      
      private function restore(balloon:ChatBalloon) : void
      {
         var _loc2_:Sprite = balloon.renderContent;
         balloon.addChild(_loc2_);
         _loc2_.transform.matrix = new Matrix();
         _loc2_.transform.colorTransform = new ColorTransform();
         _loc2_.filters = [];
         balloon.cutOverlay = null;
         delete mActive[balloon];
      }
      
      private function clear() : void
      {
         for(var _loc1_:Object in mActive)
         {
            restore(ChatBalloon(_loc1_));
         }
      }
      
      public function dispose() : void
      {
         clear();
         if(mLayer != null && mLayer.parent != null)
         {
            mLayer.parent.removeChild(mLayer);
         }
         mLayer = null;
         mWorld = null;
         mFadeLayer = null;
         mFilters.length = mOrder.length = 0;
         mFadeFilter = null;
      }
   }
}

