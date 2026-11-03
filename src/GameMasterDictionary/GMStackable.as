package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMStackable extends GMInventoryBase
   {
      
      public var UsageAttack:String;
      
      public var StackLimit:uint;
      
      public var LevelReq:uint;
      
      public var GoldMult:Number;
      
      public var ExpMult:Number;
      
      public var EquipLimit:uint;
      
      public var Buff:String;
      
      public var AccountBooster:Boolean;
      
      public function GMStackable(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            StackLimit = uint(jsonAsset.StackLimit);
            EquipLimit = uint(jsonAsset.EquipLimit);
            LevelReq = uint(jsonAsset.LevelReq);
            ExpMult = Number(jsonAsset.ExpMult);
            GoldMult = Number(jsonAsset.GoldMult);
            Buff = jsonAsset.BuffGiven;
            UsageAttack = jsonAsset.UsageAttack;
            AccountBooster = Boolean(jsonAsset.AccountBooster);
         }
      }
   }
}

