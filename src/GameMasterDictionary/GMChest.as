package GameMasterDictionary
{
   public class GMChest
   {
      
      public var Id:uint;
      
      public var Name:String;
      
      public var Rarity:String;
      
      public var IconName:String;
      
      public var IconSwf:String;
      
      public var InventoryRevealName:String;
      
      public var InventoryRevealSwf:String;
      
      public var Description:String;
      
      public function GMChest(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         Name = jsonAsset.Name;
         Rarity = jsonAsset.Rarity;
         IconName = jsonAsset.IconName;
         IconSwf = jsonAsset.IconSwf;
         InventoryRevealName = jsonAsset.InventoryRevealName;
         InventoryRevealSwf = jsonAsset.InventoryRevealSwf;
         Description = jsonAsset.Description;
      }
   }
}

