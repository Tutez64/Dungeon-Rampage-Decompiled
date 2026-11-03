package Brain.Render.Tweens
{
   import flash.utils.Dictionary;
   import starling.animation.IAnimatable;
   
   public class TweenTimeline implements IAnimatable
   {
      
      private static const COMPLETION_EPSILON:Number = 0.0001;
      
      private var mChildren:Vector.<TweenHandle> = new Vector.<TweenHandle>(0);
      
      private var mPositions:Vector.<Number> = new Vector.<Number>(0);
      
      private var mLabels:Dictionary = new Dictionary();
      
      private var mTime:Number = 0;
      
      private var mComplete:Boolean;
      
      public var onComplete:Function;
      
      public var onCompleteArgs:Array;
      
      public function TweenTimeline()
      {
         super();
      }
      
      public function get duration() : Number
      {
         var _loc2_:int = 0;
         var _loc1_:Number = NaN;
         var _loc3_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < mChildren.length)
         {
            _loc1_ = mPositions[_loc2_] + mChildren[_loc2_].totalSpan;
            if(_loc1_ > _loc3_)
            {
               _loc3_ = _loc1_;
            }
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function get currentTime() : Number
      {
         return mTime;
      }
      
      public function get isComplete() : Boolean
      {
         return mComplete;
      }
      
      public function get numChildren() : int
      {
         return mChildren.length;
      }
      
      public function addLabel(label:String, time:Number) : void
      {
         mLabels[label] = time;
      }
      
      public function resolvePosition(position:Object) : Number
      {
         var _loc2_:String = null;
         if(position is String)
         {
            _loc2_ = String(position);
            if(!(_loc2_ in mLabels))
            {
               addLabel(_loc2_,duration);
            }
            return Number(mLabels[_loc2_]);
         }
         var _loc3_:Number = Number(position);
         return isNaN(_loc3_) ? 0 : _loc3_;
      }
      
      public function insert(child:TweenHandle, position:Object = null) : void
      {
         if(child == null || child.isKilled)
         {
            return;
         }
         var _loc3_:Number = resolvePosition(position);
         child.detachFromJuggler();
         if(child.parentTimeline)
         {
            child.parentTimeline.removeChild(child);
         }
         child.parentTimeline = this;
         mChildren.push(child);
         mPositions.push(_loc3_);
         mComplete = false;
      }
      
      public function append(child:TweenHandle) : void
      {
         insert(child,duration);
      }
      
      public function removeChild(child:TweenHandle) : void
      {
         var _loc2_:int = mChildren.indexOf(child);
         if(_loc2_ == -1)
         {
            return;
         }
         mChildren.splice(_loc2_,1);
         mPositions.splice(_loc2_,1);
         if(child.parentTimeline == this)
         {
            child.parentTimeline = null;
         }
         if(mChildren.length == 0 && mTime > 0)
         {
            mComplete = true;
         }
      }
      
      public function killChildren() : void
      {
         var _loc1_:Vector.<TweenHandle> = mChildren.concat();
         for each(var _loc2_:TweenHandle in _loc1_)
         {
            _loc2_.kill();
         }
      }
      
      public function advanceTime(time:Number) : void
      {
         var _loc7_:int = 0;
         var _loc11_:TweenHandle = null;
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc12_:Number = NaN;
         if(mComplete || time == 0 || mChildren.length == 0)
         {
            return;
         }
         var _loc3_:Number = mTime;
         var _loc2_:Number = duration;
         mTime += time;
         if(mTime < 0)
         {
            mTime = 0;
         }
         if(mTime > _loc2_)
         {
            mTime = _loc2_;
         }
         var _loc4_:Vector.<TweenHandle> = mChildren.concat();
         var _loc8_:Vector.<Number> = mPositions.concat();
         _loc7_ = 0;
         while(_loc7_ < _loc4_.length)
         {
            _loc11_ = _loc4_[_loc7_];
            if(!(_loc11_.parentTimeline != this || _loc11_.isComplete))
            {
               _loc6_ = _loc8_[_loc7_];
               _loc9_ = _loc6_ + _loc11_.totalSpan;
               if(time > 0)
               {
                  if(mTime >= _loc9_)
                  {
                     _loc11_.advanceTime(_loc11_.totalSpan - _loc11_.currentTime + 0.0001);
                  }
                  else
                  {
                     _loc10_ = _loc3_ > _loc6_ ? _loc3_ : _loc6_;
                     if(mTime > _loc10_)
                     {
                        _loc11_.advanceTime(mTime - _loc10_);
                     }
                  }
               }
               else
               {
                  _loc5_ = _loc3_ < _loc9_ ? _loc3_ : _loc9_;
                  _loc12_ = mTime > _loc6_ ? mTime : _loc6_;
                  if(_loc12_ < _loc5_)
                  {
                     _loc11_.advanceTime(_loc12_ - _loc5_);
                  }
               }
            }
            _loc7_++;
         }
         if(time > 0 && mTime >= _loc2_ && allChildrenComplete())
         {
            mComplete = true;
            if(onComplete != null)
            {
               onComplete.apply(null,onCompleteArgs);
            }
         }
      }
      
      private function allChildrenComplete() : Boolean
      {
         for each(var _loc1_:TweenHandle in mChildren)
         {
            if(!_loc1_.isComplete)
            {
               return false;
            }
         }
         return true;
      }
   }
}

