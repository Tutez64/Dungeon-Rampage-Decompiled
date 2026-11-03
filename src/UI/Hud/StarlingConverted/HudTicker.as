package UI.Hud.StarlingConverted
{
   import Brain.Clock.GameClock;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class HudTicker
   {
      
      private var mViews:Vector.<IHudTick> = new Vector.<IHudTick>(0);
      
      private var mStage:Stage;
      
      private var mPending:Vector.<Function> = new Vector.<Function>(0);
      
      private var mStageViews:Vector.<IHudTick> = new Vector.<IHudTick>(0);
      
      private var mClock:GameClock;
      
      private var mTicking:Boolean = false;
      
      private var mStageTicking:Boolean = false;
      
      public var onError:Function;
      
      public function HudTicker(clock:GameClock)
      {
         super();
         mClock = clock;
      }
      
      private static function compact(views:Vector.<IHudTick>) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < views.length)
         {
            if(views[_loc2_] != null)
            {
               views[_loc3_++] = views[_loc2_];
            }
            _loc2_++;
         }
         views.length = _loc3_;
      }
      
      public function attachStage(stage:Stage) : void
      {
         if(mStage == stage)
         {
            return;
         }
         if(mStage != null)
         {
            mStage.removeEventListener("enterFrame",onStageFrame);
         }
         mStage = stage;
         if(mStage != null)
         {
            mStage.addEventListener("enterFrame",onStageFrame);
         }
      }
      
      private function onStageFrame(event:Event) : void
      {
         if(HudArtConverter.busy || mTicking || mStageTicking)
         {
            return;
         }
         try
         {
            advanceStage();
         }
         catch(error:Error)
         {
            if(onError != null)
            {
               onError(error);
            }
            else
            {
               StarlingHud.reportError(error);
            }
         }
      }
      
      private function advanceStage() : void
      {
         var _loc4_:int = 0;
         var _loc2_:IHudTick = null;
         var _loc3_:int = int(mViews.length);
         var _loc1_:int = int(mStageViews.length);
         mTicking = mStageTicking = true;
         try
         {
            _loc4_ = 0;
            while(_loc4_ < _loc1_ && _loc4_ < mStageViews.length)
            {
               _loc2_ = mStageViews[_loc4_];
               if(_loc2_ != null)
               {
                  tickView(_loc2_,0,true);
               }
               _loc4_++;
            }
            _loc4_ = 0;
            while(_loc4_ < _loc3_ && _loc4_ < mViews.length)
            {
               _loc2_ = mViews[_loc4_];
               if(_loc2_ is TimelineView && Boolean(TimelineView(_loc2_).stageRate))
               {
                  tickView(_loc2_,0,true);
               }
               _loc4_++;
            }
         }
         finally
         {
            mTicking = mStageTicking = false;
            compact(mViews);
            compact(mStageViews);
         }
      }
      
      private function tickView(view:IHudTick, length:Number, stageFrame:Boolean) : void
      {
         try
         {
            view.tick(length,stageFrame);
         }
         catch(error:Error)
         {
            if(onError != null)
            {
               onError(error);
            }
            else
            {
               StarlingHud.reportError(error);
            }
         }
      }
      
      public function register(view:IHudTick) : void
      {
         if(mViews.indexOf(view) < 0)
         {
            mViews.push(view);
         }
      }
      
      public function registerStage(view:IHudTick) : void
      {
         if(mStageViews.indexOf(view) < 0)
         {
            mStageViews.push(view);
         }
      }
      
      public function unregisterStage(view:IHudTick) : void
      {
         var _loc2_:int = mStageViews.indexOf(view);
         if(_loc2_ >= 0)
         {
            if(mStageTicking)
            {
               mStageViews[_loc2_] = null;
            }
            else
            {
               mStageViews.removeAt(_loc2_);
            }
         }
      }
      
      public function deferBake(retry:Function) : void
      {
         if(mPending.indexOf(retry) < 0)
         {
            mPending.push(retry);
         }
      }
      
      public function cancelBake(retry:Function) : void
      {
         var _loc2_:int = mPending.indexOf(retry);
         if(_loc2_ >= 0)
         {
            mPending.removeAt(_loc2_);
         }
      }
      
      public function unregister(view:IHudTick) : void
      {
         var _loc2_:int = mViews.indexOf(view);
         if(_loc2_ >= 0)
         {
            if(mTicking)
            {
               mViews[_loc2_] = null;
            }
            else
            {
               mViews.removeAt(_loc2_);
            }
         }
      }
      
      public function tick(tickLength:Number) : void
      {
         var _loc5_:Function = null;
         var _loc2_:IHudTick = null;
         if(HudArtConverter.busy || mTicking || mStageTicking)
         {
            return;
         }
         var _loc4_:int = 0;
         var _loc3_:int = int(mViews.length);
         mTicking = true;
         try
         {
            if(mPending.length > 0)
            {
               while(_loc4_ < mPending.length)
               {
                  _loc5_ = mPending[_loc4_];
                  try
                  {
                     if(_loc5_())
                     {
                        cancelBake(_loc5_);
                     }
                  }
                  catch(error:Error)
                  {
                     cancelBake(_loc5_);
                     StarlingHud.reportError(error);
                  }
                  if(_loc4_ < mPending.length && mPending[_loc4_] == _loc5_)
                  {
                     _loc4_++;
                  }
               }
            }
            _loc4_ = 0;
            while(_loc4_ < _loc3_ && _loc4_ < mViews.length)
            {
               _loc2_ = mViews[_loc4_];
               if(_loc2_ != null)
               {
                  tickView(_loc2_,tickLength,false);
               }
               _loc4_++;
            }
         }
         finally
         {
            mTicking = false;
            compact(mViews);
         }
      }
      
      public function get gameTime() : int
      {
         return mClock.gameTime;
      }
      
      public function dispose() : void
      {
         attachStage(null);
         mViews.length = mPending.length = mStageViews.length = 0;
         onError = null;
      }
   }
}

