package UI.InfiniteIsland
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMDoober;
   import GeneratedCode.InfiniteRewardData;
   import UI.Popup.DBUIPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class II_UIRewardReportPopup extends DBUIPopup
   {
      
      protected static const SWF_SCREEN_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const REPORT_POPUP_CLASS_NAME:String = "infinite_bonusRewards_popup";
      
      protected static const NEWREWARD_POPUP_CLASS_NAME:String = "nextfloor_infinite_popup";
      
      protected static const SWF_DOOBER_PATH:String = "Resources/Art2D/Doobers/db_items_doobers.swf";
      
      protected static const SWF_ITEM_PATH:String = "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      private var mNewDooberId:int;
      
      private var mFloorGold:int;
      
      private var mTotalGold:int;
      
      private var mRewardData:Vector.<InfiniteRewardData>;
      
      private var mNextGoldFloor:int;
      
      private var mNextChestFloor:int;
      
      private var mAvStartScore:int;
      
      private var mCurrentFloorNum:int;
      
      private var mRewardChests:Vector.<MovieClip>;
      
      private var mRewardSlots:Vector.<MovieClip>;
      
      private var mRewardSlotLabels:Vector.<TextField>;
      
      private var mDooberAsset:SwfAsset;
      
      private var mItemAsset:SwfAsset;
      
      private var mTimeRemaining:Number;
      
      private var mCountDownTimer:Timer;
      
      public function II_UIRewardReportPopup(dbFacade:DBFacade, rewardData:Vector.<InfiniteRewardData>, avStartScore:int, totalGold:int, floorGold:int, currentFloorNum:int, timeToShow:Number = 3, titleText:String = "", content:* = null, allowClose:Boolean = true, wantCurtain:Boolean = true, closeCallback:Function = null, useOriginalPopUp:Boolean = false)
      {
         mFloorGold = floorGold;
         mTotalGold = totalGold;
         mCurrentFloorNum = currentFloorNum;
         mAvStartScore = avStartScore;
         mTimeRemaining = timeToShow;
         if(floorGold == 0 && mCurrentFloorNum != 0)
         {
            mNextGoldFloor = avStartScore + 1;
         }
         mRewardData = rewardData;
         for each(var _loc14_:InfiniteRewardData in mRewardData)
         {
            if(_loc14_.status == 3)
            {
               mNewDooberId = _loc14_.dooberId;
            }
            if(_loc14_.status == 0)
            {
               mNextChestFloor = _loc14_.floorNumber;
               break;
            }
         }
         super(dbFacade,titleText,content,allowClose,wantCurtain,closeCallback,useOriginalPopUp);
         mRewardSlots = new Vector.<MovieClip>();
         mRewardSlots.push(mPopup.loot_01);
         mRewardSlots.push(mPopup.loot_02);
         mRewardSlots.push(mPopup.loot_03);
         mRewardSlots.push(mPopup.loot_04);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),doobersLoaded);
      }
      
      private function doobersLoaded(swfAsset:SwfAsset) : void
      {
         mDooberAsset = swfAsset;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),itemsLoaded);
      }
      
      private function itemsLoaded(swfAsset:SwfAsset) : void
      {
         mItemAsset = swfAsset;
         init();
      }
      
      private function init() : void
      {
         var _loc5_:* = null;
         var _loc1_:Boolean = false;
         var _loc11_:GMDoober = null;
         var _loc7_:GMChest = null;
         var _loc13_:Class = null;
         var _loc3_:MovieClip = null;
         var _loc6_:MovieClipRenderController = null;
         var _loc9_:GMDoober = null;
         var _loc2_:Class = null;
         var _loc10_:MovieClip = null;
         var _loc8_:MovieClipRenderController = null;
         var _loc12_:int = 0;
         mRewardChests = new Vector.<MovieClip>();
         var _loc14_:int = 0;
         _loc14_ = mTotalGold;
         var _loc4_:int = 0;
         for each(_loc5_ in mRewardData)
         {
            if(_loc4_ < mRewardSlots.length)
            {
               _loc1_ = false;
               if(_loc5_.status == 0)
               {
                  continue;
               }
               if(_loc5_.status == 1)
               {
                  _loc1_ = true;
               }
               _loc11_ = mDBFacade.gameMaster.dooberById.itemFor(_loc5_.dooberId);
               _loc7_ = mDBFacade.gameMaster.chestsById.itemFor(_loc11_.ChestId);
               _loc13_ = mItemAsset.getClass(_loc7_.IconName);
               _loc3_ = new _loc13_();
               _loc6_ = new MovieClipRenderController(mDBFacade,_loc3_);
               _loc6_.loop = false;
               _loc6_.stop();
               if(_loc4_ == 0)
               {
                  _loc3_.scaleY = 0.55;
                  _loc3_.scaleX = 0.55;
                  _loc3_.y += 0;
                  _loc3_.x -= 0;
               }
               else
               {
                  _loc3_.scaleY = 0.65;
                  _loc3_.scaleX = 0.65;
                  _loc3_.y += 0;
                  _loc3_.x -= 0;
               }
               if(_loc1_)
               {
                  desaturate(_loc3_);
               }
               mRewardSlots[_loc4_].addChild(_loc3_);
               mRewardSlots[_loc4_].loot.visible = false;
               mRewardChests.push(_loc3_);
            }
            _loc4_++;
         }
         mPopup.label_next_bonus_chest.text = "";
         if(mFloorGold || mNewDooberId)
         {
            if(mNewDooberId)
            {
               _loc9_ = mDBFacade.gameMaster.dooberById.itemFor(mNewDooberId);
               _loc2_ = mDooberAsset.getClass(_loc9_.AssetClassName);
               _loc10_ = new _loc2_();
               _loc8_ = new MovieClipRenderController(mDBFacade,_loc10_);
               _loc10_.scaleY = 0.38;
               _loc10_.scaleX = 0.38;
               _loc10_.y += 12;
               _loc8_.play(0,true);
               mPopup.loot_00.addChild(_loc10_);
               mPopup.coin_center.visible = false;
               mPopup.label_coin_count_center.visible = false;
            }
            else
            {
               mPopup.coin.visible = false;
               mPopup.label_coin_count.visible = false;
               mPopup.label_next_bonus_chest.text = Locale.getString("INFINITE_TILL_REWARD") + mNextChestFloor.toString();
            }
            mPopup.loot_00_center.visible = false;
            mPopup.loot_00.loot.visible = false;
            mPopup.label_coin_count_total.text = "x" + mTotalGold.toString();
            mPopup.label_coin_count.text = "x" + mFloorGold.toString();
            mPopup.label_coin_count_center.text = "x" + mFloorGold.toString();
         }
         else
         {
            mPopup.label.text = Locale.getString("INFINITE_BEAT");
            mPopup.label_loot_01.text = "";
            mPopup.label_loot_02.text = "";
            mPopup.label_loot_03.text = "";
            mPopup.label_loot_04.text = "";
            mRewardSlotLabels = new Vector.<TextField>();
            mRewardSlotLabels.push(mPopup.label_loot_01);
            mRewardSlotLabels.push(mPopup.label_loot_02);
            mRewardSlotLabels.push(mPopup.label_loot_03);
            mRewardSlotLabels.push(mPopup.label_loot_04);
            _loc4_ = 0;
            for each(_loc5_ in mRewardData)
            {
               if(_loc5_.status == 1 && _loc5_.floorNumber == mCurrentFloorNum)
               {
                  mRewardSlotLabels[_loc4_].text = Locale.getString("INFINITE_ALREADY_REWARD");
               }
               _loc4_++;
            }
            mPopup.label_next_bonus_coins.text = "";
            if(mNextChestFloor != 0)
            {
               mPopup.label_next_bonus_chest.text = Locale.getString("INFINITE_TILL_REWARD") + mNextChestFloor.toString();
            }
            _loc12_ = mAvStartScore + 1;
            mPopup.label_next_bonus_coins.text = Locale.getString("INFINITE_TILL_GOLD") + _loc12_.toString();
            mPopup.label_coin_count.text = "x" + mFloorGold.toString();
         }
         startCountdown();
      }
      
      private function startCountdown() : void
      {
         if(mCountDownTimer != null)
         {
            endCountdown();
         }
         mTimeRemaining -= 1;
         mPopup.countdown_bounce.countdown.countdown_text.text = "" + int(mTimeRemaining);
         mCountDownTimer = new Timer(1000);
         mCountDownTimer.addEventListener("timer",tickCountdown);
         mCountDownTimer.start();
      }
      
      private function endCountdown() : void
      {
         if(mCountDownTimer != null)
         {
            mCountDownTimer.removeEventListener("timer",tickCountdown);
            mCountDownTimer.stop();
         }
      }
      
      private function tickCountdown(event:TimerEvent) : void
      {
         mPopup.countdown_bounce.countdown.countdown_text.text = "" + int(mTimeRemaining);
         if(mTimeRemaining <= 0)
         {
            endCountdown();
            destroy();
         }
         mTimeRemaining -= 1;
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
         if(mFloorGold || mNewDooberId)
         {
            return "nextfloor_infinite_popup";
         }
         return "infinite_bonusRewards_popup";
      }
      
      override public function destroy() : void
      {
         endCountdown();
         super.destroy();
      }
   }
}

