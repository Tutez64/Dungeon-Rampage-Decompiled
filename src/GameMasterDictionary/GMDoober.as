package GameMasterDictionary
{
   import DBGlobals.As3Compat;
   import flash.Boot;
   
   public class GMDoober extends GMItem
   {
      
      public var SwfFilePath:String;
      
      public var SharedReward:String;
      
      public var ScaleVisual:Number;
      
      public var Rarity:String;
      
      public var PickupVolume:Number;
      
      public var PickupSound:String;
      
      public var MPPercentage:Number;
      
      public var InstantReward:String;
      
      public var HPPercentage:Number;
      
      public var Exp:uint;
      
      public var DooberType:String;
      
      public var ChestId:uint;
      
      public var AssetClassName:String;
      
      public function GMDoober(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            DooberType = jsonAsset.DooberType;
            SharedReward = jsonAsset.SharedReward;
            ScaleVisual = 1;
            if(As3Compat.truthy(Number(jsonAsset.ScaleVisual)))
            {
               ScaleVisual = Number(jsonAsset.ScaleVisual);
            }
            InstantReward = jsonAsset.InstantReward;
            AssetClassName = jsonAsset.AssetClassName;
            SwfFilePath = jsonAsset.SwfFilepath;
            PickupSound = jsonAsset.PickupSound;
            PickupVolume = Number(jsonAsset.PickupVol);
            Exp = uint(jsonAsset.Exp);
            ChestId = uint(jsonAsset.ChestId);
            Rarity = jsonAsset.Rarity;
            HPPercentage = Number(jsonAsset.HP_PERCENTAGE);
            MPPercentage = Number(jsonAsset.MP_PERCENTAGE);
         }
      }
      
      public function isFood() : Boolean
      {
         if(!(DooberType == "FOOD" || DooberType == "FOOD_COOK"))
         {
            return DooberType == "CHEF_FOOD";
         }
         return true;
      }
   }
}

