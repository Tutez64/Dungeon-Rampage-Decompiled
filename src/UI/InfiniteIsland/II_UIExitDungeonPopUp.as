package UI.InfiniteIsland
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.Render.MovieClipRenderController;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMDoober;
   import GeneratedCode.InfiniteRewardData;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   
   public class II_UIExitDungeonPopUp extends DBUITwoButtonPopup
   {
      
      protected static const SWF_SCREEN_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const POPUP_CLASS_NAME:String = "exitdungeon_infinite_popup";
      
      protected static const SWF_DOOBER_PATH:String = "Resources/Art2D/Doobers/db_items_doobers.swf";
      
      protected static const SWF_ITEM_PATH:String = "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      protected static const CHEST_COMMON_CLASS_NAME:String = "db_doobers_treasure_chest_basic";
      
      protected static const CHEST_UNCOMMON_CLASS_NAME:String = "db_doobers_treasure_chest_uncommon";
      
      protected static const CHEST_RARE_CLASS_NAME:String = "db_doobers_treasure_chest_rare";
      
      protected static const CHEST_LEGENDARY_CLASS_NAME:String = "db_doobers_treasure_chest_legendary";
      
      protected static const LOOT_SMALL_CLASS_NAME:String = "db_doobers_itemBox_small";
      
      protected static const LOOT_ROYAL_CLASS_NAME:String = "db_doobers_itemBox_royal";
      
      private var mDooberAsset:SwfAsset;
      
      private var mItemAsset:SwfAsset;
      
      private var mCommonChestClass:Class;
      
      private var mUncommonChestClass:Class;
      
      private var mRareChestClass:Class;
      
      private var mLegendaryChestClass:Class;
      
      private var mSmallLootClass:Class;
      
      private var mRoyalLootClass:Class;
      
      private var mCurrentRewardTF:TextField;
      
      private var mCoinTF:TextField;
      
      private var mRewardChests:Vector.<MovieClip>;
      
      private var mRewardSlots:Vector.<MovieClip>;
      
      private var mEventComponent:EventComponent;
      
      public function II_UIExitDungeonPopUp(dbFacade:DBFacade, leftCallback:Function, rightCallback:Function)
      {
         super(dbFacade,Locale.getString("UI_HUD_EXIT_TITLE"),Locale.getString("II_UI_HUD_EXIT_MESSAGE"),Locale.getString("UI_HUD_EXIT_CONFIRM"),leftCallback,Locale.getString("UI_HUD_EXIT_CANCEL"),rightCallback);
         mEventComponent = new EventComponent(mDBFacade);
         mCurrentRewardTF = mPopup.current_reward.label_currentReward;
         mCoinTF = mPopup.coin_count;
         mRewardSlots = new Vector.<MovieClip>();
         mRewardSlots.push(mPopup.current_reward.loot_01);
         mRewardSlots.push(mPopup.current_reward.loot_02);
         mRewardSlots.push(mPopup.current_reward.loot_03);
         mRewardSlots.push(mPopup.current_reward.loot_04);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),itemsLoaded);
      }
      
      private function itemsLoaded(swfAsset:SwfAsset) : void
      {
         mItemAsset = swfAsset;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),doobersLoaded);
      }
      
      private function doobersLoaded(swfAsset:SwfAsset) : void
      {
         mCommonChestClass = swfAsset.getClass("db_doobers_treasure_chest_basic");
         mUncommonChestClass = swfAsset.getClass("db_doobers_treasure_chest_uncommon");
         mRareChestClass = swfAsset.getClass("db_doobers_treasure_chest_rare");
         mLegendaryChestClass = swfAsset.getClass("db_doobers_treasure_chest_legendary");
         mSmallLootClass = swfAsset.getClass("db_doobers_itemBox_small");
         mRoyalLootClass = swfAsset.getClass("db_doobers_itemBox_royal");
         mDooberAsset = swfAsset;
         init();
      }
      
      private function init() : void
      {
         var _loc1_:* = null;
         var _loc3_:Boolean = false;
         var _loc4_:GMDoober = null;
         var _loc8_:GMChest = null;
         var _loc2_:Class = null;
         var _loc9_:Class = null;
         var _loc5_:MovieClip = null;
         var _loc7_:MovieClipRenderController = null;
         mCurrentRewardTF.text = Locale.getString("II_DINGELPUS_EXIT_POPUP_CURRENT_REWARD");
         mRewardChests = new Vector.<MovieClip>();
         var _loc11_:HeroGameObjectOwner = mDBFacade.gameObjectManager.getReferenceFromId(mDBFacade.dbAccountInfo.activeAvatarInfo.id) as HeroGameObjectOwner;
         var _loc10_:Vector.<InfiniteRewardData> = _loc11_.distributedDungeonFloor.parentArea.infiniteRewardData;
         var _loc12_:int = _loc11_.distributedDungeonFloor.parentArea.infiniteTotalGold;
         var _loc6_:int = 0;
         for each(_loc1_ in _loc10_)
         {
            if(_loc6_ < mRewardSlots.length)
            {
               _loc3_ = false;
               if(_loc1_.status == 1)
               {
                  _loc3_ = true;
               }
               else
               {
                  if(_loc1_.status == 0)
                  {
                     break;
                  }
                  if(_loc1_.status == 3)
                  {
                     continue;
                  }
               }
               _loc4_ = mDBFacade.gameMaster.dooberById.itemFor(_loc1_.dooberId);
               _loc8_ = mDBFacade.gameMaster.chestsById.itemFor(_loc4_.ChestId);
               _loc2_ = mDooberAsset.getClass(_loc4_.AssetClassName);
               _loc9_ = mItemAsset.getClass(_loc8_.IconName);
               _loc5_ = new _loc9_();
               if(_loc6_ == 0)
               {
                  _loc5_.scaleY = 0.57;
                  _loc5_.scaleX = 0.57;
               }
               else
               {
                  _loc5_.scaleY = 0.72;
                  _loc5_.scaleX = 0.72;
               }
               if(_loc3_)
               {
                  desaturate(_loc5_);
               }
               _loc7_ = new MovieClipRenderController(mDBFacade,_loc5_);
               _loc7_.loop = false;
               _loc7_.stop();
               mRewardSlots[_loc6_].addChild(_loc5_);
               mRewardSlots[_loc6_].loot.visible = false;
               mRewardChests.push(_loc5_);
            }
            _loc6_++;
         }
         mPopup.current_reward.coin_count.text = _loc12_.toString();
      }
      
      public function desaturate(obj:DisplayObject) : void
      {
         var _loc2_:Number = 0.212671;
         var _loc5_:Number = 0.71516;
         var _loc3_:Number = 0.072169;
         var _loc6_:Number = 0.7;
         var _loc4_:Number = 0.6;
         var _loc7_:Number = 0.5;
         var _loc8_:Array = [_loc2_ * _loc6_,_loc5_ * _loc6_,_loc3_ * _loc6_,0,0,_loc2_ * _loc4_,_loc5_ * _loc4_,_loc3_ * _loc4_,0,0,_loc2_ * _loc7_,_loc5_ * _loc7_,_loc3_ * _loc7_,0,0,0,0,0,1,0];
         obj.filters = [new ColorMatrixFilter(_loc8_)];
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "exitdungeon_infinite_popup";
      }
      
      override public function destroy() : void
      {
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }
}

