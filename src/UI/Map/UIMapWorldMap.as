package UI.Map
{
   import Account.MapnodeInfo;
   import Actor.FloatingMessage;
   import Actor.Revealer;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.ColorMatrix;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import DBGlobals.DBGlobal;
   import DistributedObjects.MatchMaker;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMColiseumTier;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMInfiniteDungeon;
   import GameMasterDictionary.GMMapNode;
   import Town.TownStateMachine;
   import UI.InfiniteIsland.II_UIMapBattlePopup;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIUltimateRampagePopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   
   public class UIMapWorldMap
   {
      
      private static const MAX_BOING_MAG:Number = 1.45;
      
      private static const BOING_DECAY:Number = 0.5;
      
      private static const BOING_RATE:Number = 2;
      
      private static const SQUASH_BALANCE:Number = 0.75;
      
      private static const SQUASH_RATE:Number = 0.25;
      
      private static const AVATAR_LERP_SPEED:Number = 12;
      
      private static const AVATAR_ARC_HEIGHT:Number = 30;
      
      private static const CUTSCENE_PATH:String = "Resources/Art2D/UI/animatic0104.swf";
      
      private static const CAMERA_LERP_SPEED:Number = 0.2916666666666667;
      
      private static const CAMERA_CENTER_TIMEOUT:Number = 144;
      
      private static const CAMERA_SPEED_SCALE:Number = 1;
      
      private static const LEADERBOARD_HEIGHT:Number = 90;
      
      private static const DRAG_MESSAGE_TIME:Number = 17;
      
      private static const ROOKIE_LEAGUE:uint = 0;
      
      private static const GLADIATOR_LEAGUE:uint = 1;
      
      private static const HEROIC_LEAGUE:uint = 2;
      
      private static const GRINDER_LEAGUE:uint = 3;
      
      private static const INFINITE_ISLAND_LEAGUE:uint = 4;
      
      private static var OPEN_COLOR_MATRIX:ColorMatrix = new ColorMatrix();
      
      private static var CLOSED_COLOR_MATRIX:ColorMatrix = new ColorMatrix();
      
      OPEN_COLOR_MATRIX.adjustBrightness(-20);
      OPEN_COLOR_MATRIX.adjustSaturation(0.75);
      OPEN_COLOR_MATRIX.adjustHue(65);
      CLOSED_COLOR_MATRIX.adjustBrightness(-40);
      CLOSED_COLOR_MATRIX.adjustSaturation(0);
      
      private var mLastKeyboardUpdateFrame:uint = 0;
      
      private var KEYBOARD_FRAME_DELAY_UPDATE:uint = 12;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mDBFacade:DBFacade;
      
      private var mRootMovieClip:MovieClip;
      
      private var mTownSwfAsset:SwfAsset;
      
      private var mMapAvatar:UIMapAvatar;
      
      private var mAvatarList:Array;
      
      private var mAvatarDropShadowList:Array;
      
      private var mSpentKeyMessage:MovieClip;
      
      private var mXPBar:UIProgressBar;
      
      private var mIIBattlePopup:UIMapBattlePopup;
      
      private var mRegularBattlePopup:UIMapBattlePopup;
      
      private var mBattlePopup:UIMapBattlePopup;
      
      private var mInfiniteIslandUnlocked:Boolean;
      
      private var mWantCinematics:Boolean;
      
      private var mMouseTask:Task;
      
      private var mCameraLerpTask:Task;
      
      private var mFriendFadeTask:Task;
      
      private var mCameraTargetX:Number;
      
      private var mCameraTargetY:Number;
      
      private var mCameraVelocityX:Number;
      
      private var mCameraVelocityY:Number;
      
      private var mOldMouseX:Number;
      
      private var mOldMouseY:Number;
      
      private var mMouseVelocityX:Number;
      
      private var mMouseVelocityY:Number;
      
      private var mCurrentNode:GMMapNode;
      
      private var mNodeQueue:Array;
      
      private var mNodePath:Array;
      
      private var mClosedNodeList:Set;
      
      private var mOpenNodeButtons:Map;
      
      private var mLockedNodeButtons:Map;
      
      private var mMapDragTask:Task;
      
      private var mMapNodeClass:Class;
      
      private var mDragMessageRevealer:Revealer;
      
      private var mDragMessageFloater:FloatingMessage;
      
      private var mChooseDungeonMessage:FloatingMessage;
      
      private var mShowedDragMessage:Boolean;
      
      private var mDidDrag:Boolean;
      
      private var mLeagueNameRevealer:Revealer;
      
      private var mDidKeySpentMessage:Boolean;
      
      private var mUnlockSuccessful:Boolean;
      
      private var mUnlockResponseReceived:Boolean;
      
      private var mRevealer:Revealer;
      
      private var mReturnToMapNode:GMMapNode;
      
      private var mMapWidth:Number;
      
      private var mMapHeight:Number;
      
      private var mReturnToTownButton:UIButton;
      
      private var mReturnToTownCallback:Function;
      
      private var mCurrentLeague:uint = 0;
      
      private var mLeftLeagueButton:UIButton;
      
      private var mRightLeagueButton:UIButton;
      
      protected var mTownStateMachine:TownStateMachine;
      
      private var mEpochCountdownTimer:Timer;
      
      public function UIMapWorldMap(dbFacade:DBFacade, rootMovieClip:MovieClip, townSwfAsset:SwfAsset, townStateMachine:TownStateMachine)
      {
         super();
         mDBFacade = dbFacade;
         mTownStateMachine = townStateMachine;
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIMapWorldMap");
         mEventComponent = new EventComponent(mDBFacade);
         mWantCinematics = mDBFacade.dbConfigManager.getConfigBoolean("want_story",true);
         mRootMovieClip = rootMovieClip;
         mTownSwfAsset = townSwfAsset;
         mShowedDragMessage = false;
         mInfiniteIslandUnlocked = false;
      }
      
      public function initialize(tavernCallback:Function, inventoryCallback:Function, shopCallback:Function, townCallback:Function) : void
      {
         var finalLeagueBounds:Rectangle;
         var globalBottomRight:Point;
         var setReturnNode:Function;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"UIMapWorldMap");
         mWorkComponent.doEverySeconds(59,mDBFacade.playerActivityCount.fetchPublicDungeonActivityLevel);
         finalLeagueBounds = mRootMovieClip.worldmap.infinite_island_league.getRect(mRootMovieClip.worldmap.infinite_island_league);
         globalBottomRight = mRootMovieClip.worldmap.infinite_island_league.localToGlobal(finalLeagueBounds.bottomRight);
         mMapWidth = globalBottomRight.x - mRootMovieClip.worldmap.x + 390;
         mMapHeight = mRootMovieClip.worldmap.height;
         mCurrentNode = null;
         mReturnToTownCallback = townCallback;
         setReturnNode = function(param1:Function):Function
         {
            var callback:Function = param1;
            return function():void
            {
               callback();
               mReturnToMapNode = mCurrentNode;
            };
         };
         mIIBattlePopup = new II_UIMapBattlePopup(mDBFacade,setReturnNode(tavernCallback),setReturnNode(inventoryCallback),setReturnNode(shopCallback),this.battleButtonCallback,"MapBattlePopup");
         MemoryTracker.track(mIIBattlePopup,"II_UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
         mIIBattlePopup.animatePopupOut();
         mRegularBattlePopup = new UIMapBattlePopup(mDBFacade,setReturnNode(tavernCallback),setReturnNode(inventoryCallback),setReturnNode(shopCallback),this.battleButtonCallback,"MapBattlePopup");
         MemoryTracker.track(mRegularBattlePopup,"UIMapBattlePopup - created in UIMapWorldMap.UIMapWorldMap()");
         mRegularBattlePopup.animatePopupOut();
         mBattlePopup = mRegularBattlePopup;
         mEventComponent.addListener(MatchMaker.EPOCH_ROLL_OVER_EVENT_NAME,epochRollOverHandler);
         mUnlockResponseReceived = false;
         mUnlockSuccessful = false;
         mDidKeySpentMessage = false;
         mCameraVelocityX = 0;
         mCameraVelocityY = 0;
         mCurrentLeague = 0;
         mMapNodeClass = Object(mRootMovieClip.worldmap.rookie_league.getChildByName("TUTORIAL")).constructor;
         mXPBar = new UIProgressBar(mDBFacade,mRootMovieClip.ui_league.UI_XP.xp_bar);
         mXPBar.dontKillMyChildren = true;
         setXP(mDBFacade.dbAccountInfo.activeAvatarInfo.experience,mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero);
         mRootMovieClip.ui_league.league_01.label.text = Locale.getString("MAP_PAGE_ROOKIE_LEAGUE_LABEL");
         mRootMovieClip.ui_league.league_02.label.text = Locale.getString("MAP_PAGE_GLADIATOR_LEAGUE_LABEL");
         mRootMovieClip.ui_league.league_04.label.text = Locale.getString("MAP_PAGE_CHAMPION_LEAGUE_LABEL");
         mRootMovieClip.ui_league.league_03.label.text = Locale.getString("MAP_PAGE_GRINDER_LEAGUE_LABEL");
         mRootMovieClip.ui_league.league_05.label.text = Locale.getString("MAP_PAGE_INFINITE_LEAGUE_LABEL");
         mLeftLeagueButton = new UIButton(mDBFacade,mRootMovieClip.ui_league.shift_left);
         mLeftLeagueButton.releaseCallback = function():void
         {
            var _loc1_:uint = mCurrentLeague;
            mCurrentLeague = mCurrentLeague > 0 ? mCurrentLeague - 1 : 0;
            if(_loc1_ != mCurrentLeague)
            {
               updateCurrentLeague();
            }
         };
         mRightLeagueButton = new UIButton(mDBFacade,mRootMovieClip.ui_league.shift_right);
         mRightLeagueButton.releaseCallback = function():void
         {
            var _loc1_:uint = mCurrentLeague;
            mCurrentLeague = determineNextLeague();
            if(_loc1_ != mCurrentLeague)
            {
               updateCurrentLeague();
            }
         };
         mRootMovieClip.worldmap.addEventListener("mouseDown",onMouseDown);
         mDBFacade.dbAccountInfo.activeAvatarInfo.loadHeroIcon(function(param1:MovieClip):void
         {
            UIObject.scaleToFit(param1,40);
            mRootMovieClip.ui_league.ui_avatar.addChild(param1);
         });
         clearMouseEnabledOnWorldmap();
         hideAllMapNodes();
         setupMapNodeButtons();
         setupMapNodeLinks();
         if(!mChooseDungeonMessage)
         {
            mWorkComponent.doLater(1,showChooseDungeonMessage);
         }
         if(!mShowedDragMessage)
         {
            mWorkComponent.doEverySeconds(17,function():void
            {
               var dragMessageClass:Class;
               var dragMessage:MovieClip;
               if(!mDidDrag)
               {
                  mShowedDragMessage = true;
                  dragMessageClass = mTownSwfAsset.getClass("Branch_map_drag");
                  dragMessage = new dragMessageClass() as MovieClip;
                  mRootMovieClip.addChild(dragMessage);
                  dragMessage.x = dragMessage.stage.stageWidth / 2;
                  dragMessage.y = dragMessage.stage.stageHeight * 0.4;
                  dragMessage.mouseChildren = false;
                  dragMessage.mouseEnabled = false;
                  dragMessage.alpha = 0;
                  dragMessage.scaleX = dragMessage.scaleY = 0.9;
                  if(mDragMessageRevealer)
                  {
                     mDragMessageRevealer.destroy();
                     mDragMessageRevealer = null;
                  }
                  mDragMessageRevealer = new Revealer(dragMessage,mDBFacade,24,function():void
                  {
                     mDragMessageFloater = new FloatingMessage(dragMessage,mDBFacade,32,48,1.5,0,null,function():void
                     {
                        mRootMovieClip.removeChild(dragMessage);
                     });
                  },1);
               }
            });
         }
         if(mReturnToMapNode)
         {
            moveAvatarToNode(mReturnToMapNode)();
            mReturnToMapNode = null;
         }
         mCameraTargetY = -156;
         mRootMovieClip.worldmap.x = mCameraTargetX;
         mRootMovieClip.worldmap.y = mCameraTargetY;
         updateCurrentLeague();
         clampMap();
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_PLAY_MAP_NODE",false))
         {
            setUpHacksToPlayNode();
         }
         mWorkComponent.doEveryFrame(keyboardCheck);
      }
      
      private function setupMapNodeLinks() : void
      {
         var _loc8_:int = 0;
         var _loc9_:* = 0;
         var _loc4_:GMMapNode = null;
         var _loc7_:UIButton = null;
         var _loc5_:* = 0;
         var _loc6_:UIButton = null;
         var _loc2_:* = 0;
         var _loc3_:UIButton = null;
         var _loc1_:Array = mOpenNodeButtons.keysToArray();
         _loc1_.sort(16);
         setupMapNodeNavigationUltimateRampage();
         _loc8_ = 0;
         while(_loc8_ < _loc1_.length)
         {
            _loc9_ = uint(_loc1_[_loc8_]);
            if(mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc9_))
            {
               _loc4_ = mDBFacade.gameMaster.mapNodeById.itemFor(_loc9_);
               if(_loc4_.IsInfiniteDungeon)
               {
                  break;
               }
               _loc7_ = mOpenNodeButtons.itemFor(_loc9_);
               _loc5_ = uint(_loc8_ > 0 ? _loc1_[_loc8_ - 1] : 0);
               if(_loc5_ > 0)
               {
                  _loc6_ = mOpenNodeButtons.itemFor(_loc5_);
                  if(_loc6_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc5_))
                  {
                     _loc7_.leftNavigation = _loc6_;
                  }
               }
               _loc2_ = uint(_loc8_ < _loc1_.length - 1 ? _loc1_[_loc8_ + 1] : 0);
               if(_loc2_ > 0)
               {
                  _loc3_ = mOpenNodeButtons.itemFor(_loc2_);
                  if(_loc3_ != null && mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.hasKey(_loc2_) && _loc2_ != 50150)
                  {
                     _loc7_.rightNavigation = _loc3_;
                  }
               }
            }
            _loc8_++;
         }
         setupMapNodeMenuNavigationLeagueChangeTriggers();
         setupMapNodeNavigationGladiatorLeaguePrisonPath();
         setupMapNodeNavigationGladiatorLeagueCretaceousPath();
         setupMapNodeNavigationGladiatorLeagueFrostguardPath();
         setupMapNodeNavigationChampionLeagueKnightFortressPath();
      }
      
      private function setupMapNodeMenuNavigationLeagueChangeTriggers() : void
      {
         mOpenNodeButtons.itemFor(50020).rightNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(1);
         };
         mOpenNodeButtons.itemFor(50021).leftNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(0);
         };
         mOpenNodeButtons.itemFor(50051).rightNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(2);
         };
         mOpenNodeButtons.itemFor(50052).leftNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(1);
         };
         mOpenNodeButtons.itemFor(50083).rightNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(3);
         };
         mOpenNodeButtons.itemFor(50084).leftNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(2);
         };
         mOpenNodeButtons.itemFor(50099).rightNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(4);
         };
         mOpenNodeButtons.itemFor(50156).leftNavigationAdditionalInteraction = function():void
         {
            setCurrentLeague(3);
         };
      }
      
      private function setupMapNodeNavigationGladiatorLeaguePrisonPath() : void
      {
         var _loc8_:UIButton = mOpenNodeButtons.itemFor(50026);
         var _loc6_:UIButton = mOpenNodeButtons.itemFor(50027);
         var _loc7_:UIButton = mOpenNodeButtons.itemFor(50028);
         var _loc4_:UIButton = mOpenNodeButtons.itemFor(50029);
         var _loc5_:UIButton = mOpenNodeButtons.itemFor(50030);
         var _loc2_:UIButton = mOpenNodeButtons.itemFor(50031);
         var _loc3_:UIButton = mOpenNodeButtons.itemFor(50032);
         var _loc1_:UIButton = mOpenNodeButtons.itemFor(50033);
         _loc8_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc1_.clearLeftNavigation();
         _loc8_.leftNavigation = mOpenNodeButtons.itemFor(50025);
         _loc5_.isAbove(_loc8_);
         _loc5_.leftNavigation = _loc8_;
         _loc3_.isToTheLeftOf(_loc1_);
         _loc3_.isAbove(_loc2_);
         _loc2_.isToTheLeftOf(_loc3_);
         _loc2_.isAbove(_loc5_);
         _loc5_.isToTheLeftOf(_loc2_);
         _loc8_.isToTheLeftOf(_loc6_);
         _loc6_.isToTheLeftOf(_loc7_);
         _loc7_.isToTheLeftOf(_loc4_);
         _loc4_.rightNavigation = _loc1_;
         _loc1_.isAbove(_loc4_);
      }
      
      private function setupMapNodeNavigationGladiatorLeagueCretaceousPath() : void
      {
         var _loc8_:UIButton = mOpenNodeButtons.itemFor(50036);
         var _loc4_:UIButton = mOpenNodeButtons.itemFor(50037);
         var _loc3_:UIButton = mOpenNodeButtons.itemFor(50038);
         var _loc6_:UIButton = mOpenNodeButtons.itemFor(50039);
         var _loc5_:UIButton = mOpenNodeButtons.itemFor(50040);
         var _loc2_:UIButton = mOpenNodeButtons.itemFor(50041);
         var _loc1_:UIButton = mOpenNodeButtons.itemFor(50042);
         var _loc7_:UIButton = mOpenNodeButtons.itemFor(50043);
         _loc4_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc4_.leftNavigation = _loc8_;
         _loc8_.downNavigation = _loc4_;
         _loc6_.isAbove(_loc4_);
         _loc6_.isToTheLeftOf(_loc5_);
         _loc5_.isAbove(_loc6_);
         _loc4_.isAbove(_loc3_);
         _loc3_.leftNavigation = _loc4_;
         _loc3_.isAbove(_loc2_);
         _loc3_.isToTheLeftOf(_loc2_);
         _loc2_.isAbove(_loc1_);
         _loc2_.isToTheLeftOf(_loc1_);
         _loc1_.isAbove(_loc7_);
         _loc1_.isToTheLeftOf(_loc7_);
      }
      
      private function setupMapNodeNavigationGladiatorLeagueFrostguardPath() : void
      {
         var _loc9_:UIButton = mOpenNodeButtons.itemFor(50044);
         var _loc10_:UIButton = mOpenNodeButtons.itemFor(50045);
         var _loc1_:UIButton = mOpenNodeButtons.itemFor(50046);
         var _loc2_:UIButton = mOpenNodeButtons.itemFor(50047);
         var _loc3_:UIButton = mOpenNodeButtons.itemFor(50048);
         var _loc4_:UIButton = mOpenNodeButtons.itemFor(50049);
         var _loc5_:UIButton = mOpenNodeButtons.itemFor(50050);
         var _loc6_:UIButton = mOpenNodeButtons.itemFor(50051);
         _loc9_.clearNavigationAndInteractions();
         _loc10_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc6_.clearLeftNavigation();
         var _loc7_:UIButton = mOpenNodeButtons.itemFor(50040);
         var _loc8_:UIButton = mOpenNodeButtons.itemFor(50043);
         _loc8_.isToTheLeftOf(_loc9_);
         _loc7_.isToTheLeftOf(_loc3_);
         _loc9_.isToTheLeftOf(_loc10_);
         _loc10_.isAbove(_loc9_);
         _loc10_.isToTheLeftOf(_loc1_);
         _loc1_.isAbove(_loc10_);
         _loc1_.isToTheLeftOf(_loc2_);
         _loc2_.isAbove(_loc1_);
         _loc3_.isToTheLeftOf(_loc4_);
         _loc3_.isAbove(_loc4_);
         _loc4_.isToTheLeftOf(_loc5_);
         _loc4_.isAbove(_loc5_);
         _loc5_.isAbove(_loc2_);
         _loc5_.rightNavigation = _loc2_;
         _loc2_.isToTheLeftOf(_loc6_);
      }
      
      private function setupMapNodeNavigationChampionLeagueKnightFortressPath() : void
      {
         var _loc19_:UIButton = mOpenNodeButtons.itemFor(50064);
         var _loc20_:UIButton = mOpenNodeButtons.itemFor(50065);
         var _loc22_:UIButton = mOpenNodeButtons.itemFor(50066);
         var _loc16_:UIButton = mOpenNodeButtons.itemFor(50067);
         var _loc17_:UIButton = mOpenNodeButtons.itemFor(50068);
         var _loc24_:UIButton = mOpenNodeButtons.itemFor(50069);
         var _loc5_:UIButton = mOpenNodeButtons.itemFor(50070);
         var _loc2_:UIButton = mOpenNodeButtons.itemFor(50071);
         var _loc3_:UIButton = mOpenNodeButtons.itemFor(50072);
         var _loc1_:UIButton = mOpenNodeButtons.itemFor(50073);
         _loc19_.clearNavigationAndInteractions();
         _loc20_.clearNavigationAndInteractions();
         _loc22_.clearNavigationAndInteractions();
         _loc16_.clearNavigationAndInteractions();
         _loc17_.clearNavigationAndInteractions();
         _loc24_.clearNavigationAndInteractions();
         _loc5_.clearNavigationAndInteractions();
         _loc2_.clearNavigationAndInteractions();
         _loc3_.clearNavigationAndInteractions();
         _loc1_.clearNavigationAndInteractions();
         _loc19_.isToTheLeftOf(_loc20_);
         _loc20_.isToTheLeftOf(_loc22_);
         _loc22_.isToTheLeftOf(_loc16_);
         _loc16_.isToTheLeftOf(_loc17_);
         _loc17_.isToTheLeftOf(_loc24_);
         _loc24_.isToTheLeftOf(_loc5_);
         _loc5_.isToTheLeftOf(_loc2_);
         _loc2_.isToTheLeftOf(_loc3_);
         _loc3_.isToTheLeftOf(_loc1_);
         var _loc10_:UIButton = mOpenNodeButtons.itemFor(50057);
         var _loc11_:UIButton = mOpenNodeButtons.itemFor(50058);
         var _loc7_:UIButton = mOpenNodeButtons.itemFor(50059);
         var _loc9_:UIButton = mOpenNodeButtons.itemFor(50060);
         var _loc4_:UIButton = mOpenNodeButtons.itemFor(50061);
         var _loc6_:UIButton = mOpenNodeButtons.itemFor(50062);
         var _loc28_:UIButton = mOpenNodeButtons.itemFor(50063);
         var _loc27_:UIButton = mOpenNodeButtons.itemFor(50074);
         var _loc26_:UIButton = mOpenNodeButtons.itemFor(50075);
         var _loc25_:UIButton = mOpenNodeButtons.itemFor(50076);
         _loc10_.clearNavigationAndInteractions();
         _loc11_.clearNavigationAndInteractions();
         _loc7_.clearNavigationAndInteractions();
         _loc9_.clearNavigationAndInteractions();
         _loc4_.clearNavigationAndInteractions();
         _loc6_.clearNavigationAndInteractions();
         _loc28_.clearNavigationAndInteractions();
         _loc27_.clearNavigationAndInteractions();
         _loc26_.clearNavigationAndInteractions();
         _loc25_.clearNavigationAndInteractions();
         _loc10_.isToTheLeftOf(_loc11_);
         _loc11_.isToTheLeftOf(_loc7_);
         _loc7_.isToTheLeftOf(_loc9_);
         _loc9_.isToTheLeftOf(_loc4_);
         _loc4_.isToTheLeftOf(_loc6_);
         _loc6_.isToTheLeftOf(_loc28_);
         _loc28_.isToTheLeftOf(_loc27_);
         _loc27_.isToTheLeftOf(_loc26_);
         _loc26_.isToTheLeftOf(_loc25_);
         var _loc8_:UIButton = mOpenNodeButtons.itemFor(50077);
         var _loc15_:UIButton = mOpenNodeButtons.itemFor(50078);
         var _loc14_:UIButton = mOpenNodeButtons.itemFor(50079);
         var _loc13_:UIButton = mOpenNodeButtons.itemFor(50080);
         var _loc12_:UIButton = mOpenNodeButtons.itemFor(50081);
         var _loc18_:UIButton = mOpenNodeButtons.itemFor(50082);
         var _loc21_:UIButton = mOpenNodeButtons.itemFor(50083);
         _loc8_.clearNavigationAndInteractions();
         _loc15_.clearNavigationAndInteractions();
         _loc14_.clearNavigationAndInteractions();
         _loc13_.clearNavigationAndInteractions();
         _loc12_.clearNavigationAndInteractions();
         _loc18_.clearNavigationAndInteractions();
         _loc21_.clearLeftNavigation();
         _loc1_.isAbove(_loc8_);
         _loc8_.isAbove(_loc15_);
         _loc8_.isToTheLeftOf(_loc15_);
         _loc15_.isAbove(_loc12_);
         _loc15_.rightNavigation = _loc12_;
         _loc25_.isToTheLeftOf(_loc14_);
         _loc14_.isToTheLeftOf(_loc13_);
         _loc13_.isToTheLeftOf(_loc12_);
         _loc12_.isToTheLeftOf(_loc18_);
         _loc18_.isToTheLeftOf(_loc21_);
         _loc1_.isToTheLeftOf(_loc8_);
         var _loc23_:UIButton = mOpenNodeButtons.itemFor(50056);
         _loc23_.clearRightNavigation();
         _loc19_.isAbove(_loc23_);
         _loc23_.isToTheLeftOf(_loc10_);
         _loc23_.isAbove(mOpenNodeButtons.itemFor(50055));
      }
      
      private function setupMapNodeNavigationUltimateRampage() : void
      {
         var _loc6_:UIButton = mOpenNodeButtons.itemFor(50150);
         var _loc8_:UIButton = mOpenNodeButtons.itemFor(50151);
         var _loc9_:UIButton = mOpenNodeButtons.itemFor(50153);
         var _loc4_:UIButton = mOpenNodeButtons.itemFor(50155);
         var _loc2_:UIButton = mOpenNodeButtons.itemFor(50156);
         var _loc5_:UIButton = mOpenNodeButtons.itemFor(50158);
         var _loc10_:UIButton = mOpenNodeButtons.itemFor(50159);
         var _loc7_:UIButton = mOpenNodeButtons.itemFor(50161);
         var _loc3_:UIButton = mOpenNodeButtons.itemFor(50162);
         var _loc1_:UIButton = mOpenNodeButtons.itemFor(50099);
         _loc3_.isAbove(_loc2_);
         _loc3_.isToTheLeftOf(_loc8_);
         _loc8_.isToTheLeftOf(_loc4_);
         _loc4_.isAbove(_loc6_);
         _loc6_.isAbove(_loc7_);
         _loc5_.isToTheLeftOf(_loc6_);
         _loc10_.isToTheLeftOf(_loc7_);
         _loc9_.isToTheLeftOf(_loc10_);
         _loc2_.isAbove(_loc9_);
         _loc1_.isToTheLeftOf(_loc2_);
      }
      
      public function getCurrentNodeButton() : UIButton
      {
         return mOpenNodeButtons.itemFor(mCurrentNode.Id);
      }
      
      public function getCurrentNodeLeagueValue() : uint
      {
         return getNodeLeagueValue(mCurrentNode);
      }
      
      public function getButtonLeagueView(uiObject:UIObject) : uint
      {
         var _loc5_:int = 0;
         var _loc6_:* = 0;
         var _loc2_:UIButton = null;
         var _loc3_:GMMapNode = null;
         var _loc4_:Array = mOpenNodeButtons.keysToArray();
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = uint(_loc4_[_loc5_]);
            _loc2_ = mOpenNodeButtons.itemFor(_loc6_);
            if(_loc2_ == uiObject)
            {
               _loc3_ = mDBFacade.gameMaster.mapNodeById.itemFor(_loc6_);
               return getNodeLeagueValue(_loc3_);
            }
            _loc5_++;
         }
         return 0;
      }
      
      protected function getNodeLeagueValue(gmMapNode:GMMapNode) : uint
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ <= 4)
         {
            _loc4_ = getLeagueClip(_loc3_);
            _loc2_ = _loc4_.getChildByName(gmMapNode.Constant) as MovieClip;
            if(_loc2_ != null)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return 0;
      }
      
      protected function getLeagueClip(leagueIdx:uint) : MovieClip
      {
         switch(int(leagueIdx))
         {
            case 0:
               return mRootMovieClip.worldmap.rookie_league;
            case 1:
               return mRootMovieClip.worldmap.gladiator_league;
            case 2:
               return mRootMovieClip.worldmap.heroic_league;
            case 3:
               return mRootMovieClip.worldmap.grinder_league;
            case 4:
               return mRootMovieClip.worldmap.infinite_island_league;
            default:
               return null;
         }
      }
      
      public function getCurrentLeagueView() : uint
      {
         return mCurrentLeague;
      }
      
      public function setCurrentLeague(newLeague:uint, doNamePop:Boolean = true) : void
      {
         if(newLeague != mCurrentLeague)
         {
            mCurrentLeague = newLeague;
            updateCurrentLeague(doNamePop);
         }
      }
      
      private function epochRollOverHandler(e:Event) : void
      {
         if(mBattlePopup == mIIBattlePopup)
         {
            mBattlePopup.animatePopupOut();
            setCurrentNode(mCurrentNode);
            mBattlePopup.animatePopupIn();
         }
      }
      
      private function determineNextLeague() : uint
      {
         return mCurrentLeague < 4 ? mCurrentLeague + 1 : 4;
      }
      
      private function keyboardCheck(gameClock:GameClock) : void
      {
      }
      
      private function popLeagueName(clip:MovieClip) : void
      {
         if(mLeagueNameRevealer)
         {
            mLeagueNameRevealer.destroy();
            mLeagueNameRevealer = null;
         }
         clip.scaleX = 1;
         clip.scaleY = 1;
         clip.alpha = 1;
         mLeagueNameRevealer = new Revealer(clip,mDBFacade,10);
      }
      
      private function updateCurrentLeague(doNamePop:Boolean = true) : void
      {
         var _loc2_:DBUIUltimateRampagePopup = null;
         var _loc3_:MovieClip = null;
         mRootMovieClip.ui_league.clock.visible = false;
         mRootMovieClip.ui_league.label_new_dungeon.visible = false;
         mRootMovieClip.ui_league.label_timer.visible = false;
         mRootMovieClip.ui_league.ui_avatar.visible = true;
         mRootMovieClip.ui_league.UI_XP.visible = true;
         endEpochCountdown();
         switch(int(mCurrentLeague))
         {
            case 0:
               mLeftLeagueButton.enabled = false;
               mRightLeagueButton.enabled = true;
               mRootMovieClip.ui_league.league_01.visible = true;
               mRootMovieClip.ui_league.league_02.visible = false;
               mRootMovieClip.ui_league.league_03.visible = false;
               mRootMovieClip.ui_league.league_04.visible = false;
               mRootMovieClip.ui_league.league_05.visible = false;
               centerMapOnClip(mRootMovieClip.worldmap.rookie_league,"ROOKIE");
               _loc3_ = mRootMovieClip.ui_league.league_01;
               break;
            case 1:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               mRootMovieClip.ui_league.league_01.visible = false;
               mRootMovieClip.ui_league.league_02.visible = true;
               mRootMovieClip.ui_league.league_03.visible = false;
               mRootMovieClip.ui_league.league_04.visible = false;
               mRootMovieClip.ui_league.league_05.visible = false;
               centerMapOnClip(mRootMovieClip.worldmap.gladiator_league,"GLADIATOR");
               _loc3_ = mRootMovieClip.ui_league.league_02;
               break;
            case 2:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               mRootMovieClip.ui_league.league_01.visible = false;
               mRootMovieClip.ui_league.league_02.visible = false;
               mRootMovieClip.ui_league.league_03.visible = false;
               mRootMovieClip.ui_league.league_04.visible = true;
               mRootMovieClip.ui_league.league_05.visible = false;
               centerMapOnClip(mRootMovieClip.worldmap.heroic_league,"CHAMPION");
               _loc3_ = mRootMovieClip.ui_league.league_04;
               break;
            case 3:
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = true;
               mRootMovieClip.ui_league.league_01.visible = false;
               mRootMovieClip.ui_league.league_02.visible = false;
               mRootMovieClip.ui_league.league_03.visible = true;
               mRootMovieClip.ui_league.league_04.visible = false;
               mRootMovieClip.ui_league.league_05.visible = false;
               centerMapOnClip(mRootMovieClip.worldmap.grinder_league,"GRINDHOUSE");
               _loc3_ = mRootMovieClip.ui_league.league_03;
               break;
            case 4:
               if(mInfiniteIslandUnlocked && !mDBFacade.dbAccountInfo.hasAttribute("seenUltimatePopup"))
               {
                  mDBFacade.dbAccountInfo.alterAttribute("seenUltimatePopup","1");
                  _loc2_ = new DBUIUltimateRampagePopup(mDBFacade);
                  MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in UIMapWorldMap.setLeague()");
               }
               mLeftLeagueButton.enabled = true;
               mRightLeagueButton.enabled = false;
               mRootMovieClip.ui_league.ui_avatar.visible = false;
               mRootMovieClip.ui_league.UI_XP.visible = false;
               mRootMovieClip.ui_league.league_01.visible = false;
               mRootMovieClip.ui_league.league_02.visible = false;
               mRootMovieClip.ui_league.league_03.visible = false;
               mRootMovieClip.ui_league.league_04.visible = false;
               mRootMovieClip.ui_league.league_05.visible = true;
               mRootMovieClip.ui_league.clock.visible = true;
               mRootMovieClip.ui_league.label_new_dungeon.text = Locale.getString("INFINITE_TIMER_LABEL");
               mRootMovieClip.ui_league.label_new_dungeon.visible = true;
               mRootMovieClip.ui_league.label_timer.visible = true;
               mRootMovieClip.ui_league.label_timer.text = "";
               startEpochCountdown();
               centerMapOnClip(mRootMovieClip.worldmap.infinite_island_league,"INFINITEISLAND");
               _loc3_ = null;
               break;
            default:
               Logger.warn("Map page league paging in borked state");
         }
         if(doNamePop && _loc3_)
         {
            popLeagueName(_loc3_);
         }
      }
      
      private function startEpochCountdown() : void
      {
         mEpochCountdownTimer = new Timer(1000);
         mEpochCountdownTimer.addEventListener("timer",tickEpochCountdown);
         tickEpochCountdown(null);
         mEpochCountdownTimer.start();
      }
      
      private function endEpochCountdown() : void
      {
         if(mEpochCountdownTimer != null)
         {
            mEpochCountdownTimer.removeEventListener("timer",tickEpochCountdown);
            mEpochCountdownTimer.stop();
         }
      }
      
      private function tickEpochCountdown(event:TimerEvent) : void
      {
         var _loc2_:Array = GameClock.getArrayTimeToEpoch();
         var _loc3_:String = "";
         if(_loc2_[4] == 1)
         {
            _loc3_ += _loc2_[4] + " " + Locale.getString("EPOCH_TIMER_WEEK");
         }
         else if(_loc2_[4])
         {
            _loc3_ += _loc2_[4] + " " + Locale.getString("EPOCH_TIMER_WEEKS");
         }
         if(_loc2_[3] == 1)
         {
            _loc3_ += _loc2_[3] + " " + Locale.getString("EPOCH_TIMER_DAY");
         }
         else if(_loc2_[3])
         {
            _loc3_ += _loc2_[3] + " " + Locale.getString("EPOCH_TIMER_DAYS");
         }
         if(_loc2_[4] == 0 && _loc2_[3] == 0)
         {
            _loc3_ = Number(_loc2_[2]) + ":" + zeroPad(_loc2_[1],2) + ":" + zeroPad(_loc2_[0],2);
         }
         mRootMovieClip.ui_league.label_timer.text = _loc3_;
      }
      
      public function zeroPad(number:int, width:int) : String
      {
         var _loc3_:String = "" + number;
         while(_loc3_.length < width)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      private function setXP(xp:uint, gmHero:GMHero) : void
      {
         mXPBar.value = xp;
         var _loc5_:uint = gmHero.getLevelFromExp(xp);
         mRootMovieClip.ui_league.UI_XP.xp_level.text = _loc5_.toString();
         var _loc4_:uint = xp;
         var _loc3_:uint = uint(gmHero.getLevelIndex(xp));
         var _loc7_:uint = uint(_loc3_ > 0 ? gmHero.getExpFromIndex(_loc3_ - 1) : 0);
         var _loc6_:uint = gmHero.getExpFromIndex(_loc3_);
         mXPBar.value = (_loc4_ - _loc7_) / (_loc6_ - _loc7_);
      }
      
      public function deinit() : void
      {
         mTownStateMachine = null;
         mDidDrag = false;
         mShowedDragMessage = false;
         endEpochCountdown();
         if(mXPBar)
         {
            mXPBar.destroy();
            mXPBar = null;
         }
         if(mRevealer)
         {
            mRevealer.destroy();
            mRevealer = null;
         }
         if(mLeagueNameRevealer)
         {
            mLeagueNameRevealer.destroy();
            mLeagueNameRevealer = null;
         }
         if(mChooseDungeonMessage)
         {
            mChooseDungeonMessage.destroy();
            mChooseDungeonMessage = null;
         }
         if(mDragMessageRevealer)
         {
            mDragMessageRevealer.destroy();
            mDragMessageRevealer = null;
         }
         if(mDragMessageFloater)
         {
            mDragMessageFloater.destroy();
            mDragMessageFloater = null;
         }
         if(mReturnToTownButton)
         {
            mReturnToTownButton.enabled = false;
            mReturnToTownButton.destroy();
            mReturnToTownButton = null;
         }
         mRootMovieClip.worldmap.removeEventListener("mouseUp",onMouseUp);
         mRootMovieClip.worldmap.removeEventListener("mouseOut",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseLeave",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseMove",onDrag);
         mRootMovieClip.worldmap.removeEventListener("mouseOver",onMouseOver);
         mDBFacade.mouseCursorManager.popMouseCursor();
         if(mClosedNodeList)
         {
            mClosedNodeList.clear();
         }
         mNodePath = null;
         mNodeQueue = null;
         if(mIIBattlePopup)
         {
            mIIBattlePopup.destroy();
            mIIBattlePopup = null;
         }
         if(mRegularBattlePopup)
         {
            mRegularBattlePopup.destroy();
            mRegularBattlePopup = null;
         }
         mBattlePopup = null;
         if(mMouseTask)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         if(mCameraLerpTask)
         {
            mCameraLerpTask.destroy();
            mCameraLerpTask = null;
         }
         if(mMapDragTask)
         {
            mMapDragTask.destroy();
            mMapDragTask = null;
         }
         if(mMapAvatar)
         {
            mMapAvatar.destroy(mRootMovieClip.worldmap);
            mMapAvatar = null;
         }
         if(mOpenNodeButtons)
         {
            for each(var _loc1_:UIButton in mOpenNodeButtons.toArray())
            {
               _loc1_.enabled = false;
               _loc1_.destroy();
            }
            mOpenNodeButtons.clear();
            mOpenNodeButtons = null;
         }
         if(mMouseTask)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mEventComponent)
         {
            mEventComponent.removeAllListeners();
         }
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_PLAY_MAP_NODE",false))
         {
            tearDownHacksToPlayNode();
         }
      }
      
      private function createPlayerAvatar() : void
      {
         var node:DisplayObject;
         var forceClassCompilation:UIMapAvatarDropMover;
         var mapAvatarClass:Class = mTownSwfAsset.getClass("Branch_map_avatar");
         var avatar:MovieClip = new mapAvatarClass() as MovieClip;
         var avatarDropShadowClass:Class = mTownSwfAsset.getClass("Branch_map_avatar_shadow");
         var avatarDropShadow:MovieClip = new avatarDropShadowClass() as MovieClip;
         mRootMovieClip.worldmap.addChild(avatar);
         mRootMovieClip.worldmap.addChild(avatarDropShadow);
         node = mRootMovieClip.worldmap.rookie_league.getChildByName(mCurrentNode.Constant);
         if(node)
         {
            node.visible = true;
            avatar.join.visible = false;
            avatar.x = node.x;
            avatar.y = node.y - avatar.height / 2;
            avatarDropShadow.x = avatar.x;
            avatarDropShadow.y = avatar.y;
            mDBFacade.dbAccountInfo.activeAvatarInfo.loadHeroIcon(function(param1:MovieClip):void
            {
               avatar.pic.addChild(param1);
            });
            avatarDropShadow.mouseChildren = false;
            avatarDropShadow.mouseEnabled = false;
            avatar.mouseChildren = false;
            avatar.mouseEnabled = false;
            mMapAvatar = new UIMapAvatar(mDBFacade,avatar,avatarDropShadow,Class(getDefinitionByName("UI.Map.UIMapAvatarDropMover")));
         }
      }
      
      private function friendJoinCallback(friendId:uint) : Function
      {
         return function():void
         {
            if(mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0)
            {
               mDBFacade.metrics.log("NoWeaponsEquippedWarning");
               mDBFacade.errorPopup("Warning","Cannot enter dungeon with no weapons equipped.","NO_WEAPONS_DUNGEON_ERROR_POPUP");
            }
            else
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.metrics.log("JoinFriend",{"friendId":friendId});
               mDBFacade.mainStateMachine.enterLoadingScreenState(0,"",friendId,0,true,mBattlePopup.IsPrivate);
            }
         };
      }
      
      private function clearAvatarList() : void
      {
         if(mAvatarList)
         {
            for each(var _loc2_:DisplayObject in mAvatarList)
            {
               mRootMovieClip.worldmap.removeChild(_loc2_);
            }
         }
         if(mAvatarDropShadowList)
         {
            for each(var _loc1_:DisplayObject in mAvatarDropShadowList)
            {
               mRootMovieClip.worldmap.removeChild(_loc1_);
            }
         }
      }
      
      private function sortAvatarList() : void
      {
         var i:uint;
         var avatar_clip:MovieClip;
         var shadow_clip:MovieClip;
         var ysort:Function = function(param1:MovieClip, param2:MovieClip):int
         {
            if(param1.y < param2.y - 15)
            {
               return -1;
            }
            if(param1.y > param2.y + 15)
            {
               return 1;
            }
            return 0;
         };
         mAvatarList.sort(ysort);
         mAvatarDropShadowList.sort(ysort);
         i = 0;
         while(i < mAvatarList.length)
         {
            avatar_clip = mAvatarList[i];
            shadow_clip = mAvatarDropShadowList[i];
            mRootMovieClip.worldmap.addChild(shadow_clip);
            mRootMovieClip.worldmap.addChild(avatar_clip);
            i = i + 1;
         }
      }
      
      private function updateFriends(event:Event = null) : void
      {
      }
      
      private function cutsceneSwfLoaded(className:String) : Function
      {
         return function(param1:SwfAsset):void
         {
            mRootMovieClip.visible = false;
            mBattlePopup.animatePopupOut();
            mSceneGraphComponent.fadeIn(1);
            var _loc2_:MovieClipRenderController = new MovieClipRenderController(mDBFacade,param1.root);
            mSceneGraphComponent.addChild(param1.root,50);
            _loc2_.play(0,false,cutsceneDone(param1.root,_loc2_));
         };
      }
      
      private function cutsceneDone(clip:MovieClip, movieClipRenderer:MovieClipRenderController) : Function
      {
         return function():void
         {
            mSceneGraphComponent.removeChild(clip);
            mDBFacade.mouseCursorManager.popMouseCursor();
            mDBFacade.mouseCursorManager.disable = true;
            mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,0,0,true,mBattlePopup.IsPrivate);
            movieClipRenderer.destroy();
         };
      }
      
      private function killCameraLerp() : void
      {
         if(mCameraLerpTask)
         {
            mCameraLerpTask.destroy();
            mCameraLerpTask = null;
            mCameraVelocityX = 0;
            mCameraVelocityY = 0;
         }
      }
      
      private function centerMapOnClip(clip:MovieClip, islandName:String = null) : void
      {
         var _loc6_:Rectangle = clip.getRect(clip);
         var _loc3_:Point = clip.localToGlobal(new Point(_loc6_.left + clip.width * 0.5,0));
         var _loc4_:Point = mRootMovieClip.worldmap.localToGlobal(new Point(0,0));
         var _loc5_:Number = _loc3_.x - _loc4_.x;
         if(islandName == "ROOKIE")
         {
            mCameraTargetX = mRootMovieClip.stage.stageWidth * 0.9 - _loc5_;
         }
         else if(islandName == "GLADIATOR")
         {
            mCameraTargetX = -1900;
         }
         else if(islandName == "CHAMPION")
         {
            mCameraTargetX = -3850;
         }
         else if(islandName == "GRINDHOUSE")
         {
            mCameraTargetX = -5800;
         }
         if(islandName == "INFINITEISLAND")
         {
            mCameraTargetX = -8100;
         }
         if(mCameraLerpTask)
         {
            mCameraLerpTask.destroy();
         }
         mCameraVelocityX = 0;
         mCameraVelocityY = 0;
         mCameraLerpTask = mWorkComponent.doEveryFrame(centerCamera);
      }
      
      private function centerCamera(clock:GameClock) : void
      {
         var _loc3_:Number = mCameraTargetX - mRootMovieClip.worldmap.x;
         var _loc4_:Number = mCameraTargetY - mRootMovieClip.worldmap.y;
         var _loc2_:Number = _loc3_ * _loc3_ + _loc4_ * _loc4_;
         mCameraVelocityX = _loc3_ * 0.2916666666666667;
         mRootMovieClip.worldmap.x += mCameraVelocityX;
         clampMap();
         if(_loc2_ < 0.0001)
         {
            mCameraVelocityX = 0;
            mCameraVelocityY = 0;
            killCameraLerp();
         }
      }
      
      private function startSlide() : void
      {
         mRootMovieClip.worldmap.mouseChildren = true;
         if(mMouseTask)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         mMouseTask = mWorkComponent.doEveryFrame(updateSlide);
      }
      
      private function clampMap() : void
      {
         mRootMovieClip.worldmap.x = Math.min(mRootMovieClip.worldmap.x,-13);
         mRootMovieClip.worldmap.x = Math.max(mRootMovieClip.worldmap.x,-mMapWidth + mRootMovieClip.worldmap.stage.stageWidth);
      }
      
      private function updateSlide(clock:GameClock) : void
      {
         var _loc2_:* = 0;
         var _loc7_:Point = null;
         var _loc3_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc4_:Point = null;
         updateDrag(clock);
         var _loc8_:Number = Math.abs(mMouseVelocityX);
         if(mMouseTask)
         {
            mMouseTask.destroy();
            mMouseTask = null;
            _loc2_ = mCurrentLeague;
            if(_loc8_ > 10)
            {
               if(mMouseVelocityX > 0)
               {
                  mCurrentLeague = determineNextLeague();
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
               else
               {
                  mCurrentLeague = mCurrentLeague > 0 ? mCurrentLeague - 1 : 0;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
            }
            else
            {
               _loc7_ = mRootMovieClip.worldmap.gladiator_league.localToGlobal(new Point(0,0));
               _loc3_ = mRootMovieClip.worldmap.rookie_league.localToGlobal(new Point(0,0));
               _loc5_ = mRootMovieClip.worldmap.grinder_league.localToGlobal(new Point(0,0));
               _loc6_ = mRootMovieClip.worldmap.heroic_league.localToGlobal(new Point(0,0));
               _loc4_ = mRootMovieClip.worldmap.infinite_island_league.localToGlobal(new Point(0,0));
               if(Math.abs(_loc7_.x) < Math.abs(_loc3_.x) && Math.abs(_loc7_.x) < Math.abs(_loc5_.x) && Math.abs(_loc7_.x) < Math.abs(_loc6_.x) && Math.abs(_loc7_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = 1;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
               else if(Math.abs(_loc3_.x) < Math.abs(_loc7_.x) && Math.abs(_loc3_.x) < Math.abs(_loc5_.x) && Math.abs(_loc3_.x) < Math.abs(_loc6_.x) && Math.abs(_loc3_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = 0;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
               else if(Math.abs(_loc5_.x) < Math.abs(_loc3_.x) && Math.abs(_loc5_.x) < Math.abs(_loc7_.x) && Math.abs(_loc5_.x) < Math.abs(_loc6_.x) && Math.abs(_loc5_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = 3;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
               else if(Math.abs(_loc6_.x) < Math.abs(_loc3_.x) && Math.abs(_loc6_.x) < Math.abs(_loc7_.x) && Math.abs(_loc6_.x) < Math.abs(_loc5_.x) && Math.abs(_loc6_.x) < Math.abs(_loc4_.x))
               {
                  mCurrentLeague = 2;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
               else if(Math.abs(_loc4_.x) < Math.abs(_loc3_.x) && Math.abs(_loc4_.x) < Math.abs(_loc7_.x) && Math.abs(_loc4_.x) < Math.abs(_loc5_.x) && Math.abs(_loc4_.x) < Math.abs(_loc6_.x))
               {
                  mCurrentLeague = 4;
                  updateCurrentLeague(_loc2_ != mCurrentLeague);
               }
            }
         }
      }
      
      private function updateDrag(clock:GameClock) : void
      {
         var _loc2_:Number = mMouseVelocityX * Math.min(0.9,clock.tickLength * 10);
         mRootMovieClip.worldmap.x -= _loc2_;
         mMouseVelocityX -= _loc2_;
         clampMap();
      }
      
      private function onDrag(mouseEvent:MouseEvent) : void
      {
         mDidDrag = true;
         killCameraLerp();
         var _loc2_:Number = mOldMouseX - mouseEvent.stageX;
         mMouseVelocityX += _loc2_;
         mOldMouseX = mouseEvent.stageX;
         mOldMouseY = mouseEvent.stageY;
         clampMap();
      }
      
      private function onMouseUp(mouseEvent:MouseEvent) : void
      {
         if(mMapDragTask)
         {
            mMapDragTask.destroy();
            mMapDragTask = null;
         }
         mDBFacade.mouseCursorManager.popMouseCursor();
         mRootMovieClip.worldmap.mouseChildren = true;
         mRootMovieClip.worldmap.removeEventListener("mouseUp",onMouseUp);
         mRootMovieClip.worldmap.removeEventListener("mouseOut",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseLeave",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseMove",onDrag);
         startSlide();
      }
      
      private function onMouseOut(mouseEvent:MouseEvent) : void
      {
         mDBFacade.mouseCursorManager.popMouseCursor();
         mRootMovieClip.worldmap.mouseChildren = true;
         mRootMovieClip.worldmap.removeEventListener("mouseUp",onMouseUp);
         mRootMovieClip.worldmap.removeEventListener("mouseOut",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseLeave",onMouseOut);
         mRootMovieClip.worldmap.removeEventListener("mouseMove",onDrag);
         mRootMovieClip.worldmap.addEventListener("mouseOver",onMouseOver);
         startSlide();
      }
      
      private function onMouseOver(mouseEvent:MouseEvent) : void
      {
         mRootMovieClip.worldmap.removeEventListener("mouseOver",onMouseOver);
         if(mouseEvent.buttonDown)
         {
            onMouseDown(mouseEvent);
         }
      }
      
      private function onMouseDown(mouseEvent:MouseEvent) : void
      {
         mDBFacade.mouseCursorManager.pushMouseCursor("DRAG");
         if(mMouseTask)
         {
            mMouseTask.destroy();
            mMouseTask = null;
         }
         mOldMouseX = mouseEvent.stageX;
         mOldMouseY = mouseEvent.stageY;
         mMouseVelocityX = 0;
         mMouseVelocityY = 0;
         if(!mMapDragTask)
         {
            mMapDragTask = mWorkComponent.doEveryFrame(updateDrag);
         }
         mRootMovieClip.worldmap.mouseChildren = false;
         mRootMovieClip.worldmap.addEventListener("mouseMove",onDrag);
         mRootMovieClip.worldmap.addEventListener("mouseUp",onMouseUp);
         mRootMovieClip.worldmap.addEventListener("mouseOut",onMouseOut);
         mRootMovieClip.worldmap.addEventListener("mouseLeave",onMouseOut);
      }
      
      private function isMapNode(obj:Object) : Boolean
      {
         return obj.constructor == mMapNodeClass;
      }
      
      private function clearMouseEnabledOnWorldmap() : void
      {
         var _loc1_:* = 0;
         var _loc2_:MovieClip = null;
         _loc1_ = 0;
         while(_loc1_ < mRootMovieClip.worldmap.numChildren)
         {
            _loc2_ = mRootMovieClip.worldmap.getChildAt(_loc1_) as MovieClip;
            if(_loc2_ && _loc2_ != mRootMovieClip.worldmap.TOWNBUTTON && _loc2_ != mRootMovieClip.worldmap.rookie_league && _loc2_ != mRootMovieClip.worldmap.gladiator_league && _loc2_ != mRootMovieClip.worldmap.grinder_league && _loc2_ != mRootMovieClip.worldmap.heroic_league && _loc2_ != mRootMovieClip.worldmap.infinite_island_league)
            {
               _loc2_.mouseChildren = false;
               _loc2_.mouseEnabled = false;
            }
            _loc1_++;
         }
      }
      
      private function hideAllMapNodes() : void
      {
      }
      
      private function revealCallback(childClip:MovieClip) : Function
      {
         return function(param1:GameClock):void
         {
            var _loc2_:Revealer = null;
            if(childClip)
            {
               childClip.visible = true;
               _loc2_ = new Revealer(childClip,mDBFacade,24);
            }
         };
      }
      
      private function getMapnodeFromCurrentNode1() : MapnodeInfo
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mCurrentNode.Id);
      }
      
      private function mapNodesOpen(mapNodes:Array, andDefeated:Boolean = false) : Boolean
      {
         var _loc4_:* = 0;
         var _loc3_:GMMapNode = null;
         if(!mapNodes || !mDBFacade.dbAccountInfo || !mDBFacade.dbAccountInfo.inventoryInfo)
         {
            return false;
         }
         _loc4_ = 0;
         while(_loc4_ < mapNodes.length)
         {
            _loc3_ = mapNodes[_loc4_];
            if(mapNodeOpen(_loc3_,andDefeated))
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      private function mapNodeOpen(mapNode:GMMapNode, andDefeated:Boolean = false) : Boolean
      {
         if(!mapNode || !mDBFacade.dbAccountInfo || !mDBFacade.dbAccountInfo.inventoryInfo)
         {
            return false;
         }
         var _loc3_:MapnodeInfo = mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id);
         return _loc3_ && (!andDefeated || _loc3_.MapnodeState == 1 || _loc3_.MapnodeState == 3);
      }
      
      private function mapNodeOpenNotDefeated(mapNode:GMMapNode) : Boolean
      {
         if(!mapNode || !mDBFacade.dbAccountInfo || !mDBFacade.dbAccountInfo.inventoryInfo)
         {
            return false;
         }
         var _loc2_:MapnodeInfo = mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id);
         return _loc2_ && _loc2_.MapnodeState == 3;
      }
      
      private function mapNodeLocked(mapNode:GMMapNode) : Boolean
      {
         if(!mapNode || !mDBFacade.dbAccountInfo || !mDBFacade.dbAccountInfo.inventoryInfo)
         {
            return false;
         }
         var _loc2_:MapnodeInfo = mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.itemFor(mapNode.Id);
         return _loc2_ == null;
      }
      
      private function getUnlockedNodes() : Array
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.mapnodes1.toArray();
      }
      
      private function hasLockedNextNode(node:GMMapNode) : Boolean
      {
         for each(var _loc2_:GMMapNode in node.ChildNodes)
         {
            if(_loc2_)
            {
               if(mapNodeLocked(_loc2_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function hasUnlockedChild(node:GMMapNode) : Boolean
      {
         var _loc2_:GMMapNode = null;
         for each(var _loc3_:String in node.RevealNodes)
         {
            if(_loc3_)
            {
               _loc2_ = mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_);
               if(_loc2_ && mapNodeOpen(_loc2_,true))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function isChildNode(node:GMMapNode, childConstant:String) : Boolean
      {
         for each(var _loc3_:GMMapNode in node.ChildNodes)
         {
            if(_loc3_ && _loc3_.Constant == childConstant)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getClipFromConstant(nodeConstant:String) : MovieClip
      {
         var _loc2_:MovieClip = mRootMovieClip.worldmap.rookie_league.getChildByName(nodeConstant) as MovieClip;
         if(!_loc2_)
         {
            _loc2_ = mRootMovieClip.worldmap.gladiator_league.getChildByName(nodeConstant) as MovieClip;
            if(!_loc2_)
            {
               _loc2_ = mRootMovieClip.worldmap.heroic_league.getChildByName(nodeConstant) as MovieClip;
               if(!_loc2_)
               {
                  _loc2_ = mRootMovieClip.worldmap.grinder_league.getChildByName(nodeConstant) as MovieClip;
                  if(!_loc2_)
                  {
                     _loc2_ = mRootMovieClip.worldmap.infinite_island_league.getChildByName(nodeConstant) as MovieClip;
                     if(!_loc2_)
                     {
                        return null;
                     }
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function revealChildNodes(node:GMMapNode) : void
      {
         var _loc3_:GMMapNode = null;
         var _loc2_:MovieClip = null;
         var _loc5_:GMMapNode = null;
         var _loc6_:MovieClip = getClipFromConstant(node.Constant);
         if(_loc6_ == null)
         {
            return;
         }
         _loc6_.visible = true;
         var _loc7_:Number = 0.15;
         var _loc4_:Boolean = hasUnlockedChild(node);
         for each(var _loc8_:String in node.RevealNodes)
         {
            if(_loc8_)
            {
               _loc3_ = mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc8_);
               if(!(_loc3_ && mapNodeOpen(_loc3_,true)))
               {
                  _loc2_ = getClipFromConstant(_loc8_);
                  if(_loc4_)
                  {
                     if(_loc2_)
                     {
                        _loc2_.visible = true;
                     }
                  }
                  else if(_loc2_)
                  {
                     _loc5_ = mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc2_.name);
                     if(_loc5_ && !_loc5_.AlwaysVisible)
                     {
                        mWorkComponent.doLater(_loc7_,revealCallback(_loc2_));
                        _loc7_ += 0.15;
                     }
                  }
               }
            }
         }
      }
      
      private function initializeLeagueMapNodes(league:MovieClip, isInfiniteLeague:Boolean = false) : void
      {
         var _loc5_:* = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:GMMapNode = null;
         _loc5_ = 0;
         while(_loc5_ < league.numChildren)
         {
            _loc3_ = league.getChildAt(_loc5_) as MovieClip;
            if(_loc3_)
            {
               _loc3_.arrow.visible = false;
               _loc3_.arrow.mouseEnabled = false;
               _loc3_.arrow.mouseChildren = false;
               if(_loc3_.defeated && _loc3_.unlocked && _loc3_.locked)
               {
                  _loc3_.defeated.visible = false;
                  _loc3_.unlocked.visible = false;
                  _loc3_.locked.visible = true;
               }
               if(_loc3_.lock)
               {
                  _loc3_.lock.visible = false;
                  _loc3_.lock.mouseEnabled = false;
               }
               if(_loc3_.text_popup && _loc3_.text_popup.title_label)
               {
                  _loc3_.text_popup.visible = false;
                  _loc3_.text_popup.title_label.text = Locale.getString("DUNGEON_LOCKED_TITLE");
               }
               if(_loc3_.label)
               {
                  _loc3_.label.text = "";
               }
               _loc4_ = mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc3_.name);
               if(_loc4_ == null)
               {
                  Logger.warn("Can\'t find gmMapNode for: " + _loc3_.name);
               }
               else if(!_loc4_.AlwaysVisible)
               {
                  _loc3_.visible = false;
               }
            }
            _loc5_++;
         }
      }
      
      private function initializeAllMapNodes() : void
      {
         var _loc2_:* = 0;
         var _loc1_:MovieClip = null;
         _loc2_ = 0;
         while(_loc2_ < mRootMovieClip.worldmap.numChildren)
         {
            _loc1_ = mRootMovieClip.worldmap.getChildAt(_loc2_) as MovieClip;
            if(_loc1_ && _loc1_.name.search("_unlocked") != -1)
            {
               _loc1_.visible = false;
            }
            _loc2_++;
         }
         initializeLeagueMapNodes(mRootMovieClip.worldmap.rookie_league);
         initializeLeagueMapNodes(mRootMovieClip.worldmap.gladiator_league);
         initializeLeagueMapNodes(mRootMovieClip.worldmap.grinder_league);
         initializeLeagueMapNodes(mRootMovieClip.worldmap.heroic_league);
         initializeLeagueMapNodes(mRootMovieClip.worldmap.infinite_island_league,true);
      }
      
      private function initializeOpenMapNodes() : void
      {
         var _loc8_:MapnodeInfo = null;
         var _loc5_:GMMapNode = null;
         var _loc2_:MovieClip = null;
         var _loc9_:String = null;
         var _loc11_:GMColiseumTier = null;
         var _loc3_:int = 0;
         var _loc10_:GMInfiniteDungeon = null;
         var _loc1_:Array = null;
         var _loc7_:int = 0;
         var _loc4_:Array = getUnlockedNodes();
         _loc4_.sort();
         var _loc6_:uint = 0;
         mCurrentLeague = 0;
         _loc4_.sortOn("nodeId",16);
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            _loc8_ = _loc4_[_loc6_] as MapnodeInfo;
            _loc5_ = mDBFacade.gameMaster.mapNodeById.itemFor(_loc8_.nodeId);
            if(_loc5_)
            {
               _loc2_ = mRootMovieClip.worldmap.rookie_league.getChildByName(_loc5_.Constant);
               if(!_loc2_)
               {
                  _loc2_ = mRootMovieClip.worldmap.gladiator_league.getChildByName(_loc5_.Constant);
                  mCurrentLeague = _loc2_ != null && mCurrentLeague < 1 ? 1 : mCurrentLeague;
                  if(!_loc2_)
                  {
                     _loc2_ = mRootMovieClip.worldmap.grinder_league.getChildByName(_loc5_.Constant);
                     mCurrentLeague = _loc2_ != null && mCurrentLeague < 3 ? 3 : mCurrentLeague;
                     if(!_loc2_)
                     {
                        _loc2_ = mRootMovieClip.worldmap.heroic_league.getChildByName(_loc5_.Constant);
                        mCurrentLeague = _loc2_ != null && mCurrentLeague < 2 ? 2 : mCurrentLeague;
                        if(!_loc2_)
                        {
                           _loc2_ = mRootMovieClip.worldmap.infinite_island_league.getChildByName(_loc5_.Constant);
                           mCurrentLeague = _loc2_ != null && mCurrentLeague < 4 ? 4 : mCurrentLeague;
                           if(!_loc2_)
                           {
                              Logger.warn("Can\'t find movie clip node for gmMapNode Constant: " + _loc5_.Constant);
                           }
                        }
                     }
                  }
               }
               mCurrentNode = _loc5_;
               if(_loc2_)
               {
                  if(_loc2_.text_popup && _loc2_.text_popup.title_label && _loc2_.text_popup.description_label)
                  {
                     _loc2_.text_popup.visible = true;
                     _loc2_.text_popup.title_label.text = GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",_loc5_.Constant).toUpperCase();
                     _loc11_ = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(_loc5_.TierRank);
                     if(_loc11_.TotalFloors > 0 && _loc5_.NodeType != "BOSS")
                     {
                        _loc9_ = _loc11_.TotalFloors > 1 ? Locale.getString("FLOORS") : Locale.getString("FLOOR");
                        if(_loc11_.TotalFloors >= 50)
                        {
                           _loc2_.text_popup.description_label.text = Locale.getString("INFINITE_FLOORS_POPUP");
                        }
                        else
                        {
                           _loc2_.text_popup.description_label.text = _loc11_.TotalFloors.toString() + " " + _loc9_;
                        }
                     }
                     else
                     {
                        _loc2_.text_popup.description_label.text = GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME",_loc5_.Constant);
                     }
                  }
                  _loc2_.visible = true;
                  _loc2_.arrow.visible = false;
                  _loc2_.arrow.mouseEnabled = false;
                  _loc2_.arrow.mouseChildren = false;
                  if(_loc2_.locked)
                  {
                     _loc2_.locked.visible = false;
                  }
                  if(mapNodeOpenNotDefeated(_loc5_))
                  {
                     _loc2_.unlocked.visible = true;
                     revealChildNodes(_loc5_);
                  }
                  else if(mapNodeOpen(_loc5_,true))
                  {
                     if(_loc2_.defeated)
                     {
                        _loc2_.defeated.visible = true;
                     }
                     revealChildNodes(_loc5_);
                  }
                  else if(_loc2_.unlocked)
                  {
                     _loc2_.unlocked.visible = true;
                     if(hasLockedNextNode(_loc5_))
                     {
                        _loc2_.arrow.visible = true;
                        _loc2_.arrow.mouseChildren = false;
                        _loc2_.arrow.mouseEnabled = false;
                     }
                  }
                  if(_loc5_.IsInfiniteDungeon)
                  {
                     if(mDBFacade.dbAccountInfo.localFriendInfo == null)
                     {
                        return;
                     }
                     _loc3_ = mDBFacade.dbAccountInfo.localFriendInfo.getIIAvatarScoreForNode(mDBFacade.dbAccountInfo.activeAvatarId,_loc5_.Id);
                     _loc10_ = mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(_loc5_.InfiniteDungeon);
                     _loc1_ = [_loc2_.reward01,_loc2_.reward02,_loc2_.reward03,_loc2_.reward04];
                     _loc7_ = 0;
                     while(_loc7_ < 4)
                     {
                        _loc1_[_loc7_].visible = _loc3_ > _loc10_.RewardFloors[_loc7_];
                        _loc7_++;
                     }
                  }
                  if(_loc2_.label && mCurrentLeague != 3)
                  {
                     _loc2_.label.text = GameMasterLocale.getGameMasterSubString("DUNGEON_NAME",_loc5_.Constant).toUpperCase();
                  }
                  else if(_loc2_.label && mCurrentLeague == 3)
                  {
                     _loc2_.label.visible = false;
                  }
               }
            }
            _loc6_++;
         }
      }
      
      private function createNodeButtonsForLeague(league:MovieClip) : Boolean
      {
         var _loc5_:* = 0;
         var _loc10_:MovieClip = null;
         var _loc13_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc3_:GMMapNode = null;
         var _loc9_:MovieClip = null;
         var _loc4_:MovieClipRenderController = null;
         var _loc7_:* = 0;
         var _loc6_:GMMapNode = null;
         var _loc14_:MovieClip = null;
         var _loc8_:UIButton = null;
         var _loc12_:UIButton = null;
         var _loc2_:Boolean = false;
         _loc5_ = 0;
         while(_loc5_ < league.numChildren)
         {
            _loc10_ = league.getChildAt(_loc5_) as MovieClip;
            if(_loc10_)
            {
               _loc13_ = false;
               _loc11_ = false;
               _loc3_ = mDBFacade.gameMaster.mapNodeByConstant.itemFor(_loc10_.name);
               if(_loc3_)
               {
                  if(mapNodesOpen(_loc3_.ParentNodes,false))
                  {
                     if(_loc3_.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.level)
                     {
                        if(_loc10_.level_req)
                        {
                           _loc10_.level_req.visible = false;
                        }
                     }
                     else
                     {
                        _loc13_ = true;
                        if(_loc10_.level_req)
                        {
                           _loc10_.level_req.visible = true;
                           _loc10_.level_req.level_label.text = _loc3_.LevelRequirement.toString();
                        }
                        if(_loc10_.text_popup)
                        {
                           _loc10_.text_popup.description_label.text = "You are not high enough level to play this dungeon.";
                        }
                     }
                     if(_loc3_.TrophyRequirement <= mDBFacade.dbAccountInfo.trophies)
                     {
                        if(_loc10_.level_req)
                        {
                           _loc10_.trophy_req_left.visible = false;
                           _loc10_.trophy_req.visible = false;
                        }
                     }
                     else
                     {
                        _loc13_ = true;
                        if(_loc10_.level_req.visible == true)
                        {
                           _loc10_.level_req.visible = false;
                           _loc10_.trophy_req.visible = false;
                           _loc10_.trophy_req_left.visible = true;
                           _loc10_.trophy_req_left.level_label.text = _loc3_.LevelRequirement.toString();
                           _loc10_.trophy_req_left.trophy_label.text = _loc3_.TrophyRequirement.toString();
                           _loc10_.text_popup.description_label.text = "Not high enough level, and not enough trophies.";
                        }
                        else
                        {
                           _loc10_.trophy_req_left.visible = false;
                           _loc10_.trophy_req.visible = true;
                           _loc10_.trophy_req.trophy_label.text = _loc3_.TrophyRequirement.toString();
                           _loc10_.text_popup.description_label.text = "Not enough trophies to play this dungeon.";
                        }
                     }
                     if(_loc13_)
                     {
                        if(_loc10_.lock)
                        {
                           _loc10_.lock.visible = true;
                        }
                        _loc11_ = true;
                     }
                     else if(!mapNodesOpen(_loc3_.ParentNodes,true))
                     {
                        if(_loc10_.lock)
                        {
                           _loc10_.lock.visible = true;
                        }
                        _loc13_ = true;
                     }
                  }
                  else if(_loc10_.level_req && _loc10_.trophy_req)
                  {
                     _loc10_.level_req.visible = false;
                     _loc10_.trophy_req_left.visible = false;
                     _loc10_.trophy_req.visible = false;
                  }
                  if(_loc10_.unlocked.visible == true)
                  {
                     _loc9_ = _loc10_.unlocked;
                     _loc4_ = new MovieClipRenderController(mDBFacade,_loc9_);
                     _loc4_.play(0,true);
                  }
                  else if(_loc10_.defeated.visible == true)
                  {
                     _loc9_ = _loc10_.defeated;
                  }
                  else
                  {
                     _loc13_ = true;
                     _loc9_ = _loc10_.locked;
                  }
                  if(!_loc13_)
                  {
                     _loc2_ = true;
                     _loc7_ = 0;
                     while(_loc7_ < _loc3_.ParentNodes.length)
                     {
                        _loc6_ = _loc3_.ParentNodes[_loc7_];
                        if(_loc6_ && mapNodeOpen(_loc6_,true))
                        {
                           _loc14_ = mRootMovieClip.worldmap.getChildByName(_loc6_.Constant + "_" + _loc3_.Constant + "_unlocked");
                           if(_loc14_)
                           {
                              _loc14_.visible = true;
                              _loc4_ = new MovieClipRenderController(mDBFacade,_loc14_);
                              if(_loc9_ == _loc10_.unlocked)
                              {
                                 _loc4_.play(0,false);
                              }
                              else
                              {
                                 _loc4_.setFrame(_loc14_.totalFrames - 1);
                              }
                           }
                        }
                        _loc7_++;
                     }
                     _loc8_ = new UIButton(mDBFacade,_loc9_);
                     _loc8_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
                     _loc8_.releaseCallback = moveAvatarToNode(_loc3_);
                     _loc8_.rollOverCursor = "POINT";
                     _loc8_.dontKillMyChildren = true;
                     _loc10_.text_popup.x = 0;
                     _loc10_.text_popup.y = 0;
                     _loc8_.tooltip = _loc10_.text_popup;
                     mOpenNodeButtons.add(_loc3_.Id,_loc8_);
                  }
                  else
                  {
                     _loc12_ = new UIButton(mDBFacade,_loc9_);
                     if(_loc10_.text_popup && _loc10_.text_popup.description_label)
                     {
                        if(!_loc11_)
                        {
                           _loc10_.text_popup.description_label.text = Locale.getString("DUNGEON_LOCKED_DESCRIPTION");
                        }
                        _loc10_.text_popup.x = 0;
                        _loc10_.text_popup.y = 0;
                        _loc10_.text_popup.visible = true;
                        _loc12_.tooltip = _loc10_.text_popup;
                     }
                     _loc12_.rolloverFilter = DBGlobal.UI_DISABLED_FILTER;
                     _loc12_.releaseCallback = null;
                     _loc12_.rollOverCursor = "POINT";
                     _loc12_.dontKillMyChildren = true;
                     mOpenNodeButtons.add(_loc3_.Id,_loc12_);
                  }
               }
               else
               {
                  Logger.warn("Badly named map node in worldmap: " + _loc10_.name + " for node: " + _loc3_);
               }
            }
            _loc5_++;
         }
         return _loc2_;
      }
      
      private function setupMapNodeButtons() : void
      {
         mOpenNodeButtons = new Map();
         mLockedNodeButtons = new Map();
         initializeAllMapNodes();
         initializeOpenMapNodes();
         createNodeButtonsForLeague(mRootMovieClip.worldmap.rookie_league);
         createNodeButtonsForLeague(mRootMovieClip.worldmap.gladiator_league);
         createNodeButtonsForLeague(mRootMovieClip.worldmap.grinder_league);
         createNodeButtonsForLeague(mRootMovieClip.worldmap.heroic_league);
         mInfiniteIslandUnlocked = createNodeButtonsForLeague(mRootMovieClip.worldmap.infinite_island_league);
         setCurrentNode(mCurrentNode);
      }
      
      private function startFriendFader() : void
      {
         if(!mFriendFadeTask)
         {
            mFriendFadeTask = mWorkComponent.doEveryFrame(hideFriendsOnHover);
         }
      }
      
      private function stopFriendFader() : void
      {
         if(mFriendFadeTask)
         {
            mFriendFadeTask.destroy();
            mFriendFadeTask = null;
            if(mAvatarList)
            {
               for each(var _loc1_:DisplayObject in mAvatarList)
               {
                  _loc1_.alpha = 1;
                  MovieClip(_loc1_).join.alpha = 1;
               }
            }
         }
      }
      
      private function hideFriendsOnHover(clock:GameClock) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(mAvatarList)
         {
            for each(var _loc4_:DisplayObject in mAvatarList)
            {
               _loc2_ = Math.abs(_loc4_.x - mRootMovieClip.worldmap.mouseX);
               _loc3_ = Math.abs(_loc4_.y - mRootMovieClip.worldmap.mouseY);
               if(_loc2_ < 60 && _loc3_ < 60)
               {
                  _loc2_ /= 60;
                  _loc3_ /= 60;
                  _loc4_.alpha = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_);
               }
               else
               {
                  _loc4_.alpha = 1;
               }
               MovieClip(_loc4_).join.alpha = 1 / Math.max(0.01,_loc4_.alpha);
            }
         }
      }
      
      private function clipFromNodeId(nodeId:uint) : MovieClip
      {
         var _loc2_:GMMapNode = mDBFacade.gameMaster.mapNodeById.itemFor(nodeId);
         if(_loc2_)
         {
            return getClipFromConstant(_loc2_.Constant);
         }
         return null;
      }
      
      private function checkTransition() : void
      {
         if(mUnlockResponseReceived && mDidKeySpentMessage)
         {
            if(mUnlockSuccessful)
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,0,0,true,mBattlePopup.IsPrivate);
            }
            else
            {
               mBattlePopup.battleButton.enabled = true;
               mUnlockResponseReceived = false;
               mUnlockSuccessful = false;
               mDidKeySpentMessage = false;
            }
         }
      }
      
      private function unlockMapNodeSuccessCallback(details:*) : void
      {
         mUnlockResponseReceived = true;
         mUnlockSuccessful = true;
         checkTransition();
      }
      
      private function unlockMapNodeFailCallback(err:Error) : void
      {
         mUnlockResponseReceived = true;
         mUnlockSuccessful = false;
         Logger.error(err.toString());
         checkTransition();
      }
      
      private function unlockMapNode() : void
      {
         var node:MovieClip;
         var popup:DBUIOneButtonPopup;
         var spentKeyClass:Class;
         var keyCostClip:MovieClip;
         var global_position:Point;
         var floatingMessage:FloatingMessage;
         var unlockMapNodeRPC:Function;
         if(mSpentKeyMessage)
         {
            return;
         }
         node = getClipFromConstant(mCurrentNode.Constant);
         if(!node)
         {
            Logger.error("Attempting to unlock invalid dungeon");
            return;
         }
         if(mCurrentNode.TrophyRequirement > mDBFacade.dbAccountInfo.trophies)
         {
            mDBFacade.metrics.log("NotEnoughTrophiesWarning");
            popup = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT ENOUGH TROPHIES!","OK",null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIMapWorldMap.unlockMapNode()");
            return;
         }
         spentKeyClass = mTownSwfAsset.getClass("Branch_map_spent_key");
         mSpentKeyMessage = new spentKeyClass() as MovieClip;
         keyCostClip = mBattlePopup.keyCostClip;
         global_position = keyCostClip.localToGlobal(new Point(keyCostClip.x,keyCostClip.y));
         mSpentKeyMessage.x = mBattlePopup.battleButton.root.x;
         mSpentKeyMessage.y = mBattlePopup.battleButton.root.y - 40;
         if(mCurrentNode.BasicKeys > mCurrentNode.PremiumKeys)
         {
            mSpentKeyMessage.keyamount.text = mCurrentNode.BasicKeys.toString();
         }
         else
         {
            mSpentKeyMessage.keyamount.text = mCurrentNode.PremiumKeys.toString();
         }
         mBattlePopup.battleButton.enabled = false;
         mWorkComponent.doLater(1,function(param1:GameClock):void
         {
            mBattlePopup.animatePopupOut(true);
         });
         mDBFacade.sceneGraphManager.addChild(mSpentKeyMessage,105);
         floatingMessage = new FloatingMessage(mSpentKeyMessage,mDBFacade,12,64,10,60,null,function():void
         {
            mDBFacade.sceneGraphManager.removeChild(mSpentKeyMessage);
            mDidKeySpentMessage = true;
            checkTransition();
         });
         unlockMapNodeRPC = JSONRPCService.getFunction("UnlockMapNode",mDBFacade.rpcRoot + "worldmap");
         unlockMapNodeSuccessCallback(null);
      }
      
      private function moveAvatarToNode(gmMapNode:GMMapNode, force:Boolean = false, returningToNodeFromAnotherScreen:Boolean = false) : Function
      {
         return function():void
         {
            setCurrentNode(gmMapNode);
            if(mapNodeOpen(gmMapNode,false) || mapNodesOpen(gmMapNode.ParentNodes,true))
            {
               mBattlePopup.animatePopupIn();
               return;
            }
            mBattlePopup.animatePopupOut();
         };
      }
      
      private function setCurrentNode(currentNode:GMMapNode) : void
      {
         mCurrentNode = currentNode;
         if(mCurrentNode)
         {
            if(mCurrentNode.IsInfiniteDungeon)
            {
               mBattlePopup = mIIBattlePopup;
            }
            else
            {
               mBattlePopup = mRegularBattlePopup;
            }
            mBattlePopup.currentDungeon = mCurrentNode;
            mBattlePopup.mapNodeOpen = mapNodeOpen(mCurrentNode);
            mBattlePopup.setDungeonDetails();
         }
      }
      
      public function battleButtonCallback() : void
      {
         var _loc2_:DBUIOneButtonPopup = null;
         var _loc1_:DBUIOneButtonPopup = null;
         if(mCurrentNode.LevelRequirement <= mDBFacade.dbAccountInfo.activeAvatarInfo.level)
         {
            if(mCurrentNode.TrophyRequirement > mDBFacade.dbAccountInfo.trophies)
            {
               mDBFacade.metrics.log("NotEnoughTrophiesWarning");
               _loc2_ = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT ENOUGH TROPHIES!","OK",null);
               MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
               return;
            }
            if(mapNodeOpen(mCurrentNode))
            {
               mDBFacade.mouseCursorManager.popMouseCursor();
               mDBFacade.mouseCursorManager.disable = true;
               mDBFacade.mainStateMachine.enterLoadingScreenState(mCurrentNode.Id,mCurrentNode.NodeType,0,0,true,mBattlePopup.IsPrivate);
            }
            else
            {
               unlockMapNode();
            }
         }
         else
         {
            _loc1_ = new DBUIOneButtonPopup(mDBFacade,"STOP IT!","NO! NOT HIGH ENOUGH LEVEL!","OK",null);
            MemoryTracker.track(_loc1_,"DBUIOneButtonPopup - created in UIMapWorldMap.battleButtonCallback()");
         }
      }
      
      public function showFloatingMessage(xPos:Number, yPos:Number, message:String) : void
      {
         var floatingMessage:FloatingMessage;
         var messageClass:Class = mTownSwfAsset.getClass("floating_text");
         var messageClip:MovieClip = new messageClass() as MovieClip;
         mRootMovieClip.addChild(messageClip);
         messageClip.x = xPos;
         messageClip.y = yPos;
         messageClip.mouseChildren = false;
         messageClip.mouseEnabled = false;
         messageClip.alpha = 0;
         messageClip.label.text = message;
         floatingMessage = new FloatingMessage(messageClip,mDBFacade,25,100,20,30,null,function():void
         {
            mRootMovieClip.removeChild(messageClip);
         });
      }
      
      private function showChooseDungeonMessage(clock:GameClock) : void
      {
         var messageClass:Class = mTownSwfAsset.getClass("Branch_choose_dungeon");
         var messageClip:MovieClip = new messageClass() as MovieClip;
         mRootMovieClip.addChild(messageClip);
         messageClip.x = messageClip.stage.stageWidth / 2;
         messageClip.y = messageClip.stage.stageHeight * 0.4;
         messageClip.scaleX = messageClip.scaleY = 1.5;
         messageClip.mouseChildren = false;
         messageClip.mouseEnabled = false;
         messageClip.alpha = 0;
         mRevealer = new Revealer(messageClip,mDBFacade,32,function():void
         {
            mChooseDungeonMessage = new FloatingMessage(messageClip,mDBFacade,32,32,1.35,0,null,function():void
            {
               mChooseDungeonMessage = null;
               mRootMovieClip.removeChild(messageClip);
            });
         },1);
      }
      
      public function set returnToMapNode(value:GMMapNode) : void
      {
         mReturnToMapNode = value;
      }
      
      private function buildPathFromSearchNode(node:SearchNode) : void
      {
         mNodePath = [];
         mNodePath.push(node.Node);
         while(node.Parent)
         {
            node = node.Parent;
            if(node.Parent)
            {
               mNodePath.push(node.Node);
            }
         }
      }
      
      private function findPathToNode(goal:GMMapNode) : void
      {
         var _loc2_:SearchNode = null;
         if(!goal || !mCurrentNode || goal == mCurrentNode)
         {
            return;
         }
         mNodeQueue = [];
         mClosedNodeList = new Set();
         var _loc3_:SearchNode = new SearchNode(mCurrentNode,null);
         mNodeQueue.push(_loc3_);
         while(mNodeQueue.length)
         {
            _loc2_ = mNodeQueue.shift();
            mClosedNodeList.add(_loc2_.Node);
            if(_loc2_.Node == goal)
            {
               buildPathFromSearchNode(_loc2_);
               return;
            }
            addChildrenToQueue(_loc2_);
         }
         Logger.error("Can\'t find path to selected map node.");
      }
      
      private function addChildrenToQueue(mapNode:SearchNode) : void
      {
         var _loc2_:* = 0;
         var _loc3_:GMMapNode = null;
         _loc2_ = 0;
         while(_loc2_ < mapNode.Node.ChildNodes.length)
         {
            _loc3_ = mapNode.Node.ChildNodes[_loc2_];
            if(_loc3_ && !mClosedNodeList.has(_loc3_))
            {
               mNodeQueue.push(new SearchNode(_loc3_,mapNode));
            }
            _loc2_++;
         }
      }
      
      private function setUpHacksToPlayNode() : void
      {
         mDBFacade.stageRef.addEventListener("keyDown",hackToHandleKeyPressToPlayNode);
      }
      
      private function tearDownHacksToPlayNode() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",hackToHandleKeyPressToPlayNode);
      }
      
      private function hackToHandleKeyPressToPlayNode(e:KeyboardEvent) : void
      {
         switch(int(e.keyCode) - 69)
         {
            case 0:
               hackToPlayNode(50153);
               break;
            case 12:
               hackToPlayNode(50150);
               break;
            case 13:
               hackToPlayNode(50200);
               break;
            case 18:
               hackToPlayNode(50151);
         }
      }
      
      private function hackToPlayNode(nodeIdToPlay:uint) : void
      {
         mDBFacade.mainStateMachine.enterLoadingScreenState(nodeIdToPlay,"",0,0,true,false);
      }
   }
}

import GameMasterDictionary.GMMapNode;

class SearchNode
{
   
   public var Node:GMMapNode;
   
   public var Parent:SearchNode;
   
   public function SearchNode(node:GMMapNode, parent:SearchNode)
   {
      super();
      Node = node;
      Parent = parent;
   }
}
