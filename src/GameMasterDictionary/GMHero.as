package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.As3Compat;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   import gamemasterdictionary._GMHero.ExpToLevel;
   
   public class GMHero extends GMActor
   {
      
      public static var BASE_MAX_LEVEL:uint = 100;
      
      public static var LEVELS_PER_ASCENSION:uint = 5;
      
      public static var MAX_LEVEL:uint = 150;
      
      public static var MAX_EFFECTIVE_ASCENSIONS:uint = 10;
      
      public var UpgradeToSlotOffset:Vector.<Vector.<int>>;
      
      public var UISwfFilepath:String;
      
      public var TeamAttack:String;
      
      public var StoreDescription:String;
      
      public var StatUpgrade4:String;
      
      public var StatUpgrade3:String;
      
      public var StatUpgrade2:String;
      
      public var StatUpgrade1:String;
      
      public var SpeedRating:Number;
      
      public var Power4R5:Number;
      
      public var Power4R4:Number;
      
      public var Power4R3:Number;
      
      public var Power4R2:Number;
      
      public var Power4R1:Number;
      
      public var Power4:String;
      
      public var Power3R5:Number;
      
      public var Power3R4:Number;
      
      public var Power3R3:Number;
      
      public var Power3R2:Number;
      
      public var Power3R1:Number;
      
      public var Power3:String;
      
      public var Power2R5:Number;
      
      public var Power2R4:Number;
      
      public var Power2R3:Number;
      
      public var Power2R2:Number;
      
      public var Power2R1:Number;
      
      public var Power2:String;
      
      public var Power1R5:Number;
      
      public var Power1R4:Number;
      
      public var Power1R3:Number;
      
      public var Power1R2:Number;
      
      public var Power1R1:Number;
      
      public var Power1:String;
      
      public var PortraitClassName:String;
      
      public var Pet:String;
      
      public var Normalized_upgrades:StatVector;
      
      public var IsExclusive:Boolean;
      
      public var Hidden:Boolean;
      
      public var ExperienceToLevel:Vector.<ExpToLevel>;
      
      public var DefenseRating:Number;
      
      public var DefaultSkin:String;
      
      public var DBuster1:String;
      
      public var Coins:uint;
      
      public var CharUnlockLocation:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var CharDescription:String;
      
      public var Cash:uint;
      
      public var AttackRating:Number;
      
      public var AmtStat4:Number;
      
      public var AmtStat3:Number;
      
      public var AmtStat2:Number;
      
      public var AmtStat1:Number;
      
      public var AllowedWeapons:GMMap;
      
      public function GMHero(jsonAsset:Object = undefined, splitTests:* = undefined)
      {
         var _loc3_:Boolean = false;
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Normalized_upgrades = new StatVector();
            UpgradeToSlotOffset = new Vector.<Vector.<int>>();
            UpgradeToSlotOffset.push(new Vector.<int>());
            UpgradeToSlotOffset.push(new Vector.<int>());
            UpgradeToSlotOffset.push(new Vector.<int>());
            UpgradeToSlotOffset.push(new Vector.<int>());
            ExperienceToLevel = new Vector.<ExpToLevel>();
            IsExclusive = Boolean(jsonAsset.IsExclusive);
            Hidden = Boolean(jsonAsset.Hidden);
            AmtStat1 = Number(jsonAsset.AmtStat1);
            StatUpgrade1 = jsonAsset.StatUpgrade1;
            AmtStat2 = Number(jsonAsset.AmtStat2);
            StatUpgrade2 = jsonAsset.StatUpgrade2;
            AmtStat3 = Number(jsonAsset.AmtStat3);
            StatUpgrade3 = jsonAsset.StatUpgrade3;
            AmtStat4 = Number(jsonAsset.AmtStat4);
            StatUpgrade4 = jsonAsset.StatUpgrade4;
            Power1R1 = Number(jsonAsset.Power1R1);
            Power1R2 = Number(jsonAsset.Power1R2);
            Power1R3 = Number(jsonAsset.Power1R3);
            Power1R4 = Number(jsonAsset.Power1R4);
            Power1R5 = Number(jsonAsset.Power1R5);
            Power1 = jsonAsset.Power1;
            Power2R1 = Number(jsonAsset.Power2R1);
            Power2R2 = Number(jsonAsset.Power2R2);
            Power2R3 = Number(jsonAsset.Power2R3);
            Power2R4 = Number(jsonAsset.Power2R4);
            Power2R5 = Number(jsonAsset.Power2R5);
            Power2 = jsonAsset.Power2;
            Power3R1 = Number(jsonAsset.Power3R1);
            Power3R2 = Number(jsonAsset.Power3R2);
            Power3R3 = Number(jsonAsset.Power3R3);
            Power3R4 = Number(jsonAsset.Power3R4);
            Power3R5 = Number(jsonAsset.Power3R5);
            Power3 = jsonAsset.Power3;
            Power4R1 = Number(jsonAsset.Power4R1);
            Power4R2 = Number(jsonAsset.Power4R2);
            Power4R3 = Number(jsonAsset.Power4R3);
            Power4R4 = Number(jsonAsset.Power4R4);
            Power4R5 = Number(jsonAsset.Power4R5);
            Power4 = jsonAsset.Power4;
            DBuster1 = jsonAsset.DBuster1;
            TeamAttack = jsonAsset.TeamAttack;
            Pet = jsonAsset.Pet;
            DefaultSkin = jsonAsset.DefaultSkin;
            CharNickname = jsonAsset.CharNickname;
            CharLikes = jsonAsset.CharLikes;
            CharDislikes = jsonAsset.CharDislikes;
            CharUnlockLocation = jsonAsset.CharUnlockLocation;
            CharDescription = jsonAsset.Description;
            StoreDescription = jsonAsset.StoreDescription;
            Coins = uint(jsonAsset.Coins);
            Cash = uint(jsonAsset.Cash);
            AttackRating = Number(jsonAsset.AttackRating);
            DefenseRating = Number(jsonAsset.DefenseRating);
            SpeedRating = Number(jsonAsset.SpeedRating);
            Ability = 0;
            if(jsonAsset.Ability1 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability1);
            }
            if(jsonAsset.Ability2 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability2);
            }
            if(jsonAsset.Ability3 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability3);
            }
            AllowedWeapons = new GMMap();
            if(jsonAsset.SWORD_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.SWORD_TYPE);
               AllowedWeapons.add("SWORD_TYPE",_loc3_);
            }
            if(jsonAsset.AXE_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.AXE_TYPE);
               AllowedWeapons.add("AXE_TYPE",_loc3_);
            }
            if(jsonAsset.HAMMER_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.HAMMER_TYPE);
               AllowedWeapons.add("HAMMER_TYPE",_loc3_);
            }
            if(jsonAsset.FLAIL_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FLAIL_TYPE);
               AllowedWeapons.add("FLAIL_TYPE",_loc3_);
            }
            if(jsonAsset.KATANA_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.KATANA_TYPE);
               AllowedWeapons.add("KATANA_TYPE",_loc3_);
            }
            if(jsonAsset.GREATSWORD_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.GREATSWORD_TYPE);
               AllowedWeapons.add("GREATSWORD_TYPE",_loc3_);
            }
            if(jsonAsset.SPEAR_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.SPEAR_TYPE);
               AllowedWeapons.add("SPEAR_TYPE",_loc3_);
            }
            if(jsonAsset.SHIELD_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.SHIELD_TYPE);
               AllowedWeapons.add("SHIELD_TYPE",_loc3_);
            }
            if(jsonAsset.FARMTOOL_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FARMTOOL_TYPE);
               AllowedWeapons.add("FARMTOOL_TYPE",_loc3_);
            }
            if(jsonAsset.MEATCLEAVER_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.MEATCLEAVER_TYPE);
               AllowedWeapons.add("MEATCLEAVER_TYPE",_loc3_);
            }
            if(jsonAsset.FRYING_PAN_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FRYING_PAN_TYPE);
               AllowedWeapons.add("FRYING_PAN_TYPE",_loc3_);
            }
            if(jsonAsset.COOKING_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.COOKING_TYPE);
               AllowedWeapons.add("COOKING_TYPE",_loc3_);
            }
            if(jsonAsset.BOW_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.BOW_TYPE);
               AllowedWeapons.add("BOW_TYPE",_loc3_);
            }
            if(jsonAsset.CROSSBOW_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.CROSSBOW_TYPE);
               AllowedWeapons.add("CROSSBOW_TYPE",_loc3_);
            }
            if(jsonAsset.PISTOL_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.PISTOL_TYPE);
               AllowedWeapons.add("PISTOL_TYPE",_loc3_);
            }
            if(jsonAsset.TRAP_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.TRAP_TYPE);
               AllowedWeapons.add("TRAP_TYPE",_loc3_);
            }
            if(jsonAsset.SEED_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.SEED_TYPE);
               AllowedWeapons.add("SEED_TYPE",_loc3_);
            }
            if(jsonAsset.LIGHTNING_STAFF_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.LIGHTNING_STAFF_TYPE);
               AllowedWeapons.add("LIGHTNING_STAFF_TYPE",_loc3_);
            }
            if(jsonAsset.FIRE_STAFF_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FIRE_STAFF_TYPE);
               AllowedWeapons.add("FIRE_STAFF_TYPE",_loc3_);
            }
            if(jsonAsset.FIRE_MAGIC_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FIRE_MAGIC_TYPE);
               AllowedWeapons.add("FIRE_MAGIC_TYPE",_loc3_);
            }
            if(jsonAsset.LIGHTNING_MAGIC_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.LIGHTNING_MAGIC_TYPE);
               AllowedWeapons.add("LIGHTNING_MAGIC_TYPE",_loc3_);
            }
            if(jsonAsset.THROWING_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.THROWING_TYPE);
               AllowedWeapons.add("THROWING_TYPE",_loc3_);
            }
            if(jsonAsset.SCROLL_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.SCROLL_TYPE);
               AllowedWeapons.add("SCROLL_TYPE",_loc3_);
            }
            if(jsonAsset.FLAME_STAFF_TYPE != null)
            {
               _loc3_ = Boolean(jsonAsset.FLAME_STAFF_TYPE);
               AllowedWeapons.add("FLAME_STAFF_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.LIGHT_THROWING_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.LIGHT_THROWING_TYPE);
               AllowedWeapons.add("LIGHT_THROWING_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.HEAVY_THROWING_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.HEAVY_THROWING_TYPE);
               AllowedWeapons.add("HEAVY_THROWING_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.THROWING_WEAPON_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.THROWING_WEAPON_TYPE);
               AllowedWeapons.add("THROWING_WEAPON_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.VINTAGE_SCROLL_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.VINTAGE_SCROLL_TYPE);
               AllowedWeapons.add("VINTAGE_SCROLL_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.FIRE_ORB_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.FIRE_ORB_TYPE);
               AllowedWeapons.add("FIRE_ORB_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.FIRE_RUNE_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.FIRE_RUNE_TYPE);
               AllowedWeapons.add("FIRE_RUNE_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.FIRE_GLOVE_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.FIRE_GLOVE_TYPE);
               AllowedWeapons.add("FIRE_GLOVE_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.LIGHT_SPEAR_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.LIGHT_SPEAR_TYPE);
               AllowedWeapons.add("LIGHT_SPEAR_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.HEAVY_SPEAR_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.HEAVY_SPEAR_TYPE);
               AllowedWeapons.add("HEAVY_SPEAR_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.THROWING_SPEAR_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.THROWING_SPEAR_TYPE);
               AllowedWeapons.add("THROWING_SPEAR_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.DRAGON_CHARM_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.DRAGON_CHARM_TYPE);
               AllowedWeapons.add("DRAGON_CHARM_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.DRAGON_BOOTS_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.DRAGON_BOOTS_TYPE);
               AllowedWeapons.add("DRAGON_BOOTS_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.GUN_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.GUN_TYPE);
               AllowedWeapons.add("GUN_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.HEAVY_WEAPONS_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.HEAVY_WEAPONS_TYPE);
               AllowedWeapons.add("HEAVY_WEAPONS_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.TURRET_GADGET_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.TURRET_GADGET_TYPE);
               AllowedWeapons.add("TURRET_GADGET_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.LUCHADOR_GLOVE_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.LUCHADOR_GLOVE_TYPE);
               AllowedWeapons.add("LUCHADOR_GLOVE_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.LUCHADOR_BOOT_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.LUCHADOR_BOOT_TYPE);
               AllowedWeapons.add("LUCHADOR_BOOT_TYPE",_loc3_);
            }
            if(As3Compat.truthy(jsonAsset.LUCHADOR_CHAIR_TYPE))
            {
               _loc3_ = Boolean(jsonAsset.LUCHADOR_CHAIR_TYPE);
               AllowedWeapons.add("LUCHADOR_CHAIR_TYPE",_loc3_);
            }
            UISwfFilepath = jsonAsset.UISwfFilepath;
            PortraitClassName = jsonAsset.PortraitClassName;
            IsMover = true;
         }
      }
      
      public static function maxLevelForAscension(ascensionLevel:uint) : uint
      {
         var _loc2_:uint = ascensionLevel < GMHero.MAX_EFFECTIVE_ASCENSIONS ? ascensionLevel : GMHero.MAX_EFFECTIVE_ASCENSIONS;
         return uint(GMHero.BASE_MAX_LEVEL + uint(_loc2_ * GMHero.LEVELS_PER_ASCENSION));
      }
      
      public function getTotalStatFromIndex(index:uint) : uint
      {
         if(int(index) < int(ExperienceToLevel.length))
         {
            return ExperienceToLevel[index].mTotalStatPoints;
         }
         return ExperienceToLevel[int(ExperienceToLevel.length) - 1].mTotalStatPoints;
      }
      
      public function getTotalStatFromExp(val:uint, ascensionLevel:uint) : uint
      {
         var _loc3_:int = getLevelIndex(val,ascensionLevel);
         if(_loc3_ < int(ExperienceToLevel.length))
         {
            return ExperienceToLevel[_loc3_].mTotalStatPoints;
         }
         return ExperienceToLevel[int(ExperienceToLevel.length) - 1].mTotalStatPoints;
      }
      
      public function getLevelIndex(val:Number, ascensionLevel:int) : int
      {
         var _loc8_:int = 0;
         var _loc9_:* = 0;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc3_:int = int(GMHero.maxLevelForAscension(ascensionLevel));
         var _loc4_:int = 0;
         var _loc5_:int = _loc3_;
         var _loc6_:int = int(ExperienceToLevel.length);
         var _loc7_:* = _loc5_ - _loc4_;
         while(0 < _loc7_)
         {
            _loc8_ = _loc7_ / 2;
            _loc9_ = _loc4_ + _loc8_;
            if(_loc9_ >= _loc6_)
            {
               _loc10_ = ExperienceToLevel[_loc6_ - 1].mExperience;
               _loc11_ = _loc10_ - ExperienceToLevel[_loc6_ - 2].mExperience;
               _loc12_ = _loc10_ + uint(_loc11_ * (_loc9_ + 1 - _loc6_));
               if(_loc12_ < val)
               {
                  _loc4_ = ++_loc9_;
                  _loc7_ -= _loc8_ + 1;
               }
               else
               {
                  _loc7_ = _loc8_;
               }
            }
            else if(ExperienceToLevel[_loc9_].mExperience < val)
            {
               _loc4_ = ++_loc9_;
               _loc7_ -= _loc8_ + 1;
            }
            else
            {
               _loc7_ = _loc8_;
            }
         }
         if(_loc4_ >= _loc3_)
         {
            return _loc3_ - 1;
         }
         return _loc4_;
      }
      
      public function getLevelFromIndex(index:uint) : uint
      {
         if(int(index) < int(ExperienceToLevel.length))
         {
            return ExperienceToLevel[index].mLevel;
         }
         return index;
      }
      
      public function getLevelFromExp(val:uint, ascensionLevel:uint) : uint
      {
         var _loc3_:int = getLevelIndex(val,ascensionLevel);
         if(_loc3_ < int(ExperienceToLevel.length))
         {
            return ExperienceToLevel[_loc3_].mLevel;
         }
         return _loc3_ + 1;
      }
      
      public function getExpFromIndex(index:uint) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         if(int(index) < int(ExperienceToLevel.length))
         {
            return uint(ExperienceToLevel[index].mExperience + 1);
         }
         _loc2_ = ExperienceToLevel[int(ExperienceToLevel.length) - 1].mExperience;
         _loc3_ = _loc2_ - ExperienceToLevel[int(ExperienceToLevel.length) - 2].mExperience;
         _loc4_ = _loc2_ + uint(_loc3_ * (uint(uint(index + 1) - int(ExperienceToLevel.length))));
         return uint(_loc4_ + 1);
      }
      
      public function getBaseLevelFromExp(val:uint) : uint
      {
         return getLevelFromExp(val,0);
      }
      
      public function getAllowedWeaponSubTypes() : Vector.<String>
      {
         var _loc3_:* = null as String;
         var _loc1_:Vector.<String> = new Vector.<String>();
         var _loc2_:GMMapIterator = AllowedWeapons.iterator();
         while(As3Compat.truthy(_loc2_.next()))
         {
            _loc3_ = _loc2_.get_key();
            if(As3Compat.truthy(AllowedWeapons.itemFor(_loc3_)))
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function LoadingOnly_addExpRecord(level:uint, exp:uint, statPoints:uint) : void
      {
         ExperienceToLevel.push(new ExpToLevel(level,exp,statPoints));
      }
      
      public function LoadingOnly_addAscensionExpRecord(ascensionLevel:uint, ascensionExp:uint, ascensionStatPoints:uint) : void
      {
         ExperienceToLevel.push(new ExpToLevel(ascensionLevel,ascensionExp,ascensionStatPoints));
      }
      
      public function HeroSlotHelper(statname:String, pos:int, value:Number, gm:GameMaster) : void
      {
         var _loc6_:* = null as Vector.<Number>;
         var _loc7_:* = null as GMSuperStat;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(value == 0)
         {
            return;
         }
         var _loc5_:int = DBGlobal.NameToSlotOffset(statname);
         if(_loc5_ >= 0)
         {
            UpgradeToSlotOffset[pos].push(_loc5_);
            _loc6_ = Normalized_upgrades.values;
            _loc6_[_loc5_] = _loc6_[_loc5_] + value;
         }
         else
         {
            _loc7_ = gm.superStatByConstant.itemFor(statname);
            if(_loc7_ != null)
            {
               _loc8_ = 0;
               _loc9_ = int(StatVector.slotCount);
               while(_loc8_ < _loc9_)
               {
                  _loc10_ = _loc8_++;
                  if(_loc7_.BaseValues.values[_loc10_] != 0)
                  {
                     UpgradeToSlotOffset[pos].push(_loc10_);
                     _loc6_ = Normalized_upgrades.values;
                     _loc6_[_loc10_] = _loc6_[_loc10_] + _loc7_.BaseValues.values[_loc10_];
                  }
               }
            }
            else
            {
               Logger.error("Can not find Definition for Stat: " + statname);
            }
         }
      }
   }
}

