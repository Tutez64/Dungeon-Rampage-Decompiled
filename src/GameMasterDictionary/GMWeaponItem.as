package GameMasterDictionary
{
   import Brain.Logger.Logger;
   
   public class GMWeaponItem extends GMInventoryBase
   {
      
      public static const MELEE_WEAPON_SORT:Vector.<String> = new <String>["AXE_TYPE","HAMMER_TYPE","SWORD_TYPE","MEATCLEAVER_TYPE","COOKING_TYPE","FRYING_PAN_TYPE","KATANA_TYPE","SPEAR_TYPE","SHIELD_TYPE","FARMTOOL_TYPE","GREATSWORD_TYPE","FLAIL_TYPE","MACE_TYPE","LIGHT_SPEAR_TYPE","HEAVY_SPEAR_TYPE"];
      
      public static const SHOOTING_WEAPON_SORT:Vector.<String> = new <String>["BOW_TYPE","CROSSBOW_TYPE","PISTOL_TYPE","THROWING_TYPE","HEAVY_THROWING_TYPE","LIGHT_THROWING_TYPE","TRAP_TYPE","SEED_TYPE","THROWING_SPEAR_TYPE"];
      
      public static const MAGIC_WEAPON_SORT:Vector.<String> = new <String>["LIGHTNING_STAFF_TYPE","FIRE_STAFF_TYPE","STAFF_TYPE","LIGHTNING_MAGIC_TYPE","FIRE_MAGIC_TYPE","DARK_MAGIC_TYPE","SCROLL_TYPE","FIRE_RUNE_TYPE","FLAME_STAFF_TYPE","FIRE_GLOVE_TYPE","FIRE_ORB_TYPE","DRAGON_CHARM_TYPE"];
      
      public static const ALL_WEAPON_SORT:Vector.<String> = MELEE_WEAPON_SORT.concat(SHOOTING_WEAPON_SORT).concat(MAGIC_WEAPON_SORT);
      
      public var Release:String;
      
      public var ClassType:String;
      
      public var MasterType:String;
      
      public var DoNotDrop:Boolean;
      
      public var Power:uint;
      
      public var Speed:Number;
      
      public var ScalingFactor:Number;
      
      public var WeaponController:String;
      
      public var ControllerTimeTillEnd:Number;
      
      public var HoldingAttack:String;
      
      public var ChargeAttack:String;
      
      public var ScalingMaxPowerMultiplier:Number;
      
      public var ScaleTapAttack:Boolean;
      
      public var ScalingMinProjectiles:uint;
      
      public var ScalingMaxProjectiles:uint;
      
      public var ScalingProjectileStartAngle:Number;
      
      public var ScalingProjectileEndAngle:Number;
      
      public var ScalingDistanceTime:Number;
      
      public var ScalingHeroMinDistance:Number;
      
      public var ScalingHeroMaxDistance:Number;
      
      public var ScalingProjectileMinDistance:Number;
      
      public var ScalingProjectileMaxDistance:Number;
      
      public var RepeaterOnlyChargeRepeated:Boolean;
      
      public var RepeaterIncrementSpeedPercent:Number;
      
      public var RepeaterMaxSpeedPercent:Number;
      
      public var AbilityArray:Array;
      
      public var AttackArray:Array;
      
      public var PotentialModifiers:Vector.<GMModifier>;
      
      public var PotentialLegendaryModifiers:Vector.<GMLegendaryModifier>;
      
      public var WeaponAestheticList:Vector.<GMWeaponAesthetic>;
      
      public var TapIcon:String;
      
      public var TapTitle:String;
      
      public var TapDescription:String;
      
      public var HoldIcon:String;
      
      public var HoldTitle:String;
      
      public var HoldDescription:String;
      
      public var ChooseRandomAttack:Boolean;
      
      public function GMWeaponItem(jsonAsset:Object)
      {
         super(jsonAsset);
         Release = jsonAsset.Release;
         ClassType = jsonAsset.ClassType;
         MasterType = jsonAsset.Mastertype;
         DoNotDrop = jsonAsset.DoNotDrop;
         Power = jsonAsset.Power;
         Speed = jsonAsset.Speed;
         ScalingFactor = jsonAsset.ScalingFactor;
         WeaponController = jsonAsset.WeaponController;
         ControllerTimeTillEnd = jsonAsset.ControllerTimeTillEnd;
         HoldingAttack = jsonAsset.HoldingAttack;
         ChargeAttack = jsonAsset.ChargeAttack ?? "";
         ScalingMaxPowerMultiplier = jsonAsset.ScalingMaxPowerMultiplier ?? 1;
         ScaleTapAttack = jsonAsset.ScaleTapAttack;
         ScalingMinProjectiles = jsonAsset.ScalingMinProjectileMultiplier ?? 1;
         ScalingMaxProjectiles = jsonAsset.ScalingMaxProjectileMultiplier ?? 1;
         ScalingProjectileStartAngle = jsonAsset.ScalingProjectileStartAngle ?? 0;
         ScalingProjectileEndAngle = jsonAsset.ScalingProjectileEndAngle ?? 0;
         ScalingDistanceTime = jsonAsset.ScalingDistanceTime ?? 0;
         ScalingHeroMinDistance = jsonAsset.ScalingHeroMinDistance ?? 0;
         ScalingHeroMaxDistance = jsonAsset.ScalingHeroMaxDistance ?? 0;
         ScalingProjectileMinDistance = jsonAsset.ScalingProjectileMinDistance ?? 0;
         ScalingProjectileMaxDistance = jsonAsset.ScalingProjectileMaxDistance ?? 0;
         RepeaterOnlyChargeRepeated = jsonAsset.RepeaterOnlyChargeRepeated;
         RepeaterIncrementSpeedPercent = jsonAsset.RepeaterIncrementSpeedPercent ?? 0.5;
         RepeaterMaxSpeedPercent = jsonAsset.RepeaterMaxSpeedPercent ?? 3;
         TapIcon = jsonAsset.TapIcon;
         TapTitle = jsonAsset.TapTitle ? jsonAsset.TapTitle : "";
         TapDescription = jsonAsset.TapDescription ? jsonAsset.TapDescription : "";
         HoldIcon = jsonAsset.HoldIcon;
         HoldTitle = jsonAsset.HoldTitle ? jsonAsset.HoldTitle : "";
         HoldDescription = jsonAsset.HoldDescription ? jsonAsset.HoldDescription : "";
         AbilityArray = new Array(jsonAsset.Ability1,jsonAsset.Ability2,jsonAsset.Ability3,jsonAsset.Ability4,jsonAsset.Ability5);
         AttackArray = new Array(jsonAsset.Attack1,jsonAsset.Attack2,jsonAsset.Attack3,jsonAsset.Attack4,jsonAsset.Attack5,jsonAsset.Attack6,jsonAsset.Attack7,jsonAsset.Attack8,jsonAsset.Attack9,jsonAsset.Attack10);
         ChooseRandomAttack = jsonAsset.ChooseRandomAttack;
         WeaponAestheticList = new Vector.<GMWeaponAesthetic>();
         ItemCategory = "WEAPON";
         PotentialModifiers = new Vector.<GMModifier>();
         PotentialLegendaryModifiers = new Vector.<GMLegendaryModifier>();
      }
      
      public function getWeaponAesthetic(level:uint, isLegendary:Boolean = false) : GMWeaponAesthetic
      {
         var _loc3_:int = 0;
         if(WeaponAestheticList == null)
         {
            Logger.error("No weapon aesthetic list on weapon: " + this.Constant + ", id: " + this.Id);
            return null;
         }
         _loc3_ = 0;
         while(_loc3_ < WeaponAestheticList.length)
         {
            if(isLegendary)
            {
               if(WeaponAestheticList[_loc3_].IsLegendary)
               {
                  return WeaponAestheticList[_loc3_];
               }
            }
            else if(level >= WeaponAestheticList[_loc3_].MinLevel && level <= WeaponAestheticList[_loc3_].MaxLevel)
            {
               return WeaponAestheticList[_loc3_];
            }
            _loc3_++;
         }
         if(isLegendary)
         {
            return WeaponAestheticList[0];
         }
         Logger.error("Unable to find Weapon Aesthetic for weapon : " + this.Constant);
         return WeaponAestheticList[0];
      }
   }
}

