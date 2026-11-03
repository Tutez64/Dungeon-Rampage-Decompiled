package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMChest
   {
      
      public var Rarity:String;
      
      public var Name:String;
      
      public var InventoryRevealSwf:String;
      
      public var InventoryRevealName:String;
      
      public var Id:uint;
      
      public var IconSwf:String;
      
      public var IconName:String;
      
      public var Description:String;
      
      public function GMChest(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = uint(jsonAsset.Id);
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

