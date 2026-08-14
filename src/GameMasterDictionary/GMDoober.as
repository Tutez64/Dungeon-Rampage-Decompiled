package GameMasterDictionary
{
   public class GMDoober extends GMItem
   {
      
      public var DooberType:String;
      
      public var SharedReward:String;
      
      public var InstantReward:String;
      
      public var ScaleVisual:Number;
      
      public var AssetClassName:String;
      
      public var SwfFilePath:String;
      
      public var PickupSound:String;
      
      public var PickupVolume:Number;
      
      public var Exp:uint;
      
      public var ChestId:uint;
      
      public var Rarity:String;
      
      public var HPPercentage:Number;
      
      public var MPPercentage:Number;
      
      public function GMDoober(jsonAsset:Object)
      {
         super(jsonAsset);
         DooberType = jsonAsset.DooberType;
         SharedReward = jsonAsset.SharedReward;
         ScaleVisual = 1;
         if(jsonAsset.ScaleVisual)
         {
            ScaleVisual = jsonAsset.ScaleVisual;
         }
         InstantReward = jsonAsset.InstantReward;
         AssetClassName = jsonAsset.AssetClassName;
         SwfFilePath = jsonAsset.SwfFilepath;
         PickupSound = jsonAsset.PickupSound;
         PickupVolume = jsonAsset.PickupVol;
         Exp = jsonAsset.Exp;
         ChestId = jsonAsset.ChestId;
         Rarity = jsonAsset.Rarity;
         HPPercentage = jsonAsset.HP_PERCENTAGE;
         MPPercentage = jsonAsset.MP_PERCENTAGE;
      }
      
      public function isFood() : Boolean
      {
         return DooberType == "FOOD" || DooberType == "FOOD_COOK" || DooberType == "CHEF_FOOD";
      }
   }
}

