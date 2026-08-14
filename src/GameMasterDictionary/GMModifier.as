package GameMasterDictionary
{
   public class GMModifier extends GMItem
   {
      
      public var Type:String;
      
      public var Level:uint;
      
      public var IconName:String;
      
      public var Description:String;
      
      public var MELEE_SPD:Number;
      
      public var SHOOT_SPD:Number;
      
      public var MAGIC_SPD:Number;
      
      public var MP_COST:Number;
      
      public var CHAIN:Number;
      
      public var PIERCE:Number;
      
      public var MODIFIER_LEVEL:Number;
      
      public var MODIFIER_TYPE:String;
      
      public var COOLDOWN_REDUC:Number;
      
      public var CHARGE_REDUC:Number;
      
      public var INCREASE_COLLISION:Number;
      
      public var MAX_PROJECTILES:uint;
      
      public var INCREASED_PROJECTILE_ANGLE_PERCENT:Number;
      
      public function GMModifier(jsonAsset:Object)
      {
         super(jsonAsset);
         Type = jsonAsset.MODIFIER_TYPE;
         Level = jsonAsset.MODIFIER_LEVEL;
         IconName = jsonAsset.IconName;
         Description = jsonAsset.Description;
         MODIFIER_LEVEL = jsonAsset.MODIFIER_LEVEL;
         MODIFIER_TYPE = jsonAsset.MODIFIER_TYPE;
         MELEE_SPD = 1;
         SHOOT_SPD = 1;
         MAGIC_SPD = 1;
         MP_COST = 1;
         CHAIN = 0;
         PIERCE = 0;
         COOLDOWN_REDUC = 1;
         CHARGE_REDUC = 1;
         INCREASE_COLLISION = 1;
         MAX_PROJECTILES = 0;
         INCREASED_PROJECTILE_ANGLE_PERCENT = 0;
         if(jsonAsset.hasOwnProperty("MELEE_SPD"))
         {
            MELEE_SPD = jsonAsset.MELEE_SPD;
         }
         if(jsonAsset.hasOwnProperty("SHOOT_SPD"))
         {
            SHOOT_SPD = jsonAsset.SHOOT_SPD;
         }
         if(jsonAsset.hasOwnProperty("MAGIC_SPD"))
         {
            MAGIC_SPD = jsonAsset.MAGIC_SPD;
         }
         if(jsonAsset.hasOwnProperty("MP_COST"))
         {
            MP_COST = jsonAsset.MP_COST;
         }
         if(jsonAsset.hasOwnProperty("PIERCE"))
         {
            PIERCE = jsonAsset.PIERCE;
         }
         if(jsonAsset.hasOwnProperty("CHAIN"))
         {
            CHAIN = jsonAsset.CHAIN;
         }
         if(jsonAsset.hasOwnProperty("MAX_PROJECTILES"))
         {
            MAX_PROJECTILES = jsonAsset.MAX_PROJECTILES;
         }
         if(jsonAsset.hasOwnProperty("INCREASED_PROJECTILE_ANGLE_PERCENT"))
         {
            INCREASED_PROJECTILE_ANGLE_PERCENT = jsonAsset.INCREASED_PROJECTILE_ANGLE_PERCENT;
         }
         if(jsonAsset.hasOwnProperty("COOLDOWN_REDUC"))
         {
            COOLDOWN_REDUC = jsonAsset.COOLDOWN_REDUC;
         }
         if(jsonAsset.hasOwnProperty("CHARGE_UP_REDUC"))
         {
            CHARGE_REDUC = jsonAsset.CHARGE_UP_REDUC;
         }
         if(jsonAsset.hasOwnProperty("ATTACK_COLLISION_SCALE"))
         {
            INCREASE_COLLISION = jsonAsset.ATTACK_COLLISION_SCALE as Number;
         }
      }
   }
}

