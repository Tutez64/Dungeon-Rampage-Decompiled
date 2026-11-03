package Brain.WorkLoop
{
   import Brain.Clock.GameClock;
   import Brain.Utils.MemoryTracker;
   import Collections.Set;
   import flash.display.Sprite;
   
   public class WorkLoopManager extends Sprite
   {
      
      protected var mTasks:Set = new Set();
      
      private var mTaskSnapshot:Array;
      
      protected var mCurrentGameClock:GameClock;
      
      protected var doLaterQueue:SimplePriorityQueue = new SimplePriorityQueue(1024);
      
      public function WorkLoopManager(gameClock:GameClock)
      {
         super();
         mCurrentGameClock = gameClock;
         MemoryTracker.track(mTasks,"Set - frame tasks in WorkLoopManager()","brain");
         MemoryTracker.track(doLaterQueue,"SimplePriorityQueue - doLater queue in WorkLoopManager()","brain");
      }
      
      public function update(gameClock:GameClock) : void
      {
         mCurrentGameClock = gameClock;
         advance();
      }
      
      public function get gameClock() : GameClock
      {
         return mCurrentGameClock;
      }
      
      public function doEveryFrame(callback:Function, ownerLabel:String = null) : Task
      {
         var _loc3_:Task = new Task();
         _loc3_.callback = callback;
         mTasks.add(_loc3_);
         mTaskSnapshot = null;
         var _loc4_:String = ownerLabel ? "Task - " + ownerLabel + " every frame" : "Task - every frame task in WorkLoopManager.doEveryFrame()";
         MemoryTracker.track(_loc3_,_loc4_,"brain");
         return _loc3_;
      }
      
      public function doEverySeconds(delay:Number, callback:Function, repeated:Boolean = true, ownerLabel:String = null) : DoLater
      {
         return doLater(delay,callback,repeated,ownerLabel);
      }
      
      public function CalculateCallbackTime(delay:Number) : uint
      {
         return mCurrentGameClock.gameTime + delay * 1000;
      }
      
      public function doLater(delay:Number, callback:Function, repeat:Boolean = true, ownerLabel:String = null) : DoLater
      {
         var _loc6_:DoLater = new DoLater(repeat);
         _loc6_.delay = delay;
         _loc6_.dueTime = mCurrentGameClock.gameTime + _loc6_.delay * 1000;
         _loc6_.callback = callback;
         doLaterQueue.enqueue(_loc6_);
         var _loc5_:String = ownerLabel ? "DoLater - " + ownerLabel + " delay=" + delay + "s repeat=" + repeat : "DoLater - delay=" + delay + "s repeat=" + repeat + " in WorkLoopManager.doLater()";
         MemoryTracker.track(_loc6_,_loc5_,"brain");
         return _loc6_;
      }
      
      public function removeDoLater(doLaterTask:DoLater) : Boolean
      {
         doLaterTask.destroy();
         return doLaterQueue.remove(doLaterTask);
      }
      
      protected function removeTask(task:Task) : Boolean
      {
         task.destroy();
         mTaskSnapshot = null;
         return mTasks.remove(task);
      }
      
      private function advance() : void
      {
         processTasks();
         processDoLaters();
      }
      
      private function processTasks() : void
      {
         var _loc1_:Task = null;
         var _loc3_:int = 0;
         if(mTasks.size == 0)
         {
            return;
         }
         if(mTaskSnapshot == null)
         {
            mTaskSnapshot = mTasks.toArray();
         }
         var _loc4_:Array = mTaskSnapshot;
         var _loc2_:int = int(_loc4_.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = _loc4_[_loc3_];
            if(_loc1_.isDestroyed())
            {
               removeTask(_loc1_);
            }
            else if(_loc1_.callback != null)
            {
               _loc1_.callback(mCurrentGameClock);
            }
            _loc3_++;
         }
      }
      
      private function processDoLaters() : void
      {
         var _loc1_:DoLater = null;
         if(doLaterQueue.size == 0)
         {
            return;
         }
         while(doLaterQueue.front && doLaterQueue.front.priority >= -mCurrentGameClock.gameTime)
         {
            _loc1_ = doLaterQueue.dequeue() as DoLater;
            if(_loc1_ && !_loc1_.isDestroyed())
            {
               if(_loc1_.callback != null)
               {
                  _loc1_.callback(mCurrentGameClock);
               }
               if(_loc1_.repeat && !_loc1_.isDestroyed())
               {
                  _loc1_.dueTime += _loc1_.delay * 1000;
                  doLaterQueue.enqueue(_loc1_);
               }
            }
         }
      }
   }
}

