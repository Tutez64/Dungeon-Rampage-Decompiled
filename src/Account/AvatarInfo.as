package Account
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Utils.Utf8BitArray;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMMapNode;
   import GameMasterDictionary.GMSkin;
   
   public class AvatarInfo
   {
      
      public static const MAX_EFFECTIVE_LEVEL:uint = GMHero.MAX_LEVEL;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSwfAsset:SwfAsset;
      
      private var mResponseCallback:Function;
      
      private var mCallbackSuccess:Function;
      
      private var mCallbackFailure:Function;
      
      public var accountId:uint;
      
      public var avatarType:uint;
      
      public var created:String;
      
      public var experience:uint;
      
      public var id:uint;
      
      public var statUpgrade1:uint;
      
      public var statUpgrade2:uint;
      
      public var statUpgrade3:uint;
      
      public var statUpgrade4:uint;
      
      public var skinId:uint;
      
      public var consumable1Id:uint;
      
      public var consumable1Count:uint;
      
      public var consumable2Id:uint;
      
      public var consumable2Count:uint;
      
      public var mAscensionLevel:uint;
      
      public var mNextAscensionGemCost:uint;
      
      public var mMaxSkillPoints:uint;
      
      public var mEquippedConsumables:Vector.<Consumable>;
      
      public var mMapNodes:Vector.<AvatarMapNodeInfo>;
      
      public var mCompletedMapnodeMask:Utf8BitArray;
      
      public var mTrophyMapnodeMask:Utf8BitArray;
      
      private var mGMHero:GMHero;
      
      public function AvatarInfo(dbFacade:DBFacade, avatarJson:Object, responseCallback:Function)
      {
         super();
         mMapNodes = new Vector.<AvatarMapNodeInfo>();
         mEquippedConsumables = new Vector.<Consumable>();
         mCompletedMapnodeMask = new Utf8BitArray();
         mTrophyMapnodeMask = new Utf8BitArray();
         mDBFacade = dbFacade;
         mResponseCallback = responseCallback;
         init(avatarJson);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function get mapNodes() : Vector.<AvatarMapNodeInfo>
      {
         return mMapNodes;
      }
      
      public function hasTrophy(bitIndex:uint) : Boolean
      {
         return mTrophyMapnodeMask.getBit(bitIndex);
      }
      
      public function destroy() : void
      {
         mEquippedConsumables = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mGMHero = null;
         mDBFacade = null;
         mMapNodes = null;
      }
      
      public function init(avatarJson:Object) : void
      {
         parseJson(avatarJson);
         mGMHero = mDBFacade.gameMaster.heroById.itemFor(avatarType);
      }
      
      public function get skillPointsEarned() : uint
      {
         return mMaxSkillPoints;
      }
      
      public function get skillPointsAvailable() : int
      {
         return Math.max(this.skillPointsEarned - this.skillPointsSpent,0);
      }
      
      public function get skillPointsSpent() : uint
      {
         return statUpgrade1 + statUpgrade2 + statUpgrade3 + statUpgrade4;
      }
      
      public function get cloutLevel() : uint
      {
         var _loc1_:GMHero = mDBFacade.gameMaster.heroById.itemFor(avatarType);
         return _loc1_.getLevelFromExp(experience,mAscensionLevel);
      }
      
      public function get effectiveLevel() : uint
      {
         return Math.min(cloutLevel,MAX_EFFECTIVE_LEVEL);
      }
      
      public function get ogLevel() : uint
      {
         var _loc1_:GMHero = mDBFacade.gameMaster.heroById.itemFor(avatarType);
         return Math.min(_loc1_.getLevelFromExp(experience,mAscensionLevel),100);
      }
      
      public function get canAscend() : Boolean
      {
         if(mDBFacade.dbAccountInfo.premiumCurrency < mNextAscensionGemCost)
         {
            return false;
         }
         if(cloutLevel < GMHero.maxLevelForAscension(mAscensionLevel))
         {
            return false;
         }
         var _loc1_:uint = uint(mGMHero.getLevelIndex(experience,mAscensionLevel));
         return experience >= mGMHero.getExpFromIndex(_loc1_);
      }
      
      public function get levelForWeaponComparison() : uint
      {
         if(cloutLevel <= 99)
         {
            return cloutLevel;
         }
         return 9001;
      }
      
      public function get gmHero() : GMHero
      {
         return mGMHero;
      }
      
      public function loadHeroIcon(loadedCallback:Function) : void
      {
         var iconClass:Class;
         var gmSkin:GMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
         if(!mSwfAsset)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath),function(param1:SwfAsset):void
            {
               mSwfAsset = param1;
               iconClass = param1.getClass(gmSkin.IconName);
               loadedCallback(new iconClass());
            });
         }
         else
         {
            iconClass = mSwfAsset.getClass(gmSkin.IconName);
            loadedCallback(new iconClass());
         }
      }
      
      private function parseJson(avatarJson:Object) : void
      {
         var _loc2_:AvatarMapNodeInfo = null;
         var _loc3_:GMMapNode = null;
         var _loc4_:uint = 0;
         var _loc5_:Utf8BitArray = null;
         if(avatarJson == null)
         {
            return;
         }
         mCompletedMapnodeMask.init(avatarJson.completed_mapnode_mask);
         mTrophyMapnodeMask.init(avatarJson.trophy_mapnode_mask);
         accountId = avatarJson.account_id as uint;
         avatarType = avatarJson.avatar_id as uint;
         created = avatarJson.created as String;
         experience = avatarJson.experience as uint;
         id = avatarJson.id as uint;
         statUpgrade1 = avatarJson.statupgrade1 as uint;
         statUpgrade2 = avatarJson.statupgrade2 as uint;
         statUpgrade3 = avatarJson.statupgrade3 as uint;
         statUpgrade4 = avatarJson.statupgrade4 as uint;
         skinId = avatarJson.skin_type as uint;
         consumable1Id = avatarJson.consumable1_id as uint;
         consumable1Count = avatarJson.consumable1_count as uint;
         mEquippedConsumables.push(new Consumable(0,consumable1Id,consumable1Count));
         consumable2Id = avatarJson.consumable2_id as uint;
         consumable2Count = avatarJson.consumable2_count as uint;
         mEquippedConsumables.push(new Consumable(1,consumable2Id,consumable2Count));
         mAscensionLevel = avatarJson.ascension_level;
         mMaxSkillPoints = avatarJson.max_skill_points;
         mNextAscensionGemCost = avatarJson.ascension_gem_cost;
         if(mDBFacade.NODE_RULES == 0)
         {
            _loc4_ = 0;
            while(_loc4_ < mCompletedMapnodeMask.getLength())
            {
               if(mCompletedMapnodeMask.getBit(_loc4_))
               {
                  _loc2_ = new AvatarMapNodeInfo();
                  _loc3_ = mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc4_);
                  if(_loc3_ == null)
                  {
                     Logger.warn("Unable to find map node for bit index: " + _loc4_);
                  }
                  else
                  {
                     _loc2_.node_id = _loc3_.Id;
                     _loc2_.trophy = _loc3_.NodeType == GMMapNode.BOSS_NODE_TYPE || _loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE ? 1 : 0;
                     _loc2_.isCompleted = true;
                     mMapNodes.push(_loc2_);
                  }
               }
               _loc4_++;
            }
         }
         else
         {
            _loc5_ = mDBFacade.dbAccountInfo.getCompletedMapnodeMask();
            _loc4_ = 0;
            while(_loc4_ < _loc5_.getLength())
            {
               if(_loc5_.getBit(_loc4_))
               {
                  _loc2_ = new AvatarMapNodeInfo();
                  _loc3_ = mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc4_);
                  _loc2_.node_id = _loc3_.Id;
                  _loc2_.trophy = mCompletedMapnodeMask.getBit(_loc4_) && (_loc3_.NodeType == GMMapNode.BOSS_NODE_TYPE || _loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE) ? 1 : 0;
                  _loc2_.isCompleted = mCompletedMapnodeMask.getBit(_loc4_);
                  mMapNodes.push(_loc2_);
               }
               _loc4_++;
            }
         }
      }
      
      public function RPC_updateAvatarSlots(val1:uint, val2:uint, val3:uint, val4:uint, successCallback:Function, failureCallback:Function) : void
      {
         mCallbackSuccess = successCallback;
         mCallbackFailure = failureCallback;
         var _loc7_:Function = JSONRPCService.getFunction("updateAvatarSlots",mDBFacade.rpcRoot + "avatarrecord");
         _loc7_(mDBFacade.validationToken,accountId,id,val1,val2,val3,val4,mResponseCallback,updateFailure);
      }
      
      public function RPC_updateAvatarSkin() : void
      {
         var _loc1_:Function = JSONRPCService.getFunction("setSkin",mDBFacade.rpcRoot + "avatarrecord");
         _loc1_(mDBFacade.validationToken,accountId,id,skinId,mResponseCallback,updateFailure);
      }
      
      private function updateFailure(err:Error) : void
      {
         if(mCallbackFailure != null)
         {
            mCallbackFailure(err);
         }
      }
      
      public function get equippedConsumables() : Vector.<Consumable>
      {
         return mEquippedConsumables;
      }
   }
}

class AvatarMapNodeInfo
{
   
   public var node_id:uint;
   
   public var trophy:uint;
   
   public var isCompleted:Boolean;
   
   public function AvatarMapNodeInfo()
   {
      super();
   }
}
