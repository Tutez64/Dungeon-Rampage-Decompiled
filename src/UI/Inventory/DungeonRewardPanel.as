package UI.Inventory
{
   import Account.ChestInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.UI.UIObject;
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
         var _loc5_:uint = 0;
         var _loc4_:uint = 0;
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
         var _loc2_:uint = 0;
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
         var _loc1_:uint = 0;
         if(mDungeonRewardElements == null)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].destroy();
            _loc1_++;
         }
         mDungeonRewardElements = null;
      }
      
      public function removeChestFromInventory(chestInfo:ChestInfo) : void
      {
         var _loc2_:uint = 0;
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
         var _loc2_:uint = 0;
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
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < mDungeonRewardElements.length)
         {
            mDungeonRewardElements[_loc1_].deSelect();
            _loc1_++;
         }
      }
      
      public function setupChestCardNavigation(abandonButton:UIObject, keepButton:UIObject, selectedChest:ChestInfo) : UIObject
      {
         var _loc4_:DungeonRewardElement = null;
         var _loc5_:uint = 0;
         var _loc6_:DungeonRewardElement = null;
         _loc5_ = 0;
         while(_loc5_ < mDungeonRewardElements.length)
         {
            _loc6_ = mDungeonRewardElements[_loc5_];
            _loc6_.clearNavigationAndInteractions();
            if(_loc5_ == 0)
            {
               abandonButton.downNavigation = _loc6_;
               _loc6_.upNavigation = abandonButton;
            }
            else if(_loc5_ == 1)
            {
               keepButton.downNavigation = _loc6_;
               _loc6_.upNavigation = keepButton;
            }
            if(_loc4_ != null)
            {
               _loc4_.isToTheLeftOf(_loc6_);
            }
            _loc4_ = _loc6_;
            _loc5_++;
         }
         return getNavigationEntry(selectedChest);
      }
      
      public function getNavigationEntry(selectedChest:ChestInfo) : UIObject
      {
         var _loc2_:DungeonRewardElement = null;
         for each(var _loc3_:DungeonRewardElement in mDungeonRewardElements)
         {
            if(_loc2_ == null)
            {
               _loc2_ = _loc3_;
            }
            if(selectedChest != null && _loc3_.chestInfo.gmId == selectedChest.gmId)
            {
               return _loc3_;
            }
         }
         return _loc2_;
      }
      
      public function setupInventoryChestNavigation(abandonButton:UIObject) : void
      {
         var _loc2_:DungeonRewardElement = null;
         var _loc3_:uint = 0;
         var _loc4_:DungeonRewardElement = null;
         _loc3_ = 0;
         while(_loc3_ < mDungeonRewardElements.length)
         {
            _loc4_ = mDungeonRewardElements[_loc3_];
            _loc4_.clearNavigationAndInteractions();
            if(_loc3_ == 0)
            {
               abandonButton.downNavigation = _loc4_;
               _loc4_.upNavigation = abandonButton;
            }
            if(_loc2_ != null)
            {
               _loc2_.isToTheLeftOf(_loc4_);
            }
            _loc2_ = _loc4_;
            _loc3_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:uint = 0;
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

