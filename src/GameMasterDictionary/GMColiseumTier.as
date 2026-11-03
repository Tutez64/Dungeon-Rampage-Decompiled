package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMColiseumTier extends GMItem
   {
      
      public var TotalFloors:int;
      
      public var MusicFilepath:String;
      
      public var MinLevel:int;
      
      public var BonusGold:Number;
      
      public var BonusExp:Number;
      
      public function GMColiseumTier(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            MusicFilepath = jsonAsset.MusicFilepath;
            BonusGold = Number(jsonAsset.Gold);
            BonusExp = Number(jsonAsset.Exp);
            MinLevel = int(jsonAsset.MinLevel);
            TotalFloors = int(jsonAsset.MinFloors);
         }
      }
   }
}

