package UI.FriendManager
{
   import Account.FriendInfo;
   import Account.PlayerSpecialStatus;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIToggleButton;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.Portrait.PlayerPortraitView;
   import UI.Portrait.PlayerPortraits;
   import UI.UIPagingPanel;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class FriendPopulater
   {
      
      public static const TOTAL_IN_ROW:uint = 5;
      
      public static const TOTAL_IN_COL:uint = 3;
      
      public static const FRIEND_POPULATER_POS_X:Number = 732.9;
      
      public static const FRIEND_POPULATER_POS_Y:Number = 542.15;
      
      public static const SELECTION_OPTIONS_POS_X:Number = 358.7;
      
      public static const SELECTION_OPTIONS_POS_Y:Number = 482.85;
      
      public static const FRIEND_POPULATER_CLASS:String = "friends_populater";
      
      private var mPortraits:PlayerPortraits = new PlayerPortraits();
      
      public var SelectAllButtonSelected:Boolean = false;
      
      public var NoneButtonSelected:Boolean = false;
      
      private var mFriendPopulaterMC:MovieClip;
      
      private var mPagination:UIPagingPanel;
      
      private var mCurrentPage:uint;
      
      private var mTotalPages:uint;
      
      private var mDBFacade:DBFacade;
      
      private var mUIFriendManager:UIFriendManager;
      
      private var mTownStateMachine:TownStateMachine;
      
      private var mListOfFriends:Vector.<FriendInfo>;
      
      private var mListOfFriendSlots:Vector.<MovieClip>;
      
      private var mFriendSelectedToggles:Map;
      
      private var mFriendsSelectedAcrossPages:Map;
      
      private var togglesSelectedArray:Array;
      
      private var mSelectAllButton:UIButton;
      
      private var mSelectNoneButton:UIButton;
      
      private var mUIObjectAboveFriendList:UIObject;
      
      private var mUIObjectBelowFriendListLeft:UIObject;
      
      private var mUIObjectBelowFriendListRight:UIObject;
      
      public function FriendPopulater(dbFacade:DBFacade, townStateMachine:TownStateMachine, listOfFriends:Vector.<FriendInfo>, friendManager:UIFriendManager)
      {
         super();
         mDBFacade = dbFacade;
         mTownStateMachine = townStateMachine;
         mListOfFriends = listOfFriends;
         mUIFriendManager = friendManager;
         mListOfFriendSlots = new Vector.<MovieClip>();
         mFriendSelectedToggles = new Map();
         mFriendsSelectedAcrossPages = new Map();
         togglesSelectedArray = [];
         var _loc5_:Class = mTownStateMachine.getTownAsset("friends_populater");
         mFriendPopulaterMC = new _loc5_();
         mFriendPopulaterMC.x = 732.9;
         mFriendPopulaterMC.y = 542.15;
         mUIFriendManager.addToUI(mFriendPopulaterMC);
         createSelectionOptionsUI();
         createPagination();
      }
      
      private function createSelectionOptionsUI() : void
      {
         mFriendPopulaterMC.fm_selection_options.visible = true;
         Locale.setText(mFriendPopulaterMC.fm_selection_options.txt_select,"SELECT");
         mSelectAllButton = new UIButton(mDBFacade,mFriendPopulaterMC.fm_selection_options.button_all);
         Locale.setText(mFriendPopulaterMC.fm_selection_options.button_all.label,"ALL");
         mSelectAllButton.releaseCallback = selectAllButtonPressed;
         mSelectAllButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mSelectNoneButton = new UIButton(mDBFacade,mFriendPopulaterMC.fm_selection_options.button_none);
         Locale.setText(mFriendPopulaterMC.fm_selection_options.button_none.label,"NONE");
         mSelectNoneButton.releaseCallback = selectNoneButtonPressed;
         mSelectNoneButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
      }
      
      private function createPagination() : void
      {
         mTotalPages = Math.max(1,Math.ceil(mListOfFriends.length / (5 * 3)));
         mPagination = new UIPagingPanel(mDBFacade,0,mFriendPopulaterMC.pagination_friends,mTownStateMachine.townSwf.getClass("pagination_button"),setCurrentPage);
         MemoryTracker.track(mPagination,"UIPagingPanel - created in FriendPopulater.createPagination()");
         setCurrentPage(0);
      }
      
      private function refreshPagination(page:uint) : void
      {
         mPagination.currentPage = mTotalPages ? Math.min(mTotalPages - 1,page) : 0;
         mPagination.numPages = mTotalPages;
         mPagination.visible = true;
      }
      
      private function setCurrentPage(page:uint) : void
      {
         var _loc2_:int = 0;
         mCurrentPage = page;
         refreshPagination(page);
         _loc2_ = 0;
         while(_loc2_ < mListOfFriendSlots.length)
         {
            mUIFriendManager.removeFromUI(mListOfFriendSlots[_loc2_]);
            _loc2_++;
         }
         mListOfFriendSlots.splice(0,mListOfFriendSlots.length);
         mPortraits.clear();
         destroyToggles();
         mFriendSelectedToggles.clear();
         populateUIOnPage(page);
         refreshMenuNavigation();
      }
      
      private function populateFriendSlot(idx:uint, friend:FriendInfo) : void
      {
         var _loc7_:Class = mTownStateMachine.getTownAsset("friend_slot");
         var _loc4_:MovieClip = new _loc7_() as MovieClip;
         var _loc6_:MovieClip = mFriendPopulaterMC.getChildByName("slot_" + idx.toString()) as MovieClip;
         var _loc8_:Point = new Point(mFriendPopulaterMC.x - 732.9,mFriendPopulaterMC.y - 542.15);
         var _loc12_:Point = mDBFacade.designLocalToGlobal(_loc6_,_loc8_);
         var _loc9_:Number = 52.5;
         var _loc11_:Point = new Point(-5,5);
         var _loc10_:Point = _loc4_.friend_pic.transform.matrix.transformPoint(new Point(_loc11_.x + _loc9_ / 2,_loc11_.y + _loc9_ / 2));
         _loc4_.x = _loc12_.x - _loc10_.x;
         _loc4_.y = _loc12_.y - _loc10_.y - 5;
         _loc4_.friend_name.x = _loc10_.x - _loc4_.friend_name.width / 2;
         _loc4_.friend_name.text = friend.name;
         _loc4_.friend_name.textColor = PlayerSpecialStatus.getSpecialTextColor(friend.name,_loc4_.friend_name.textColor);
         var _loc3_:PlayerPortraitView = mPortraits.showFriend(_loc4_.friend_pic,mDBFacade,friend,_loc9_);
         _loc3_.x = _loc11_.x;
         _loc3_.y = _loc11_.y;
         _loc4_.friend_pic.default_pic.visible = false;
         if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(friend.excludeId) < 0)
         {
            _loc4_.gift.visible = false;
         }
         else
         {
            _loc4_.gift.visible = true;
         }
         _loc4_.friend_pic.you_online.visible = false;
         _loc4_.friend_pic.friend_offline.visible = false;
         _loc4_.friend_pic.friend_online.visible = false;
         _loc4_.join.visible = false;
         if(friend.isOnline())
         {
            _loc4_.friend_pic.friend_online.visible = false;
         }
         else
         {
            _loc4_.friend_pic.friend_offline.visible = false;
         }
         TextUtil.setText(_loc4_.friend_level.level,friend.trophies.toString());
         _loc4_.friend_ascension.mouseEnabled = false;
         _loc4_.friend_ascension.mouseChildren = false;
         _loc4_.friend_ascension.visible = friend.ascensionLevel > 0;
         TextUtil.setText(_loc4_.friend_ascension.level,friend.ascensionLevel.toString());
         var _loc13_:Boolean = mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx);
         var _loc5_:UIToggleButton = new UIToggleButton(mDBFacade,idx,_loc4_.friends_toggle,_loc13_,changeToggleStatusCallback);
         _loc5_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mFriendSelectedToggles.add(idx,_loc5_);
         mUIFriendManager.addToUI(_loc4_);
         mListOfFriendSlots.push(_loc4_);
      }
      
      private function changeToggleStatusCallback(idx:uint, selected:Boolean) : void
      {
         if(mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx))
         {
            mFriendsSelectedAcrossPages.removeKey(mCurrentPage * (5 * 3) + idx);
         }
         else
         {
            mFriendsSelectedAcrossPages.add(mCurrentPage * (5 * 3) + idx,selected);
         }
      }
      
      private function populateUIOnPage(pageNum:uint) : void
      {
         mListOfFriendSlots.splice(0,mListOfFriendSlots.length);
         var _loc3_:int = 0;
         var _loc4_:int = pageNum * (5 * 3);
         var _loc2_:uint = _loc4_ + 5 * 3;
         if(_loc2_ > mListOfFriends.length)
         {
            _loc2_ -= _loc2_ - mListOfFriends.length;
         }
         while(_loc4_ < _loc2_)
         {
            populateFriendSlot(_loc3_,mListOfFriends[_loc4_]);
            _loc4_++;
            _loc3_++;
         }
      }
      
      public function refreshGiftedOnCurrentPage() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = mCurrentPage * (5 * 3);
         var _loc1_:int = (mCurrentPage + 1) * (5 * 3) - 1;
         _loc3_ = _loc2_;
         while(_loc3_ < mListOfFriends.length)
         {
            if(_loc3_ > _loc1_)
            {
               break;
            }
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc3_].excludeId) < 0)
            {
               mListOfFriendSlots[_loc3_ - _loc2_].gift.visible = false;
            }
            else
            {
               mListOfFriendSlots[_loc3_ - _loc2_].gift.visible = true;
            }
            _loc3_++;
         }
      }
      
      private function selectAllButtonPressed() : void
      {
         var _loc8_:int = 0;
         var _loc5_:UIToggleButton = null;
         var _loc1_:int = 0;
         var _loc4_:FriendInfo = null;
         var _loc6_:int = 0;
         var _loc7_:FriendInfo = null;
         SelectAllButtonSelected = true;
         NoneButtonSelected = false;
         var _loc3_:int = mCurrentPage * (5 * 3);
         var _loc2_:int = (mCurrentPage + 1) * (5 * 3) - 1;
         _loc8_ = _loc3_;
         while(_loc8_ <= _loc2_)
         {
            _loc5_ = mFriendSelectedToggles.itemFor(_loc8_ - _loc3_);
            if(_loc5_ != null)
            {
               _loc1_ = mCurrentPage * (5 * 3);
               if(_loc1_ <= mListOfFriends.length)
               {
                  if(_loc8_ >= mListOfFriends.length)
                  {
                     break;
                  }
                  _loc4_ = mListOfFriends[_loc8_];
                  if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(_loc4_.excludeId) < 0)
                  {
                     _loc5_.selected = true;
                  }
               }
            }
            _loc8_++;
         }
         _loc6_ = _loc3_;
         while(_loc6_ <= _loc2_)
         {
            if(_loc6_ <= mListOfFriends.length - 1)
            {
               _loc7_ = mListOfFriends[_loc6_];
               if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(_loc7_.excludeId) < 0)
               {
                  mFriendsSelectedAcrossPages.add(_loc6_,true);
               }
            }
            _loc6_++;
         }
      }
      
      private function selectNoneButtonPressed() : void
      {
         var _loc1_:int = 0;
         var _loc2_:UIToggleButton = null;
         SelectAllButtonSelected = false;
         NoneButtonSelected = true;
         _loc1_ = 0;
         while(_loc1_ < mListOfFriendSlots.length)
         {
            _loc2_ = mFriendSelectedToggles.itemFor(_loc1_);
            if(_loc2_ != null)
            {
               _loc2_.selected = false;
            }
            _loc1_++;
         }
         mFriendsSelectedAcrossPages.clear();
      }
      
      public function setupMenuNavigation(upObject:UIObject, downObjectLeft:UIObject, downObjectRight:UIObject = null) : void
      {
         mUIObjectAboveFriendList = upObject;
         mUIObjectBelowFriendListLeft = downObjectLeft;
         mUIObjectBelowFriendListRight = downObjectRight;
         refreshMenuNavigation();
      }
      
      public function getFirstNavigationUIObject() : UIObject
      {
         var _loc1_:UIToggleButton = mFriendSelectedToggles.itemFor(0);
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return mSelectAllButton;
      }
      
      private function refreshMenuNavigation() : void
      {
         if(mUIObjectAboveFriendList == null || mUIObjectBelowFriendListLeft == null)
         {
            return;
         }
         mSelectAllButton.clearNavigationAndInteractions();
         mSelectNoneButton.clearNavigationAndInteractions();
         mPagination.getPageLeftButton.clearNavigationAndInteractions();
         mPagination.getPageRightButton.clearNavigationAndInteractions();
         mUIObjectBelowFriendListLeft.clearUpNavigation();
         if(mUIObjectBelowFriendListRight != null)
         {
            mUIObjectBelowFriendListRight.clearUpNavigation();
         }
         linkFriendGrid();
         linkListControls();
         mUIFriendManager.linkTabsToCurrentState();
         mDBFacade.menuNavigationController.setFocusedUiObject(getFirstNavigationUIObject());
      }
      
      private function linkFriendGrid() : void
      {
         var _loc2_:uint = 0;
         var _loc3_:UIToggleButton = null;
         var _loc4_:UIToggleButton = null;
         var _loc5_:UIToggleButton = null;
         var _loc1_:uint = mListOfFriendSlots.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = mFriendSelectedToggles.itemFor(_loc2_);
            if(_loc3_ != null)
            {
               if(_loc2_ % 5 != 0)
               {
                  _loc4_ = mFriendSelectedToggles.itemFor(_loc2_ - 1);
                  if(_loc4_ != null)
                  {
                     _loc4_.isToTheLeftOf(_loc3_);
                  }
               }
               if(_loc2_ < 5)
               {
                  _loc3_.upNavigation = mUIObjectAboveFriendList;
               }
               else
               {
                  _loc5_ = mFriendSelectedToggles.itemFor(_loc2_ - 5);
                  if(_loc5_ != null)
                  {
                     _loc5_.isAbove(_loc3_);
                  }
               }
               if(_loc2_ + 5 >= _loc1_)
               {
                  _loc3_.downNavigation = mSelectAllButton;
               }
            }
            _loc2_++;
         }
      }
      
      private function linkListControls() : void
      {
         var _loc3_:int = 0;
         mSelectAllButton.isToTheLeftOf(mSelectNoneButton);
         var _loc5_:UIObject = getLastRowFirstToggle();
         if(_loc5_ == null)
         {
            _loc5_ = mUIObjectAboveFriendList;
         }
         mSelectAllButton.upNavigation = _loc5_;
         mSelectNoneButton.upNavigation = _loc5_;
         var _loc2_:Array = getPaginationObjects();
         _loc3_ = 1;
         while(_loc3_ < _loc2_.length)
         {
            UIObject(_loc2_[_loc3_ - 1]).isToTheLeftOf(UIObject(_loc2_[_loc3_]));
            _loc3_++;
         }
         for each(var _loc1_:UIObject in _loc2_)
         {
            _loc1_.upNavigation = mSelectAllButton;
            _loc1_.downNavigation = mUIObjectBelowFriendListLeft;
         }
         var _loc4_:UIObject = getFirstFocusableObject(_loc2_);
         mSelectAllButton.downNavigation = _loc4_ ?? mUIObjectBelowFriendListLeft;
         mSelectNoneButton.downNavigation = _loc4_ ?? mUIObjectBelowFriendListLeft;
         var _loc6_:UIObject = _loc4_ ?? mSelectAllButton;
         mUIObjectBelowFriendListLeft.upNavigation = _loc6_;
         if(mUIObjectBelowFriendListRight != null)
         {
            mUIObjectBelowFriendListRight.upNavigation = _loc6_;
         }
      }
      
      private function getLastRowFirstToggle() : UIObject
      {
         var _loc1_:uint = mListOfFriendSlots.length;
         if(_loc1_ == 0)
         {
            return null;
         }
         var _loc2_:uint = uint((_loc1_ - 1) / 5) * 5;
         return mFriendSelectedToggles.itemFor(_loc2_);
      }
      
      private function getPaginationObjects() : Array
      {
         var _loc3_:int = 0;
         var _loc1_:UIButton = null;
         var _loc2_:Array = [mPagination.getPageLeftButton];
         _loc3_ = 0;
         while(_loc3_ < mPagination.numPageButtons)
         {
            _loc1_ = mPagination.getPageButton(_loc3_);
            if(_loc1_ != null)
            {
               _loc2_.push(_loc1_);
            }
            _loc3_++;
         }
         _loc2_.push(mPagination.getPageRightButton);
         return _loc2_;
      }
      
      private function getFirstFocusableObject(uiObjects:Array) : UIObject
      {
         for each(var _loc2_:UIObject in uiObjects)
         {
            if(_loc2_ != null && _loc2_.canBeFocused())
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getSelectedToggles() : Array
      {
         togglesSelectedArray = mFriendsSelectedAcrossPages.keysToArray();
         return togglesSelectedArray;
      }
      
      public function destroy() : void
      {
         mPortraits.destroy();
         mListOfFriends = null;
         mListOfFriendSlots.splice(0,mListOfFriendSlots.length);
         mListOfFriendSlots = null;
         if(mPagination != null)
         {
            mPagination.destroy();
            mPagination = null;
         }
         mUIFriendManager.removeFromUI(mFriendPopulaterMC);
         mFriendPopulaterMC = null;
         mDBFacade = null;
         mUIFriendManager = null;
         destroyToggles();
         mFriendSelectedToggles = null;
         mFriendsSelectedAcrossPages = null;
         mUIObjectAboveFriendList = null;
         mUIObjectBelowFriendListLeft = null;
         mUIObjectBelowFriendListRight = null;
         togglesSelectedArray = null;
      }
      
      private function destroyToggles() : void
      {
         var _loc2_:UIToggleButton = null;
         var _loc1_:Array = mFriendSelectedToggles.keysToArray();
         for each(var _loc3_:uint in _loc1_)
         {
            _loc2_ = mFriendSelectedToggles.itemFor(_loc3_);
            if(_loc2_ != null)
            {
               _loc2_.destroy();
            }
         }
      }
   }
}

