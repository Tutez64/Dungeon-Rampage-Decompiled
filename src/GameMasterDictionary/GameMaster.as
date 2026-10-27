package GameMasterDictionary
{
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import DBGlobals.DBGlobal;
   import org.as3commons.collections.Map;
   
   public class GameMaster
   {
      
      public var Heroes:Vector.<GMHero> = new Vector.<GMHero>();
      
      public var Npcs:Vector.<GMNpc> = new Vector.<GMNpc>();
      
      public var Attacks:Vector.<GMAttack> = new Vector.<GMAttack>();
      
      public var Projectiles:Vector.<GMProjectile> = new Vector.<GMProjectile>();
      
      public var Buffs:Vector.<GMBuff> = new Vector.<GMBuff>();
      
      public var Auras:Vector.<GMAura> = new Vector.<GMAura>();
      
      public var WeaponItems:Vector.<GMWeaponItem> = new Vector.<GMWeaponItem>();
      
      public var WeaponAesthetics:Vector.<GMWeaponAesthetic> = new Vector.<GMWeaponAesthetic>();
      
      public var WeaponMastertypes:Vector.<GMWeaponMastertype> = new Vector.<GMWeaponMastertype>();
      
      public var ItemDrops:Vector.<GMItemDrop> = new Vector.<GMItemDrop>();
      
      public var Doobers:Vector.<GMDoober> = new Vector.<GMDoober>();
      
      public var DooberDrops:Vector.<GMDooberDrop> = new Vector.<GMDooberDrop>();
      
      public var MapNodes:Vector.<GMMapNode> = new Vector.<GMMapNode>();
      
      public var DungeonModifiers:Vector.<GMDungeonModifier> = new Vector.<GMDungeonModifier>();
      
      public var Stats:Vector.<GMStat> = new Vector.<GMStat>();
      
      public var SuperStats:Vector.<GMSuperStat> = new Vector.<GMSuperStat>();
      
      public var Props:Vector.<GMProp> = new Vector.<GMProp>();
      
      public var Offers:Vector.<GMOffer> = new Vector.<GMOffer>();
      
      public var Stackables:Vector.<GMStackable> = new Vector.<GMStackable>();
      
      public var CashDeals:Vector.<GMCashDeal> = new Vector.<GMCashDeal>();
      
      public var FeedPosts:Vector.<GMFeedPosts> = new Vector.<GMFeedPosts>();
      
      public var Achievements:Vector.<GMAchievement> = new Vector.<GMAchievement>();
      
      public var Hints:Vector.<GMHints> = new Vector.<GMHints>();
      
      public var ColiseumTiers:Vector.<GMColiseumTier> = new Vector.<GMColiseumTier>();
      
      public var Skins:Vector.<GMSkin> = new Vector.<GMSkin>();
      
      public var Chests:Vector.<GMChest> = new Vector.<GMChest>();
      
      public var Keys:Vector.<GMKey> = new Vector.<GMKey>();
      
      public var Rarity:Vector.<GMRarity> = new Vector.<GMRarity>();
      
      public var Modifiers:Vector.<GMModifier> = new Vector.<GMModifier>();
      
      public var LegendaryModifiers:Vector.<GMLegendaryModifier> = new Vector.<GMLegendaryModifier>();
      
      public var heroById:Map;
      
      public var npcById:Map;
      
      public var attackById:Map;
      
      public var projectileById:Map;
      
      public var buffById:Map;
      
      public var buffColorTypeById:Map;
      
      public var auraById:Map;
      
      public var weaponItemById:Map;
      
      public var weaponSubtypeById:Map;
      
      public var itemDropById:Map;
      
      public var dooberById:Map;
      
      public var dooberDropById:Map;
      
      public var dooberByChestId:Map;
      
      public var mapNodeById:Map;
      
      public var mapNodeByBitIndex:Map;
      
      public var infiniteDungeonsById:Map;
      
      public var dungeonModifierById:Map;
      
      public var statById:Map;
      
      public var superStatById:Map;
      
      public var propById:Map;
      
      public var offerById:Map;
      
      public var offerByStackableId:Map;
      
      public var stackableById:Map;
      
      public var cashDealById:Map;
      
      public var feedPostsById:Map;
      
      public var coliseumTierById:Map;
      
      public var achievementsById:Map;
      
      public var skinsById:Map;
      
      public var chestsById:Map;
      
      public var keysByOfferId:Map;
      
      public var rarityById:Map;
      
      public var modifiersById:Map;
      
      public var legendaryModifiersById:Map;
      
      public var heroByConstant:Map;
      
      public var npcByConstant:Map;
      
      public var attackByConstant:Map;
      
      public var projectileByConstant:Map;
      
      public var weaponAestheticByWeaponItemConstant:Map;
      
      public var buffByConstant:Map;
      
      public var auraByConstant:Map;
      
      public var weaponItemByConstant:Map;
      
      public var weaponSubtypeByConstant:Map;
      
      public var itemDropByConstant:Map;
      
      public var dooberByConstant:Map;
      
      public var dooberDropByConstant:Map;
      
      public var mapNodeByConstant:Map;
      
      public var infiniteDungeonsByConstant:Map;
      
      public var dungeonModifierByConstant:Map;
      
      public var statByConstant:Map;
      
      public var superStatByConstant:Map;
      
      public var propByConstant:Map;
      
      public var stackableByConstant:Map;
      
      public var feedPostsByConstant:Map;
      
      public var hintsByConstant:Map;
      
      public var coliseumTierByConstant:Map;
      
      private var mSkinsByConstant:Map;
      
      private var mDefaultSkins:Map;
      
      public var rarityByConstant:Map;
      
      public var modifiersByConstant:Map;
      
      public var legendaryModifiersByConstant:Map;
      
      private var mSecurityValue:int;
      
      public var weaponSubtypesSortedByID:Array;
      
      public var stat_BonusMultiplier:StatVector;
      
      public var stat_bias:StatVector;
      
      public var stat_MaxCap:StatVector;
      
      protected var mGameMasterJson:Object;
      
      public var triggerToTriggerable:Map;
      
      public var TriggerableIdToTriggerableEvent:Map;
      
      public function GameMaster(gameMasterJson:Object, splitTests:Object)
      {
         super();
         mGameMasterJson = gameMasterJson;
         try
         {
            buildDictionary(splitTests);
         }
         catch(e:Error)
         {
            Logger.fatal("Failed to process DB_GameMaster.json\n" + e.message,e);
         }
         PostProcess(splitTests);
      }
      
      public static function getSplitTestString(key:String, defaultValue:String, tests:Object) : String
      {
         for each(var _loc4_:Object in tests)
         {
            if(_loc4_.name == key)
            {
               return _loc4_.value;
            }
         }
         return defaultValue;
      }
      
      public function init() : void
      {
      }
      
      public function destroy() : void
      {
      }
      
      public function get securityChecksum() : int
      {
         return mSecurityValue;
      }
      
      public function getActorMap(type:uint) : Map
      {
         if(heroById.hasKey(type))
         {
            return heroById;
         }
         if(npcById.hasKey(type))
         {
            return npcById;
         }
         Logger.warn("ID: " + type.toString() + " not found in hero or npc map. Returning null");
         return null;
      }
      
      public function PostProcessWeaponItem() : void
      {
         var _loc2_:int = 0;
         var _loc1_:GMWeaponItem = null;
         _loc2_ = 0;
         while(_loc2_ < WeaponItems.length)
         {
            _loc1_ = WeaponItems[_loc2_];
            _loc1_.WeaponAestheticList = weaponAestheticByWeaponItemConstant.itemFor(_loc1_.Constant);
            if(_loc1_.WeaponAestheticList == null)
            {
               Logger.error(_loc1_.Constant + " doesn\'t have an aesthetic");
            }
            _loc2_++;
         }
      }
      
      public function PostProcess(slpittests:Object) : void
      {
         var _loc3_:* = 0;
         var _loc2_:GMStat = null;
         PostProcessWeaponItem();
         stat_bias = new StatVector();
         stat_BonusMultiplier = new StatVector();
         stat_MaxCap = new StatVector();
         _loc3_ = 0;
         while(_loc3_ < DBGlobal.StatNames.length)
         {
            _loc2_ = statByConstant.itemFor(DBGlobal.StatNames[_loc3_]);
            if(_loc2_ != null)
            {
               stat_BonusMultiplier.values[_loc3_] = _loc2_.Bonus;
               stat_MaxCap.values[_loc3_] = _loc2_.MaxCap;
            }
            _loc3_++;
         }
         stat_bias.values[8] = 1;
         stat_bias.values[9] = 1;
         stat_bias.values[10] = 1;
         stat_bias.values[13] = 1;
      }
      
      public function buildDictionary(splitTests:Object) : void
      {
         var superStatArray:Array;
         var heroArray:Array;
         var levelingArray:Array;
         var TotalExperience:Number;
         var TotalStats:Number;
         var lidx:Number;
         var levelId:Number;
         var levelValue:Number;
         var statValue:Number;
         var npcArray:Array;
         var attackArray:Array;
         var projectileArray:Array;
         var buffArray:Array;
         var buffColorTypeArray:Array;
         var gmBuffColorType:GMBuffColorType;
         var auraArray:Array;
         var ModifiersArray:Array;
         var modifier:GMModifier;
         var LegendaryModifiersArray:Array;
         var legendaryModifier:GMLegendaryModifier;
         var weaponItemArray:Array;
         var gmWeapon:GMWeaponItem;
         var gmMod:GMModifier;
         var gmLegendaryMod:GMLegendaryModifier;
         var weaponMastertypeArray:Array;
         var dooberArray:Array;
         var dooberDropArray:Array;
         var mapNodeArray:Array;
         var infiniteDungeonArray:Array;
         var gmInfiniteDungeon:GMInfiniteDungeon;
         var dungeonModifierArray:Array;
         var PropArray:Array;
         var OfferArray:Array;
         var offer:GMOffer;
         var OfferDetailArray:Array;
         var detail:GMOfferDetail;
         var ChestsArray:Array;
         var chest:GMChest;
         var KeysArray:Array;
         var key:GMKey;
         var RarityArray:Array;
         var rarity:GMRarity;
         var WeaponAestheticArray:Array;
         var weaponAesthetic:GMWeaponAesthetic;
         var weaponAestheticVector:Vector.<GMWeaponAesthetic>;
         var tempAestheticVector:Vector.<GMWeaponAesthetic>;
         var splitTest:Object;
         var wantCoinAltOffers:Boolean;
         var wantCashRanger:Boolean;
         var gmOffer:GMOffer;
         var fullPriceOffer:GMOffer;
         var coinOffer:GMOffer;
         var stackableArray:Array;
         var stackable:GMStackable;
         var cashDealArray:Array;
         var cashDeal:GMCashDeal;
         var sortOrder:String;
         var feedPostsArray:Array;
         var feedPost:GMFeedPosts;
         var achievementsArray:Array;
         var achievement:GMAchievement;
         var hintsArray:Array;
         var hint:GMHints;
         var coliseumTiersArray:Array;
         var tier:GMColiseumTier;
         var skinsArray:Array;
         var skin:GMSkin;
         var defaultGmSkin:GMSkin;
         var playerScales:Array;
         mSecurityValue = 0;
         var securityCatergoryCounter:int = 0;
         statById = new Map();
         statByConstant = new Map();
         var statArray:Array = mGameMasterJson.Stats;
         var idx:Number = 0;
         while(idx < statArray.length)
         {
            Stats[idx] = new GMStat(statArray[idx]);
            statById.add(Stats[idx].Id,Stats[idx]);
            statByConstant.add(Stats[idx].Constant,Stats[idx]);
            idx = idx + 1;
         }
         superStatById = new Map();
         superStatByConstant = new Map();
         superStatArray = mGameMasterJson.SuperStats;
         idx = 0;
         while(idx < superStatArray.length)
         {
            SuperStats[idx] = new GMSuperStat(superStatArray[idx]);
            superStatById.add(SuperStats[idx].Id,SuperStats[idx]);
            superStatByConstant.add(SuperStats[idx].Constant,SuperStats[idx]);
            idx = idx + 1;
         }
         heroById = new Map();
         heroByConstant = new Map();
         heroArray = mGameMasterJson.Hero;
         levelingArray = mGameMasterJson.Leveling;
         idx = 0;
         while(idx < heroArray.length)
         {
            Heroes[idx] = new GMHero(heroArray[idx],splitTests);
            TotalExperience = 0;
            TotalStats = 0;
            lidx = 0;
            while(lidx < levelingArray.length)
            {
               levelId = Number(levelingArray[lidx].Level);
               levelValue = Number(levelingArray[lidx][Heroes[idx].Constant]);
               statValue = Number(levelingArray[lidx].StatPoints);
               if(levelValue != 0)
               {
                  TotalExperience += levelValue;
                  TotalStats += statValue;
                  Heroes[idx].LoadingOnly_addExpRecord(levelId,TotalExperience - 1,TotalStats);
               }
               lidx = lidx + 1;
            }
            heroById.add(Heroes[idx].Id,Heroes[idx]);
            heroByConstant.add(Heroes[idx].Constant,Heroes[idx]);
            Heroes[idx].HeroSlotHelper(Heroes[idx].StatUpgrade1,0,Heroes[idx].AmtStat1,this);
            Heroes[idx].HeroSlotHelper(Heroes[idx].StatUpgrade2,1,Heroes[idx].AmtStat2,this);
            Heroes[idx].HeroSlotHelper(Heroes[idx].StatUpgrade3,2,Heroes[idx].AmtStat3,this);
            Heroes[idx].HeroSlotHelper(Heroes[idx].StatUpgrade4,3,Heroes[idx].AmtStat4,this);
            securityCatergoryCounter += Heroes[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         npcById = new Map();
         npcByConstant = new Map();
         npcArray = mGameMasterJson.Npc;
         idx = 0;
         while(idx < npcArray.length)
         {
            Npcs[idx] = new GMNpc(npcArray[idx]);
            npcById.add(Npcs[idx].Id,Npcs[idx]);
            npcByConstant.add(Npcs[idx].Constant,Npcs[idx]);
            securityCatergoryCounter += Npcs[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         attackById = new Map();
         attackByConstant = new Map();
         attackArray = mGameMasterJson.Attack;
         idx = 0;
         while(idx < attackArray.length)
         {
            Attacks[idx] = new GMAttack(attackArray[idx]);
            attackById.add(Attacks[idx].Id,Attacks[idx]);
            attackByConstant.add(Attacks[idx].Constant,Attacks[idx]);
            securityCatergoryCounter += Attacks[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         projectileById = new Map();
         projectileByConstant = new Map();
         projectileArray = mGameMasterJson.Projectile;
         idx = 0;
         while(idx < projectileArray.length)
         {
            Projectiles[idx] = new GMProjectile(projectileArray[idx]);
            projectileById.add(Projectiles[idx].Id,Projectiles[idx]);
            projectileByConstant.add(Projectiles[idx].Constant,Projectiles[idx]);
            securityCatergoryCounter += Projectiles[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         buffById = new Map();
         buffByConstant = new Map();
         buffArray = mGameMasterJson.Buff;
         idx = 0;
         while(idx < buffArray.length)
         {
            Buffs[idx] = new GMBuff(buffArray[idx]);
            buffById.add(Buffs[idx].Id,Buffs[idx]);
            buffByConstant.add(Buffs[idx].Constant,Buffs[idx]);
            securityCatergoryCounter += Buffs[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         buffColorTypeById = new Map();
         buffColorTypeArray = mGameMasterJson.BuffColorType;
         idx = 0;
         while(idx < buffColorTypeArray.length)
         {
            gmBuffColorType = new GMBuffColorType(buffColorTypeArray[idx]);
            buffColorTypeById.add(gmBuffColorType.Id,gmBuffColorType);
            idx = idx + 1;
         }
         auraById = new Map();
         auraByConstant = new Map();
         auraArray = mGameMasterJson.Auras;
         idx = 0;
         while(idx < auraArray.length)
         {
            Auras[idx] = new GMAura(auraArray[idx]);
            auraById.add(Auras[idx].Id,Auras[idx]);
            auraByConstant.add(Auras[idx].Constant,Auras[idx]);
            idx = idx + 1;
         }
         modifiersById = new Map();
         modifiersByConstant = new Map();
         ModifiersArray = mGameMasterJson.Modifiers;
         idx = 0;
         while(idx < ModifiersArray.length)
         {
            modifier = new GMModifier(ModifiersArray[idx]);
            Modifiers[idx] = modifier;
            modifiersById.add(modifier.Id,modifier);
            modifiersByConstant.add(modifier.Constant,modifier);
            idx = idx + 1;
         }
         legendaryModifiersById = new Map();
         legendaryModifiersByConstant = new Map();
         LegendaryModifiersArray = mGameMasterJson.LegendaryModifiers;
         idx = 0;
         while(idx < LegendaryModifiersArray.length)
         {
            legendaryModifier = new GMLegendaryModifier(LegendaryModifiersArray[idx]);
            LegendaryModifiers[idx] = legendaryModifier;
            legendaryModifiersById.add(legendaryModifier.Id,legendaryModifier);
            legendaryModifiersByConstant.add(legendaryModifier.Constant,legendaryModifier);
            idx = idx + 1;
         }
         weaponItemById = new Map();
         weaponItemByConstant = new Map();
         weaponItemArray = mGameMasterJson.WeaponItem;
         idx = 0;
         while(idx < weaponItemArray.length)
         {
            gmWeapon = new GMWeaponItem(weaponItemArray[idx]);
            WeaponItems[idx] = gmWeapon;
            weaponItemById.add(gmWeapon.Id,gmWeapon);
            weaponItemByConstant.add(gmWeapon.Constant,gmWeapon);
            for each(gmMod in Modifiers)
            {
               if(weaponItemArray[idx][gmMod.MODIFIER_TYPE])
               {
                  gmWeapon.PotentialModifiers.push(gmMod);
               }
            }
            for each(gmLegendaryMod in LegendaryModifiers)
            {
               gmWeapon.PotentialLegendaryModifiers.push(gmLegendaryMod);
            }
            idx = idx + 1;
         }
         weaponSubtypeById = new Map();
         weaponSubtypeByConstant = new Map();
         weaponSubtypesSortedByID = [];
         weaponMastertypeArray = mGameMasterJson.WeaponMastertype;
         idx = 0;
         while(idx < weaponMastertypeArray.length)
         {
            WeaponMastertypes[idx] = new GMWeaponMastertype(weaponMastertypeArray[idx]);
            weaponSubtypeById.add(WeaponMastertypes[idx].Id,WeaponMastertypes[idx]);
            weaponSubtypeByConstant.add(WeaponMastertypes[idx].Constant,WeaponMastertypes[idx]);
            weaponSubtypesSortedByID.push(WeaponMastertypes[idx].Id);
            idx = idx + 1;
         }
         weaponSubtypesSortedByID.sort();
         dooberById = new Map();
         dooberByConstant = new Map();
         dooberByChestId = new Map();
         dooberArray = mGameMasterJson.Doobers;
         idx = 0;
         while(idx < dooberArray.length)
         {
            Doobers[idx] = new GMDoober(dooberArray[idx]);
            dooberById.add(Doobers[idx].Id,Doobers[idx]);
            dooberByConstant.add(Doobers[idx].Constant,Doobers[idx]);
            if(Doobers[idx].ChestId > 0)
            {
               dooberByChestId.add(Doobers[idx].ChestId,Doobers[idx]);
            }
            idx = idx + 1;
         }
         dooberDropById = new Map();
         dooberDropByConstant = new Map();
         dooberDropArray = mGameMasterJson.DooberDrop;
         idx = 0;
         while(idx < dooberDropArray.length)
         {
            DooberDrops[idx] = new GMDooberDrop(dooberDropArray[idx]);
            dooberDropById.add(DooberDrops[idx].Id,DooberDrops[idx]);
            dooberDropByConstant.add(DooberDrops[idx].Constant,DooberDrops[idx]);
            idx = idx + 1;
         }
         mapNodeById = new Map();
         mapNodeByConstant = new Map();
         mapNodeByBitIndex = new Map();
         mapNodeArray = mGameMasterJson.MapPage;
         idx = 0;
         while(idx < mapNodeArray.length)
         {
            MapNodes[idx] = new GMMapNode(mapNodeArray[idx]);
            mapNodeById.add(MapNodes[idx].Id,MapNodes[idx]);
            mapNodeByConstant.add(MapNodes[idx].Constant,MapNodes[idx]);
            mapNodeByBitIndex.add(MapNodes[idx].BitIndex,MapNodes[idx]);
            idx = idx + 1;
         }
         addChildrenToParentNodes();
         fixupMapNodeParents();
         infiniteDungeonsById = new Map();
         infiniteDungeonsByConstant = new Map();
         infiniteDungeonArray = mGameMasterJson.InfiniteDungeons;
         idx = 0;
         while(idx < infiniteDungeonArray.length)
         {
            gmInfiniteDungeon = new GMInfiniteDungeon(infiniteDungeonArray[idx]);
            infiniteDungeonsById.add(gmInfiniteDungeon.Id,gmInfiniteDungeon);
            infiniteDungeonsByConstant.add(gmInfiniteDungeon.Constant,gmInfiniteDungeon);
            idx = idx + 1;
         }
         dungeonModifierById = new Map();
         dungeonModifierByConstant = new Map();
         dungeonModifierArray = mGameMasterJson.DungeonModifier;
         idx = 0;
         while(idx < dungeonModifierArray.length)
         {
            DungeonModifiers[idx] = new GMDungeonModifier(dungeonModifierArray[idx]);
            dungeonModifierById.add(DungeonModifiers[idx].Id,DungeonModifiers[idx]);
            dungeonModifierByConstant.add(DungeonModifiers[idx].Constant,DungeonModifiers[idx]);
            idx = idx + 1;
         }
         propById = new Map();
         propByConstant = new Map();
         PropArray = mGameMasterJson.Prop;
         idx = 0;
         while(idx < PropArray.length)
         {
            Props[idx] = new GMProp(PropArray[idx]);
            propById.add(Props[idx].Id,Props[idx]);
            propByConstant.add(Props[idx].Constant,Props[idx]);
            idx = idx + 1;
         }
         offerById = new Map();
         OfferArray = mGameMasterJson.Offers;
         idx = 0;
         while(idx < OfferArray.length)
         {
            offer = new GMOffer(OfferArray[idx],splitTests);
            if(this.shouldIncludeOffer(offer,splitTests))
            {
               Offers.push(offer);
               offerById.add(offer.Id,offer);
            }
            idx = idx + 1;
         }
         offerByStackableId = new Map();
         OfferDetailArray = mGameMasterJson.OfferDetails;
         idx = 0;
         while(idx < OfferDetailArray.length)
         {
            detail = new GMOfferDetail(OfferDetailArray[idx]);
            offer = offerById.itemFor(detail.OfferId);
            if(offer)
            {
               offer.Details.push(detail);
            }
            if(detail.StackableId > 0)
            {
               offerByStackableId.add(detail.StackableId,offer);
            }
            idx = idx + 1;
         }
         chestsById = new Map();
         ChestsArray = mGameMasterJson.Chests;
         idx = 0;
         while(idx < ChestsArray.length)
         {
            chest = new GMChest(ChestsArray[idx]);
            Chests[idx] = chest;
            chestsById.add(chest.Id,chest);
            idx = idx + 1;
         }
         keysByOfferId = new Map();
         KeysArray = mGameMasterJson.Keys;
         idx = 0;
         while(idx < KeysArray.length)
         {
            key = new GMKey(KeysArray[idx]);
            Keys[idx] = key;
            keysByOfferId.add(key.OfferId,key);
            idx = idx + 1;
         }
         rarityById = new Map();
         rarityByConstant = new Map();
         RarityArray = mGameMasterJson.Rarity;
         idx = 0;
         while(idx < RarityArray.length)
         {
            rarity = new GMRarity(RarityArray[idx]);
            Rarity[idx] = rarity;
            rarityById.add(rarity.Id,rarity);
            rarityByConstant.add(rarity.Type,rarity);
            idx = idx + 1;
         }
         weaponAestheticByWeaponItemConstant = new Map();
         WeaponAestheticArray = mGameMasterJson.WeaponAesthetics;
         idx = 0;
         while(idx < WeaponAestheticArray.length)
         {
            weaponAesthetic = new GMWeaponAesthetic(WeaponAestheticArray[idx]);
            weaponAestheticVector = weaponAestheticByWeaponItemConstant.itemFor(weaponAesthetic.WeaponItemConstant);
            if(weaponAestheticVector == null)
            {
               tempAestheticVector = new Vector.<GMWeaponAesthetic>();
               tempAestheticVector.push(weaponAesthetic);
               weaponAestheticByWeaponItemConstant.add(weaponAesthetic.WeaponItemConstant,tempAestheticVector);
            }
            else
            {
               weaponAestheticVector.push(weaponAesthetic);
            }
            idx = idx + 1;
         }
         wantCoinAltOffers = true;
         wantCashRanger = true;
         for each(gmOffer in Offers)
         {
            if(gmOffer.SaleTargetOfferId)
            {
               fullPriceOffer = offerById.itemFor(gmOffer.SaleTargetOfferId);
               if(!fullPriceOffer)
               {
                  Logger.error("Invalid sale from offer: " + gmOffer.Id.toString() + " sale offer: " + gmOffer.SaleTargetOfferId.toString());
                  continue;
               }
               gmOffer.SaleTargetOffer = fullPriceOffer;
               if(!fullPriceOffer.SaleOffers)
               {
                  fullPriceOffer.SaleOffers = new Vector.<GMOffer>();
               }
               fullPriceOffer.SaleOffers.push(gmOffer);
            }
            if(gmOffer.CurrencyType == "PREMIUM" && gmOffer.CoinOfferId)
            {
               coinOffer = offerById.itemFor(gmOffer.CoinOfferId);
               if(!coinOffer)
               {
                  Logger.error("Invalid coin offer: " + gmOffer.Id.toString() + " CoinOfferId: " + gmOffer.CoinOfferId);
               }
               if(coinOffer.CurrencyType != "BASIC")
               {
                  Logger.error("CoinOfferId must be BASIC_CURRENCY: " + gmOffer.CoinOfferId);
               }
               coinOffer.IsCoinAltOffer = true;
               if(wantCoinAltOffers || gmOffer.Tab == "KEY")
               {
                  gmOffer.CoinOffer = coinOffer;
               }
            }
         }
         stackableById = new Map();
         stackableByConstant = new Map();
         stackableArray = mGameMasterJson.Stackables;
         idx = 0;
         while(idx < stackableArray.length)
         {
            stackable = new GMStackable(stackableArray[idx]);
            Stackables[idx] = stackable;
            stackableById.add(stackable.Id,stackable);
            stackableByConstant.add(stackable.Constant,stackable);
            securityCatergoryCounter += Stackables[idx].SecurityValue;
            idx = idx + 1;
         }
         securityCatergoryCounter %= 1097;
         mSecurityValue += securityCatergoryCounter;
         securityCatergoryCounter = 0;
         idx = 0;
         while(idx < Offers.length)
         {
            offer = Offers[idx];
            if(offer.Details == null)
            {
               Logger.error("Offer: " + offer.Id + " has no offer item details.");
            }
            if(!offer.IsBundle && offer.Details.length > 1)
            {
               Logger.error("Offer: " + offer.Id + " is not a bundle but has multiple item details.");
            }
            idx = idx + 1;
         }
         cashDealById = new Map();
         cashDealArray = mGameMasterJson.CashDeals;
         idx = 0;
         while(idx < cashDealArray.length)
         {
            cashDeal = new GMCashDeal(cashDealArray[idx],splitTests);
            CashDeals[idx] = cashDeal;
            cashDealById.add(cashDeal.Id,cashDeal);
            idx = idx + 1;
         }
         sortOrder = getSplitTestString("CashDealSort","HighestFirst",splitTests);
         if(sortOrder == "HighestFirst")
         {
            CashDeals.sort(function(param1:GMCashDeal, param2:GMCashDeal):int
            {
               return param2.Price - param1.Price;
            });
         }
         else
         {
            CashDeals.sort(function(param1:GMCashDeal, param2:GMCashDeal):int
            {
               return param1.Price - param2.Price;
            });
         }
         feedPostsById = new Map();
         feedPostsByConstant = new Map();
         feedPostsArray = mGameMasterJson.Feedposts;
         idx = 0;
         while(idx < feedPostsArray.length)
         {
            feedPost = new GMFeedPosts(feedPostsArray[idx]);
            FeedPosts[idx] = feedPost;
            feedPostsById.add(feedPost.Id,feedPost);
            feedPostsByConstant.add(feedPost.Constant,feedPost);
            idx = idx + 1;
         }
         achievementsById = new Map();
         achievementsArray = mGameMasterJson.Achievements;
         idx = 0;
         while(idx < achievementsArray.length)
         {
            achievement = new GMAchievement(achievementsArray[idx]);
            Achievements[idx] = achievement;
            achievementsById.add(achievement.Id,achievement);
            idx = idx + 1;
         }
         hintsByConstant = new Map();
         hintsArray = mGameMasterJson.Hints;
         idx = 0;
         while(idx < hintsArray.length)
         {
            hint = new GMHints(hintsArray[idx]);
            Hints[idx] = hint;
            hintsByConstant.add(hint.Constant,hint);
            idx = idx + 1;
         }
         coliseumTierById = new Map();
         coliseumTierByConstant = new Map();
         coliseumTiersArray = mGameMasterJson.ColiseumTiers;
         idx = 0;
         while(idx < coliseumTiersArray.length)
         {
            tier = new GMColiseumTier(coliseumTiersArray[idx]);
            ColiseumTiers[idx] = tier;
            coliseumTierById.add(tier.Id,tier);
            coliseumTierByConstant.add(tier.Constant,tier);
            idx = idx + 1;
         }
         skinsById = new Map();
         mSkinsByConstant = new Map();
         skinsArray = mGameMasterJson.Skins;
         idx = 0;
         while(idx < skinsArray.length)
         {
            skin = new GMSkin(skinsArray[idx]);
            Skins[idx] = skin;
            skinsById.add(skin.Id,skin);
            mSkinsByConstant.add(skin.Constant,skin);
            idx = idx + 1;
         }
         Skins.sort(function(param1:GMSkin, param2:GMSkin):int
         {
            var _loc5_:int = 0;
            var _loc4_:GMOffer = null;
            var _loc3_:GMOffer = null;
            _loc5_ = 0;
            while(_loc5_ < Offers.length)
            {
               offer = Offers[_loc5_];
               if(offer.Tab == "SKIN" && offer.Location == "STORE" && !offer.IsBundle && !offer.SaleTargetOffer && !offer.IsCoinAltOffer)
               {
                  if(offer.Details[0].SkinId == param1.Id)
                  {
                     _loc4_ = offer;
                  }
                  else if(offer.Details[0].SkinId == param2.Id)
                  {
                     _loc3_ = offer;
                  }
                  if(_loc4_ != null && _loc3_ != null)
                  {
                     break;
                  }
               }
               _loc5_++;
            }
            if(_loc4_ != null && _loc3_ != null)
            {
               return _loc3_.Price - _loc4_.Price;
            }
            if(_loc4_)
            {
               return 1;
            }
            if(_loc3_)
            {
               return -1;
            }
            return 0;
         });
         mDefaultSkins = new Map();
         idx = 0;
         while(idx < heroArray.length)
         {
            defaultGmSkin = mSkinsByConstant.itemFor(Heroes[idx].DefaultSkin);
            mDefaultSkins.add(defaultGmSkin.Id,defaultGmSkin);
            idx = idx + 1;
         }
         playerScales = mGameMasterJson.PlayerScale;
         idx = 0;
         while(idx < playerScales.length)
         {
            new GMPlayerScale(playerScales[idx]);
            idx = idx + 1;
         }
         triggerToTriggerable = new Map();
         TriggerableIdToTriggerableEvent = new Map();
      }
      
      private function shouldIncludeOffer(gmOffer:GMOffer, splitTests:Object) : Boolean
      {
         var _loc3_:Number = 0;
         if(gmOffer.VisibleDate)
         {
            _loc3_ = gmOffer.VisibleDate.getTime();
         }
         else if(gmOffer.StartDate)
         {
            _loc3_ = gmOffer.StartDate.getTime();
         }
         var _loc5_:Number = 0;
         if(gmOffer.SoldOutDate)
         {
            _loc5_ = gmOffer.SoldOutDate.getTime();
         }
         else if(gmOffer.EndDate)
         {
            _loc5_ = gmOffer.EndDate.getTime();
         }
         var _loc4_:Number = GameClock.getWebServerTime();
         if(_loc4_ == 0)
         {
            _loc4_ = GameClock.date.getTime();
         }
         if(_loc3_ > 0)
         {
            if(_loc3_ > _loc4_)
            {
               return false;
            }
            if(_loc5_ > 0 && _loc5_ < _loc4_)
            {
               return false;
            }
         }
         else if(_loc5_ > 0 && _loc5_ < _loc4_)
         {
            return false;
         }
         return true;
      }
      
      public function storeHasSaleNow() : Boolean
      {
         var _loc1_:GMOffer = null;
         for each(var _loc2_:GMOffer in Offers)
         {
            _loc1_ = _loc2_.isOnSaleNow;
            if(_loc1_ && _loc1_.isSale)
            {
               return true;
            }
         }
         return false;
      }
      
      public function storeHasNewOffers() : Boolean
      {
         for each(var _loc1_:GMOffer in Offers)
         {
            if(_loc1_.isNew)
            {
               return true;
            }
         }
         return false;
      }
      
      private function addChildrenToParentNodes() : void
      {
         var _loc2_:GMMapNode = null;
         for each(var _loc1_:GMMapNode in MapNodes)
         {
            if(_loc1_.PrefixupParentNode)
            {
               _loc2_ = mapNodeByConstant.itemFor(_loc1_.PrefixupParentNode);
               _loc2_.ChildNodes.push(_loc1_.Constant);
            }
         }
      }
      
      private function fixupMapNodeParents() : void
      {
         var _loc1_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:GMMapNode = null;
         _loc1_ = 0;
         while(_loc1_ < MapNodes.length)
         {
            _loc2_ = 0;
            while(_loc2_ < MapNodes[_loc1_].ChildNodes.length)
            {
               _loc3_ = mapNodeByConstant.itemFor(MapNodes[_loc1_].ChildNodes[_loc2_]);
               if(_loc3_)
               {
                  _loc3_.ParentNodes.push(MapNodes[_loc1_]);
                  MapNodes[_loc1_].ChildNodes[_loc2_] = _loc3_;
               }
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function getSkinByType(skinType:uint) : GMSkin
      {
         var _loc2_:GMSkin = skinsById.itemFor(skinType);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find GMSkin for skinType: " + skinType);
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
      
      public function isSkinTypeADefaultSkin(skinType:uint) : Boolean
      {
         return mDefaultSkins.hasKey(skinType);
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
      
      public function getMapNode(idx:uint) : GMMapNode
      {
         return mapNodeById.itemFor(idx);
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
   }
}

