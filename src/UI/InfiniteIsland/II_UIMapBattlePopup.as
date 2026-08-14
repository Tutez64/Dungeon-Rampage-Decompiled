package UI.InfiniteIsland
{
   import Account.FriendInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIScrollPane;
   import Brain.UI.UISlider;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMDoober;
   import GameMasterDictionary.GMDungeonModifier;
   import GameMasterDictionary.GMInfiniteDungeon;
   import GeneratedCode.InfiniteMapNodeDetail;
   import UI.Map.UIMapBattlePopup;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
   public class II_UIMapBattlePopup extends UIMapBattlePopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const II_POPUP_CLASS_NAME:String = "battle_popup_infinite_island";
      
      protected static const SWF_ITEM_PATH:String = "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      private static const TOTAL_TOP_LEADERBOARD_SLOTS:uint = 20;
      
      private var mFloorModifierLabels:Vector.<UIObject>;
      
      private var mScrollPane:UIScrollPane;
      
      private var mSlider:UISlider;
      
      private var mSliderUpButton:UIButton;
      
      private var mSliderDownButton:UIButton;
      
      private var mChampionsboardFriendSlots:Vector.<II_UIChampionsboardSlot>;
      
      private var mChampionsboardTopSlots:Vector.<II_UIChampionsboardSlot>;
      
      private var mFriends:Vector.<FriendInfo>;
      
      private var mTopScoresBtn:UIButton;
      
      private var mIsChampionsBoardFriends:Boolean;
      
      private var mTopTwentyScores:Map;
      
      private var mItemAsset:SwfAsset;
      
      private var mReadyForChests:Boolean = false;
      
      private var mRewardSlots:Vector.<MovieClip>;
      
      private var mRewardChests:Vector.<MovieClip>;
      
      public function II_UIMapBattlePopup(dbFacade:DBFacade, changeHeroReleaseCallback:Function, changeStatReleaseCallback:Function, changeShopReleaseCallback:Function, battleReleaseCallback:Function, titleText:String)
      {
         super(dbFacade,changeHeroReleaseCallback,changeStatReleaseCallback,changeShopReleaseCallback,battleReleaseCallback,titleText);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),itemsLoaded);
         mTopTwentyScores = new Map();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "battle_popup_infinite_island";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var i:int;
         var friends:Map;
         var friendsKeyArray:Array;
         var key:uint;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.label_killSwitch.text = Locale.getString("KILL_SWITCH");
         mPopup.label_weeklyTopScores.text = Locale.getString("II_WEEKLY_FRIENDS_SCORES");
         mFloorModifierLabels = new Vector.<UIObject>();
         i = 0;
         while(i < 4)
         {
            mFloorModifierLabels.push(new UIObject(mDBFacade,mPopup.getChildByName("floor_modifier_" + (i + 1).toString()) as MovieClip));
            i = i + 1;
         }
         mScrollPane = new UIScrollPane(mDBFacade,mPopup.leaderboard_scroll_panel);
         mSlider = new UISlider(mDBFacade,mPopup.slider,1);
         mSlider.minimum = 500;
         mSlider.maximum = 0;
         mSlider.value = 0;
         mSlider.updateCallback = mScrollPane.scrollToY;
         mSliderUpButton = new UIButton(mDBFacade,mPopup.uparrow);
         mSliderUpButton.releaseCallback = function():void
         {
            mSlider.valueWithCallback = mSlider.value - 20;
         };
         mSliderDownButton = new UIButton(mDBFacade,mPopup.downarrow);
         mSliderDownButton.releaseCallback = function():void
         {
            mSlider.valueWithCallback = mSlider.value + 20;
         };
         mScrollPane.addMouseWheelFunctionality(mSlider,20,mPopup);
         mTopScoresBtn = new UIButton(mDBFacade,mPopup.button_topScores);
         mTopScoresBtn.visible = false;
         mTopScoresBtn.enabled = false;
         mTopScoresBtn.releaseCallback = switchChampionsBoardType;
         friends = mDBFacade.dbAccountInfo.friendInfos;
         friendsKeyArray = friends.keysToArray();
         mChampionsboardFriendSlots = new Vector.<II_UIChampionsboardSlot>();
         mFriends = new Vector.<FriendInfo>();
         i = 0;
         for each(key in friendsKeyArray)
         {
            mFriends.push(friends.itemFor(key));
            mChampionsboardFriendSlots.push(new II_UIChampionsboardSlot(mDBFacade,i++));
         }
         mChampionsboardTopSlots = new Vector.<II_UIChampionsboardSlot>();
         i = 0;
         while(i < 20)
         {
            mChampionsboardTopSlots.push(new II_UIChampionsboardSlot(mDBFacade,i));
            i = i + 1;
         }
         mScrollPane.scrollByY(mSlider.value);
      }
      
      override public function setDungeonDetails() : void
      {
         var _loc3_:int = 0;
         var _loc4_:GMDungeonModifier = null;
         var _loc1_:Function = null;
         super.setDungeonDetails();
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         var _loc2_:InfiniteMapNodeDetail = mDBFacade.getInfiniteDungeonDetailForNodeId(mCurrentDungeon.Id);
         var _loc5_:GMInfiniteDungeon = mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(mCurrentDungeon.InfiniteDungeon);
         _loc3_ = 0;
         while(_loc3_ < _loc2_.modifiers.length)
         {
            mFloorModifierLabels[_loc3_].root.label_floor_modifier.text = Locale.getString("BATTLE_POP_UP_II_FLOOR:") + _loc5_.DModFloorStart[_loc3_].toString();
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_.modifiers.length)
         {
            _loc4_ = mDBFacade.gameMaster.dungeonModifierById.itemFor(_loc2_.modifiers[_loc3_]);
            if(_loc4_)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconFilepath),lateLoadForModifier(_loc3_,_loc4_));
            }
            _loc3_++;
         }
         mIsChampionsBoardFriends = true;
         switchChampionsBoardType();
         mScrollPane.scrollByY(mSlider.value);
         if(!mTopTwentyScores.itemFor(mCurrentDungeon.Id))
         {
            _loc1_ = JSONRPCService.getFunction("getTopTwenty",mDBFacade.rpcRoot + "championsboard");
            _loc1_(mDBFacade.dbAccountInfo.id,mCurrentDungeon.Id,mDBFacade.validationToken,onReceivedTopScores);
         }
         mReadyForChests = true;
         if(mItemAsset != null)
         {
            populateChests();
         }
      }
      
      private function itemsLoaded(swfAsset:SwfAsset) : void
      {
         mItemAsset = swfAsset;
         if(mReadyForChests)
         {
            populateChests();
         }
      }
      
      private function populateChests() : void
      {
         var _loc7_:int = 0;
         var _loc1_:int = 0;
         var _loc3_:GMDoober = null;
         var _loc9_:GMChest = null;
         var _loc10_:Class = null;
         var _loc4_:MovieClip = null;
         var _loc8_:MovieClipRenderController = null;
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         mRewardChests = new Vector.<MovieClip>();
         mRewardSlots = new Vector.<MovieClip>();
         mRewardSlots.push(mPopup.loot_01);
         mRewardSlots.push(mPopup.loot_02);
         mRewardSlots.push(mPopup.loot_03);
         mRewardSlots.push(mPopup.loot_04);
         var _loc11_:GMInfiniteDungeon = mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(mCurrentDungeon.InfiniteDungeon);
         var _loc2_:int = mDBFacade.dbAccountInfo.localFriendInfo.getIIAvatarScoreForNode(mDBFacade.dbAccountInfo.activeAvatarId,mCurrentDungeon.Id);
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            while(mRewardSlots[_loc7_].numChildren > 1)
            {
               mRewardSlots[_loc7_].removeChildAt(1);
            }
            mRewardSlots[_loc7_].loot.visible = true;
            _loc7_++;
         }
         var _loc5_:int = 0;
         for each(var _loc6_:int in _loc11_.RewardFloors)
         {
            _loc1_ = 0;
            if(_loc2_ > _loc6_)
            {
               _loc1_ = _loc11_.FloorRewardsMap.itemFor(_loc6_);
            }
            if(_loc1_)
            {
               _loc3_ = mDBFacade.gameMaster.dooberById.itemFor(_loc1_);
               _loc9_ = mDBFacade.gameMaster.chestsById.itemFor(_loc3_.ChestId);
               _loc10_ = mItemAsset.getClass(_loc9_.IconName);
               _loc4_ = new _loc10_();
               _loc8_ = new MovieClipRenderController(mDBFacade,_loc4_);
               _loc8_.loop = false;
               _loc8_.stop();
               if(_loc1_ == 30104)
               {
                  _loc4_.scaleY = 0.6;
                  _loc4_.scaleX = 0.6;
                  _loc4_.y += 6;
                  _loc4_.x -= 0;
               }
               else
               {
                  _loc4_.scaleY = 0.82;
                  _loc4_.scaleX = 0.82;
                  _loc4_.y += 6;
                  _loc4_.x -= 0;
               }
               mRewardSlots[_loc5_].addChild(_loc4_);
               mRewardSlots[_loc5_].loot.visible = false;
               mRewardChests.push(_loc4_);
               _loc5_++;
            }
         }
      }
      
      private function onReceivedTopScores(result:*) : void
      {
         if(result == false)
         {
            return;
         }
         mTopTwentyScores.add(mCurrentDungeon.Id,new II_ChampionsboardListPerNode(result));
      }
      
      private function switchChampionsBoardType() : void
      {
         var _loc1_:II_ChampionsboardListPerNode = null;
         var _loc2_:II_ChampionsboardTopScore = null;
         mSlider.valueWithCallback = 0;
         var _loc3_:int = 0;
         if(mIsChampionsBoardFriends)
         {
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardTopSlots.length)
            {
               if(mScrollPane.root.contains(mChampionsboardTopSlots[_loc3_].root))
               {
                  mScrollPane.root.removeChild(mChampionsboardTopSlots[_loc3_].root);
               }
               _loc3_++;
            }
            mFriends.sort(sortFriends);
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardFriendSlots.length)
            {
               mChampionsboardFriendSlots[_loc3_].setDungeonDetails(mCurrentDungeon.Id,mFriends[_loc3_],mFriends[_loc3_].id == mDBFacade.dbAccountInfo.id);
               mScrollPane.root.addChild(mChampionsboardFriendSlots[_loc3_].root);
               if(mFriends[_loc3_].id == mDBFacade.dbAccountInfo.id)
               {
                  mSlider.valueWithCallback = _loc3_ * 15.3;
               }
               _loc3_++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardFriendSlots.length)
            {
               if(mScrollPane.root.contains(mChampionsboardFriendSlots[_loc3_].root))
               {
                  mScrollPane.root.removeChild(mChampionsboardFriendSlots[_loc3_].root);
               }
               _loc3_++;
            }
            if(mTopTwentyScores.hasKey(mCurrentDungeon.Id))
            {
               _loc1_ = mTopTwentyScores.itemFor(mCurrentDungeon.Id);
               _loc1_.sort();
               _loc3_ = 0;
               while(_loc3_ < _loc1_.getTotalScores())
               {
                  _loc2_ = _loc1_.getTopScoreForNum(_loc3_);
                  mChampionsboardTopSlots[_loc3_].setDungeonDetailsForTopTwenty(_loc2_.name,_loc2_.score,_loc2_.skinId,_loc2_.weaponsJson);
                  mScrollPane.root.addChild(mChampionsboardTopSlots[_loc3_].root);
                  _loc3_++;
               }
            }
         }
         mPopup.label_weeklyTopScores.text = Locale.getString("II_WEEKLY_FRIENDS_SCORES");
         mTopScoresBtn.label.text = Locale.getString("II_FRIENDS_SCORES");
      }
      
      private function sortFriends(f1:FriendInfo, f2:FriendInfo) : int
      {
         return f2.getIILeaderboardScoreForNode(mCurrentDungeon.Id) - f1.getIILeaderboardScoreForNode(mCurrentDungeon.Id);
      }
      
      private function lateLoadForModifier(index:uint, gmDungeonModifer:GMDungeonModifier) : Function
      {
         return function(param1:SwfAsset):void
         {
            var _loc2_:MovieClip = null;
            mFloorModifierLabels[index].root.label_floor_modifier.text += "\n" + GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifer.Constant);
            var _loc3_:Class = param1.getClass(gmDungeonModifer.IconName);
            if(_loc3_)
            {
               _loc2_ = new _loc3_() as MovieClip;
               _loc2_.scaleX = _loc2_.scaleY = 0.5;
               while(mFloorModifierLabels[index].root.floor_modifier_icon.numChildren > 0)
               {
                  mFloorModifierLabels[index].root.floor_modifier_icon.removeChildAt(0);
               }
               mFloorModifierLabels[index].root.floor_modifier_icon.addChild(_loc2_);
            }
            mFloorModifierLabels[index].tooltip.title_label.text = GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifer.Constant);
            mFloorModifierLabels[index].tooltip.description_label.text = GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION",gmDungeonModifer.Constant);
         };
      }
      
      override public function destroy() : void
      {
         var _loc1_:* = null;
         mScrollPane.destroy();
         mSlider.destroy();
         mSliderUpButton.destroy();
         mSliderDownButton.destroy();
         mScrollPane = null;
         mSlider = null;
         mSliderUpButton = null;
         mSliderDownButton = null;
         if(mChampionsboardFriendSlots)
         {
            for each(_loc1_ in mChampionsboardFriendSlots)
            {
               _loc1_.destroy();
            }
            mChampionsboardFriendSlots = null;
         }
         mFloorModifierLabels = null;
         super.destroy();
      }
   }
}

