package Floor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.Floor;
   import Events.II_FloorCompleteEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMDungeonModifier;
   import GameMasterDictionary.GMMapNode;
   import UI.InfiniteIsland.II_UIRewardReportPopup;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FloorEndingGui
   {
      
      public static const DUNGEON_FAILED_EVENT:String = "DUNGEON_FAILED_EVENT";
      
      public static const CLIENT_COUNTDOWN_FINISHED_EVENT:String = "CLIENT_COUNTDOWN_FINISHED_EVENT";
      
      public static const DUNGEON_FINISHED_SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      public static const DUNGEON_MODIFIER_ICONS_SWF_PATH:String = "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";
      
      private static const DEFEAT_COUNTDOWN_FIRST_SCREEN_TIME:int = 2;
      
      protected var mRoot:Sprite;
      
      protected var mScreensRoot:MovieClip;
      
      protected var mKillswitchIconsSwfAsset:SwfAsset;
      
      protected var mCountdownTimerLabel:TextField;
      
      protected var mDBFacade:DBFacade;
      
      private var mSecondsUntilTransition:int;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mEventComponent:EventComponent;
      
      private var mUpdateCountdownTask:Task;
      
      private var mDefeatCountdownTween:TweenMax;
      
      private var mVictoryRenderer:MovieClipRenderController;
      
      private var mDefeatRenderer:MovieClipRenderController;
      
      private var mStartRenderer:MovieClipRenderController;
      
      private var mCurrentFloorRenderer:MovieClipRenderController;
      
      private var mCountdownRenderer:MovieClipRenderController;
      
      private var mCountdownTextField:TextField;
      
      private var mDefeatCountdownStartClip:MovieClip;
      
      private var mDefeatCountdownRenderer:MovieClipRenderController;
      
      private var mDefeatCountdownTextField:TextField;
      
      private var mKillswitchRenderer:MovieClipRenderController;
      
      private var mFloor:Floor;
      
      private var mFloorGUIStarted:Boolean;
      
      private var mShowStartSplash:Boolean;
      
      private var mRootInstanceName:String;
      
      private var mNodeType:String;
      
      public function FloorEndingGui(floor:Floor, nodeType:String, dbFacade:DBFacade)
      {
         super();
         mFloor = floor;
         mFloorGUIStarted = false;
         mDBFacade = dbFacade;
         mRoot = new Sprite();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"FloorEndingGui");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"FloorEndingGui");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mNodeType = nodeType;
         mShowStartSplash = mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState";
         mSceneGraphComponent.addChild(mRoot,50);
         switch(mNodeType)
         {
            case "DUNGEON":
               mRootInstanceName = "scrn_dungeon_regular";
               break;
            case "BOSS":
               mRootInstanceName = "scrn_dungeon_boss";
               break;
            case "INFINITE":
               mRootInstanceName = "scrn_dungeon_ultimate";
               break;
            case "TAVERN":
               mRootInstanceName = "scrn_dungeon_regular";
               break;
            default:
               mRootInstanceName = "scrn_dungeon_regular";
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),dungeonFinishedSwfLoaded);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Modifier/db_icons_modifier.swf"),function(param1:SwfAsset):void
         {
            mKillswitchIconsSwfAsset = param1;
         });
      }
      
      private function dungeonFinishedSwfLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass(mRootInstanceName);
         mScreensRoot = new _loc2_();
         mScreensRoot.mouseEnabled = false;
         if(mNodeType != "INFINITE")
         {
            mVictoryRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_victory_instance);
            mCountdownRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_countdown_instance);
            mCountdownTextField = mCountdownRenderer.clip.countdown_bounce.countdown.countdown_text;
         }
         mDefeatRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_defeat);
         mStartRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_start_instance);
         mCurrentFloorRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_floor);
         mDefeatCountdownRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_defeat_countdown);
         mDefeatCountdownStartClip = mScreensRoot.scrn_defeat_start_text;
         mDefeatCountdownTextField = mDefeatCountdownRenderer.clip.countdown_bounce.countdown.countdown_text as TextField;
         hideAll();
         if(!mFloorGUIStarted)
         {
            floorStart();
         }
      }
      
      public function floorEnding(timeUntilTransition:uint) : void
      {
         var _loc2_:II_UIRewardReportPopup = null;
         if(mFloor.isInfiniteDungeon)
         {
            mDBFacade.eventManager.dispatchEvent(new II_FloorCompleteEvent());
            mFloor.gmMapNode;
            mFloor.parentArea.addInfiniteFloorGoldToTotal();
            _loc2_ = new II_UIRewardReportPopup(mDBFacade,mFloor.parentArea.infiniteRewardData,mFloor.parentArea.infiniteStartScore,mFloor.parentArea.infiniteTotalGold,mFloor.parentArea.infiniteFloorGold,mFloor.getCurrentFloorNum(),timeUntilTransition," hello",null);
            MemoryTracker.track(_loc2_,"II_UIRewardReportPopup - created in FloorEndingGui.floorComplete()");
         }
         else
         {
            setUpFloorEndingCountdownGui(timeUntilTransition);
         }
         checkToAddRootToScene();
      }
      
      public function floorFailing(timeUntilTransition:uint) : void
      {
         if(timeUntilTransition == 0)
         {
            stopDefeatCounterIfRunning();
         }
         else
         {
            setUpFloorFailingCountdownGui(timeUntilTransition);
            checkToAddRootToScene();
         }
      }
      
      public function floorStart() : void
      {
         var _loc1_:GMMapNode = null;
         var _loc2_:String = null;
         if(mScreensRoot != null && mFloor.gmMapNode)
         {
            mDBFacade.refreshHUD();
            mFloorGUIStarted = true;
            _loc1_ = mFloor.gmMapNode;
            _loc2_ = _loc1_.NodeType;
            if(_loc2_ == "INFINITE")
            {
               mKillswitchRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_killSwitchEngage);
               mKillswitchRenderer.clip.visible = false;
            }
            displayStart();
         }
      }
      
      public function dungeonVictory() : void
      {
         if(mScreensRoot != null)
         {
            displayVictory();
            checkToAddRootToScene();
         }
      }
      
      public function dungeonFailure() : void
      {
         if(mScreensRoot != null)
         {
            mEventComponent.dispatchEvent(new Event("DUNGEON_FAILED_EVENT"));
            stopDefeatCounterIfRunning();
            displayDefeat();
            checkToAddRootToScene();
         }
      }
      
      public function hideAll() : void
      {
         if(mScreensRoot)
         {
            if(mRoot.contains(mScreensRoot))
            {
               mRoot.removeChild(mScreensRoot);
            }
            if(mStartRenderer)
            {
               mStartRenderer.stop();
               mStartRenderer.clip.visible = false;
            }
            if(mCurrentFloorRenderer)
            {
               mCurrentFloorRenderer.stop();
               mCurrentFloorRenderer.clip.visible = false;
            }
            if(mVictoryRenderer)
            {
               mVictoryRenderer.stop();
               mVictoryRenderer.clip.visible = false;
            }
            if(mCountdownRenderer)
            {
               mCountdownRenderer.stop();
               mCountdownRenderer.clip.visible = false;
            }
            if(mDefeatRenderer)
            {
               mDefeatRenderer.stop();
               mDefeatRenderer.clip.visible = false;
            }
            if(mDefeatCountdownStartClip)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownRenderer)
            {
               mDefeatCountdownRenderer.stop();
               mDefeatCountdownRenderer.clip.visible = false;
            }
         }
      }
      
      private function screenFinished(movieClipRenderer:MovieClipRenderController) : void
      {
         movieClipRenderer.clip.visible = false;
         checkToRemoveRoot();
      }
      
      private function displayNewKillswitches() : void
      {
         var _loc2_:* = 0;
         var _loc1_:Vector.<GMDungeonModifier> = new Vector.<GMDungeonModifier>();
         _loc2_ = 0;
         while(_loc2_ < mFloor.activeGMDungeonModifiers.length)
         {
            if(mFloor.activeGMDungeonModifiers[_loc2_].NewThisFloor)
            {
               _loc1_.push(mFloor.activeGMDungeonModifiers[_loc2_].GMDungeonMod);
            }
            _loc2_++;
         }
         playKillswitchIntros(_loc1_,0);
         checkToRemoveRoot();
      }
      
      private function playKillswitchIntros(killswitches:Vector.<GMDungeonModifier>, index:uint) : void
      {
         var _loc4_:Class = null;
         var _loc3_:Function = null;
         if(mKillswitchRenderer == null)
         {
            Logger.debug("Trying to play killswitch intros without a kill switch renderer.");
            return;
         }
         if(killswitches.length > index)
         {
            if(mKillswitchIconsSwfAsset)
            {
               _loc4_ = mKillswitchIconsSwfAsset.getClass(killswitches[index].IconName);
               while(mKillswitchRenderer.clip.modifier.modifier.numChildren > 0)
               {
                  mKillswitchRenderer.clip.modifier.modifier.removeChildAt(0);
               }
               if(_loc4_ == null)
               {
                  Logger.warn("Unable to find iconClass for iconName: " + killswitches[index].IconName);
               }
               else
               {
                  mKillswitchRenderer.clip.modifier.modifier.addChild(new _loc4_());
               }
            }
            _loc3_ = becauseFlashSucksAtScopingVariables(killswitches,index + 1);
            mKillswitchRenderer.play(0,false,_loc3_);
            mKillswitchRenderer.clip.banner_modifier.label_modifier.text = GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",killswitches[index].Constant);
            mKillswitchRenderer.clip.visible = true;
            return;
         }
         screenFinished(mKillswitchRenderer);
      }
      
      private function becauseFlashSucksAtScopingVariables(killswitches:Vector.<GMDungeonModifier>, index:uint) : Function
      {
         return function():void
         {
            playKillswitchIntros(killswitches,index);
         };
      }
      
      private function displayVictory() : void
      {
         checkToAddRootToScene();
         mVictoryRenderer.clip.visible = true;
         mVictoryRenderer.play(0,false,function():void
         {
            screenFinished(mVictoryRenderer);
         });
      }
      
      private function displayDefeat() : void
      {
         checkToAddRootToScene();
         mDefeatRenderer.clip.visible = true;
         mDefeatRenderer.play(0,false,function():void
         {
            screenFinished(mDefeatRenderer);
         });
      }
      
      private function displayStart() : void
      {
         checkToAddRootToScene();
         displayCurrentFloor();
         if(mShowStartSplash && !mStartRenderer.isPlaying)
         {
            mStartRenderer.clip.visible = true;
            mStartRenderer.playRate = 0.65;
            mStartRenderer.play(0,false,function():void
            {
               if(mStartRenderer)
               {
                  mStartRenderer.clip.visible = false;
                  displayNewKillswitches();
               }
            });
         }
         else
         {
            displayNewKillswitches();
         }
      }
      
      private function displayCurrentFloor() : void
      {
         checkToAddRootToScene();
         mCurrentFloorRenderer.clip.visible = true;
         if(mFloor.getMaxFloorNum() >= 50)
         {
            mCurrentFloorRenderer.clip.scrn_floor.textField.text = Locale.getString("FLOOR").toUpperCase() + " " + mFloor.getCurrentFloorNum().toString();
         }
         else
         {
            mCurrentFloorRenderer.clip.scrn_floor.textField.text = Locale.getString("FLOOR").toUpperCase() + " " + mFloor.getCurrentFloorNum().toString() + " OF " + mFloor.getMaxFloorNum().toString();
         }
         mCurrentFloorRenderer.playRate = 0.8;
         mCurrentFloorRenderer.play(0,false,function():void
         {
            screenFinished(mCurrentFloorRenderer);
         });
      }
      
      private function checkToRemoveRoot() : void
      {
         if(!mCurrentFloorRenderer.isPlaying && (mStartRenderer == null || !mStartRenderer.isPlaying) && !(mVictoryRenderer != null && !mVictoryRenderer.isPlaying) && !mDefeatRenderer.isPlaying && !(mKillswitchRenderer != null && !mKillswitchRenderer.isPlaying) && mUpdateCountdownTask == null)
         {
            mSceneGraphComponent.removeChild(mRoot);
            hideAll();
         }
      }
      
      private function checkToAddRootToScene() : void
      {
         if(mRoot && !mRoot.contains(mScreensRoot))
         {
            mRoot.addChild(mScreensRoot);
         }
         if(!mSceneGraphComponent.contains(mRoot,50))
         {
            mSceneGraphComponent.addChild(mRoot,50);
         }
      }
      
      private function setUpFloorEndingCountdownGui(timeUntilTransition:uint) : void
      {
         if(timeUntilTransition == 0)
         {
            return;
         }
         mSecondsUntilTransition = timeUntilTransition;
         mCountdownTextField.text = mSecondsUntilTransition.toString();
         mCountdownRenderer.play(0,false);
         mCountdownRenderer.clip.visible = true;
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorEndingCountdown);
      }
      
      private function setUpInfiniteDungeonFloorEndingCountdownGui(timeUntilTransition:uint) : void
      {
         if(timeUntilTransition == 0)
         {
            return;
         }
         mSecondsUntilTransition = timeUntilTransition;
         mCountdownTextField.text = mSecondsUntilTransition.toString();
         mCountdownRenderer.play(0,false);
         mCountdownRenderer.clip.visible = true;
         mScreensRoot.Scrn_nextfloor_infinite.basic.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.uncommon.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.rare.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.legendary.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.coin_count.text = "3000";
         initInfiniteDungeonTotalReward(5000,2);
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorEndingCountdown);
      }
      
      private function initInfiniteDungeonTotalReward(coinVal:int, totalRewardsEarned:uint) : void
      {
         var _loc4_:int = 0;
         mScreensRoot.Scrn_nextfloor_infinite.current_reward.label_currentReward.text = Locale.getString("TOTAL_REWARD");
         var _loc3_:Vector.<MovieClip> = new Vector.<MovieClip>();
         _loc3_.push(mScreensRoot.Scrn_nextfloor_infinite.current_reward.basic);
         _loc3_.push(mScreensRoot.Scrn_nextfloor_infinite.current_reward.uncommon);
         _loc3_.push(mScreensRoot.Scrn_nextfloor_infinite.current_reward.rare);
         _loc3_.push(mScreensRoot.Scrn_nextfloor_infinite.current_reward.legendary);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].stop();
            _loc4_++;
         }
         mScreensRoot.Scrn_nextfloor_infinite.current_reward.coin_count.text = coinVal.toString();
         _loc4_ = int(totalRewardsEarned);
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].nextFrame();
            _loc3_[_loc4_].stop();
            _loc4_++;
         }
      }
      
      private function setUpFloorFailingCountdownGui(timeUntilTransition:uint) : void
      {
         mDefeatCountdownStartClip.visible = true;
         mSecondsUntilTransition = timeUntilTransition;
         mDefeatCountdownTween = TweenMax.to(mDefeatCountdownStartClip,2,{
            "visible":false,
            "onComplete":defeatCountdownTweenFinished
         });
      }
      
      private function defeatCountdownTweenFinished() : void
      {
         if(mDefeatCountdownStartClip)
         {
            mDefeatCountdownStartClip.visible = false;
         }
         if(mDefeatCountdownTextField)
         {
            mDefeatCountdownTextField.text = mSecondsUntilTransition.toString();
         }
         if(mDefeatCountdownRenderer)
         {
            mDefeatCountdownRenderer.play(0,false);
            mDefeatCountdownRenderer.clip.visible = true;
         }
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorFailingCountdown);
      }
      
      private function isCountdownComplete() : Boolean
      {
         mSecondsUntilTransition = mSecondsUntilTransition - 1;
         if(mSecondsUntilTransition < 0)
         {
            if(mUpdateCountdownTask != null)
            {
               mUpdateCountdownTask.destroy();
               mUpdateCountdownTask = null;
            }
            return true;
         }
         return false;
      }
      
      private function updateFloorEndingCountdown(gameClock:GameClock) : void
      {
         if(!isCountdownComplete())
         {
            mCountdownTextField.text = mSecondsUntilTransition.toString();
            mCountdownRenderer.play(0,false);
         }
         else
         {
            mSceneGraphComponent.fadeOut(1);
         }
      }
      
      private function updateFloorFailingCountdown(gameClock:GameClock) : void
      {
         if(!isCountdownComplete())
         {
            mDefeatCountdownTextField.text = mSecondsUntilTransition.toString();
            mDefeatCountdownRenderer.play(0,false);
         }
         else
         {
            mEventComponent.dispatchEvent(new Event("CLIENT_COUNTDOWN_FINISHED_EVENT"));
            screenFinished(mDefeatCountdownRenderer);
         }
      }
      
      private function stopDefeatCounterIfRunning() : void
      {
         if(mDefeatCountdownTween)
         {
            if(mDefeatCountdownStartClip)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownTextField)
            {
               mDefeatCountdownTextField.text = mSecondsUntilTransition.toString();
            }
            if(mDefeatCountdownRenderer)
            {
               mDefeatCountdownRenderer.play(0,false);
               mDefeatCountdownRenderer.clip.visible = true;
            }
            mDefeatCountdownTween.kill();
            mDefeatCountdownTween = null;
         }
         if(mUpdateCountdownTask)
         {
            mUpdateCountdownTask.destroy();
            mUpdateCountdownTask = null;
         }
         mSecondsUntilTransition = 0;
         screenFinished(mDefeatCountdownRenderer);
      }
      
      public function destroy() : void
      {
         mFloor = null;
         mSceneGraphComponent.fadeOut(0);
         hideAll();
         if(mUpdateCountdownTask)
         {
            mUpdateCountdownTask.destroy();
         }
         mUpdateCountdownTask = null;
         if(mDefeatCountdownTween)
         {
            if(mDefeatCountdownStartClip)
            {
               mDefeatCountdownStartClip.visible = false;
            }
            if(mDefeatCountdownTextField)
            {
               mDefeatCountdownTextField.text = mSecondsUntilTransition.toString();
            }
            if(mDefeatCountdownRenderer)
            {
               mDefeatCountdownRenderer.play(0,false);
               mDefeatCountdownRenderer.clip.visible = true;
            }
            mDefeatCountdownTween.kill();
            mDefeatCountdownTween = null;
         }
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mScreensRoot = null;
         mRoot = null;
         mCountdownTextField = null;
         mCountdownTimerLabel = null;
         TweenMax.killTweensOf(mDefeatCountdownStartClip);
         mDefeatCountdownStartClip = null;
         mDefeatCountdownTextField = null;
         if(mVictoryRenderer)
         {
            mVictoryRenderer.destroy();
         }
         mVictoryRenderer = null;
         if(mDefeatRenderer)
         {
            mDefeatRenderer.destroy();
         }
         mDefeatRenderer = null;
         if(mStartRenderer)
         {
            mStartRenderer.destroy();
         }
         mStartRenderer = null;
         if(mCurrentFloorRenderer)
         {
            mCurrentFloorRenderer.destroy();
         }
         mCurrentFloorRenderer = null;
         mDefeatCountdownStartClip = null;
         mCountdownTextField = null;
         mDefeatCountdownTextField = null;
         if(mCountdownRenderer)
         {
            mCountdownRenderer.destroy();
         }
         mCountdownRenderer = null;
         if(mDefeatCountdownRenderer)
         {
            mDefeatCountdownRenderer.destroy();
         }
         mDefeatCountdownRenderer = null;
         if(mKillswitchRenderer)
         {
            mKillswitchRenderer.destroy();
            mKillswitchRenderer = null;
         }
         mDBFacade = null;
      }
   }
}

