package GameMasterDictionary
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import DBGlobals.As3Compat;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   import haxe.Log;
   
   public class GameMaster
   {
      
      public var weaponSubtypesSortedByID:Array;
      
      public var weaponSubtypeById:GMMap;
      
      public var weaponSubtypeByConstant:GMMap;
      
      public var weaponItemById:GMMap;
      
      public var weaponItemByConstant:GMMap;
      
      public var weaponAestheticByWeaponItemConstant:GMMap;
      
      public var superStatById:GMMap;
      
      public var superStatByConstant:GMMap;
      
      public var stat_bias:StatVector;
      
      public var stat_MaxCap:StatVector;
      
      public var stat_BonusMultiplier:StatVector;
      
      public var statById:GMMap;
      
      public var statByConstant:GMMap;
      
      public var stackableById:GMMap;
      
      public var stackableByConstant:GMMap;
      
      public var skinsById:GMMap;
      
      public var rarityById:GMMap;
      
      public var rarityByConstant:GMMap;
      
      public var propById:GMMap;
      
      public var propByConstant:GMMap;
      
      public var projectileById:GMMap;
      
      public var projectileByConstant:GMMap;
      
      public var offerByStackableId:GMMap;
      
      public var offerById:GMMap;
      
      public var npcById:GMMap;
      
      public var npcByConstant:GMMap;
      
      public var modifiersById:GMMap;
      
      public var modifiersByConstant:GMMap;
      
      public var maxAscensionCount:uint;
      
      public var mapNodeById:GMMap;
      
      public var mapNodeByConstant:GMMap;
      
      public var mapNodeByBitIndex:GMMap;
      
      public var mSkinsByConstant:GMMap;
      
      public var mSecurityValue:int;
      
      public var mGameMasterJson:Object;
      
      public var mDefaultSkins:GMMap;
      
      public var legendaryModifiersById:GMMap;
      
      public var legendaryModifiersByConstant:GMMap;
      
      public var keysByOfferId:GMMap;
      
      public var itemDropById:GMMap;
      
      public var itemDropByConstant:GMMap;
      
      public var infiniteDungeonsById:GMMap;
      
      public var infiniteDungeonsByConstant:GMMap;
      
      public var hintsByConstant:GMMap;
      
      public var heroById:GMMap;
      
      public var heroByConstant:GMMap;
      
      public var dungeonModifierById:GMMap;
      
      public var dungeonModifierByConstant:GMMap;
      
      public var dooberDropById:GMMap;
      
      public var dooberDropByConstant:GMMap;
      
      public var dooberById:GMMap;
      
      public var dooberByConstant:GMMap;
      
      public var dooberByChestId:GMMap;
      
      public var coliseumTierById:GMMap;
      
      public var coliseumTierByConstant:GMMap;
      
      public var chestsById:GMMap;
      
      public var buffColorTypeById:GMMap;
      
      public var buffById:GMMap;
      
      public var buffByConstant:GMMap;
      
      public var auraById:GMMap;
      
      public var auraByConstant:GMMap;
      
      public var attackById:GMMap;
      
      public var attackByConstant:GMMap;
      
      public var WeaponMastertypes:Vector.<GMWeaponMastertype>;
      
      public var WeaponItems:Vector.<GMWeaponItem>;
      
      public var WeaponAesthetics:Vector.<GMWeaponAesthetic>;
      
      public var SuperStats:Vector.<GMSuperStat>;
      
      public var Stats:Vector.<GMStat>;
      
      public var Stackables:Vector.<GMStackable>;
      
      public var Skins:Vector.<GMSkin>;
      
      public var Rarity:Vector.<GMRarity>;
      
      public var Props:Vector.<GMProp>;
      
      public var Projectiles:Vector.<GMProjectile>;
      
      public var Offers:Vector.<GMOffer>;
      
      public var Npcs:Vector.<GMNpc>;
      
      public var Modifiers:Vector.<GMModifier>;
      
      public var MapNodes:Vector.<GMMapNode>;
      
      public var LegendaryModifiers:Vector.<GMLegendaryModifier>;
      
      public var Keys:Vector.<GMKey>;
      
      public var ItemDrops:Vector.<GMItemDrop>;
      
      public var Hints:Vector.<GMHints>;
      
      public var Heroes:Vector.<GMHero>;
      
      public var DungeonModifiers:Vector.<GMDungeonModifier>;
      
      public var Doobers:Vector.<GMDoober>;
      
      public var DooberDrops:Vector.<GMDooberDrop>;
      
      public var ColiseumTiers:Vector.<GMColiseumTier>;
      
      public var Chests:Vector.<GMChest>;
      
      public var Buffs:Vector.<GMBuff>;
      
      public var Auras:Vector.<GMAura>;
      
      public var Attacks:Vector.<GMAttack>;
      
      public function GameMaster(gameMasterJson:Object = undefined, splitTests:* = undefined)
      {
         var _loc4_:* = null as Error;
         if(Boot.skip_constructor)
         {
            return;
         }
         LegendaryModifiers = new Vector.<GMLegendaryModifier>();
         Modifiers = new Vector.<GMModifier>();
         Rarity = new Vector.<GMRarity>();
         Keys = new Vector.<GMKey>();
         Chests = new Vector.<GMChest>();
         Skins = new Vector.<GMSkin>();
         ColiseumTiers = new Vector.<GMColiseumTier>();
         Hints = new Vector.<GMHints>();
         Stackables = new Vector.<GMStackable>();
         Offers = new Vector.<GMOffer>();
         Props = new Vector.<GMProp>();
         SuperStats = new Vector.<GMSuperStat>();
         Stats = new Vector.<GMStat>();
         DungeonModifiers = new Vector.<GMDungeonModifier>();
         MapNodes = new Vector.<GMMapNode>();
         DooberDrops = new Vector.<GMDooberDrop>();
         Doobers = new Vector.<GMDoober>();
         ItemDrops = new Vector.<GMItemDrop>();
         WeaponMastertypes = new Vector.<GMWeaponMastertype>();
         WeaponAesthetics = new Vector.<GMWeaponAesthetic>();
         WeaponItems = new Vector.<GMWeaponItem>();
         Auras = new Vector.<GMAura>();
         Buffs = new Vector.<GMBuff>();
         Projectiles = new Vector.<GMProjectile>();
         Attacks = new Vector.<GMAttack>();
         Npcs = new Vector.<GMNpc>();
         Heroes = new Vector.<GMHero>();
         mGameMasterJson = gameMasterJson;
         try
         {
            buildDictionary(splitTests);
         }
         catch(_loc_e_:Error)
         {
            _loc4_ = _loc_e_;
            Logger.fatal("Failed to process DB_GameMaster_C.json\n" + Std.string(_loc4_.message),_loc4_);
         }
         PostProcess(splitTests);
      }
      
      public static function getSplitTestString(key:String, defaultValue:String, tests:*) : String
      {
         var _loc6_:* = null;
         var _loc4_:int = 0;
         var _loc5_:Array = As3Compat.values(tests);
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_];
            _loc4_++;
            if(_loc6_.name == key)
            {
               return _loc6_.value;
            }
         }
         return defaultValue;
      }
      
      public function storeHasSaleNow() : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:* = null as GMOffer;
         var _loc1_:int = 0;
         var _loc2_:int = int(Offers.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            _loc4_ = Offers[_loc3_].get_isOnSaleNow();
            if(_loc4_ != null && _loc4_.get_isSale())
            {
               return true;
            }
         }
         return false;
      }
      
      public function storeHasNewOffers() : Boolean
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = int(Offers.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            if(Offers[_loc3_].get_isNew())
            {
               return true;
            }
         }
         return false;
      }
      
      public function shouldIncludeOffer(gmOffer:GMOffer, splitTests:*) : Boolean
      {
         var _loc3_:Number = 0;
         if(gmOffer.VisibleDate != null)
         {
            _loc3_ = gmOffer.VisibleDate.getTime();
         }
         else if(gmOffer.StartDate != null)
         {
            _loc3_ = gmOffer.StartDate.getTime();
         }
         var _loc4_:Number = 0;
         if(gmOffer.SoldOutDate != null)
         {
            _loc4_ = gmOffer.SoldOutDate.getTime();
         }
         else if(gmOffer.EndDate != null)
         {
            _loc4_ = gmOffer.EndDate.getTime();
         }
         var _loc5_:Number = GameClock.getWebServerTime();
         if(_loc5_ == 0)
         {
            _loc5_ = GameClock.date.getTime();
         }
         if(_loc3_ > 0)
         {
            if(_loc3_ > _loc5_)
            {
               return false;
            }
            if(_loc4_ > 0 && _loc4_ < _loc5_)
            {
               return false;
            }
         }
         else if(_loc4_ > 0 && _loc4_ < _loc5_)
         {
            return false;
         }
         return true;
      }
      
      public function isSkinTypeADefaultSkin(skinType:uint) : Boolean
      {
         return mDefaultSkins.hasKey(skinType);
      }
      
      public function init() : void
      {
      }
      
      public function get_securityChecksum() : int
      {
         return mSecurityValue;
      }
      
      public function get securityChecksum() : int
      {
         return get_securityChecksum();
      }
      
      public function getStackableByConstant(skinConstant:String) : GMSkin
      {
         var _loc2_:GMSkin = mSkinsByConstant.itemFor(skinConstant);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinConstant: " + skinConstant);
         }
         return _loc2_;
      }
      
      public function getSkinByType(skinType:uint) : GMSkin
      {
         var _loc2_:GMSkin = skinsById.itemFor(skinType);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinType: " + ("" + skinType));
         }
         return _loc2_;
      }
      
      public function getSkinByConstant(skinConstant:String) : GMSkin
      {
         var _loc2_:GMSkin = mSkinsByConstant.itemFor(skinConstant);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinConstant: " + skinConstant);
         }
         return _loc2_;
      }
      
      public function getMapNode(idx:uint) : GMMapNode
      {
         return mapNodeById.itemFor(idx);
      }
      
      public function getHeroByConstant(heroConstant:String) : GMHero
      {
         var _loc2_:GMHero = heroByConstant.itemFor(heroConstant);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMHero for constant: " + heroConstant);
         }
         return _loc2_;
      }
      
      public function getActorMap(type:uint) : GMMap
      {
         if(heroById.hasKey(type))
         {
            return heroById;
         }
         if(npcById.hasKey(type))
         {
            return npcById;
         }
         Logger.warn("ID: " + ("" + type) + " not found in hero or npc GMMap. Returning null");
         return null;
      }
      
      public function fixupMapNodeParents() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:* = null as GMMapNode;
         var _loc1_:int = 0;
         var _loc2_:int = int(MapNodes.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            _loc4_ = 0;
            _loc5_ = int(MapNodes[_loc3_].ChildNodes.length);
            while(_loc4_ < _loc5_)
            {
               _loc6_ = _loc4_++;
               _loc7_ = mapNodeByConstant.itemFor(MapNodes[_loc3_].ChildNodes[_loc6_]);
               if(_loc7_ != null)
               {
                  _loc7_.ParentNodes.push(MapNodes[_loc3_]);
                  MapNodes[_loc3_].ChildNodes[_loc6_] = _loc7_;
               }
            }
         }
      }
      
      public function destroy() : void
      {
      }
      
      public function buildDictionary(splitTests:*) : void
      {
         var _gthis:GameMaster;
         var _loc6_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc27_:* = null as GMBuffColorType;
         var _loc30_:* = null as GMModifier;
         var _loc32_:* = null as GMLegendaryModifier;
         var _loc34_:* = null as GMWeaponItem;
         var _loc35_:* = null as GMModifier;
         var _loc41_:* = null as GMInfiniteDungeon;
         var _loc45_:* = null as GMOffer;
         var _loc47_:* = null as GMOfferDetail;
         var _loc49_:* = null as GMChest;
         var _loc51_:* = null as GMKey;
         var _loc53_:* = null as GMRarity;
         var _loc55_:* = null as GMWeaponAesthetic;
         var _loc56_:* = null as Vector.<GMWeaponAesthetic>;
         var _loc57_:* = null as Vector.<GMWeaponAesthetic>;
         var _loc60_:* = null as GMOffer;
         var _loc61_:* = null as GMOffer;
         var _loc63_:* = null as GMStackable;
         var _loc65_:* = null as GMHints;
         var _loc67_:* = null as GMColiseumTier;
         var _loc69_:* = null as GMSkin;
         var _loc70_:* = null as GMSkin;
         _gthis = this;
         mSecurityValue = 0;
         var _loc2_:* = 0;
         statById = new GMMap();
         statByConstant = new GMMap();
         var _loc3_:Array = mGameMasterJson.Stats;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Stats[_loc6_] = new GMStat(_loc3_[_loc6_]);
            statById.add(Stats[_loc6_].Id,Stats[_loc6_]);
            statByConstant.add(Stats[_loc6_].Constant,Stats[_loc6_]);
         }
         superStatById = new GMMap();
         superStatByConstant = new GMMap();
         var _loc7_:Array = mGameMasterJson.SuperStats;
         _loc4_ = 0;
         _loc5_ = int(_loc7_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            SuperStats[_loc6_] = new GMSuperStat(_loc7_[_loc6_]);
            superStatById.add(SuperStats[_loc6_].Id,SuperStats[_loc6_]);
            superStatByConstant.add(SuperStats[_loc6_].Constant,SuperStats[_loc6_]);
         }
         heroById = new GMMap();
         heroByConstant = new GMMap();
         var _loc8_:Array = mGameMasterJson.Hero;
         var _loc9_:Array = mGameMasterJson.Leveling;
         var _loc10_:Array = mGameMasterJson.AscensionLeveling;
         maxAscensionCount = int(_loc10_.length) > 0 ? GMHero.MAX_EFFECTIVE_ASCENSIONS : 0;
         _loc4_ = 0;
         _loc5_ = int(_loc8_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Heroes[_loc6_] = new GMHero(_loc8_[_loc6_],splitTests);
            _loc11_ = 0;
            _loc12_ = 0;
            _loc13_ = 0;
            _loc14_ = int(_loc9_.length);
            while(_loc13_ < _loc14_)
            {
               _loc15_ = _loc13_++;
               _loc16_ = _loc9_[_loc15_].Level;
               _loc17_ = _loc9_[_loc15_].XpForLevel;
               _loc18_ = _loc9_[_loc15_].StatPoints;
               if(_loc17_ != 0)
               {
                  _loc11_ += _loc17_;
                  _loc12_ += _loc18_;
                  Heroes[_loc6_].LoadingOnly_addExpRecord(int(_loc16_),int(_loc11_ - 1),int(_loc12_));
               }
            }
            _loc13_ = 0;
            _loc14_ = int(_loc10_.length);
            while(_loc13_ < _loc14_)
            {
               _loc15_ = _loc13_++;
               _loc19_ = _loc10_[_loc15_].Level;
               _loc20_ = _loc10_[_loc15_].XpForLevel;
               _loc21_ = 2;
               if(_loc20_ != 0)
               {
                  _loc11_ = _loc20_ + _loc11_;
                  _loc12_ = _loc21_ + _loc12_;
                  Heroes[_loc6_].LoadingOnly_addAscensionExpRecord(_loc19_,int(_loc11_ - 1),int(_loc12_));
               }
            }
            heroById.add(Heroes[_loc6_].Id,Heroes[_loc6_]);
            heroByConstant.add(Heroes[_loc6_].Constant,Heroes[_loc6_]);
            Heroes[_loc6_].HeroSlotHelper(Heroes[_loc6_].StatUpgrade1,0,Heroes[_loc6_].AmtStat1,this);
            Heroes[_loc6_].HeroSlotHelper(Heroes[_loc6_].StatUpgrade2,1,Heroes[_loc6_].AmtStat2,this);
            Heroes[_loc6_].HeroSlotHelper(Heroes[_loc6_].StatUpgrade3,2,Heroes[_loc6_].AmtStat3,this);
            Heroes[_loc6_].HeroSlotHelper(Heroes[_loc6_].StatUpgrade4,3,Heroes[_loc6_].AmtStat4,this);
            _loc2_ += Heroes[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         npcById = new GMMap();
         npcByConstant = new GMMap();
         var _loc22_:Array = mGameMasterJson.Npc;
         _loc4_ = 0;
         _loc5_ = int(_loc22_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Npcs[_loc6_] = new GMNpc(_loc22_[_loc6_]);
            npcById.add(Npcs[_loc6_].Id,Npcs[_loc6_]);
            npcByConstant.add(Npcs[_loc6_].Constant,Npcs[_loc6_]);
            _loc2_ += Npcs[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         attackById = new GMMap();
         attackByConstant = new GMMap();
         var _loc23_:Array = mGameMasterJson.Attack;
         _loc4_ = 0;
         _loc5_ = int(_loc23_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Attacks[_loc6_] = new GMAttack(_loc23_[_loc6_]);
            attackById.add(Attacks[_loc6_].Id,Attacks[_loc6_]);
            attackByConstant.add(Attacks[_loc6_].Constant,Attacks[_loc6_]);
            _loc2_ += Attacks[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         projectileById = new GMMap();
         projectileByConstant = new GMMap();
         var _loc24_:Array = mGameMasterJson.Projectile;
         _loc4_ = 0;
         _loc5_ = int(_loc24_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Projectiles[_loc6_] = new GMProjectile(_loc24_[_loc6_]);
            projectileById.add(Projectiles[_loc6_].Id,Projectiles[_loc6_]);
            projectileByConstant.add(Projectiles[_loc6_].Constant,Projectiles[_loc6_]);
            _loc2_ += Projectiles[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         buffById = new GMMap();
         buffByConstant = new GMMap();
         var _loc25_:Array = mGameMasterJson.Buff;
         _loc4_ = 0;
         _loc5_ = int(_loc25_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Buffs[_loc6_] = new GMBuff(_loc25_[_loc6_]);
            buffById.add(Buffs[_loc6_].Id,Buffs[_loc6_]);
            buffByConstant.add(Buffs[_loc6_].Constant,Buffs[_loc6_]);
            _loc2_ += Buffs[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         buffColorTypeById = new GMMap();
         var _loc26_:Array = mGameMasterJson.BuffColorType;
         _loc4_ = 0;
         _loc5_ = int(_loc26_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc27_ = new GMBuffColorType(_loc26_[_loc6_]);
            buffColorTypeById.add(_loc27_.Id,_loc27_);
         }
         auraById = new GMMap();
         auraByConstant = new GMMap();
         var _loc28_:Array = mGameMasterJson.Auras;
         _loc4_ = 0;
         _loc5_ = int(_loc28_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Auras[_loc6_] = new GMAura(_loc28_[_loc6_]);
            auraById.add(Auras[_loc6_].Id,Auras[_loc6_]);
            auraByConstant.add(Auras[_loc6_].Constant,Auras[_loc6_]);
         }
         modifiersById = new GMMap();
         modifiersByConstant = new GMMap();
         var _loc29_:Array = mGameMasterJson.Modifiers;
         _loc4_ = 0;
         _loc5_ = int(_loc29_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc30_ = new GMModifier(_loc29_[_loc6_]);
            Modifiers[_loc6_] = _loc30_;
            modifiersById.add(_loc30_.Id,_loc30_);
            modifiersByConstant.add(_loc30_.Constant,_loc30_);
         }
         legendaryModifiersById = new GMMap();
         legendaryModifiersByConstant = new GMMap();
         var _loc31_:Array = mGameMasterJson.LegendaryModifiers;
         _loc4_ = 0;
         _loc5_ = int(_loc31_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc32_ = new GMLegendaryModifier(_loc31_[_loc6_]);
            LegendaryModifiers[_loc6_] = _loc32_;
            legendaryModifiersById.add(_loc32_.Id,_loc32_);
            legendaryModifiersByConstant.add(_loc32_.Constant,_loc32_);
         }
         weaponItemById = new GMMap();
         weaponItemByConstant = new GMMap();
         var _loc33_:Array = mGameMasterJson.WeaponItem;
         _loc4_ = 0;
         _loc5_ = int(_loc33_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc34_ = new GMWeaponItem(_loc33_[_loc6_]);
            WeaponItems[_loc6_] = _loc34_;
            weaponItemById.add(_loc34_.Id,_loc34_);
            weaponItemByConstant.add(_loc34_.Constant,_loc34_);
            _loc13_ = 0;
            _loc14_ = int(Modifiers.length);
            while(_loc13_ < _loc14_)
            {
               _loc15_ = _loc13_++;
               _loc35_ = Modifiers[_loc15_];
               if(As3Compat.truthy(Reflect.field(_loc33_[_loc6_],_loc35_.MODIFIER_TYPE)))
               {
                  _loc34_.PotentialModifiers.push(_loc35_);
               }
            }
            _loc13_ = 0;
            _loc14_ = int(LegendaryModifiers.length);
            while(_loc13_ < _loc14_)
            {
               _loc15_ = _loc13_++;
               _loc34_.PotentialLegendaryModifiers.push(LegendaryModifiers[_loc15_]);
            }
         }
         weaponSubtypeById = new GMMap();
         weaponSubtypeByConstant = new GMMap();
         weaponSubtypesSortedByID = [];
         var _loc36_:Array = mGameMasterJson.WeaponMastertype;
         _loc4_ = 0;
         _loc5_ = int(_loc36_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            WeaponMastertypes[_loc6_] = new GMWeaponMastertype(_loc36_[_loc6_]);
            weaponSubtypeById.add(WeaponMastertypes[_loc6_].Id,WeaponMastertypes[_loc6_]);
            weaponSubtypeByConstant.add(WeaponMastertypes[_loc6_].Constant,WeaponMastertypes[_loc6_]);
            weaponSubtypesSortedByID.push(WeaponMastertypes[_loc6_].Id);
         }
         weaponSubtypesSortedByID.sort(function(a:*, b:*):int
         {
            var _loc3_:String = Std.string(a);
            var _loc4_:String = Std.string(b);
            if(_loc3_ < _loc4_)
            {
               return -1;
            }
            if(_loc3_ > _loc4_)
            {
               return 1;
            }
            return 0;
         });
         dooberById = new GMMap();
         dooberByConstant = new GMMap();
         dooberByChestId = new GMMap();
         var _loc37_:Array = mGameMasterJson.Doobers;
         _loc4_ = 0;
         _loc5_ = int(_loc37_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Doobers[_loc6_] = new GMDoober(_loc37_[_loc6_]);
            dooberById.add(Doobers[_loc6_].Id,Doobers[_loc6_]);
            dooberByConstant.add(Doobers[_loc6_].Constant,Doobers[_loc6_]);
            if(Doobers[_loc6_].ChestId > 0)
            {
               dooberByChestId.add(Doobers[_loc6_].ChestId,Doobers[_loc6_]);
            }
         }
         dooberDropById = new GMMap();
         dooberDropByConstant = new GMMap();
         var _loc38_:Array = mGameMasterJson.DooberDrop;
         _loc4_ = 0;
         _loc5_ = int(_loc38_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            DooberDrops[_loc6_] = new GMDooberDrop(_loc38_[_loc6_]);
            dooberDropById.add(DooberDrops[_loc6_].Id,DooberDrops[_loc6_]);
            dooberDropByConstant.add(DooberDrops[_loc6_].Constant,DooberDrops[_loc6_]);
         }
         mapNodeById = new GMMap();
         mapNodeByConstant = new GMMap();
         mapNodeByBitIndex = new GMMap();
         var _loc39_:Array = mGameMasterJson.MapPage;
         _loc4_ = 0;
         _loc5_ = int(_loc39_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            MapNodes[_loc6_] = new GMMapNode(_loc39_[_loc6_]);
            mapNodeById.add(MapNodes[_loc6_].Id,MapNodes[_loc6_]);
            mapNodeByConstant.add(MapNodes[_loc6_].Constant,MapNodes[_loc6_]);
            mapNodeByBitIndex.add(MapNodes[_loc6_].BitIndex,MapNodes[_loc6_]);
         }
         addChildrenToParentNodes();
         fixupMapNodeParents();
         infiniteDungeonsById = new GMMap();
         infiniteDungeonsByConstant = new GMMap();
         var _loc40_:Array = mGameMasterJson.InfiniteDungeons;
         _loc4_ = 0;
         _loc5_ = int(_loc40_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc41_ = new GMInfiniteDungeon(_loc40_[_loc6_]);
            infiniteDungeonsById.add(_loc41_.Id,_loc41_);
            infiniteDungeonsByConstant.add(_loc41_.Constant,_loc41_);
         }
         dungeonModifierById = new GMMap();
         dungeonModifierByConstant = new GMMap();
         var _loc42_:Array = mGameMasterJson.DungeonModifier;
         _loc4_ = 0;
         _loc5_ = int(_loc42_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            DungeonModifiers[_loc6_] = new GMDungeonModifier(_loc42_[_loc6_]);
            dungeonModifierById.add(DungeonModifiers[_loc6_].Id,DungeonModifiers[_loc6_]);
            dungeonModifierByConstant.add(DungeonModifiers[_loc6_].Constant,DungeonModifiers[_loc6_]);
         }
         propById = new GMMap();
         propByConstant = new GMMap();
         var _loc43_:Array = mGameMasterJson.Prop;
         _loc4_ = 0;
         _loc5_ = int(_loc43_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            Props[_loc6_] = new GMProp(_loc43_[_loc6_]);
            propById.add(Props[_loc6_].Id,Props[_loc6_]);
            propByConstant.add(Props[_loc6_].Constant,Props[_loc6_]);
         }
         offerById = new GMMap();
         var _loc44_:Array = mGameMasterJson.Offers;
         _loc4_ = 0;
         _loc5_ = int(_loc44_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc45_ = new GMOffer(_loc44_[_loc6_],splitTests);
            if(shouldIncludeOffer(_loc45_,splitTests))
            {
               Offers.push(_loc45_);
               offerById.add(_loc45_.Id,_loc45_);
            }
         }
         offerByStackableId = new GMMap();
         var _loc46_:Array = mGameMasterJson.OfferDetails;
         _loc4_ = 0;
         _loc5_ = int(_loc46_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc47_ = new GMOfferDetail(_loc46_[_loc6_]);
            _loc45_ = offerById.itemFor(_loc47_.OfferId);
            if(_loc45_ != null)
            {
               _loc45_.Details.push(_loc47_);
            }
            if(_loc47_.StackableId > 0)
            {
               offerByStackableId.add(_loc47_.StackableId,_loc45_);
            }
         }
         chestsById = new GMMap();
         var _loc48_:Array = mGameMasterJson.Chests;
         _loc4_ = 0;
         _loc5_ = int(_loc48_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc49_ = new GMChest(_loc48_[_loc6_]);
            Chests[_loc6_] = _loc49_;
            chestsById.add(_loc49_.Id,_loc49_);
         }
         keysByOfferId = new GMMap();
         var _loc50_:Array = mGameMasterJson.Keys;
         _loc4_ = 0;
         _loc5_ = int(_loc50_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc51_ = new GMKey(_loc50_[_loc6_]);
            Keys[_loc6_] = _loc51_;
            keysByOfferId.add(_loc51_.OfferId,_loc51_);
         }
         rarityById = new GMMap();
         rarityByConstant = new GMMap();
         var _loc52_:Array = mGameMasterJson.Rarity;
         _loc4_ = 0;
         _loc5_ = int(_loc52_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc53_ = new GMRarity(_loc52_[_loc6_]);
            Rarity[_loc6_] = _loc53_;
            rarityById.add(_loc53_.Id,_loc53_);
            rarityByConstant.add(_loc53_.Type,_loc53_);
         }
         weaponAestheticByWeaponItemConstant = new GMMap();
         var _loc54_:Array = mGameMasterJson.WeaponAesthetics;
         _loc4_ = 0;
         _loc5_ = int(_loc54_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc55_ = new GMWeaponAesthetic(_loc54_[_loc6_]);
            _loc56_ = weaponAestheticByWeaponItemConstant.itemFor(_loc55_.WeaponItemConstant);
            if(_loc56_ == null)
            {
               _loc57_ = new Vector.<GMWeaponAesthetic>();
               _loc57_.push(_loc55_);
               weaponAestheticByWeaponItemConstant.add(_loc55_.WeaponItemConstant,_loc57_);
            }
            else
            {
               _loc56_.push(_loc55_);
            }
         }
         var _loc58_:Boolean = true;
         var _loc59_:Boolean = true;
         _loc4_ = 0;
         _loc5_ = int(Offers.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc60_ = Offers[_loc6_];
            if(_loc60_.SaleTargetOfferId != 0)
            {
               _loc61_ = offerById.itemFor(_loc60_.SaleTargetOfferId);
               if(_loc61_ == null)
               {
                  Logger.error("Invalid sale from offer: " + ("" + _loc60_.Id) + " sale offer: " + ("" + _loc60_.SaleTargetOfferId));
                  continue;
               }
               _loc60_.SaleTargetOffer = _loc61_;
               if(_loc61_.SaleOffers == null)
               {
                  _loc61_.SaleOffers = new Vector.<GMOffer>();
               }
               _loc61_.SaleOffers.push(_loc60_);
            }
            if(_loc60_.CurrencyType == GMOffer.PREMIUM_CURRENCY && _loc60_.CoinOfferId != 0)
            {
               _loc61_ = offerById.itemFor(_loc60_.CoinOfferId);
               if(_loc61_ == null)
               {
                  Logger.error("Invalid coin offer: " + ("" + _loc60_.Id) + " CoinOfferId: " + ("" + _loc60_.CoinOfferId));
               }
               if(_loc61_.CurrencyType != GMOffer.BASIC_CURRENCY)
               {
                  Logger.error("CoinOfferId must be BASIC_CURRENCY: " + ("" + _loc60_.CoinOfferId));
               }
               _loc61_.IsCoinAltOffer = true;
               if(_loc58_ || _loc60_.Tab == "KEY")
               {
                  _loc60_.CoinOffer = _loc61_;
               }
            }
         }
         stackableById = new GMMap();
         stackableByConstant = new GMMap();
         var _loc62_:Array = mGameMasterJson.Stackables;
         _loc4_ = 0;
         _loc5_ = int(_loc62_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc63_ = new GMStackable(_loc62_[_loc6_]);
            Stackables[_loc6_] = _loc63_;
            stackableById.add(_loc63_.Id,_loc63_);
            stackableByConstant.add(_loc63_.Constant,_loc63_);
            _loc2_ += Stackables[_loc6_].get_SecurityValue();
         }
         _loc2_ %= 1097;
         mSecurityValue += _loc2_;
         _loc2_ = 0;
         _loc4_ = 0;
         _loc5_ = int(Offers.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc45_ = Offers[_loc6_];
            if(_loc45_.Details == null)
            {
               Logger.error("Offer: " + ("" + _loc45_.Id) + " has no offer item details.");
            }
            if(!_loc45_.IsBundle && int(_loc45_.Details.length) > 1)
            {
               Logger.error("Offer: " + ("" + _loc45_.Id) + " is not a bundle but has multiple item details.");
            }
         }
         hintsByConstant = new GMMap();
         var _loc64_:Array = mGameMasterJson.Hints;
         _loc4_ = 0;
         _loc5_ = int(_loc64_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc65_ = new GMHints(_loc64_[_loc6_]);
            Hints[_loc6_] = _loc65_;
            hintsByConstant.add(_loc65_.Constant,_loc65_);
         }
         coliseumTierById = new GMMap();
         coliseumTierByConstant = new GMMap();
         var _loc66_:Array = mGameMasterJson.ColiseumTiers;
         _loc4_ = 0;
         _loc5_ = int(_loc66_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc67_ = new GMColiseumTier(_loc66_[_loc6_]);
            ColiseumTiers[_loc6_] = _loc67_;
            coliseumTierById.add(_loc67_.Id,_loc67_);
            coliseumTierByConstant.add(_loc67_.Constant,_loc67_);
         }
         skinsById = new GMMap();
         mSkinsByConstant = new GMMap();
         var _loc68_:Array = mGameMasterJson.Skins;
         _loc4_ = 0;
         _loc5_ = int(_loc68_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc69_ = new GMSkin(_loc68_[_loc6_]);
            Skins[_loc6_] = _loc69_;
            skinsById.add(_loc69_.Id,_loc69_);
            mSkinsByConstant.add(_loc69_.Constant,_loc69_);
         }
         Skins.sort(function(skinA:GMSkin, skinB:GMSkin):int
         {
            var _loc7_:int = 0;
            var _loc8_:* = null as GMOffer;
            var _loc3_:GMOffer = null;
            var _loc4_:GMOffer = null;
            var _loc5_:int = 0;
            var _loc6_:int = int(_gthis.Offers.length);
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc5_++;
               _loc8_ = _gthis.Offers[_loc7_];
               if(_loc8_.Tab == "SKIN" && _loc8_.Location == "STORE" && !_loc8_.IsBundle && _loc8_.SaleTargetOffer == null && !_loc8_.IsCoinAltOffer)
               {
                  if(_loc8_.Details[0].SkinId == skinA.Id)
                  {
                     _loc3_ = _loc8_;
                  }
                  else if(_loc8_.Details[0].SkinId == skinB.Id)
                  {
                     _loc4_ = _loc8_;
                  }
                  if(_loc3_ != null && _loc4_ != null)
                  {
                     break;
                  }
               }
            }
            if(_loc3_ != null && _loc4_ != null)
            {
               return int(_loc4_.get_Price() - _loc3_.get_Price());
            }
            if(_loc3_ != null)
            {
               return 1;
            }
            if(_loc4_ != null)
            {
               return -1;
            }
            return 0;
         });
         mDefaultSkins = new GMMap();
         _loc4_ = 0;
         _loc5_ = int(_loc8_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc70_ = mSkinsByConstant.itemFor(Heroes[_loc6_].DefaultSkin);
            mDefaultSkins.add(_loc70_.Id,_loc70_);
         }
         var _loc71_:Array = mGameMasterJson.PlayerScale;
         _loc4_ = 0;
         _loc5_ = int(_loc71_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            new GMPlayerScale(_loc71_[_loc6_]);
         }
      }
      
      public function addChildrenToParentNodes() : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null as GMMapNode;
         var _loc5_:* = null as String;
         var _loc6_:* = null as GMMapNode;
         var _loc1_:int = 0;
         var _loc2_:int = int(MapNodes.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            _loc4_ = MapNodes[_loc3_];
            _loc5_ = _loc4_.PrefixupParentNode;
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc6_ = mapNodeByConstant.itemFor(_loc4_.PrefixupParentNode);
               _loc6_.ChildNodes.push(_loc4_.Constant);
            }
         }
      }
      
      public function PostProcessWeaponItem() : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null as GMWeaponItem;
         var _loc1_:int = 0;
         var _loc2_:int = int(WeaponItems.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            _loc4_ = WeaponItems[_loc3_];
            _loc4_.WeaponAestheticList = weaponAestheticByWeaponItemConstant.itemFor(_loc4_.Constant);
            if(_loc4_.WeaponAestheticList == null)
            {
               Logger.error(_loc4_.Constant + " doesn\'t have an aesthetic");
            }
         }
      }
      
      public function PostProcess(slpittests:*) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null as GMStat;
         PostProcessWeaponItem();
         stat_bias = new StatVector();
         stat_BonusMultiplier = new StatVector();
         stat_MaxCap = new StatVector();
         var _loc2_:int = 0;
         var _loc3_:int = int(DBGlobal.StatNames.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = statByConstant.itemFor(DBGlobal.StatNames[_loc4_]);
            if(_loc5_ == null)
            {
               Log.trace("Error Finding State By name " + DBGlobal.StatNames[_loc4_],{
                  "fileName":"../DungeonBusters/Client/GameMasterProjectHaxe/src/gamemasterdictionary/GameMaster.hx",
                  "lineNumber":253,
                  "className":"gamemasterdictionary.GameMaster",
                  "methodName":"PostProcess"
               });
            }
            else
            {
               stat_BonusMultiplier.values[_loc4_] = _loc5_.Bonus;
               stat_MaxCap.values[_loc4_] = _loc5_.MaxCap;
            }
         }
         stat_bias.values[DBGlobal.MELEE_SPD] = 1;
         stat_bias.values[DBGlobal.SHOOT_SPD] = 1;
         stat_bias.values[DBGlobal.MAGIC_SPD] = 1;
         stat_bias.values[DBGlobal.MOVEMENT] = 1;
      }
   }
}

