package UI.FriendManager
{
   import Account.FriendInfo;
   import Account.PlayerSpecialStatus;
   import Brain.UI.UIButton;
   import Brain.UI.UIToggleButton;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownStateMachine;
   import UI.UIPagingPanel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import org.as3commons.collections.Map;
   
   public class FriendPopulater
   {
      
      public static const TOTAL_IN_ROW:uint = 5;
      
      public static const TOTAL_IN_COL:uint = 3;
      
      public static const FRIEND_POPULATER_POS_X:Number = 732.9;
      
      public static const FRIEND_POPULATER_POS_Y:Number = 542.15;
      
      public static const SELECTION_OPTIONS_POS_X:Number = 358.7;
      
      public static const SELECTION_OPTIONS_POS_Y:Number = 482.85;
      
      public static const FRIEND_POPULATER_CLASS:String = "friends_populater";
      
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
         mFriendPopulaterMC.fm_selection_options.txt_select.text = Locale.getString("SELECT");
         mSelectAllButton = new UIButton(mDBFacade,mFriendPopulaterMC.fm_selection_options.button_all);
         mFriendPopulaterMC.fm_selection_options.button_all.label.text = Locale.getString("ALL");
         mSelectAllButton.releaseCallback = selectAllButtonPressed;
         mSelectNoneButton = new UIButton(mDBFacade,mFriendPopulaterMC.fm_selection_options.button_none);
         mFriendPopulaterMC.fm_selection_options.button_none.label.text = Locale.getString("NONE");
         mSelectNoneButton.releaseCallback = selectNoneButtonPressed;
      }
      
      private function createPagination() : void
      {
         mTotalPages = 1 + Math.floor(mListOfFriends.length / (5 * 3));
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
         mFriendSelectedToggles.clear();
         populateUIOnPage(page);
      }
      
      private function populateFriendSlot(idx:uint, friend:FriendInfo) : void
      {
         var _loc8_:Class = mTownStateMachine.getTownAsset("friend_slot");
         var _loc5_:MovieClip = new _loc8_() as MovieClip;
         var _loc7_:MovieClip = mFriendPopulaterMC.getChildByName("slot_" + idx.toString()) as MovieClip;
         var _loc9_:Point = new Point(mFriendPopulaterMC.x - 732.9,mFriendPopulaterMC.y - 542.15);
         _loc5_.x = _loc7_.localToGlobal(_loc9_).x - _loc5_.width / 2 - 3;
         _loc5_.y = _loc7_.localToGlobal(_loc9_).y - _loc5_.height / 2 - 5;
         _loc5_.friend_name.text = friend.name;
         _loc5_.friend_name.textColor = PlayerSpecialStatus.getSpecialTextColor(friend.name,_loc5_.friend_name.textColor);
         var _loc3_:Boolean = true;
         if(mDBFacade.isFacebookPlayer)
         {
            _loc3_ = false;
         }
         var _loc4_:DisplayObject = friend.clonePic();
         _loc4_.x = -5;
         _loc4_.y = 5;
         if(_loc3_)
         {
            _loc4_.scaleX = _loc4_.scaleY = 1.05;
            _loc5_.friend_pic.addChild(_loc4_);
            _loc5_.friend_pic.default_pic.visible = false;
         }
         else
         {
            _loc5_.friend_pic.addChild(_loc4_);
            _loc5_.friend_pic.default_pic.visible = false;
         }
         if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(friend.excludeId) < 0)
         {
            _loc5_.gift.visible = false;
         }
         else
         {
            _loc5_.gift.visible = true;
         }
         _loc5_.friend_pic.you_online.visible = false;
         _loc5_.friend_pic.friend_offline.visible = false;
         _loc5_.friend_pic.friend_online.visible = false;
         _loc5_.join.visible = false;
         if(friend.isOnline())
         {
            _loc5_.friend_pic.friend_online.visible = false;
         }
         else
         {
            _loc5_.friend_pic.friend_offline.visible = false;
         }
         _loc5_.friend_level.level.text = friend.trophies.toString();
         var _loc6_:Boolean = mFriendsSelectedAcrossPages.hasKey(mCurrentPage * (5 * 3) + idx);
         mFriendSelectedToggles.add(idx,new UIToggleButton(mDBFacade,idx,_loc5_.friends_toggle,_loc6_,changeToggleStatusCallback));
         mUIFriendManager.addToUI(_loc5_);
         mListOfFriendSlots.push(_loc5_);
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
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc2_:int = mCurrentPage * (5 * 3);
         var _loc1_:int = (mCurrentPage + 1) * (5 * 3) - 1;
         _loc4_ = _loc2_;
         while(_loc4_ < mListOfFriends.length)
         {
            if(_loc4_ > _loc1_)
            {
               break;
            }
            if(mDBFacade.dbAccountInfo.giftExcludeIds.indexOf(mListOfFriends[_loc4_].excludeId) < 0)
            {
               mListOfFriendSlots[_loc4_ - _loc2_].gift.visible = false;
            }
            else
            {
               mListOfFriendSlots[_loc4_ - _loc2_].gift.visible = true;
            }
            _loc4_++;
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
         while(_loc8_ < _loc2_)
         {
            _loc5_ = mFriendSelectedToggles.itemFor(_loc8_ - _loc3_);
            if(_loc5_ != null)
            {
               _loc1_ = mCurrentPage * (5 * 3);
               if(_loc1_ <= mListOfFriends.length)
               {
                  if(_loc8_ > mListOfFriends.length)
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
         while(_loc6_ < _loc2_)
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
      
      public function getSelectedToggles() : Array
      {
         togglesSelectedArray = mFriendsSelectedAcrossPages.keysToArray();
         return togglesSelectedArray;
      }
      
      public function destroy() : void
      {
         var _loc2_:UIToggleButton = null;
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
         var _loc1_:Array = mFriendSelectedToggles.keysToArray();
         for each(var _loc3_:uint in _loc1_)
         {
            _loc2_ = mFriendSelectedToggles.itemFor(_loc3_);
            _loc2_.destroy();
         }
         mFriendSelectedToggles = null;
         mFriendsSelectedAcrossPages = null;
         togglesSelectedArray = null;
      }
   }
}

