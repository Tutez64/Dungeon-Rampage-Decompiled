package Brain.StateMachine
{
   public class State
   {
      
      protected var mName:String = new String();
      
      protected var mFinishedCallback:Function;
      
      protected var mRunning:Boolean = false;
      
      public function State(stateName:String, finishedCallback:Function = null)
      {
         super();
         mName = stateName;
         mFinishedCallback = finishedCallback;
      }
      
      public function get running() : Boolean
      {
         return mRunning;
      }
      
      public function set finishedCallback(callback:Function) : void
      {
         mFinishedCallback = callback;
      }
      
      public function get name() : String
      {
         return mName;
      }
      
      public function enterState() : void
      {
         mRunning = true;
      }
      
      public function exitState() : void
      {
         mRunning = false;
      }
      
      public function destroy() : void
      {
         mFinishedCallback = null;
         mRunning = false;
      }
   }
}

