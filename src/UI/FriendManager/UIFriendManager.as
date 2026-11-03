package UI.FriendManager
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIRadioButton;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Collections.IMapIterator;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Town.TownHeader;
   import Town.TownStateMachine;
   import UI.FriendManager.States.UIBlocked;
   import UI.FriendManager.States.UIFMState;
   import UI.FriendManager.States.UIFriends;
   import UI.FriendManager.States.UIInvite;
   import UI.FriendManager.States.UIPending;
   import UI.UINewsFeed.UINewsFeedController;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   
   public class UIFriendManager
   {
      
      public static const ERROR_TOO_MANY_FRIENDS:int = -290;
      
      public static const STATE_FRIENDS:uint = 1;
      
      public static const STATE_PENDING:uint = 2;
      
      public static const STATE_BLOCKED:uint = 3;
      
      public static const STATE_INVITE:uint = 4;
      
      public static var FRIENDSHIP_MADE:String = "FRIENDSHIP_MADE";
      
      private static const TAB_NAVIGATION_ORDER:Vector.<uint> = new <uint>[1,4,2,3];
      
      private var mDBFacade:DBFacade;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mRoot:MovieClip;
      
      private var mTownHeader:TownHeader;
      
      private var mSwfAsset:SwfAsset;
      
      public var states:Map;
      
      public var currentState:int = -1;
      
      private var mTabButtons:Map;
      
      private var mStateLayer:MovieClip;
      
      private var mAlert:MovieClip;
      
      private var mAlertRenderer:MovieClipRenderController;
      
      protected var mNewsFeedController:UINewsFeedController;
      
      public function UIFriendManager(dbFacade:DBFacade, townStateMachine:TownStateMachine, rootClip:MovieClip)
      {
         super();
         mDBFacade = dbFacade;
         mSwfAsset = townStateMachine.townSwf;
         mTownHeader = townStateMachine.townHeader;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIFriendManager");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIFriendManager");
         states = new Map();
         states.add(1,new UIFriends(this,mDBFacade,townStateMachine));
         states.add(4,new UIInvite(this,mDBFacade,townStateMachine));
         states.add(2,new UIPending(this,mDBFacade,townStateMachine));
         states.add(3,new UIBlocked(this,mDBFacade,townStateMachine));
         if(!mNewsFeedController)
         {
            mNewsFeedController = new UINewsFeedController(mDBFacade);
         }
         mNewsFeedController.startFeedTask();
         setupUI(rootClip);
      }
      
      public static function createFriendRPCErrorCallback(dbFacade:DBFacade, contextName:String) : Function
      {
         return function(param1:Error):void
         {
            handleFriendError(param1,dbFacade,contextName);
         };
      }
      
      public static function handleFriendError(e:Error, dbFacade:DBFacade, contextName:String = null) : void
      {
         var _loc4_:String = contextName ? contextName : "FriendRPC";
         if(e.errorID == -290)
         {
            Logger.warn(_loc4_ + " failed with too many friends: " + e.message);
            dbFacade.errorPopup(Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_TITLE"),Locale.getString("DRINVITE_FAILED_TOO_MANY_FRIENDS_POPUP_DESC") + e.message,"TOO_MANY_FRIENDS_POPUP");
         }
         else
         {
            Logger.error(_loc4_ + " failed with error code: " + e.errorID + " and message: " + e.message,e);
         }
      }
      
      private function setupUI(rootClip:MovieClip) : void
      {
         var tabButton:UIRadioButton;
         var tabInt:uint;
         var iter:IMapIterator;
         mRoot = rootClip;
         mTabButtons = new Map();
         var group:String = "UIFriendsTabGroup";
         mTabButtons.add(1,new UIRadioButton(mDBFacade,mRoot.tab_friends,group));
         mTabButtons.add(4,new UIRadioButton(mDBFacade,mRoot.tab_invite,group));
         mTabButtons.add(2,new UIRadioButton(mDBFacade,mRoot.tab_pending,group));
         mTabButtons.add(3,new UIRadioButton(mDBFacade,mRoot.tab_blocked,group));
         iter = mTabButtons.iterator() as IMapIterator;
         while(iter.hasNext())
         {
            tabButton = iter.next();
            tabInt = iter.key;
            Locale.setText(tabButton.label,"FRIEND_MANAGEMENT_TAB_" + tabInt.toString());
            tabButton.root.category = tabInt;
            tabButton.root.new_label.visible = false;
            tabButton.releaseCallbackThis = function(param1:UIButton):void
            {
               changeTab(param1 as UIRadioButton);
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mStateLayer = new MovieClip();
         mRoot.addChild(mStateLayer);
         mAlert = mRoot.tab_pending.alert_icon;
         mAlertRenderer = new MovieClipRenderController(mDBFacade,mAlert);
         mAlertRenderer.play(0,true);
         mAlert.visible = false;
      }
      
      public function enableTabButton(state:uint) : void
      {
         var _loc2_:UIRadioButton = mTabButtons.itemFor(state);
         _loc2_.root.filters = [new ColorMatrixFilter()];
         if(state == 2)
         {
         }
      }
      
      public function disableTabButton(state:uint) : void
      {
         var _loc2_:UIRadioButton = mTabButtons.itemFor(state);
         var _loc3_:Number = 0.212671;
         var _loc5_:Number = 0.71516;
         var _loc4_:Number = 0.072169;
         var _loc6_:Array = [];
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([_loc3_,_loc5_,_loc4_,0,0]);
         _loc6_ = _loc6_.concat([0,0,0,1,0]);
         _loc2_.root.filters = [new ColorMatrixFilter(_loc6_)];
      }
      
      public function init(state:uint) : void
      {
         mTabButtons.itemFor(state).selected = true;
         changeState(state);
      }
      
      public function animateEntry() : void
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock):void
            {
               mTownHeader.animateHeader();
            });
         }
      }
      
      public function changeTab(radioButton:UIRadioButton) : void
      {
         var wrappedCallBack:Function;
         radioButton.selected = true;
         wrappedCallBack = function():void
         {
            changeState(radioButton.root.category);
         };
         wrappedCallBack();
      }
      
      public function changeState(newState:uint) : void
      {
         if(currentState == newState)
         {
            return;
         }
         if(currentState > -1)
         {
            states.itemFor(currentState).exit();
         }
         currentState = newState;
         states.itemFor(currentState).enter();
         linkTabsToCurrentState();
      }
      
      public function showPreviousTab() : void
      {
         showAdjacentTab(-1);
      }
      
      public function showNextTab() : void
      {
         showAdjacentTab(1);
      }
      
      private function showAdjacentTab(direction:int) : void
      {
         var _loc5_:int = TAB_NAVIGATION_ORDER.indexOf(currentState);
         if(_loc5_ < 0)
         {
            return;
         }
         var _loc4_:int = (_loc5_ + direction + TAB_NAVIGATION_ORDER.length) % TAB_NAVIGATION_ORDER.length;
         var _loc3_:UIRadioButton = mTabButtons.itemFor(TAB_NAVIGATION_ORDER[_loc4_]);
         changeTab(_loc3_);
         var _loc2_:UIObject = (states.itemFor(currentState) as UIFMState).getFirstNavigationUIObject();
         if(_loc2_ != null && _loc2_.canBeFocused())
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc2_);
         }
         else if(_loc3_.canBeFocused())
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc3_);
         }
      }
      
      public function setupMenuNavigation() : void
      {
         var _loc3_:UIRadioButton = mTabButtons.itemFor(1);
         var _loc4_:UIRadioButton = mTabButtons.itemFor(4);
         var _loc1_:UIRadioButton = mTabButtons.itemFor(2);
         var _loc2_:UIRadioButton = mTabButtons.itemFor(3);
         _loc3_.isToTheLeftOf(_loc4_);
         _loc4_.isToTheLeftOf(_loc1_);
         _loc1_.isToTheLeftOf(_loc2_);
         mTownHeader.addCoinButton.isAbove(_loc3_);
         _loc4_.upNavigation = mTownHeader.addCoinButton;
         mTownHeader.addGemButton.isAbove(_loc1_);
         mTownHeader.closeButton.isAbove(_loc2_);
         linkTabsToCurrentState();
      }
      
      public function resetMenuNavigation() : void
      {
         var _loc2_:UIRadioButton = null;
         var _loc1_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.clearNavigationAndInteractions();
            _loc2_.setFocused(false);
         }
      }
      
      public function get currentTabButton() : UIRadioButton
      {
         if(currentState < 0)
         {
            return null;
         }
         return mTabButtons.itemFor(currentState);
      }
      
      public function linkTabsToCurrentState() : void
      {
         var _loc2_:UIRadioButton = null;
         var _loc3_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc2_ = _loc3_.next();
            _loc2_.clearDownNavigation();
         }
         if(currentState < 0)
         {
            return;
         }
         var _loc1_:UIObject = (states.itemFor(currentState) as UIFMState).getFirstNavigationUIObject();
         if(_loc1_ == null)
         {
            return;
         }
         _loc3_ = mTabButtons.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc2_ = _loc3_.next();
            _loc2_.downNavigation = _loc1_;
         }
         _loc1_.clearUpNavigation();
         _loc1_.upNavigation = mTabButtons.itemFor(currentState);
      }
      
      public function updateHeading(str:String) : void
      {
         TextUtil.setText(mRoot.avatar_heading_text,str);
      }
      
      public function updateDescription(str:String, selectable:Boolean = false) : void
      {
         TextUtil.setText(mRoot.avatar_description_text,str,2.73);
         TextUtil.fitToField(mRoot.avatar_description_text);
         mRoot.avatar_description_text.selectable = selectable;
      }
      
      public function cleanUp() : void
      {
         if(currentState > -1)
         {
            states.itemFor(currentState).exit();
            currentState = -1;
         }
      }
      
      public function set alert(val:Boolean) : void
      {
         mAlert.visible = val;
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function addToUI(mc:MovieClip) : void
      {
         mStateLayer.addChild(mc);
      }
      
      public function removeFromUI(mc:MovieClip) : void
      {
         mStateLayer.removeChild(mc);
      }
      
      public function clearUI() : void
      {
         while(mStateLayer.numChildren > 0)
         {
            mStateLayer.removeChild(mStateLayer.getChildAt(mStateLayer.numChildren - 1));
         }
      }
      
      public function setPendingList(pending:Array) : void
      {
         Logger.debug("setPending");
         if(states.itemFor(2) != null)
         {
            states.itemFor(2).pendingFriendRequests = pending;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:UIRadioButton = null;
         var _loc3_:UIFMState = null;
         var _loc1_:IMapIterator = mTabButtons.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
            mAlertRenderer = null;
         }
         cleanUp();
         var _loc4_:IMapIterator = states.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc3_ = _loc4_.next() as UIFMState;
            if(_loc3_)
            {
               _loc3_.destroy();
            }
         }
         states.clear();
         states = null;
         mDBFacade = null;
         mSwfAsset = null;
         mTownHeader = null;
         if(mNewsFeedController)
         {
            mNewsFeedController.destroy();
            mNewsFeedController = null;
         }
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         mLogicalWorkComponent.destroy();
      }
   }
}

