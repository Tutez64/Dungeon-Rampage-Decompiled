package Brain.WorkLoop
{
   import Brain.Clock.GameClock;
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import flash.utils.Dictionary;
   
   public class WorkComponent extends Component
   {
      
      protected var mWorkLoopManager:WorkLoopManager;
      
      protected var mTasks:Dictionary;
      
      protected var mOwnerName:String;
      
      private var mTasksLabel:String;
      
      public function WorkComponent(dbFacade:Facade, workLoopManager:WorkLoopManager, ownerName:String = null)
      {
         super(dbFacade);
         mOwnerName = ownerName;
         mTasksLabel = "Dictionary - tasks in " + (ownerName || "WorkComponent") + "()";
         mTasks = new Dictionary(true);
         MemoryTracker.track(mTasks,mTasksLabel,"brain");
         mWorkLoopManager = workLoopManager;
      }
      
      public function get gameClock() : GameClock
      {
         return mWorkLoopManager.gameClock;
      }
      
      public function doEveryFrame(callback:Function) : Task
      {
         var _loc2_:Task = mWorkLoopManager.doEveryFrame(callback,mOwnerName);
         mTasks[_loc2_] = 1;
         return _loc2_;
      }
      
      public function doLater(delay:Number, callback:Function) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doLater(delay,callback,false,mOwnerName);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function doEverySeconds(interval:Number, callback:Function) : Task
      {
         var _loc3_:Task = mWorkLoopManager.doEverySeconds(interval,callback,true,mOwnerName);
         mTasks[_loc3_] = 1;
         return _loc3_;
      }
      
      public function clear() : void
      {
         for(var _loc1_:Object in mTasks)
         {
            Task(_loc1_).destroy();
         }
         mTasks = new Dictionary(true);
         MemoryTracker.track(mTasks,mTasksLabel,"brain");
      }
      
      override public function destroy() : void
      {
         for(var _loc1_:Object in mTasks)
         {
            Task(_loc1_).destroy();
         }
         mTasks = null;
         mWorkLoopManager = null;
         super.destroy();
      }
   }
}

