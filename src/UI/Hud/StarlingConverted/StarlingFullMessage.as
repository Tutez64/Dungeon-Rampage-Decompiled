package UI.Hud.StarlingConverted
{
   import Facade.DBFacade;
   import flash.utils.getTimer;
   import starling.display.DisplayObject;
   
   public class StarlingFullMessage implements IHudTick
   {
      
      private var mFacade:DBFacade;
      
      private var mRoot:DisplayObject;
      
      private var mTicker:HudTicker;
      
      private var mStart:uint;
      
      private var mFloatAt:int;
      
      private var mTickLength:Number;
      
      private var mPhase:int;
      
      public var changed:Function;
      
      public function StarlingFullMessage(facade:DBFacade, root:DisplayObject, ticker:HudTicker)
      {
         super();
         mFacade = facade;
         mRoot = root;
         mTicker = ticker;
         if(root != null)
         {
            root.visible = false;
         }
         if(root is ArtDisplay)
         {
            ArtDisplay(root).setHudVisibility(false);
         }
      }
      
      public function show() : void
      {
         if(mRoot == null || mPhase != 0)
         {
            return;
         }
         mStart = mFacade.gameClock.frame;
         mTickLength = mFacade.gameClock.tickLength;
         mPhase = 1;
         mRoot.visible = true;
         if(mRoot is ArtDisplay)
         {
            ArtDisplay(mRoot).setHudVisibility(true);
         }
         mRoot.alpha = 1;
         mRoot.scaleX = mRoot.scaleY = 1;
         mTicker.register(this);
         mTicker.registerStage(this);
         if(changed != null)
         {
            changed();
         }
      }
      
      public function tick(tickLength:Number, stageFrame:Boolean) : void
      {
         var _loc5_:Number = NaN;
         var _loc3_:uint = 0;
         var _loc4_:Number = NaN;
         if(mPhase == 1 && !stageFrame)
         {
            _loc3_ = mFacade.gameClock.frame - mStart;
            if(_loc3_ > 8)
            {
               mRoot.alpha = mRoot.scaleX = mRoot.scaleY = 1;
               mFloatAt = getTimer();
               mPhase = 2;
            }
            else
            {
               _loc5_ = _loc3_ / 8;
               mRoot.alpha = _loc5_ * _loc5_ * _loc5_ * _loc5_;
               mRoot.scaleX = mRoot.scaleY = _loc3_ / 16;
            }
         }
         else if(mPhase == 2 && stageFrame)
         {
            _loc4_ = (getTimer() - mFloatAt) / (1000 * mTickLength);
            _loc5_ = Math.max(0,Math.min(1,(_loc4_ - 2) / 12.8));
            mRoot.scaleX = mRoot.scaleY = 1 + 0.125 * (1 - Math.pow(1 - _loc5_,5));
            _loc5_ = Math.max(0,Math.min(1,(_loc4_ - 14.8) / 3.2));
            mRoot.alpha = (1 - _loc5_) * (1 - _loc5_);
            if(_loc4_ >= 18)
            {
               stop();
            }
         }
         if(changed != null)
         {
            changed();
         }
      }
      
      public function stop() : void
      {
         mPhase = 0;
         mTicker.unregister(this);
         mTicker.unregisterStage(this);
         if(mRoot == null)
         {
            return;
         }
         mRoot.alpha = 0;
         mRoot.scaleX = mRoot.scaleY = 1;
      }
      
      public function dispose() : void
      {
         stop();
         changed = null;
         mFacade = null;
         mRoot = null;
         mTicker = null;
      }
   }
}

