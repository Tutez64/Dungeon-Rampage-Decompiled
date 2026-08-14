package Account
{
   import Actor.Player.SkinInfo;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Events.BoostersParsedEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMKey;
   import GameMasterDictionary.GMMapNode;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMStackable;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class DBInventoryInfo
   {
      
      public static const II_FIRST_MAPNODE_ID:uint = 50150;
      
      protected var mDBFacade:DBFacade;
      
      private var mAvatars:Map;
      
      private var mItems:Map;
      
      private var mChests:Vector.<ChestInfo>;
      
      private var mLastPendingChest:int;
      
      private var mKeys:Vector.<KeyInfo>;
      
      private var mStackablesByDatabaseId:Map;
      
      private var mStackablesByStackableId:Map;
      
      private var mBoostersByDatabaseId:Map;
      
      private var mBoostersByStackableId:Map;
      
      private var mPets:Map;
      
      private var mSkins:Map;
      
      private var mResponseCallback:Function;
      
      private var mParseErrorCallback:Function;
      
      protected var mEventComponent:EventComponent;
      
      private var mStorageLimitWeapon:uint;
      
      private var mStorageLimitOther:uint;
      
      private var mFirstParse:Boolean;
      
      private var mTotalHeroesOwned:uint;
      
      public function DBInventoryInfo(dbFacade:DBFacade, responseCallback:Function, parseErrorCallback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mAvatars = new Map();
         mItems = new Map();
         mChests = new Vector.<ChestInfo>();
         mLastPendingChest = -1;
         mKeys = new Vector.<KeyInfo>();
         mStackablesByDatabaseId = new Map();
         mStackablesByStackableId = new Map();
         mBoostersByDatabaseId = new Map();
         mBoostersByStackableId = new Map();
         mPets = new Map();
         mSkins = new Map();
         mFirstParse = true;
         mTotalHeroesOwned = 0;
         mResponseCallback = responseCallback;
         mParseErrorCallback = parseErrorCallback;
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function listAllBoosters() : Array
      {
         return mBoostersByStackableId.keysToArray();
      }
      
      public function getStackableByStackId(stackIndex:int) : StackableInfo
      {
         return mStackablesByStackableId.itemFor(stackIndex);
      }
      
      public function findHighestBoosterXP() : BoosterInfo
      {
         var _loc4_:BoosterInfo = null;
         var _loc1_:BoosterInfo = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Array = listAllBoosters();
         for(var _loc3_:String in _loc2_)
         {
            _loc5_ = int(_loc2_[_loc3_]);
            _loc1_ = mBoostersByStackableId.itemFor(_loc5_);
            _loc6_ = timeTillBoosterExpire(_loc5_);
            if(_loc1_ != null && _loc1_.BuffInfo.Exp > 1 && _loc6_ > 0)
            {
               if(_loc4_ == null || _loc1_.BuffInfo.Exp > _loc4_.BuffInfo.Exp)
               {
                  _loc4_ = _loc1_;
               }
            }
         }
         return _loc4_;
      }
      
      public function findHighestBoosterGold() : BoosterInfo
      {
         var _loc4_:BoosterInfo = null;
         var _loc1_:BoosterInfo = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Array = listAllBoosters();
         for(var _loc3_:String in _loc2_)
         {
            _loc5_ = int(_loc2_[_loc3_]);
            _loc1_ = mBoostersByStackableId.itemFor(_loc5_);
            _loc6_ = timeTillBoosterExpire(_loc5_);
            if(_loc1_ != null && _loc1_.BuffInfo.Gold > 1 && _loc6_ > 0)
            {
               if(_loc4_ == null || _loc1_.BuffInfo.Gold > _loc4_.BuffInfo.Gold)
               {
                  _loc4_ = _loc1_;
               }
            }
         }
         return _loc4_;
      }
      
      public function timestampBooster(stackId:int) : String
      {
         var _loc2_:BoosterInfo = null;
         if(mBoostersByStackableId.hasKey(stackId))
         {
            _loc2_ = mBoostersByStackableId.itemFor(stackId);
            if(_loc2_ != null)
            {
               return _loc2_.timeStamp();
            }
         }
         return "";
      }
      
      public function timeTillBoosterExpire(stackId:int) : int
      {
         var _loc3_:BoosterInfo = mBoostersByStackableId.itemFor(stackId);
         var _loc2_:Date = dateBooster(_loc3_.gmId);
         return int(_loc2_.getTime() - GameClock.getWebServerTime());
      }
      
      public function timeTillNextBoosterExpire() : int
      {
         var _loc2_:BoosterInfo = null;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = listAllBoosters();
         var _loc1_:int = -1;
         for(var _loc4_:String in _loc3_)
         {
            _loc6_ = int(_loc3_[_loc4_]);
            _loc2_ = mBoostersByStackableId.itemFor(_loc6_);
            _loc5_ = timeTillBoosterExpire(_loc2_.gmId);
            if(_loc5_ > 0)
            {
               if(_loc1_ == -1 || _loc5_ < _loc1_)
               {
                  _loc1_ = _loc5_;
               }
            }
         }
         return _loc1_;
      }
      
      public function dateBooster(stackId:int) : Date
      {
         var _loc2_:Date = GameClock.getWebServerDate();
         var _loc3_:String = timestampBooster(stackId);
         if(_loc3_ != "")
         {
            return GameClock.parseW3CDTF(_loc3_,true);
         }
         return null;
      }
      
      public function get unequippedWeaponCount() : uint
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         var _loc1_:uint = 0;
         _loc2_ = mItems.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            if(!_loc3_.isEquipped)
            {
               _loc1_++;
            }
         }
         return uint(_loc1_ + mChests.length);
      }
      
      public function get numStacks() : uint
      {
         return mStackablesByDatabaseId.size;
      }
      
      public function getStackCount(stackableId:uint) : uint
      {
         var _loc2_:StackableInfo = mStackablesByStackableId.itemFor(stackableId);
         return _loc2_ ? _loc2_.count : 0;
      }
      
      public function getAvatarInfoForAvatarInstanceId(instanceId:uint) : AvatarInfo
      {
         return mAvatars.itemFor(instanceId);
      }
      
      public function getAvatarInfoForHeroType(heroType:uint) : AvatarInfo
      {
         var _loc3_:IMapIterator = null;
         var _loc2_:AvatarInfo = null;
         _loc3_ = mAvatars.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc2_ = _loc3_.next();
            if(heroType == _loc2_.avatarType)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function modifiersMatch(details:GMOfferDetail, itemInfo:ItemInfo) : Boolean
      {
         var _loc3_:uint = 0;
         if(details.Modifier1)
         {
            _loc3_++;
         }
         if(details.Modifier2)
         {
            _loc3_++;
         }
         if(details.Modifier3)
         {
            _loc3_++;
         }
         if(_loc3_ != itemInfo.modifiers.length)
         {
            return false;
         }
         if(details.Modifier1 && !itemInfo.hasModifier(details.Modifier1))
         {
            return false;
         }
         if(details.Modifier2 && !itemInfo.hasModifier(details.Modifier2))
         {
            return false;
         }
         if(details.Modifier3 && !itemInfo.hasModifier(details.Modifier3))
         {
            return false;
         }
         return true;
      }
      
      public function ownsExactWeapon(details:GMOfferDetail) : Boolean
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         _loc2_ = mItems.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            if(details.WeaponId == _loc3_.gmId && details.WeaponPower == _loc3_.power && this.modifiersMatch(details,_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public function ownsItem(infoId:uint) : Boolean
      {
         var _loc5_:IMapIterator = null;
         var _loc6_:ItemInfo = null;
         var _loc2_:AvatarInfo = null;
         var _loc4_:PetInfo = null;
         var _loc7_:StackableInfo = null;
         var _loc3_:SkinInfo = null;
         _loc5_ = mItems.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc6_ = _loc5_.next();
            if(infoId == _loc6_.gmId)
            {
               return true;
            }
         }
         _loc7_ = mStackablesByStackableId.itemFor(infoId);
         if(_loc7_ && _loc7_.count > 0)
         {
            return true;
         }
         _loc5_ = mAvatars.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc2_ = _loc5_.next();
            if(infoId == _loc2_.avatarType)
            {
               return true;
            }
         }
         _loc5_ = mPets.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc4_ = _loc5_.next();
            if(infoId == _loc4_.PetType)
            {
               return true;
            }
         }
         _loc5_ = mSkins.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc3_ = _loc5_.next();
            if(infoId == _loc3_.skinType)
            {
               return true;
            }
         }
         if(mDBFacade.gameMaster.isSkinTypeADefaultSkin(infoId))
         {
            return true;
         }
         return false;
      }
      
      public function getEquipedItemsOnAvatar(avatarInstanceId:uint) : Vector.<ItemInfo>
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc2_:Vector.<ItemInfo> = new Vector.<ItemInfo>();
         _loc3_ = mItems.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next() as ItemInfo;
            if(_loc4_.avatarId == avatarInstanceId)
            {
               _loc2_.push(_loc4_);
            }
         }
         return _loc2_;
      }
      
      public function getEquipedPetsOnAvatar(avatarInstanceId:uint) : Vector.<PetInfo>
      {
         var _loc4_:IMapIterator = null;
         var _loc3_:PetInfo = null;
         var _loc2_:Vector.<PetInfo> = new Vector.<PetInfo>();
         _loc4_ = mPets.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc3_ = _loc4_.next() as PetInfo;
            if(_loc3_.EquippedHero == avatarInstanceId)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getEquipedConsumablesOnAvatar(avatarInfo:AvatarInfo) : Vector.<StackableInfo>
      {
         var _loc4_:* = null;
         var _loc5_:StackableInfo = null;
         var _loc2_:GMStackable = null;
         var _loc3_:Vector.<StackableInfo> = new Vector.<StackableInfo>();
         if(avatarInfo.consumable1Id > 0 && avatarInfo.consumable1Count > 0)
         {
            _loc2_ = mDBFacade.gameMaster.stackableById.itemFor(avatarInfo.consumable1Id);
            _loc5_ = new StackableInfo(mDBFacade,null,_loc2_);
            _loc5_.setPropertiesAsConsumable(_loc2_.Id,0,avatarInfo.consumable1Count);
            _loc3_.push(_loc5_);
         }
         if(avatarInfo.consumable2Id > 0 && avatarInfo.consumable2Count > 0)
         {
            _loc2_ = mDBFacade.gameMaster.stackableById.itemFor(avatarInfo.consumable2Id);
            _loc5_ = new StackableInfo(mDBFacade,null,mDBFacade.gameMaster.stackableById.itemFor(avatarInfo.consumable2Id));
            _loc5_.setPropertiesAsConsumable(_loc2_.Id,1,avatarInfo.consumable2Count);
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      public function get highestAvatarLevel() : uint
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_:uint = 0;
         var _loc3_:IMapIterator = mAvatars.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc1_ = _loc3_.next();
            _loc2_ = Math.max(_loc2_,_loc1_.level);
         }
         return _loc2_;
      }
      
      public function get items() : Map
      {
         return mItems;
      }
      
      public function get chests() : Vector.<ChestInfo>
      {
         return mChests;
      }
      
      public function get keys() : Vector.<KeyInfo>
      {
         return mKeys;
      }
      
      public function get stackables() : Map
      {
         return mStackablesByDatabaseId;
      }
      
      public function get stackablesByStackableID() : Map
      {
         return mStackablesByStackableId;
      }
      
      public function get avatars() : Map
      {
         return mAvatars;
      }
      
      public function get mapnodes1() : Map
      {
         var _loc5_:* = 0;
         var _loc1_:MapnodeInfo = null;
         var _loc2_:GMMapNode = null;
         var _loc12_:* = 0;
         var _loc9_:Boolean = false;
         var _loc10_:* = 0;
         var _loc11_:* = 0;
         var _loc4_:Map = new Map();
         var _loc3_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc7_:uint = _loc3_.level;
         var _loc6_:uint = mDBFacade.dbAccountInfo.trophies;
         var _loc8_:Object = mDBFacade.dbAccountInfo.activeAvatarInfo.mapNodes;
         _loc5_ = 0;
         while(_loc5_ < _loc3_.mapNodes.length)
         {
            _loc1_ = new MapnodeInfo();
            _loc12_ = _loc3_.mapNodes[_loc5_].node_id;
            if(_loc3_.mapNodes[_loc5_].isCompleted)
            {
               _loc1_.init(_loc12_,1);
            }
            else
            {
               _loc1_.init(_loc12_,3);
            }
            _loc4_.add(_loc12_,_loc1_);
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < mDBFacade.gameMaster.MapNodes.length)
         {
            _loc2_ = mDBFacade.gameMaster.MapNodes[_loc5_];
            if(_loc4_.itemFor(_loc2_.Id) == null && _loc2_.LevelRequirement <= _loc7_ && _loc2_.TrophyRequirement <= _loc6_)
            {
               if(_loc2_.ParentNodes.length == 0)
               {
                  _loc1_ = new MapnodeInfo();
                  _loc1_.init(_loc2_.Id,2);
                  _loc4_.add(_loc2_.Id,_loc1_);
               }
               else
               {
                  _loc9_ = false;
                  _loc10_ = 0;
                  while(_loc10_ < _loc3_.mapNodes.length && !_loc9_)
                  {
                     _loc11_ = 0;
                     while(_loc11_ < _loc2_.ParentNodes.length && !_loc9_)
                     {
                        if(_loc2_.ParentNodes[_loc11_].Id == _loc3_.mapNodes[_loc10_].node_id)
                        {
                           _loc9_ = true;
                        }
                        _loc11_++;
                     }
                     _loc10_++;
                  }
                  if(_loc9_)
                  {
                     _loc1_ = new MapnodeInfo();
                     _loc1_.init(_loc2_.Id,2);
                     _loc4_.add(_loc2_.Id,_loc1_);
                  }
               }
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function get pets() : Map
      {
         return mPets;
      }
      
      public function getTotalHeroesOwned() : uint
      {
         return mTotalHeroesOwned;
      }
      
      public function parseJson(accountJson:Object) : void
      {
         if(accountJson.account_avatars)
         {
            parseAvatars(accountJson.account_avatars);
         }
         if(accountJson.account_items)
         {
            parseItems(accountJson.account_items);
         }
         if(accountJson.account_chests)
         {
            parseChests(accountJson.account_chests);
         }
         if(accountJson)
         {
            parseKeys(accountJson);
         }
         if(accountJson.account_stackables)
         {
            parseStackables(accountJson.account_stackables);
         }
         if(accountJson.buckets_weapon)
         {
            mStorageLimitWeapon = accountJson.buckets_weapon;
         }
         if(accountJson.buckets_other)
         {
            mStorageLimitOther = accountJson.buckets_other;
         }
         if(accountJson.account_pets)
         {
            parsePetInfo(accountJson.account_pets);
         }
         if(accountJson.account_skins)
         {
            parseSkinInfo(accountJson.account_skins);
         }
         if(accountJson.account_boosters)
         {
            parseBoosters(accountJson.account_boosters);
         }
         mFirstParse = false;
         mTotalHeroesOwned = mAvatars.size;
      }
      
      private function parseAvatars(avatarsJson:Object) : void
      {
         var _loc2_:AvatarInfo = null;
         var _loc4_:* = 0;
         mAvatars.clear();
         var _loc3_:Array = avatarsJson as Array;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = new AvatarInfo(mDBFacade,_loc3_[_loc4_],mResponseCallback);
            mAvatars.add(_loc2_.id,_loc2_);
            _loc4_++;
         }
      }
      
      private function parseItems(itemsJson:Object) : void
      {
         var _loc4_:ItemInfo = null;
         var _loc2_:* = 0;
         var _loc3_:Array = mItems.keysToArray();
         mItems.clear();
         var _loc5_:Array = itemsJson as Array;
         _loc2_ = 0;
         while(_loc2_ < _loc5_.length)
         {
            _loc4_ = new ItemInfo(mDBFacade,_loc5_[_loc2_]);
            if(!mFirstParse && _loc3_.indexOf(_loc5_[_loc2_].id) == -1)
            {
               _loc4_.isNew = true;
            }
            mItems.add(_loc4_.databaseId,_loc4_);
            _loc2_++;
         }
      }
      
      private function parseChests(chestsJson:Object) : void
      {
         var _loc6_:ChestInfo = null;
         var _loc7_:* = 0;
         var _loc5_:Boolean = false;
         var _loc3_:Vector.<ChestInfo> = mChests.slice();
         mChests.splice(0,mChests.length);
         var _loc2_:Array = chestsJson as Array;
         _loc7_ = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc5_ = false;
            if(!mFirstParse)
            {
               for each(var _loc4_:ChestInfo in _loc3_)
               {
                  if(_loc4_.databaseId == _loc2_[_loc7_].id)
                  {
                     _loc5_ = true;
                     break;
                  }
               }
            }
            else
            {
               _loc5_ = true;
            }
            _loc6_ = new ChestInfo(mDBFacade,_loc2_[_loc7_]);
            if(!_loc5_)
            {
               _loc6_.isNew = true;
            }
            mChests.push(_loc6_);
            _loc7_++;
         }
      }
      
      private function parseKeys(accountsJson:Object) : void
      {
         var _loc6_:KeyInfo = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc2_:* = 0;
         mKeys.splice(0,mKeys.length);
         var _loc3_:Vector.<GMKey> = mDBFacade.gameMaster.Keys;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_].OfferId;
            _loc2_ = 0;
            switch(int(_loc4_))
            {
               case 0:
                  _loc2_ = uint(accountsJson.basic_keys);
                  break;
               case 1:
                  _loc2_ = uint(accountsJson.uncommon_keys);
                  break;
               case 2:
                  _loc2_ = uint(accountsJson.rare_keys);
                  break;
               case 3:
                  _loc2_ = uint(accountsJson.legendary_keys);
            }
            _loc6_ = new KeyInfo(mDBFacade.gameMaster.keysByOfferId.itemFor(_loc5_),mDBFacade.gameMaster.offerById.itemFor(_loc5_),_loc2_);
            mKeys.push(_loc6_);
            _loc4_++;
         }
      }
      
      private function parseStackables(stackablesJson:Object) : void
      {
         var _loc5_:StackableInfo = null;
         var _loc4_:* = 0;
         var _loc2_:Array = mStackablesByDatabaseId.keysToArray();
         mStackablesByDatabaseId.clear();
         mStackablesByStackableId.clear();
         var _loc3_:Array = stackablesJson as Array;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = new StackableInfo(mDBFacade,_loc3_[_loc4_]);
            if(!mFirstParse && _loc2_.indexOf(_loc3_[_loc4_].id) == -1)
            {
               _loc5_.isNew = true;
            }
            mStackablesByDatabaseId.add(_loc5_.databaseId,_loc5_);
            mStackablesByStackableId.add(_loc5_.gmId,_loc5_);
            _loc4_++;
         }
      }
      
      private function parseBoosters(boostersJson:Object) : void
      {
         var _loc2_:BoosterInfo = null;
         var _loc3_:* = 0;
         var _loc5_:Array = mBoostersByDatabaseId.keysToArray();
         mBoostersByDatabaseId.clear();
         mBoostersByStackableId.clear();
         var _loc4_:Array = boostersJson as Array;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc2_ = new BoosterInfo(mDBFacade,_loc4_[_loc3_]);
            if(!mFirstParse && _loc5_.indexOf(_loc4_[_loc3_].id) == -1)
            {
               _loc2_.isNew = true;
            }
            mBoostersByDatabaseId.add(_loc2_.databaseId,_loc2_);
            mBoostersByStackableId.add(_loc2_.gmId,_loc2_);
            _loc3_++;
         }
         mDBFacade.eventManager.dispatchEvent(new BoostersParsedEvent("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE"));
      }
      
      private function parsePetInfo(petsJson:Object) : void
      {
         var _loc3_:PetInfo = null;
         var _loc4_:* = 0;
         var _loc5_:Array = mPets.keysToArray();
         mPets.clear();
         var _loc2_:Array = petsJson as Array;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = new PetInfo(mDBFacade,_loc2_[_loc4_]);
            if(!mFirstParse && _loc5_.indexOf(_loc2_[_loc4_].id) == -1)
            {
               _loc3_.isNew = true;
            }
            mPets.add(_loc3_.databaseId,_loc3_);
            _loc4_++;
         }
      }
      
      private function parseSkinInfo(skinsJson:Object) : void
      {
         var _loc3_:SkinInfo = null;
         var _loc4_:* = 0;
         mSkins.clear();
         var _loc2_:Array = skinsJson as Array;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = new SkinInfo(mDBFacade,_loc2_[_loc4_]);
            mSkins.add(_loc3_.skinType,_loc3_);
            _loc4_++;
         }
      }
      
      public function openChest(chestInstanceId:uint, forHeroId:uint, forHeroSkinId:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function;
         if(mLastPendingChest == chestInstanceId && 0)
         {
            Logger.error("Chest has already been opened on Server. Chest id:" + chestInstanceId);
            mLastPendingChest = -1;
            return;
         }
         mLastPendingChest = chestInstanceId;
         rpcFunc = JSONRPCService.getFunction("OpenChest",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,chestInstanceId,mDBFacade.validationToken,forHeroId,forHeroSkinId,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(chestInstanceId,param1);
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function dropChest(chestInstanceId:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("DropChest",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,chestInstanceId,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(chestInstanceId,param1);
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function canThisAvatarEquipThisItem(avatarInfo:AvatarInfo, itemInfo:ItemInfo) : Boolean
      {
         if(avatarInfo == null)
         {
            return false;
         }
         if(itemInfo == null)
         {
            return false;
         }
         if(!canAvatarEquipThisMasterType(avatarInfo,itemInfo.gmWeaponItem.MasterType))
         {
            return false;
         }
         if(avatarInfo.level < itemInfo.requiredLevel)
         {
            return false;
         }
         return true;
      }
      
      public function canAvatarEquipThisMasterType(avatarInfo:AvatarInfo, masterType:String) : Boolean
      {
         return avatarInfo.gmHero.AllowedWeapons.hasKey(masterType);
      }
      
      public function recalculateWeaponPowers(responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var itemInfo:ItemInfo;
         var rpcFunc:Function;
         var iter:IMapIterator = mItems.iterator() as IMapIterator;
         var itemIds:Array = [];
         while(iter.hasNext())
         {
            itemInfo = iter.next();
            itemIds.push(itemInfo.databaseId);
         }
         rpcFunc = JSONRPCService.getFunction("RecalculateWeaponPowers",mDBFacade.rpcRoot + "inventorymanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,itemIds,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(param1);
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function equipItemOnAvatar(avatarInstanceId:uint, itemInstanceId:uint, equipSlot:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("equipItemOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,itemInstanceId,equipSlot,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function unequipItemOffAvatar(itemInfo:InventoryBaseInfo, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function;
         if(!itemInfo.isEquipped)
         {
            Logger.error("Trying to unequip an item that is not currently equipped.");
            if(errorCallback != null)
            {
               errorCallback(new Error("Trying to unequip an item that is not currently equipped.",-1));
            }
         }
         rpcFunc = JSONRPCService.getFunction("unequipItemOffAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,itemInfo.databaseId,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function equipConsumableOnAvatar(avatarInstanceId:uint, stackableId:uint, equipSlot:uint, swapping:Boolean = false, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("equipConsumableOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,stackableId,equipSlot,swapping,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function unequipConsumableOffAvatar(avatarInstanceId:uint, stackableId:uint, equipSlot:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("unequipConsumableOffAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,stackableId,equipSlot,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function canEquipThisConsumable(avatarInfo:AvatarInfo, equipSlot:uint, consumableId:uint) : Boolean
      {
         var _loc4_:Boolean = true;
         if(equipSlot == 0)
         {
            if(avatarInfo.consumable2Id > 0 && avatarInfo.consumable2Count > 0)
            {
               _loc4_ = avatarInfo.consumable2Id != consumableId;
            }
         }
         else if(equipSlot == 1)
         {
            if(avatarInfo.consumable1Id > 0 && avatarInfo.consumable1Count > 0)
            {
               _loc4_ = avatarInfo.consumable1Id != consumableId;
            }
         }
         return _loc4_;
      }
      
      public function equipPetOnAvatar(avatarInstanceId:uint, petId:uint, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function = JSONRPCService.getFunction("equipPetOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,petId,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function unequipPet(petInfo:PetInfo, responseFinishedCallback:Function = null, errorCallback:Function = null) : void
      {
         var rpcFunc:Function;
         if(!petInfo.isEquipped)
         {
            Logger.error("Trying to unequip a pet that is not currently equipped.");
            if(errorCallback != null)
            {
               errorCallback(new Error("Trying to unequip a pet that is not currently equipped.",-1));
            }
         }
         rpcFunc = JSONRPCService.getFunction("unEquipPet",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,petInfo.databaseId,mDBFacade.validationToken,function(param1:*):void
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error):void
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function numberOfEmptySlotsInWeaponStorage() : uint
      {
         return mStorageLimitWeapon - unequippedWeaponCount;
      }
      
      public function isThereEmptySpaceInWeaponStorage() : Boolean
      {
         return unequippedWeaponCount < mStorageLimitWeapon;
      }
      
      public function get storageLimitWeapon() : uint
      {
         return mStorageLimitWeapon;
      }
      
      public function isEquippableByAnyOwnedAvatar(itemInfo:ItemInfo) : Boolean
      {
         var _loc3_:IMapIterator = null;
         var _loc2_:AvatarInfo = null;
         _loc3_ = mAvatars.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc2_ = _loc3_.next();
            if(this.canThisAvatarEquipThisItem(_loc2_,itemInfo))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get hasNewEquippableItems() : Boolean
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc5_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc3_ = mItems.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            if(_loc4_.isNew && this.isEquippableByAnyOwnedAvatar(_loc4_))
            {
               return true;
            }
         }
         _loc3_ = mStackablesByStackableId.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc5_ = _loc3_.next();
            if(_loc5_.isNew)
            {
               return true;
            }
         }
         _loc3_ = mPets.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc1_ = _loc3_.next();
            if(_loc1_.isNew)
            {
               return true;
            }
         }
         for each(var _loc2_:ChestInfo in mChests)
         {
            if(_loc2_.isNew)
            {
               return true;
            }
         }
         return false;
      }
      
      public function markItemsNotNew() : void
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc5_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc3_ = mItems.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc4_.isNew = false;
         }
         _loc3_ = mStackablesByStackableId.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc5_ = _loc3_.next();
            _loc5_.isNew = false;
         }
         _loc3_ = mPets.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc1_ = _loc3_.next();
            _loc1_.isNew = false;
         }
         for each(var _loc2_:ChestInfo in mChests)
         {
            _loc2_.isNew = false;
         }
      }
      
      public function getSkinsForHero(gmHero:GMHero, offerBySkinId:Map) : Vector.<GMSkin>
      {
         var skin:GMSkin;
         var offer:GMOffer;
         var result:Vector.<GMSkin> = new Vector.<GMSkin>();
         for each(skin in mDBFacade.gameMaster.Skins)
         {
            if(skin.ForHero == gmHero.Constant)
            {
               offer = offerBySkinId.itemFor(skin.Id);
               if(!isSkinExpired(skin,offer))
               {
                  result.push(skin);
               }
            }
         }
         result.sort(function(param1:GMSkin, param2:GMSkin):int
         {
            return param1.Id - param2.Id;
         });
         return result;
      }
      
      public function isSkinExpired(skin:GMSkin, offer:GMOffer) : Boolean
      {
         var _loc7_:Number = GameClock.date.getTime();
         var _loc4_:Boolean = false;
         var _loc3_:Number = 0;
         var _loc6_:Boolean = false;
         var _loc5_:Number = 0;
         if(offer)
         {
            _loc4_ = offer.VisibleDate != null || offer.StartDate != null;
            if(_loc4_)
            {
               _loc3_ = offer.VisibleDate != null ? offer.VisibleDate.getTime() : offer.StartDate.getTime();
            }
            _loc6_ = offer.EndDate != null || offer.SoldOutDate != null;
            if(_loc6_)
            {
               _loc5_ = offer.SoldOutDate != null ? offer.SoldOutDate.getTime() : offer.EndDate.getTime();
            }
         }
         if(doesPlayerOwnSkin(skin.Id) || (offer != null && !_loc4_ || _loc3_ <= _loc7_ && (!_loc6_ || _loc5_ > _loc7_)))
         {
            return false;
         }
         return true;
      }
      
      public function doesPlayerOwnSkin(skinId:uint) : Boolean
      {
         return mSkins.hasKey(skinId) || mDBFacade.gameMaster.isSkinTypeADefaultSkin(skinId);
      }
      
      public function getSkinInfo(skinId:uint) : SkinInfo
      {
         if(mSkins.hasKey(skinId))
         {
            return mSkins.itemFor(skinId);
         }
         return null;
      }
      
      public function getDefaultSkinForHero(gmHero:GMHero) : GMSkin
      {
         var _loc2_:GMSkin = mDBFacade.gameMaster.getSkinByConstant(gmHero.DefaultSkin);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find default skin for hero type: " + gmHero.Id);
         }
         return _loc2_;
      }
      
      public function canShowInfiniteIsland() : Boolean
      {
         var _loc1_:MapnodeInfo = mapnodes1.itemFor(50150);
         return _loc1_ != null;
      }
   }
}

