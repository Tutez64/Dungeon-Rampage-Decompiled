package Floor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
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
      
      protected var mKillSwitchIconsSwfAsset:SwfAsset;
      
      protected var mCountdownTimerLabel:TextField;
      
      protected var mDBFacade:DBFacade;
      
      private var mSecondsUntilTransition:int;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mEventComponent:EventComponent;
      
      private var mUpdateCountdownTask:Task;
      
      private var mDefeatCountdownTween:TweenHandle;
      
      private var mVictoryRenderer:MovieClipRenderController;
      
      private var mDefeatRenderer:MovieClipRenderController;
      
      private var mStartRenderer:MovieClipRenderController;
      
      private var mCurrentFloorRenderer:MovieClipRenderController;
      
      private var mCountdownRenderer:MovieClipRenderController;
      
      private var mCountdownTextField:TextField;
      
      private var mDefeatCountdownStartClip:MovieClip;
      
      private var mDefeatCountdownRenderer:MovieClipRenderController;
      
      private var mDefeatCountdownBounceRenderer:MovieClipRenderController;
      
      private var mDefeatCountdownTextField:TextField;
      
      private var mKillSwitchRenderer:MovieClipRenderController;
      
      private var mFloor:Floor;
      
      private var mFloorGUIStarted:Boolean;
      
      private var mStartRequested:Boolean;
      
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
            case GMMapNode.DUNGEON_NODE_TYPE:
               mRootInstanceName = "scrn_dungeon_regular";
               break;
            case GMMapNode.BOSS_NODE_TYPE:
               mRootInstanceName = "scrn_dungeon_boss";
               break;
            case GMMapNode.INFINITE_NODE_TYPE:
               mRootInstanceName = "scrn_dungeon_ultimate";
               break;
            case GMMapNode.TAVERN_NODE_TYPE:
               mRootInstanceName = "scrn_dungeon_regular";
               break;
            default:
               mRootInstanceName = "scrn_dungeon_regular";
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),dungeonFinishedSwfLoaded);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Modifier/db_icons_modifier.swf"),function(param1:SwfAsset):void
         {
            mKillSwitchIconsSwfAsset = param1;
         });
      }
      
      private function dungeonFinishedSwfLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass(mRootInstanceName);
         mScreensRoot = new _loc2_();
         mScreensRoot.mouseEnabled = false;
         if(mNodeType != GMMapNode.INFINITE_NODE_TYPE)
         {
            mVictoryRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_victory_instance);
            mCountdownRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_countdown_instance);
            mCountdownTextField = mCountdownRenderer.clip.countdown_bounce.countdown.countdown_text;
         }
         mDefeatRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_defeat);
         mStartRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_start_instance);
         mCurrentFloorRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_floor);
         mDefeatCountdownRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_defeat_countdown);
         mDefeatCountdownBounceRenderer = new MovieClipRenderController(mDBFacade,mDefeatCountdownRenderer.clip.countdown_bounce);
         mDefeatCountdownStartClip = mScreensRoot.scrn_defeat_start_text;
         mDefeatCountdownTextField = mDefeatCountdownRenderer.clip.countdown_bounce.countdown.countdown_text as TextField;
         hideAll();
         if(mStartRequested && !mFloorGUIStarted)
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
         mStartRequested = true;
         if(mScreensRoot != null && mFloor.gmMapNode)
         {
            mDBFacade.refreshHUD();
            mFloorGUIStarted = true;
            _loc1_ = mFloor.gmMapNode;
            _loc2_ = _loc1_.NodeType;
            if(_loc2_ == GMMapNode.INFINITE_NODE_TYPE)
            {
               mKillSwitchRenderer = new MovieClipRenderController(mDBFacade,mScreensRoot.scrn_killSwitchEngage);
               mKillSwitchRenderer.clip.visible = false;
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
            if(mDefeatCountdownBounceRenderer)
            {
               mDefeatCountdownBounceRenderer.stop();
            }
         }
      }
      
      private function screenFinished(movieClipRenderer:MovieClipRenderController) : void
      {
         movieClipRenderer.clip.visible = false;
         checkToRemoveRoot();
      }
      
      private function displayNewKillSwitches() : void
      {
         var _loc2_:uint = 0;
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
         playKillSwitchIntros(_loc1_,0);
         checkToRemoveRoot();
      }
      
      private function playKillSwitchIntros(killSwitches:Vector.<GMDungeonModifier>, index:uint) : void
      {
         var _loc4_:Class = null;
         var _loc3_:Function = null;
         if(mKillSwitchRenderer == null)
         {
            Logger.debug("Trying to play killSwitch intros without a kill switch renderer.");
            return;
         }
         if(killSwitches.length > index)
         {
            if(mKillSwitchIconsSwfAsset)
            {
               _loc4_ = mKillSwitchIconsSwfAsset.getClass(killSwitches[index].IconName);
               while(mKillSwitchRenderer.clip.modifier.modifier.numChildren > 0)
               {
                  mKillSwitchRenderer.clip.modifier.modifier.removeChildAt(0);
               }
               if(_loc4_ == null)
               {
                  Logger.warn("Unable to find iconClass for iconName: " + killSwitches[index].IconName);
               }
               else
               {
                  mKillSwitchRenderer.clip.modifier.modifier.addChild(new _loc4_());
               }
            }
            _loc3_ = becauseFlashSucksAtScopingVariables(killSwitches,index + 1);
            mKillSwitchRenderer.play(0,false,_loc3_);
            TextUtil.setText(mKillSwitchRenderer.clip.banner_modifier.label_modifier,GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",killSwitches[index].Constant));
            mKillSwitchRenderer.clip.visible = true;
            return;
         }
         screenFinished(mKillSwitchRenderer);
      }
      
      private function becauseFlashSucksAtScopingVariables(killSwitches:Vector.<GMDungeonModifier>, index:uint) : Function
      {
         return function():void
         {
            playKillSwitchIntros(killSwitches,index);
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
                  displayNewKillSwitches();
               }
            });
         }
         else
         {
            displayNewKillSwitches();
         }
      }
      
      private function displayCurrentFloor() : void
      {
         checkToAddRootToScene();
         mCurrentFloorRenderer.clip.visible = true;
         if(mFloor.getMaxFloorNum() >= 50)
         {
            TextUtil.setText(mCurrentFloorRenderer.clip.scrn_floor.textField,Locale.getString("FLOOR").toUpperCase() + " " + mFloor.getCurrentFloorNum().toString());
         }
         else
         {
            TextUtil.setText(mCurrentFloorRenderer.clip.scrn_floor.textField,Locale.getString("FLOOR").toUpperCase() + " " + mFloor.getCurrentFloorNum().toString() + " OF " + mFloor.getMaxFloorNum().toString());
         }
         mCurrentFloorRenderer.playRate = 0.8;
         mCurrentFloorRenderer.play(0,false,function():void
         {
            screenFinished(mCurrentFloorRenderer);
         });
      }
      
      private function checkToRemoveRoot() : void
      {
         if(!mCurrentFloorRenderer.isPlaying && (mStartRenderer == null || !mStartRenderer.isPlaying) && !(mVictoryRenderer != null && !mVictoryRenderer.isPlaying) && !mDefeatRenderer.isPlaying && !(mKillSwitchRenderer != null && !mKillSwitchRenderer.isPlaying) && mUpdateCountdownTask == null)
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
         TextUtil.setText(mCountdownTextField,mSecondsUntilTransition.toString());
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
         TextUtil.setText(mCountdownTextField,mSecondsUntilTransition.toString());
         mCountdownRenderer.play(0,false);
         mCountdownRenderer.clip.visible = true;
         mScreensRoot.Scrn_nextfloor_infinite.basic.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.uncommon.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.rare.visible = false;
         mScreensRoot.Scrn_nextfloor_infinite.legendary.visible = false;
         TextUtil.setText(mScreensRoot.Scrn_nextfloor_infinite.coin_count,"3000");
         initInfiniteDungeonTotalReward(5000,2);
         mUpdateCountdownTask = mLogicalWorkComponent.doEverySeconds(1,updateFloorEndingCountdown);
      }
      
      private function initInfiniteDungeonTotalReward(coinVal:int, totalRewardsEarned:uint) : void
      {
         var _loc4_:int = 0;
         Locale.setText(mScreensRoot.Scrn_nextfloor_infinite.current_reward.label_currentReward,"TOTAL_REWARD");
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
         TextUtil.setText(mScreensRoot.Scrn_nextfloor_infinite.current_reward.coin_count,coinVal.toString());
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
         if(mDefeatCountdownTween)
         {
            mDBFacade.mTween.killTween(mDefeatCountdownTween);
            mDefeatCountdownTween = null;
         }
         if(mUpdateCountdownTask)
         {
            mUpdateCountdownTask.destroy();
            mUpdateCountdownTask = null;
         }
         mDefeatCountdownStartClip.visible = true;
         mSecondsUntilTransition = timeUntilTransition;
         mDefeatCountdownTween = mDBFacade.mTween.tweenMaxTo(mDefeatCountdownStartClip,2,{
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
            TextUtil.setText(mDefeatCountdownTextField,mSecondsUntilTransition.toString());
         }
         if(mDefeatCountdownBounceRenderer)
         {
            mDefeatCountdownBounceRenderer.stop();
         }
         if(mDefeatCountdownRenderer)
         {
            mDefeatCountdownRenderer.play(0,false);
            mDefeatCountdownRenderer.clip.visible = true;
         }
         mDefeatCountdownTween = null;
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
            TextUtil.setText(mCountdownTextField,mSecondsUntilTransition.toString());
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
            TextUtil.setText(mDefeatCountdownTextField,mSecondsUntilTransition.toString());
            mDefeatCountdownBounceRenderer.play(0,false);
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
            mDBFacade.mTween.killTween(mDefeatCountdownTween);
            mDefeatCountdownTween = null;
         }
         if(mUpdateCountdownTask)
         {
            mUpdateCountdownTask.destroy();
            mUpdateCountdownTask = null;
         }
         if(mDefeatCountdownRenderer)
         {
            mDefeatCountdownRenderer.stop();
         }
         if(mDefeatCountdownBounceRenderer)
         {
            mDefeatCountdownBounceRenderer.stop();
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
            mDBFacade.mTween.killTween(mDefeatCountdownTween);
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
         mDBFacade.mTween.killTweensOf(mDefeatCountdownStartClip);
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
         if(mDefeatCountdownBounceRenderer)
         {
            mDefeatCountdownBounceRenderer.destroy();
         }
         mDefeatCountdownBounceRenderer = null;
         if(mKillSwitchRenderer)
         {
            mKillSwitchRenderer.destroy();
            mKillSwitchRenderer = null;
         }
         mDBFacade = null;
      }
   }
}

