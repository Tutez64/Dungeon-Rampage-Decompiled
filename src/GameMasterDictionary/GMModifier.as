package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMModifier extends GMItem
   {
      
      public var Type:String;
      
      public var SHOOT_SPD:Number;
      
      public var PIERCE:Number;
      
      public var MP_COST:Number;
      
      public var MODIFIER_TYPE:String;
      
      public var MODIFIER_LEVEL:Number;
      
      public var MELEE_SPD:Number;
      
      public var MAX_PROJECTILES:uint;
      
      public var MAGIC_SPD:Number;
      
      public var Level:uint;
      
      public var IconName:String;
      
      public var INCREASE_COLLISION:Number;
      
      public var INCREASED_PROJECTILE_ANGLE_PERCENT:Number;
      
      public var Description:String;
      
      public var COOLDOWN_REDUC:Number;
      
      public var CHARGE_REDUC:Number;
      
      public var CHAIN:Number;
      
      public function GMModifier(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Type = jsonAsset.MODIFIER_TYPE;
            Level = uint(jsonAsset.MODIFIER_LEVEL);
            IconName = jsonAsset.IconName;
            Description = jsonAsset.Description;
            MODIFIER_LEVEL = uint(jsonAsset.MODIFIER_LEVEL);
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
            if(Reflect.hasField(jsonAsset,"MELEE_SPD"))
            {
               MELEE_SPD = jsonAsset.MELEE_SPD;
            }
            if(Reflect.hasField(jsonAsset,"SHOOT_SPD"))
            {
               SHOOT_SPD = jsonAsset.SHOOT_SPD;
            }
            if(Reflect.hasField(jsonAsset,"MAGIC_SPD"))
            {
               MAGIC_SPD = jsonAsset.MAGIC_SPD;
            }
            if(Reflect.hasField(jsonAsset,"MP_COST"))
            {
               MP_COST = jsonAsset.MP_COST;
            }
            if(Reflect.hasField(jsonAsset,"PIERCE"))
            {
               PIERCE = jsonAsset.PIERCE;
            }
            if(Reflect.hasField(jsonAsset,"CHAIN"))
            {
               CHAIN = jsonAsset.CHAIN;
            }
            if(Reflect.hasField(jsonAsset,"MAX_PROJECTILES"))
            {
               MAX_PROJECTILES = jsonAsset.MAX_PROJECTILES;
            }
            if(Reflect.hasField(jsonAsset,"INCREASED_PROJECTILE_ANGLE_PERCENT"))
            {
               INCREASED_PROJECTILE_ANGLE_PERCENT = jsonAsset.INCREASED_PROJECTILE_ANGLE_PERCENT;
            }
            if(Reflect.hasField(jsonAsset,"COOLDOWN_REDUC"))
            {
               COOLDOWN_REDUC = jsonAsset.COOLDOWN_REDUC;
            }
            if(Reflect.hasField(jsonAsset,"CHARGE_UP_REDUC"))
            {
               CHARGE_REDUC = jsonAsset.CHARGE_UP_REDUC;
            }
            if(Reflect.hasField(jsonAsset,"ATTACK_COLLISION_SCALE"))
            {
               INCREASE_COLLISION = jsonAsset.ATTACK_COLLISION_SCALE;
            }
         }
      }
   }
}

