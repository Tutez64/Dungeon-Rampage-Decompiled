package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.DBGlobal;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class GMHero extends GMActor
   {
      
      public var IsExclusive:Boolean;
      
      public var Hidden:Boolean;
      
      public var AmtStat1:Number;
      
      public var StatUpgrade1:String;
      
      public var AmtStat2:Number;
      
      public var StatUpgrade2:String;
      
      public var AmtStat3:Number;
      
      public var StatUpgrade3:String;
      
      public var AmtStat4:Number;
      
      public var StatUpgrade4:String;
      
      public var Power1R1:Number;
      
      public var Power1R2:Number;
      
      public var Power1R3:Number;
      
      public var Power1R4:Number;
      
      public var Power1R5:Number;
      
      public var Power1:String;
      
      public var Power2R1:Number;
      
      public var Power2R2:Number;
      
      public var Power2R3:Number;
      
      public var Power2R4:Number;
      
      public var Power2R5:Number;
      
      public var Power2:String;
      
      public var Power3R1:Number;
      
      public var Power3R2:Number;
      
      public var Power3R3:Number;
      
      public var Power3R4:Number;
      
      public var Power3R5:Number;
      
      public var Power3:String;
      
      public var Power4R1:Number;
      
      public var Power4R2:Number;
      
      public var Power4R3:Number;
      
      public var Power4R4:Number;
      
      public var Power4R5:Number;
      
      public var Power4:String;
      
      public var DBuster1:String;
      
      public var TeamAttack:String;
      
      public var Pet:String;
      
      public var AllowedWeapons:Map;
      
      public var UISwfFilepath:String;
      
      public var FeedPostPicture:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var CharUnlockLocation:String;
      
      public var CharDescription:String;
      
      public var StoreDescription:String;
      
      public var Coins:uint;
      
      public var Cash:uint;
      
      public var SpeedRating:Number;
      
      public var AttackRating:Number;
      
      public var DefenseRating:Number;
      
      public var DefaultSkin:String;
      
      private var ExperienceToLevel:Vector.<ExpToLevel>;
      
      public var UpgradeToSlotOffset:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(4,true);
      
      public var Normalized_upgrades:StatVector;
      
      public function GMHero(jsonAsset:Object, splitTests:Object)
      {
         var _loc3_:Boolean = false;
         super(jsonAsset);
         Normalized_upgrades = new StatVector();
         UpgradeToSlotOffset = new Vector.<Vector.<int>>();
         UpgradeToSlotOffset.push(new Vector.<int>());
         UpgradeToSlotOffset.push(new Vector.<int>());
         UpgradeToSlotOffset.push(new Vector.<int>());
         UpgradeToSlotOffset.push(new Vector.<int>());
         ExperienceToLevel = new Vector.<ExpToLevel>();
         IsExclusive = jsonAsset.IsExclusive;
         Hidden = jsonAsset.Hidden;
         AmtStat1 = jsonAsset.AmtStat1;
         StatUpgrade1 = jsonAsset.StatUpgrade1;
         AmtStat2 = jsonAsset.AmtStat2;
         StatUpgrade2 = jsonAsset.StatUpgrade2;
         AmtStat3 = jsonAsset.AmtStat3;
         StatUpgrade3 = jsonAsset.StatUpgrade3;
         AmtStat4 = jsonAsset.AmtStat4;
         StatUpgrade4 = jsonAsset.StatUpgrade4;
         Power1R1 = jsonAsset.Power1R1;
         Power1R2 = jsonAsset.Power1R2;
         Power1R3 = jsonAsset.Power1R3;
         Power1R4 = jsonAsset.Power1R4;
         Power1R5 = jsonAsset.Power1R5;
         Power1 = jsonAsset.Power1;
         Power2R1 = jsonAsset.Power2R1;
         Power2R2 = jsonAsset.Power2R2;
         Power2R3 = jsonAsset.Power2R3;
         Power2R4 = jsonAsset.Power2R4;
         Power2R5 = jsonAsset.Power2R5;
         Power2 = jsonAsset.Power2;
         Power3R1 = jsonAsset.Power3R1;
         Power3R2 = jsonAsset.Power3R2;
         Power3R3 = jsonAsset.Power3R3;
         Power3R4 = jsonAsset.Power3R4;
         Power3R5 = jsonAsset.Power3R5;
         Power3 = jsonAsset.Power3;
         Power4R1 = jsonAsset.Power4R1;
         Power4R2 = jsonAsset.Power4R2;
         Power4R3 = jsonAsset.Power4R3;
         Power4R4 = jsonAsset.Power4R4;
         Power4R5 = jsonAsset.Power4R5;
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
         Coins = jsonAsset.Coins;
         Cash = jsonAsset.Cash;
         AttackRating = jsonAsset.AttackRating;
         DefenseRating = jsonAsset.DefenseRating;
         SpeedRating = jsonAsset.SpeedRating;
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
         AllowedWeapons = new Map();
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
         if(jsonAsset.LIGHT_THROWING_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.LIGHT_THROWING_TYPE);
            AllowedWeapons.add("LIGHT_THROWING_TYPE",_loc3_);
         }
         if(jsonAsset.HEAVY_THROWING_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.HEAVY_THROWING_TYPE);
            AllowedWeapons.add("HEAVY_THROWING_TYPE",_loc3_);
         }
         if(jsonAsset.THROWING_WEAPON_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.THROWING_WEAPON_TYPE);
            AllowedWeapons.add("THROWING_WEAPON_TYPE",_loc3_);
         }
         if(jsonAsset.VINTAGE_SCROLL_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.VINTAGE_SCROLL_TYPE);
            AllowedWeapons.add("VINTAGE_SCROLL_TYPE",_loc3_);
         }
         if(jsonAsset.FIRE_ORB_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.FIRE_ORB_TYPE);
            AllowedWeapons.add("FIRE_ORB_TYPE",_loc3_);
         }
         if(jsonAsset.FIRE_RUNE_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.FIRE_RUNE_TYPE);
            AllowedWeapons.add("FIRE_RUNE_TYPE",_loc3_);
         }
         if(jsonAsset.FIRE_GLOVE_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.FIRE_GLOVE_TYPE);
            AllowedWeapons.add("FIRE_GLOVE_TYPE",_loc3_);
         }
         if(jsonAsset.LIGHT_SPEAR_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.LIGHT_SPEAR_TYPE);
            AllowedWeapons.add("LIGHT_SPEAR_TYPE",_loc3_);
         }
         if(jsonAsset.HEAVY_SPEAR_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.HEAVY_SPEAR_TYPE);
            AllowedWeapons.add("HEAVY_SPEAR_TYPE",_loc3_);
         }
         if(jsonAsset.THROWING_SPEAR_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.THROWING_SPEAR_TYPE);
            AllowedWeapons.add("THROWING_SPEAR_TYPE",_loc3_);
         }
         if(jsonAsset.DRAGON_CHARM_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.DRAGON_CHARM_TYPE);
            AllowedWeapons.add("DRAGON_CHARM_TYPE",_loc3_);
         }
         if(jsonAsset.DRAGON_BOOTS_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.DRAGON_BOOTS_TYPE);
            AllowedWeapons.add("DRAGON_BOOTS_TYPE",_loc3_);
         }
         if(jsonAsset.GUN_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.GUN_TYPE);
            AllowedWeapons.add("GUN_TYPE",_loc3_);
         }
         if(jsonAsset.HEAVY_WEAPONS_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.HEAVY_WEAPONS_TYPE);
            AllowedWeapons.add("HEAVY_WEAPONS_TYPE",_loc3_);
         }
         if(jsonAsset.TURRET_GADGET_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.TURRET_GADGET_TYPE);
            AllowedWeapons.add("TURRET_GADGET_TYPE",_loc3_);
         }
         if(jsonAsset.LUCHADOR_GLOVE_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.LUCHADOR_GLOVE_TYPE);
            AllowedWeapons.add("LUCHADOR_GLOVE_TYPE",_loc3_);
         }
         if(jsonAsset.LUCHADOR_BOOT_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.LUCHADOR_BOOT_TYPE);
            AllowedWeapons.add("LUCHADOR_BOOT_TYPE",_loc3_);
         }
         if(jsonAsset.LUCHADOR_CHAIR_TYPE)
         {
            _loc3_ = Boolean(jsonAsset.LUCHADOR_CHAIR_TYPE);
            AllowedWeapons.add("LUCHADOR_CHAIR_TYPE",_loc3_);
         }
         UISwfFilepath = jsonAsset.UISwfFilepath;
         FeedPostPicture = jsonAsset.FeedPostPicture;
         IsMover = true;
      }
      
      public function getAllowedWeaponSubTypes() : Vector.<String>
      {
         var _loc3_:String = null;
         var _loc2_:Vector.<String> = new Vector.<String>();
         var _loc1_:IMapIterator = AllowedWeapons.iterator() as IMapIterator;
         while(_loc1_.next())
         {
            _loc3_ = _loc1_.key as String;
            if(AllowedWeapons.itemFor(_loc3_) as Boolean)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function HeroSlotHelper(statname:String, pos:int, value:Number, gm:GameMaster) : void
      {
         var _loc6_:GMSuperStat = null;
         var _loc7_:int = 0;
         if(value == 0)
         {
            return;
         }
         var _loc5_:int = DBGlobal.NameToSlotOffset(statname);
         if(_loc5_ >= 0)
         {
            UpgradeToSlotOffset[pos].push(_loc5_);
            Normalized_upgrades.values[_loc5_] += value;
         }
         else
         {
            _loc6_ = gm.superStatByConstant.itemFor(statname);
            if(_loc6_ != null)
            {
               _loc7_ = 0;
               while(_loc7_ < StatVector.slotCount)
               {
                  if(_loc6_.BaseValues.values[_loc7_] != 0)
                  {
                     UpgradeToSlotOffset[pos].push(_loc7_);
                     Normalized_upgrades.values[_loc7_] += _loc6_.BaseValues.values[_loc7_];
                  }
                  _loc7_++;
               }
            }
            else
            {
               Logger.error("Can not find Definition for Stat: " + statname);
            }
         }
      }
      
      public function LoadingOnly_addExpRecord(level:uint, exp:uint, statPoints:uint) : void
      {
         ExperienceToLevel.push(new ExpToLevel(level,exp,statPoints));
      }
      
      public function getLevelIndex(val:Number) : int
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = int(ExperienceToLevel.length);
         var _loc6_:int = 0;
         var _loc2_:int = _loc4_;
         var _loc7_:int = _loc2_ - _loc6_;
         while(0 < _loc7_)
         {
            _loc3_ = _loc7_ / 2;
            _loc5_ = _loc6_ + _loc3_;
            if(ExperienceToLevel[_loc5_].mExperience < val)
            {
               _loc6_ = ++_loc5_;
               _loc7_ -= _loc3_ + 1;
            }
            else
            {
               _loc7_ = _loc3_;
            }
         }
         if(_loc6_ >= _loc4_)
         {
            return _loc4_ - 1;
         }
         return _loc6_;
      }
      
      public function getLevelFromExp(val:uint) : uint
      {
         return ExperienceToLevel[getLevelIndex(val)].mLevel;
      }
      
      public function getTotalStatFromExp(val:uint) : uint
      {
         return ExperienceToLevel[getLevelIndex(val)].mTotalStatPoints;
      }
      
      public function getLevelFromIndex(index:uint) : uint
      {
         return ExperienceToLevel[index].mLevel;
      }
      
      public function getExpFromIndex(index:uint) : uint
      {
         return ExperienceToLevel[index].mExperience + 1;
      }
      
      public function getTotalStatFromIndex(index:uint) : uint
      {
         return ExperienceToLevel[index].mTotalStatPoints;
      }
   }
}

class ExpToLevel
{
   
   public var mLevel:uint;
   
   public var mExperience:uint;
   
   public var mTotalStatPoints:uint;
   
   public function ExpToLevel(level:uint, experience:uint, totalStatPoints:uint)
   {
      super();
      mLevel = level;
      mExperience = experience;
      mTotalStatPoints = totalStatPoints;
   }
}
