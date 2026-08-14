package Account
{
   import Brain.Clock.GameClock;
   import Brain.Utils.TimeSpan;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMBuff;
   import GameMasterDictionary.GMStackable;
   
   public class BoosterInfo extends InventoryBaseInfo
   {
      
      private var mTimestampEnd:String;
      
      private var mGMStackable:GMStackable;
      
      private var mBuff:GMBuff;
      
      public function BoosterInfo(dbFacade:DBFacade, json:Object)
      {
         super(dbFacade,json);
         mGMStackable = mDBFacade.gameMaster.stackableById.itemFor(mGMId);
         mBuff = mDBFacade.gameMaster.buffByConstant.itemFor(mGMStackable.Buff);
      }
      
      public function timeStamp() : String
      {
         return mTimestampEnd;
      }
      
      public function get StackInfo() : GMStackable
      {
         return mGMStackable;
      }
      
      public function get BuffInfo() : GMBuff
      {
         return mBuff;
      }
      
      public function getDisplayTimeLeft() : String
      {
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_:Date = _loc2_.dateBooster(this.gmId);
         if(_loc1_ == null)
         {
            return Locale.getString("EXPIRED");
         }
         var _loc3_:TimeSpan = new TimeSpan(_loc1_.time);
         return _loc3_.getTimeBetweenTimeSpanAndNow(true);
      }
      
      public function getEndDate() : Date
      {
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         return _loc2_.dateBooster(this.gmId);
      }
      
      public function getTimeLeft() : Number
      {
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_:Date = _loc2_.dateBooster(this.gmId);
         if(_loc1_ == null)
         {
            return 0;
         }
         return _loc1_.getTime() - GameClock.getWebServerTime();
      }
      
      override protected function parseJson(json:Object) : void
      {
         if(json == null)
         {
            return;
         }
         mGMId = json.stack_id as uint;
         mAccountId = json.account_id as uint;
         mDatabaseId = json.id as uint;
         mTimestampEnd = json.timestamp_end as String;
         mIsNew = false;
      }
   }
}

