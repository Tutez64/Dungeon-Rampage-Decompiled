package GameMasterDictionary
{
   public class GMOfferDetail
   {
      
      public var OfferId:uint;
      
      public var WeaponId:uint;
      
      public var WeaponPower:uint;
      
      public var Level:uint;
      
      public var Rarity:String;
      
      public var Modifier1:String;
      
      public var Modifier2:String;
      
      public var Modifier3:String;
      
      public var ChestId:uint;
      
      public var HeroId:uint;
      
      public var PetId:uint;
      
      public var SkinId:uint;
      
      public var StackableId:uint;
      
      public var StackableCount:uint;
      
      public var Coins:uint;
      
      public var BasicKeys:uint;
      
      public var UncommonKeys:uint;
      
      public var RareKeys:uint;
      
      public var LegendaryKeys:uint;
      
      public var WeaponSlots:uint;
      
      public var Gems:uint;
      
      public function GMOfferDetail(jsonAsset:Object)
      {
         super();
         OfferId = jsonAsset.OfferId;
         WeaponId = jsonAsset.WeaponId;
         WeaponPower = jsonAsset.WeaponPower;
         Level = jsonAsset.Level != null ? jsonAsset.Level : 0;
         Rarity = jsonAsset.Rarity;
         Modifier1 = jsonAsset.Modifier1;
         Modifier2 = jsonAsset.Modifier2;
         Modifier3 = jsonAsset.Modifier3;
         ChestId = jsonAsset.ChestId;
         HeroId = jsonAsset.HeroId;
         PetId = jsonAsset.PetId;
         SkinId = jsonAsset.SkinId;
         StackableId = jsonAsset.StackableId;
         StackableCount = jsonAsset.StackableCount;
         Coins = jsonAsset.Coins;
         BasicKeys = jsonAsset.BasicKeys;
         UncommonKeys = jsonAsset.UncommonKeys;
         RareKeys = jsonAsset.RareKeys;
         LegendaryKeys = jsonAsset.LegendaryKeys;
         WeaponSlots = jsonAsset.WeaponSlots;
         Gems = jsonAsset.Gems;
      }
   }
}

