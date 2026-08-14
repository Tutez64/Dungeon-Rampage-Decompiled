package Actor
{
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   
   public class Revealer
   {
      
      public static const REVEAL_POP:uint = 0;
      
      public static const REVEAL_SMOOTH:uint = 1;
      
      private var mDBFacade:DBFacade;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mRoot:DisplayObject;
      
      private var mFinishedCallback:Function;
      
      private var mStartFrame:uint;
      
      private var mDuration:uint;
      
      private var mTargetScale:Number;
      
      private var mRevealType:uint;
      
      public function Revealer(root:DisplayObject, dbFacade:DBFacade, duration:uint, finishedCallback:Function = null, revealType:uint = 0)
      {
         super();
         mDBFacade = dbFacade;
         mRoot = root;
         mFinishedCallback = finishedCallback;
         mDuration = duration;
         mStartFrame = dbFacade.gameClock.frame;
         mTargetScale = root.scaleX;
         mRevealType = revealType;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"Revealer");
         mWorkComponent.doEveryFrame(update);
      }
      
      private function update(clock:GameClock) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:uint = clock.frame - mStartFrame;
         if(_loc5_ > mDuration)
         {
            mRoot.alpha = 1;
            mRoot.scaleX = mRoot.scaleY = mTargetScale;
            mWorkComponent.destroy();
            if(mFinishedCallback != null)
            {
               mFinishedCallback();
               mFinishedCallback = null;
            }
         }
         else
         {
            _loc4_ = _loc5_ / mDuration;
            if(mRevealType == 0)
            {
               mRoot.alpha = 1 - Math.pow(_loc4_,2);
            }
            else
            {
               mRoot.alpha = Math.pow(_loc4_,4);
            }
            _loc2_ = mDuration;
            _loc3_ = mDuration;
            if(mRevealType == 0)
            {
               mRoot.scaleX = mRoot.scaleY = 1 - ((_loc5_ + _loc3_) / (_loc2_ + _loc3_) - _loc3_ / (_loc2_ + _loc3_));
            }
            else
            {
               mRoot.scaleX = mRoot.scaleY = ((_loc5_ + _loc3_) / (_loc2_ + _loc3_) - _loc3_ / (_loc2_ + _loc3_)) * mTargetScale;
            }
         }
      }
      
      public function destroy() : void
      {
         if(mRoot)
         {
            mRoot.scaleX = mRoot.scaleY = mTargetScale;
         }
         mWorkComponent.destroy();
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
            mFinishedCallback = null;
         }
         mDBFacade = null;
         mRoot = null;
      }
   }
}

