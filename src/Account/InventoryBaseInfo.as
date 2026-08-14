package Account
{
   import Facade.DBFacade;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMInventoryBase;
   import org.as3commons.collections.Map;
   
   public class InventoryBaseInfo
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mDatabaseId:uint;
      
      protected var mGMId:uint;
      
      protected var mAccountId:uint;
      
      protected var mIsNew:Boolean;
      
      protected var mGMInventoryBase:GMInventoryBase;
      
      protected var mGMChestInfo:GMChest;
      
      protected var mKeys:Map;
      
      public function InventoryBaseInfo(dbFacade:DBFacade, json:Object)
      {
         super();
         mDBFacade = dbFacade;
         parseJson(json);
      }
      
      public function get Description() : String
      {
         return mGMInventoryBase.Description;
      }
      
      public function get uiSwfFilepath() : String
      {
         return mGMInventoryBase != null ? mGMInventoryBase.UISwfFilepath : null;
      }
      
      public function get iconScale() : Number
      {
         return 100;
      }
      
      public function get iconName() : String
      {
         return mGMInventoryBase != null ? mGMInventoryBase.IconName : null;
      }
      
      public function get hasColoredBackground() : Boolean
      {
         return false;
      }
      
      public function get backgroundIconName() : String
      {
         return "";
      }
      
      public function get backgroundSwfPath() : String
      {
         return "";
      }
      
      public function get backgroundIconBorderName() : String
      {
         return "";
      }
      
      public function get Name() : String
      {
         return mGMInventoryBase.Name;
      }
      
      public function get sellCoins() : int
      {
         return mGMInventoryBase.SellCoins;
      }
      
      public function get gmInventoryBase() : GMInventoryBase
      {
         return mGMInventoryBase;
      }
      
      public function get gmChestInfo() : GMChest
      {
         return mGMChestInfo;
      }
      
      public function set keys(keyMap:Map) : void
      {
         mKeys = keyMap;
      }
      
      public function get keys() : Map
      {
         return mKeys;
      }
      
      public function get isEquipped() : Boolean
      {
         return false;
      }
      
      public function get isNew() : Boolean
      {
         return mIsNew;
      }
      
      public function set isNew(value:Boolean) : void
      {
         mIsNew = value;
      }
      
      public function get databaseId() : uint
      {
         return mDatabaseId;
      }
      
      public function get gmId() : uint
      {
         return mGMId;
      }
      
      public function get needsRenderer() : Boolean
      {
         return false;
      }
      
      protected function parseJson(json:Object) : void
      {
      }
      
      public function getTextColor() : uint
      {
         return 16763904;
      }
      
      public function hasGMPropertySetup() : Boolean
      {
         return mGMInventoryBase != null || mGMChestInfo != null;
      }
      
      public function get weaponAestheticConstant() : String
      {
         return "";
      }
   }
}

