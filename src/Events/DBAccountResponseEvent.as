package Events
{
   import Account.DBAccountInfo;
   import flash.events.Event;
   
   public class DBAccountResponseEvent extends Event
   {
      
      public static const EVENT_NAME:String = "DB_ACCOUNT_INFO_RESPONSE";
      
      protected var mDBAccountInfo:DBAccountInfo;
      
      public function DBAccountResponseEvent(dbAccountInfo:DBAccountInfo, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("DB_ACCOUNT_INFO_RESPONSE",bubbles,cancelable);
         mDBAccountInfo = dbAccountInfo;
         if(dbAccountInfo.inventoryInfo.canShowInfiniteIsland())
         {
            dbAccountInfo.getAllMapnodeScoresRPC(mDBAccountInfo.id);
         }
      }
      
      public function get dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
   }
}

