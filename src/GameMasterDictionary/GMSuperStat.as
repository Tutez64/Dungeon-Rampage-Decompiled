package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMSuperStat extends GMItem
   {
      
      public var TrapPower:Number;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var CooldownReduction:Number;
      
      public var CookingRarityMinPerPoint:Number;
      
      public var CookingRarityMaxPerPoint:Number;
      
      public var CookingRarityMaxBase:Number;
      
      public var CookingFoodOnHitPerPoint:Number;
      
      public var CookingBuffDurationPerPoint:Number;
      
      public var BaseValues:StatVector;
      
      public var Ability3:String;
      
      public var Ability2:String;
      
      public var Ability1:String;
      
      public function GMSuperStat(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            BaseValues = new StatVector();
            BaseValues.SetFromJSON(jsonAsset);
            Ability1 = jsonAsset.Ability1;
            Ability2 = jsonAsset.Ability2;
            Ability3 = jsonAsset.Ability3;
            IconName = jsonAsset.IconName;
            Description = jsonAsset.Description;
            CooldownReduction = Number(jsonAsset.CooldownReduction);
            CookingRarityMinPerPoint = Number(jsonAsset.CookingRarityMinPerPoint);
            CookingRarityMaxPerPoint = Number(jsonAsset.CookingRarityMaxPerPoint);
            CookingRarityMaxBase = Number(jsonAsset.CookingRarityMaxBase);
            CookingBuffDurationPerPoint = Number(jsonAsset.CookingBuffDurationPerPoint);
            CookingFoodOnHitPerPoint = Number(jsonAsset.CookingFoodOnHitPerPoint);
            TrapPower = Number(jsonAsset.TrapPower);
         }
      }
   }
}

