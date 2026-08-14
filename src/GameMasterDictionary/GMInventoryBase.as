package GameMasterDictionary
{
   public class GMInventoryBase extends GMItem
   {
      
      public static const WEAPON_CATEGORY:String = "WEAPON";
      
      public static const POWERUP_CATEGORY:String = "POWERUP";
      
      public static const PET_CATEGORY:String = "PET";
      
      public static const STUFF_CATEGORY:String = "STUFF";
      
      public var Coins:int;
      
      public var Cash:int;
      
      public var CashB:int;
      
      public var CashC:int;
      
      public var CashD:int;
      
      public var CashE:int;
      
      public var CashF:int;
      
      public var CashG:int;
      
      public var CashH:int;
      
      public var CashI:int;
      
      public var SellCoins:int;
      
      public var IconName:String;
      
      public var UISwfFilepath:String;
      
      public var Description:String;
      
      public var ItemCategory:String;
      
      public var ItemSubclass:String;
      
      public function GMInventoryBase(jsonAsset:Object)
      {
         super(jsonAsset);
         Coins = jsonAsset.Coins;
         Cash = jsonAsset.Cash;
         CashB = jsonAsset.CashB;
         CashC = jsonAsset.CashC;
         CashD = jsonAsset.CashD;
         CashE = jsonAsset.CashE;
         CashF = jsonAsset.CashF;
         CashG = jsonAsset.CashG;
         CashH = jsonAsset.CashH;
         CashI = jsonAsset.CashI;
         SellCoins = jsonAsset.SellCoins;
         ItemCategory = jsonAsset.ItemCategory;
         ItemSubclass = jsonAsset.ItemSubclass;
         IconName = jsonAsset.IconName;
         UISwfFilepath = jsonAsset.UISwfFilepath;
         Description = jsonAsset.Description;
      }
   }
}

