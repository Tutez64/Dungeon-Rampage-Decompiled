package Brain.WorkLoop
{
   import Brain.Clock.GameClock;
   import Brain.Utils.MemoryTracker;
   import flash.display.Sprite;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
   public class WorkLoopManager extends Sprite
   {
      
      protected var mTasks:Set = new Set();
      
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
      
      protected function removeDoLater(doLaterTask:DoLater) : Boolean
      {
         doLaterTask.destroy();
         return doLaterQueue.remove(doLaterTask);
      }
      
      protected function removeTask(task:Task) : Boolean
      {
         task.destroy();
         return mTasks.remove(task);
      }
      
      private function advance() : void
      {
         processTasks();
         processDoLaters();
      }
      
      private function processTasks() : void
      {
         var _loc2_:Task = null;
         if(mTasks.size == 0)
         {
            return;
         }
         var _loc1_:ISetIterator = mTasks.iterator() as ISetIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            if(_loc2_.isDestroyed())
            {
               _loc1_.remove();
               removeTask(_loc2_);
            }
            else if(_loc2_.callback != null)
            {
               _loc2_.callback(mCurrentGameClock);
            }
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
               if(_loc1_.repeat)
               {
                  _loc1_.dueTime += _loc1_.delay * 1000;
                  doLaterQueue.enqueue(_loc1_);
               }
            }
         }
      }
   }
}

