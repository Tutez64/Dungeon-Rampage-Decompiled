package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMStat extends GMItem
   {
      
      public var StatType:String;
      
      public var MaxCap:Number;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var Bonus:Number;
      
      public function GMStat(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            StatType = jsonAsset.StatType;
            Bonus = Number(jsonAsset.Bonus);
            MaxCap = Number(jsonAsset.MaxCap);
            IconName = jsonAsset.IconName;
            Description = jsonAsset.Description;
         }
      }
   }
}

