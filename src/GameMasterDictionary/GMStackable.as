package GameMasterDictionary
{
   public class GMStackable extends GMInventoryBase
   {
      
      public var StackLimit:uint;
      
      public var EquipLimit:uint;
      
      public var LevelReq:uint;
      
      public var ExpMult:Number;
      
      public var GoldMult:Number;
      
      public var AccountBooster:Boolean;
      
      public var Buff:String;
      
      public var UsageAttack:String;
      
      public function GMStackable(jsonAsset:Object)
      {
         super(jsonAsset);
         StackLimit = jsonAsset.StackLimit;
         EquipLimit = jsonAsset.EquipLimit;
         LevelReq = jsonAsset.LevelReq;
         ExpMult = jsonAsset.ExpMult;
         GoldMult = jsonAsset.GoldMult;
         Buff = jsonAsset.BuffGiven;
         UsageAttack = jsonAsset.UsageAttack;
         AccountBooster = jsonAsset.AccountBooster;
      }
   }
}

