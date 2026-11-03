package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.As3Compat;
   import flash.Boot;
   
   public class GMWeaponItem extends GMInventoryBase
   {
      
      public static var MELEE_WEAPON_SORT:Vector.<String> = Vector.<String>(["AXE_TYPE","HAMMER_TYPE","SWORD_TYPE","MEATCLEAVER_TYPE","COOKING_TYPE","FRYING_PAN_TYPE","KATANA_TYPE","SPEAR_TYPE","SHIELD_TYPE","FARMTOOL_TYPE","GREATSWORD_TYPE","FLAIL_TYPE","MACE_TYPE","LIGHT_SPEAR_TYPE","HEAVY_SPEAR_TYPE"]);
      
      public static var SHOOTING_WEAPON_SORT:Vector.<String> = Vector.<String>(["BOW_TYPE","CROSSBOW_TYPE","PISTOL_TYPE","THROWING_TYPE","HEAVY_THROWING_TYPE","LIGHT_THROWING_TYPE","TRAP_TYPE","SEED_TYPE","THROWING_SPEAR_TYPE"]);
      
      public static var MAGIC_WEAPON_SORT:Vector.<String> = Vector.<String>(["LIGHTNING_STAFF_TYPE","FIRE_STAFF_TYPE","STAFF_TYPE","LIGHTNING_MAGIC_TYPE","FIRE_MAGIC_TYPE","DARK_MAGIC_TYPE","SCROLL_TYPE","FIRE_RUNE_TYPE","FLAME_STAFF_TYPE","FIRE_GLOVE_TYPE","FIRE_ORB_TYPE","DRAGON_CHARM_TYPE"]);
      
      public static var ALL_WEAPON_SORT:Vector.<String> = GMWeaponItem.MELEE_WEAPON_SORT.concat(GMWeaponItem.SHOOTING_WEAPON_SORT).concat(GMWeaponItem.MAGIC_WEAPON_SORT);
      
      public var WeaponController:String;
      
      public var WeaponAestheticList:Vector.<GMWeaponAesthetic>;
      
      public var TapTitle:String;
      
      public var TapIcon:String;
      
      public var TapDescription:String;
      
      public var Speed:Number;
      
      public var ScalingProjectileStartAngle:Number;
      
      public var ScalingProjectileMinDistance:Number;
      
      public var ScalingProjectileMaxDistance:Number;
      
      public var ScalingProjectileEndAngle:Number;
      
      public var ScalingMinProjectiles:uint;
      
      public var ScalingMaxProjectiles:uint;
      
      public var ScalingMaxPowerMultiplier:Number;
      
      public var ScalingHeroMinDistance:Number;
      
      public var ScalingHeroMaxDistance:Number;
      
      public var ScalingFactor:Number;
      
      public var ScalingDistanceTime:Number;
      
      public var ScaleTapAttack:Boolean;
      
      public var RepeaterOnlyChargeRepeated:Boolean;
      
      public var RepeaterMaxSpeedPercent:Number;
      
      public var RepeaterIncrementSpeedPercent:Number;
      
      public var Release:String;
      
      public var Power:uint;
      
      public var PotentialModifiers:Vector.<GMModifier>;
      
      public var PotentialLegendaryModifiers:Vector.<GMLegendaryModifier>;
      
      public var MasterType:String;
      
      public var HoldingAttack:String;
      
      public var HoldTitle:String;
      
      public var HoldIcon:String;
      
      public var HoldDescription:String;
      
      public var DoNotDrop:Boolean;
      
      public var ControllerTimeTillEnd:Number;
      
      public var ClassType:String;
      
      public var ChooseRandomAttack:Boolean;
      
      public var ChargeAttack:String;
      
      public var AttackArray:Array;
      
      public var AbilityArray:Array;
      
      public function GMWeaponItem(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Release = jsonAsset.Release;
            ClassType = jsonAsset.ClassType;
            MasterType = jsonAsset.Mastertype;
            DoNotDrop = Boolean(jsonAsset.DoNotDrop);
            Power = uint(jsonAsset.Power);
            Speed = Number(jsonAsset.Speed);
            ScalingFactor = Number(jsonAsset.ScalingFactor);
            WeaponController = jsonAsset.WeaponController;
            ControllerTimeTillEnd = Number(jsonAsset.ControllerTimeTillEnd);
            HoldingAttack = jsonAsset.HoldingAttack;
            ChargeAttack = jsonAsset.ChargeAttack != null ? jsonAsset.ChargeAttack : "";
            ScalingMaxPowerMultiplier = jsonAsset.ScalingMaxPowerMultiplier != null ? Number(jsonAsset.ScalingMaxPowerMultiplier) : 1;
            ScaleTapAttack = Boolean(jsonAsset.ScaleTapAttack);
            ScalingMinProjectiles = jsonAsset.ScalingMinProjectileMultiplier != null ? uint(jsonAsset.ScalingMinProjectileMultiplier) : 1;
            ScalingMaxProjectiles = jsonAsset.ScalingMaxProjectileMultiplier != null ? uint(jsonAsset.ScalingMaxProjectileMultiplier) : 1;
            ScalingProjectileStartAngle = jsonAsset.ScalingProjectileStartAngle != null ? Number(jsonAsset.ScalingProjectileStartAngle) : 0;
            ScalingProjectileEndAngle = jsonAsset.ScalingProjectileEndAngle != null ? Number(jsonAsset.ScalingProjectileEndAngle) : 0;
            ScalingDistanceTime = jsonAsset.ScalingDistanceTime != null ? Number(jsonAsset.ScalingDistanceTime) : 0;
            ScalingHeroMinDistance = jsonAsset.ScalingHeroMinDistance != null ? Number(jsonAsset.ScalingHeroMinDistance) : 0;
            ScalingHeroMaxDistance = jsonAsset.ScalingHeroMaxDistance != null ? Number(jsonAsset.ScalingHeroMaxDistance) : 0;
            ScalingProjectileMinDistance = jsonAsset.ScalingProjectileMinDistance != null ? Number(jsonAsset.ScalingProjectileMinDistance) : 0;
            ScalingProjectileMaxDistance = jsonAsset.ScalingProjectileMaxDistance != null ? Number(jsonAsset.ScalingProjectileMaxDistance) : 0;
            RepeaterOnlyChargeRepeated = Boolean(jsonAsset.RepeaterOnlyChargeRepeated);
            RepeaterIncrementSpeedPercent = jsonAsset.RepeaterIncrementSpeedPercent != null ? Number(jsonAsset.RepeaterIncrementSpeedPercent) : 0.5;
            RepeaterMaxSpeedPercent = jsonAsset.RepeaterMaxSpeedPercent != null ? Number(jsonAsset.RepeaterMaxSpeedPercent) : 3;
            TapIcon = jsonAsset.TapIcon;
            TapTitle = As3Compat.truthy(jsonAsset.TapTitle) ? jsonAsset.TapTitle : "";
            TapDescription = As3Compat.truthy(jsonAsset.TapDescription) ? jsonAsset.TapDescription : "";
            HoldIcon = jsonAsset.HoldIcon;
            HoldTitle = As3Compat.truthy(jsonAsset.HoldTitle) ? jsonAsset.HoldTitle : "";
            HoldDescription = As3Compat.truthy(jsonAsset.HoldDescription) ? jsonAsset.HoldDescription : "";
            AbilityArray = [jsonAsset.Ability1,jsonAsset.Ability2,jsonAsset.Ability3,jsonAsset.Ability4,jsonAsset.Ability5];
            AttackArray = [jsonAsset.Attack1,jsonAsset.Attack2,jsonAsset.Attack3,jsonAsset.Attack4,jsonAsset.Attack5,jsonAsset.Attack6,jsonAsset.Attack7,jsonAsset.Attack8,jsonAsset.Attack9,jsonAsset.Attack10];
            ChooseRandomAttack = Boolean(jsonAsset.ChooseRandomAttack);
            WeaponAestheticList = new Vector.<GMWeaponAesthetic>();
            ItemCategory = GMInventoryBase.WEAPON_CATEGORY;
            PotentialModifiers = new Vector.<GMModifier>();
            PotentialLegendaryModifiers = new Vector.<GMLegendaryModifier>();
         }
      }
      
      public function getWeaponAesthetic(level:uint, isLegendary:Boolean = false) : GMWeaponAesthetic
      {
         var _loc6_:int = 0;
         if(WeaponAestheticList == null)
         {
            Logger.error("No weapon aesthetic list on weapon: " + Constant + ", id: " + Std.string(Id));
            return null;
         }
         var _loc3_:uint = level > 100 ? 100 : level;
         var _loc4_:int = 0;
         var _loc5_:int = int(WeaponAestheticList.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            if(isLegendary)
            {
               if(WeaponAestheticList[_loc6_].IsLegendary)
               {
                  return WeaponAestheticList[_loc6_];
               }
            }
            else if(_loc3_ >= WeaponAestheticList[_loc6_].MinLevel && _loc3_ <= WeaponAestheticList[_loc6_].MaxLevel)
            {
               return WeaponAestheticList[_loc6_];
            }
         }
         if(isLegendary)
         {
            return WeaponAestheticList[0];
         }
         Logger.error("Unable to find Weapon Aesthetic for weapon : " + Constant);
         return WeaponAestheticList[0];
      }
   }
}

