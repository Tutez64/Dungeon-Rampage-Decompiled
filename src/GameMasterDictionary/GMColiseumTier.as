package GameMasterDictionary
{
   public class GMColiseumTier extends GMItem
   {
      
      public var MusicFilepath:String;
      
      public var BonusGold:Number;
      
      public var BonusExp:Number;
      
      public var MinLevel:uint;
      
      public var TotalFloors:uint;
      
      public function GMColiseumTier(jsonAsset:Object)
      {
         super(jsonAsset);
         MusicFilepath = jsonAsset.MusicFilepath;
         BonusGold = jsonAsset.Gold;
         BonusExp = jsonAsset.Exp;
         MinLevel = jsonAsset.MinLevel;
         TotalFloors = jsonAsset.MinFloors;
      }
   }
}

