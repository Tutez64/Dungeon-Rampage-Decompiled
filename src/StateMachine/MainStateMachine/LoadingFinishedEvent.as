package StateMachine.MainStateMachine
{
   import Account.DBAccountInfo;
   import flash.events.Event;
   
   public class LoadingFinishedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "LoadingFinishedEvent";
      
      private var mDBAccountInfo:DBAccountInfo;
      
      public function LoadingFinishedEvent(dbAccountInfo:DBAccountInfo, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("LoadingFinishedEvent",bubbles,cancelable);
         mDBAccountInfo = dbAccountInfo;
      }
      
      public function get dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
   }
}

