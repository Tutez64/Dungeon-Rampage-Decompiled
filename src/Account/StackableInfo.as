package Account
{
   import Facade.DBFacade;
   import GameMasterDictionary.GMStackable;
   
   public class StackableInfo extends InventoryBaseInfo
   {
      
      private var mCount:uint;
      
      private var mGMStackable:GMStackable;
      
      private var mConsumableSlot:int = -1;
      
      public function StackableInfo(dbFacade:DBFacade, json:Object, gmStackable:GMStackable = null)
      {
         if(json == null)
         {
            mDBFacade = dbFacade;
            mGMStackable = gmStackable;
         }
         else
         {
            super(dbFacade,json);
            mGMStackable = mDBFacade.gameMaster.stackableById.itemFor(mGMId);
         }
         mGMInventoryBase = mGMStackable;
      }
      
      public function get gmStackable() : GMStackable
      {
         return mGMStackable;
      }
      
      override public function get isEquipped() : Boolean
      {
         return this.gmStackable && mConsumableSlot != -1 && this.gmStackable.AccountBooster == false;
      }
      
      public function get equipSlot() : int
      {
         return mConsumableSlot;
      }
      
      public function get count() : uint
      {
         return mCount;
      }
      
      public function set count(value:uint) : void
      {
         mCount = value;
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
         mCount = json.count as uint;
         mIsNew = false;
         mConsumableSlot = -1;
      }
      
      public function setPropertiesAsConsumable(gmId:uint, slot:uint, count:uint) : void
      {
         mGMId = gmId;
         mAccountId = 0;
         mDatabaseId = 0;
         mCount = count;
         mConsumableSlot = slot;
         mIsNew = false;
      }
      
      public function setConsumableSlot(slotNum:uint) : void
      {
         mConsumableSlot = slotNum;
      }
      
      override public function get hasColoredBackground() : Boolean
      {
         return false;
      }
      
      override public function get backgroundIconName() : String
      {
         return "";
      }
      
      override public function get backgroundSwfPath() : String
      {
         return "";
      }
      
      override public function hasGMPropertySetup() : Boolean
      {
         return mGMStackable != null;
      }
      
      public function get consumableSlot() : int
      {
         return mConsumableSlot;
      }
   }
}

