package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMOfferDetail
   {
      
      public var WeaponSlots:uint;
      
      public var WeaponPower:uint;
      
      public var WeaponId:uint;
      
      public var UncommonKeys:uint;
      
      public var StackableId:uint;
      
      public var StackableCount:uint;
      
      public var SkinId:uint;
      
      public var Rarity:String;
      
      public var RareKeys:uint;
      
      public var PetId:uint;
      
      public var OfferId:uint;
      
      public var Modifier3:String;
      
      public var Modifier2:String;
      
      public var Modifier1:String;
      
      public var Level:uint;
      
      public var LegendaryKeys:uint;
      
      public var HeroId:uint;
      
      public var Gems:uint;
      
      public var Coins:uint;
      
      public var ChestId:uint;
      
      public var BasicKeys:uint;
      
      public function GMOfferDetail(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         OfferId = uint(jsonAsset.OfferId);
         WeaponId = uint(jsonAsset.WeaponId);
         WeaponPower = uint(jsonAsset.WeaponPower);
         Level = jsonAsset.Level != null ? uint(jsonAsset.Level) : 0;
         Rarity = jsonAsset.Rarity;
         Modifier1 = jsonAsset.Modifier1;
         Modifier2 = jsonAsset.Modifier2;
         Modifier3 = jsonAsset.Modifier3;
         ChestId = uint(jsonAsset.ChestId);
         HeroId = uint(jsonAsset.HeroId);
         PetId = uint(jsonAsset.PetId);
         SkinId = uint(jsonAsset.SkinId);
         StackableId = uint(jsonAsset.StackableId);
         StackableCount = uint(jsonAsset.StackableCount);
         Coins = uint(jsonAsset.Coins);
         BasicKeys = uint(jsonAsset.BasicKeys);
         UncommonKeys = uint(jsonAsset.UncommonKeys);
         RareKeys = uint(jsonAsset.RareKeys);
         LegendaryKeys = uint(jsonAsset.LegendaryKeys);
         WeaponSlots = uint(jsonAsset.WeaponSlots);
         Gems = uint(jsonAsset.Gems);
      }
   }
}

