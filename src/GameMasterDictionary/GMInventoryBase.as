package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMInventoryBase extends GMItem
   {
      
      public static var WEAPON_CATEGORY:String = "WEAPON";
      
      public static var POWERUP_CATEGORY:String = "POWERUP";
      
      public static var PET_CATEGORY:String = "PET";
      
      public static var STUFF_CATEGORY:String = "STUFF";
      
      public var UISwfFilepath:String;
      
      public var SellCoins:int;
      
      public var ItemSubclass:String;
      
      public var ItemCategory:String;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var Coins:int;
      
      public var CashI:int;
      
      public var CashH:int;
      
      public var CashG:int;
      
      public var CashF:int;
      
      public var CashE:int;
      
      public var CashD:int;
      
      public var CashC:int;
      
      public var CashB:int;
      
      public var Cash:int;
      
      public function GMInventoryBase(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Coins = int(jsonAsset.Coins);
            Cash = int(jsonAsset.Cash);
            CashB = int(jsonAsset.CashB);
            CashC = int(jsonAsset.CashC);
            CashD = int(jsonAsset.CashD);
            CashE = int(jsonAsset.CashE);
            CashF = int(jsonAsset.CashF);
            CashG = int(jsonAsset.CashG);
            CashH = int(jsonAsset.CashH);
            CashI = int(jsonAsset.CashI);
            SellCoins = int(jsonAsset.SellCoins);
            ItemCategory = jsonAsset.ItemCategory;
            ItemSubclass = jsonAsset.ItemSubclass;
            IconName = jsonAsset.IconName;
            UISwfFilepath = jsonAsset.UISwfFilepath;
            Description = jsonAsset.Description;
         }
      }
   }
}

