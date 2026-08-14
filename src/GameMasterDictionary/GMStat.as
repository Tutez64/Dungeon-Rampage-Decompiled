package GameMasterDictionary
{
   public class GMStat extends GMItem
   {
      
      public var StatType:String;
      
      public var Bonus:Number;
      
      public var MaxCap:Number;
      
      public var IconName:String;
      
      public var Description:String;
      
      public function GMStat(jsonAsset:Object)
      {
         super(jsonAsset);
         StatType = jsonAsset.StatType;
         Bonus = jsonAsset.Bonus;
         MaxCap = jsonAsset.MaxCap;
         IconName = jsonAsset.IconName;
         Description = jsonAsset.Description;
      }
   }
}

