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
   import Metrics.PixelTracker;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IIterator;
   
   public class AvatarInfo
   {
      
      public static var mAvatarMapIndexes:Map = new Map();
      
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
      
      public var mEquippedConsumables:Vector.<Consumable>;
      
      public var mMapNodes:Vector.<AvatarMapNodeInfo>;
      
      public var mCompletedMapnodeMask:Utf8BitArray;
      
      private var mGMHero:GMHero;
      
      public function AvatarInfo(dbFacade:DBFacade, avatarJson:Object, responseCallback:Function)
      {
         super();
         mMapNodes = new Vector.<AvatarMapNodeInfo>();
         mEquippedConsumables = new Vector.<Consumable>();
         mCompletedMapnodeMask = new Utf8BitArray();
         mDBFacade = dbFacade;
         mResponseCallback = responseCallback;
         init(avatarJson);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function get mapNodes() : Vector.<AvatarMapNodeInfo>
      {
         return mMapNodes;
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
         return mGMHero.getTotalStatFromExp(this.experience);
      }
      
      public function get skillPointsAvailable() : int
      {
         return Math.max(this.skillPointsEarned - this.skillPointsSpent,0);
      }
      
      public function get skillPointsSpent() : uint
      {
         return statUpgrade1 + statUpgrade2 + statUpgrade3 + statUpgrade4;
      }
      
      public function get level() : uint
      {
         var _loc1_:GMHero = mDBFacade.gameMaster.heroById.itemFor(avatarType);
         return _loc1_.getLevelFromExp(experience);
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
         var _loc6_:AvatarMapNodeInfo = null;
         var _loc7_:GMMapNode = null;
         var _loc11_:* = 0;
         var _loc10_:Utf8BitArray = null;
         var _loc3_:IIterator = null;
         var _loc4_:* = 0;
         if(avatarJson == null)
         {
            return;
         }
         mCompletedMapnodeMask.init(avatarJson.completed_mapnode_mask);
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
         var _loc2_:Set = new Set();
         var _loc5_:Set = null;
         var _loc9_:Boolean = true;
         if(mAvatarMapIndexes.hasKey(id))
         {
            _loc5_ = mAvatarMapIndexes.itemFor(id);
            _loc9_ = false;
         }
         var _loc8_:uint = 0;
         if(mDBFacade.NODE_RULES == 0)
         {
            _loc11_ = mCompletedMapnodeMask.getLength();
            _loc8_ = 0;
            while(_loc8_ < mCompletedMapnodeMask.getLength())
            {
               if(mCompletedMapnodeMask.getBit(_loc8_))
               {
                  _loc6_ = new AvatarMapNodeInfo();
                  _loc7_ = mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc8_);
                  if(_loc7_ == null)
                  {
                     Logger.warn("Unable to find map node for bit index: " + _loc8_);
                  }
                  else
                  {
                     _loc6_.node_id = _loc7_.Id;
                     _loc2_.add(_loc7_.Id);
                     _loc6_.trophy = _loc7_.NodeType == "BOSS" || _loc7_.NodeType == "INFINITE" ? 1 : 0;
                     _loc6_.isCompleted = true;
                     mMapNodes.push(_loc6_);
                  }
               }
               _loc8_++;
            }
         }
         else
         {
            _loc10_ = mDBFacade.dbAccountInfo.getCompletedMapnodeMask();
            _loc8_ = 0;
            while(_loc8_ < _loc10_.getLength())
            {
               if(_loc10_.getBit(_loc8_))
               {
                  _loc6_ = new AvatarMapNodeInfo();
                  _loc7_ = mDBFacade.gameMaster.mapNodeByBitIndex.itemFor(_loc8_);
                  _loc6_.node_id = _loc7_.Id;
                  _loc2_.add(_loc7_.Id);
                  _loc6_.trophy = mCompletedMapnodeMask.getBit(_loc8_) && (_loc7_.NodeType == "BOSS" || _loc7_.NodeType == "INFINITE") ? 1 : 0;
                  _loc6_.isCompleted = mCompletedMapnodeMask.getBit(_loc8_);
                  mMapNodes.push(_loc6_);
               }
               _loc8_++;
            }
         }
         if(mDBFacade.accountId == accountId)
         {
            if(!_loc9_)
            {
               _loc3_ = _loc2_.iterator();
               while(_loc3_.hasNext())
               {
                  _loc4_ = uint(_loc3_.next());
                  if(!_loc5_.has(_loc4_))
                  {
                     PixelTracker.logMapNodeUnlocked(mDBFacade,_loc4_);
                  }
               }
            }
         }
         if(mAvatarMapIndexes.has(id))
         {
            mAvatarMapIndexes.replaceFor(id,_loc2_);
         }
         else
         {
            mAvatarMapIndexes.add(id,_loc2_);
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
