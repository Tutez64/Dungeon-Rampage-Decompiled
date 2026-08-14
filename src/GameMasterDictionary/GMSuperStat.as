package GameMasterDictionary
{
   public class GMSuperStat extends GMItem
   {
      
      public var BaseValues:StatVector;
      
      public var Ability1:String;
      
      public var Ability2:String;
      
      public var Ability3:String;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var CooldownReduction:Number;
      
      public function GMSuperStat(jsonAsset:Object)
      {
         super(jsonAsset);
         BaseValues = new StatVector();
         BaseValues.SetFromJSON(jsonAsset);
         Ability1 = jsonAsset.Ability1;
         Ability2 = jsonAsset.Ability2;
         Ability3 = jsonAsset.Ability3;
         IconName = jsonAsset.IconName;
         Description = jsonAsset.Description;
         CooldownReduction = jsonAsset.CooldownReduction;
      }
   }
}

