package UI.Inventory
{
   import Account.ChestInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import DistributedObjects.DistributedDungeonSummary;
   import Facade.DBFacade;
   import GameMasterDictionary.GMChest;
   import GeneratedCode.DungeonReport;
   import flash.display.MovieClip;
   
   public class DungeonRewardPanel
   {
      
      private var mDungeonSummary:DistributedDungeonSummary;
      
      private var mRewardPanel:MovieClip;
      
      protected var mDBFacade:DBFacade;
      
      protected var mSelectedCallback:Function;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mDungeonRewardElements:Vector.<DungeonRewardElement>;
      
      public function DungeonRewardPanel(dbFacade:DBFacade, rewardPanelRoot:MovieClip, dungeonSummary:DistributedDungeonSummary, selectedCallback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mRewardPanel = rewardPanelRoot;
         mDungeonSummary = dungeonSummary;
         mSelectedCallback = selectedCallback;
         populateRewardPanel();
      }
      
      private function populateRewardPanel() : void
      {
         var _loc2_:DungeonRewardElement = null;
         var _loc3_:ChestInfo = null;
         var _loc5_:* = 0;
         var _loc4_:* = 0;
         clearRewardPanel();
         mDungeonRewardElements = new Vector.<DungeonRewardElement>();
         var _loc1_:DungeonReport = mDungeonSummary.report[0];
         mRewardPanel.equip_slot_1.visible = true;
         mRewardPanel.equip_slot_2.visible = true;
         mRewardPanel.equip_slot_3.visible = true;
         if(mDungeonSummary.isSingleChestList[0])
         {
            mRewardPanel.equip_slot_1.visible = false;
            mRewardPanel.equip_slot_2.visible = false;
            mRewardPanel.equip_slot_3.select.visible = false;
         }
         else
         {
            mRewardPanel.equip_slot_1.select.visible = false;
            mRewardPanel.equip_slot_2.select.visible = false;
            mRewardPanel.equip_slot_3.visible = false;
         }
         var _loc6_:Array = [_loc1_.chest_type_1,_loc1_.chest_type_2,_loc1_.chest_type_3,_loc1_.chest_type_4];
         _loc6_.sort(mDungeonSummary.compareChestTypes);
         _loc5_ = _loc1_.chest_type_1;
         _loc4_ = _loc1_.chest_type_2;
         _loc5_ = uint(_loc6_[0]);
         _loc4_ = uint(_loc6_[1]);
         if(_loc5_ > 0)
         {
            _loc3_ = new ChestInfo(mDBFacade,null);
            _loc3_.setParams(_loc5_);
            _loc3_.setFromDungeonSummary();
            if(mDungeonSummary.isSingleChestList[0])
            {
               _loc2_ = new DungeonRewardElement(mDBFacade,mRewardPanel.equip_slot_3.graphic,_loc3_,mSelectedCallback);
            }
            else
            {
               _loc2_ = new DungeonRewardElement(mDBFacade,mRewardPanel.equip_slot_1.graphic,_loc3_,mSelectedCallback);
            }
            mDungeonRewardElements.push(_loc2_);
         }
         if(_loc4_ > 0)
         {
            _loc3_ = new ChestInfo(mDBFacade,null);
            _loc3_.setParams(_loc4_);
            _loc3_.setFromDungeonSummary();
            _loc2_ = new DungeonRewardElement(mDBFacade,mRewardPanel.equip_slot_2.graphic,_loc3_,mSelectedCallback);
            mDungeonRewardElements.push(_loc2_);
         }
      }
      
      public function setChestAsSelected(chestGM:GMChest) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmChestInfo == chestGM)
            {
               mDungeonRewardElements[_loc2_].callSelectedCallback();
               highlightChest(mDungeonRewardElements[_loc2_].chestInfo);
            }
            _loc2_++;
         }
      }
      
      public function refresh() : void
      {
         populateRewardPanel();
      }
      
      private function clearRewardPanel() : void
      {
         var _loc1_:* = 0;
         if(mDungeonRewardElements == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].clear();
            _loc1_++;
         }
      }
      
      public function removeChestFromInventory(chestInfo:ChestInfo) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmId == chestInfo.gmId)
            {
               mDungeonRewardElements[_loc2_].empty();
            }
            _loc2_++;
         }
      }
      
      public function show() : void
      {
         mRewardPanel.visible = true;
      }
      
      public function hide() : void
      {
         mRewardPanel.visible = false;
      }
      
      public function highlightChest(chestInfo:ChestInfo) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < mDungeonRewardElements.length)
         {
            if(mDungeonRewardElements[_loc2_].chestInfo.gmId == chestInfo.gmId)
            {
               mDungeonRewardElements[_loc2_].select();
            }
            else
            {
               mDungeonRewardElements[_loc2_].deSelect();
            }
            _loc2_++;
         }
      }
      
      public function clearHighlights() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].deSelect();
            _loc1_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:* = 0;
         mDungeonSummary = null;
         mRewardPanel = null;
         mDBFacade = null;
         mSelectedCallback = null;
         mAssetLoadingComponent = null;
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].destroy();
            _loc1_++;
         }
         mDungeonRewardElements = null;
      }
   }
}

