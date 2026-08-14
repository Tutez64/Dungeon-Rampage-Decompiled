package Events
{
   import Account.DBAccountInfo;
   import flash.events.Event;
   
   public class DBAccountLoadedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "DB_ACCOUNT_INFO_LOADED";
      
      protected var mDBAccountInfo:DBAccountInfo;
      
      public function DBAccountLoadedEvent(dbAccountInfo:DBAccountInfo, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("DB_ACCOUNT_INFO_LOADED",bubbles,cancelable);
         mDBAccountInfo = dbAccountInfo;
      }
      
      public function get dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
   }
}

