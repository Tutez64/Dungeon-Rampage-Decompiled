package Brain.Render.Tweens
{
   import starling.animation.DelayedCall;
   import starling.animation.IAnimatable;
   import starling.animation.Juggler;
   import starling.animation.Tween;
   import starling.events.EventDispatcher;
   
   public class TweenHandle extends EventDispatcher implements IAnimatable
   {
      
      private static const COMPLETION_EPSILON:Number = 0.0001;
      
      private var mPrimary:IAnimatable;
      
      private var mSideTweens:Vector.<Tween>;
      
      private var mTarget:Object;
      
      private var mDelay:Number = 0;
      
      private var mFixedSpan:Number = 0;
      
      private var mTime:Number = 0;
      
      private var mPaused:Boolean;
      
      private var mReversed:Boolean;
      
      private var mKilled:Boolean;
      
      private var mFinished:Boolean;
      
      private var mCompletionPending:Boolean;
      
      private var mJuggler:Juggler;
      
      internal var parentTimeline:TweenTimeline;
      
      internal var onFinished:Function;
      
      private var mCompleteHooks:Vector.<Function>;
      
      private var mKillHooks:Vector.<Function>;
      
      private var mUserOnStart:Function;
      
      private var mUserOnStartArgs:Array;
      
      private var mUserOnUpdate:Function;
      
      private var mUserOnUpdateArgs:Array;
      
      private var mUserOnComplete:Function;
      
      private var mUserOnCompleteArgs:Array;
      
      public function TweenHandle(primary:IAnimatable, target:Object = null)
      {
         super();
         mPrimary = primary;
         mTarget = target;
         var _loc3_:Tween = primary as Tween;
         if(_loc3_)
         {
            _loc3_.onStart = handleStart;
            _loc3_.onUpdate = handleUpdate;
            _loc3_.onComplete = handleComplete;
         }
      }
      
      internal function addSideTween(tween:Tween) : void
      {
         if(mSideTweens == null)
         {
            mSideTweens = new Vector.<Tween>(0);
         }
         mSideTweens.push(tween);
      }
      
      internal function refreshSpan() : void
      {
         var _loc2_:Tween = mPrimary as Tween;
         var _loc1_:DelayedCall = mPrimary as DelayedCall;
         if(_loc2_)
         {
            mDelay = _loc2_.delay;
            if(_loc2_.repeatCount == 0)
            {
               mFixedSpan = Infinity;
            }
            else
            {
               mFixedSpan = _loc2_.delay + _loc2_.totalTime * _loc2_.repeatCount + _loc2_.repeatDelay * (_loc2_.repeatCount - 1);
            }
         }
         else if(_loc1_)
         {
            mDelay = 0;
            mFixedSpan = _loc1_.totalTime;
         }
      }
      
      internal function setCallbacks(onStart:Function, onStartArgs:Array, onUpdate:Function, onUpdateArgs:Array, onComplete:Function, onCompleteArgs:Array) : void
      {
         mUserOnStart = onStart;
         mUserOnStartArgs = onStartArgs;
         mUserOnUpdate = onUpdate;
         mUserOnUpdateArgs = onUpdateArgs;
         mUserOnComplete = onComplete;
         mUserOnCompleteArgs = onCompleteArgs;
      }
      
      internal function addCompleteHook(hook:Function) : void
      {
         if(mCompleteHooks == null)
         {
            mCompleteHooks = new Vector.<Function>(0);
         }
         mCompleteHooks.push(hook);
      }
      
      internal function addKillHook(hook:Function) : void
      {
         if(mKillHooks == null)
         {
            mKillHooks = new Vector.<Function>(0);
         }
         mKillHooks.push(hook);
      }
      
      internal function attachToJuggler(juggler:Juggler) : void
      {
         if(mKilled || mFinished)
         {
            return;
         }
         mJuggler = juggler;
         juggler.add(this);
      }
      
      internal function detachFromJuggler() : void
      {
         if(mJuggler)
         {
            mJuggler.remove(this);
            mJuggler = null;
         }
      }
      
      internal function get timeline() : TweenTimeline
      {
         return mPrimary as TweenTimeline;
      }
      
      public function advanceTime(time:Number) : void
      {
         if(mKilled || mFinished || mPaused || time == 0)
         {
            return;
         }
         if(mReversed)
         {
            time = -time;
         }
         var _loc4_:Number = totalSpan;
         var _loc3_:Number = mTime + time;
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ > _loc4_)
         {
            _loc3_ = _loc4_;
         }
         mTime = _loc3_;
         mCompletionPending = false;
         mPrimary.advanceTime(time);
         if(mSideTweens)
         {
            for each(var _loc2_:Tween in mSideTweens)
            {
               _loc2_.advanceTime(time);
            }
         }
         if(mCompletionPending)
         {
            mCompletionPending = false;
            executeComplete();
         }
         if(!mKilled && !mFinished && time > 0 && isInnerComplete)
         {
            finish();
         }
      }
      
      public function play() : void
      {
         mReversed = false;
         mPaused = false;
      }
      
      public function pause() : void
      {
         mPaused = true;
      }
      
      public function resume() : void
      {
         mPaused = false;
      }
      
      public function reverse() : void
      {
         mReversed = true;
         mPaused = false;
      }
      
      public function complete() : void
      {
         if(mKilled || mFinished)
         {
            return;
         }
         var _loc1_:Number = totalSpan;
         if(!isFinite(_loc1_))
         {
            return;
         }
         mReversed = false;
         mPaused = false;
         advanceTime(_loc1_ - mTime + 0.0001);
      }
      
      public function kill() : void
      {
         if(mKilled)
         {
            return;
         }
         mKilled = true;
         detachFromJuggler();
         if(parentTimeline)
         {
            parentTimeline.removeChild(this);
            parentTimeline = null;
         }
         if(timeline)
         {
            timeline.killChildren();
         }
         if(mKillHooks)
         {
            for each(var _loc1_:Function in mKillHooks)
            {
               _loc1_();
            }
         }
         notifyFinished();
      }
      
      public function get totalSpan() : Number
      {
         var _loc1_:TweenTimeline = timeline;
         return _loc1_ ? _loc1_.duration : mFixedSpan;
      }
      
      public function get currentTime() : Number
      {
         return mTime;
      }
      
      public function get progress() : Number
      {
         var _loc2_:Number = totalSpan;
         if(!isFinite(_loc2_))
         {
            return 0;
         }
         var _loc1_:Number = _loc2_ - mDelay;
         if(_loc1_ <= 0)
         {
            return mFinished || mTime >= _loc2_ ? 1 : 0;
         }
         var _loc3_:Number = (mTime - mDelay) / _loc1_;
         return _loc3_ < 0 ? 0 : (_loc3_ > 1 ? 1 : _loc3_);
      }
      
      public function get isComplete() : Boolean
      {
         return mFinished;
      }
      
      public function get isKilled() : Boolean
      {
         return mKilled;
      }
      
      public function get target() : Object
      {
         return mTarget;
      }
      
      public function get delayedCallback() : Function
      {
         var _loc1_:DelayedCall = mPrimary as DelayedCall;
         return _loc1_ ? _loc1_.callback : null;
      }
      
      private function get isInnerComplete() : Boolean
      {
         var _loc2_:Tween = mPrimary as Tween;
         if(_loc2_)
         {
            return _loc2_.isComplete;
         }
         var _loc1_:DelayedCall = mPrimary as DelayedCall;
         if(_loc1_)
         {
            return _loc1_.isComplete;
         }
         var _loc3_:TweenTimeline = mPrimary as TweenTimeline;
         return _loc3_ ? _loc3_.isComplete : true;
      }
      
      private function finish() : void
      {
         mFinished = true;
         dispatchEventWith("removeFromJuggler");
         mJuggler = null;
         notifyFinished();
      }
      
      private function notifyFinished() : void
      {
         var _loc1_:Function = null;
         if(onFinished != null)
         {
            _loc1_ = onFinished;
            onFinished = null;
            _loc1_(this);
         }
      }
      
      private function handleStart() : void
      {
         if(mUserOnStart != null)
         {
            mUserOnStart.apply(null,mUserOnStartArgs);
         }
      }
      
      private function handleUpdate() : void
      {
         if(mUserOnUpdate != null)
         {
            mUserOnUpdate.apply(null,mUserOnUpdateArgs);
         }
      }
      
      private function handleComplete() : void
      {
         mCompletionPending = true;
      }
      
      private function executeComplete() : void
      {
         if(mCompleteHooks)
         {
            for each(var _loc1_:Function in mCompleteHooks)
            {
               _loc1_();
            }
         }
         if(mUserOnComplete != null)
         {
            mUserOnComplete.apply(null,mUserOnCompleteArgs);
         }
      }
   }
}

