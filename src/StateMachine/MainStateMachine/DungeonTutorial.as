package StateMachine.MainStateMachine
{
   import Actor.Player.Input.DungeonBusterControlActivatedEvent;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Render.MovieClipRenderer;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   import Facade.Locale;
   import Input.KeyBindings.InputAction;
   import SteamInput.OnSteamInputButtonPressedEvent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   
   public class DungeonTutorial
   {
      
      public static const MOVEMENT_TUTORIAL:String = "MOVEMENT_TUTORIAL";
      
      public static const BUSTER_TUTORIAL:String = "BUSTER_TUTORIAL";
      
      public static const CHARGE_TUTORIAL:String = "CHARGE_TUTORIAL";
      
      public static const REVIVE_TUTORIAL:String = "REVIVE_TUTORIAL";
      
      public static const LOOT_SHARING_TUTORIAL:String = "LOOT_SHARING_TUTORIAL";
      
      public static const SUPER_WEAK_TUTORIAL:String = "SUPER_WEAK_TUTORIAL";
      
      public static const TUTORIAL_PANEL_LEFT:String = "TUTORIAL_PANEL_LEFT";
      
      public static const TUTORIAL_PANEL_RIGHT:String = "TUTORIAL_PANEL_RIGHT";
      
      public static const REVIVE_SPACEBAR_PRESSED_EVENT:String = "REVIVE_SPACEBAR_PRESSED";
      
      public static const CHEST_TUTORIAL_NEARBY:String = "CHEST_TUTORIAL_NEARBY";
      
      public static const CHEST_TUTORIAL_COLLECTED:String = "CHEST_TUTORIAL_COLLECTED";
      
      public static const COOLDOWN_TUTORIAL:String = "COOLDOWN_TUTORIAL";
      
      public static const SCALING_TUTORIAL:String = "SCALING_TUTORIAL";
      
      public static const REPEATER_TUTORIAL:String = "REPEATER_TUTORIAL";
      
      private static const ATTACK_POPUP_DELAY:Number = 1;
      
      private static const TUTORIAL_SWF:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      private static const CARD_SCALE:Number = 1;
      
      private static const LOOT_CARD_SCALE:Number = 1.1764705882352942;
      
      private static const CONTROLLER_GLYPH_SIZE:Number = 56;
      
      private static const CONTROLLER_STICK_GLYPH_SIZE:Number = 80;
      
      private static const GAMEPAD_MOVEMENT_DEADZONE:Number = 0.05;
      
      private static const ATTACK_ACTIONS:Array = ["attack_weapon_1","attack_weapon_2","attack_weapon_3"];
      
      protected var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mMovementTutorialDone:Boolean = false;
      
      private var mMovementPopup:MovieClip;
      
      private var mGamepadMovementTask:Task;
      
      private var mAttackTutorialDone:Boolean = false;
      
      private var mAttackPopup:MovieClip;
      
      private var mChestTutorialDone:Boolean = false;
      
      private var mChestCloseButton:UIButton;
      
      private var mChestPopup:MovieClip;
      
      private var mCooldownRenderer:MovieClipRenderer;
      
      private var mCooldownTutorialReadyToClose:Boolean = false;
      
      private var mScalingTutorialReadyToClose:Boolean = false;
      
      private var mRepeaterTutorialReadyToClose:Boolean = false;
      
      private var mChargeTutorialReadyToClose:Boolean = false;
      
      private var mCooldownTutorialDone:Boolean = false;
      
      private var mScalingTutorialDone:Boolean = false;
      
      private var mRepeaterTutorialDone:Boolean = false;
      
      private var mChargeTutorialDone:Boolean = false;
      
      private var mBusterTutorialDone:Boolean = false;
      
      private var mBusterCloseButton:UIButton;
      
      private var mBusterPopup:MovieClip;
      
      private var mChargeCloseButton:UIButton;
      
      private var mChargePopup:MovieClip;
      
      private var mReviveTutorialDone:Boolean = false;
      
      private var mReviveCloseButton:UIButton;
      
      private var mRevivePopup:MovieClip;
      
      private var mRevivePopupPosition:String;
      
      private var mLootSharingTutorialDone:Boolean = false;
      
      private var mLootSharingCloseButton:UIButton;
      
      private var mLootSharingPopup:MovieClip;
      
      private var mLootSharingChestRenderer:MovieClipRenderer;
      
      private var mSuperWeakTutorialDone:Boolean = false;
      
      private var mSuperWeakCloseButton:UIButton;
      
      private var mSuperWeakPopup:MovieClip;
      
      private var mTutorialComplete:Boolean = false;
      
      public function DungeonTutorial(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DungeonTutorial");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"DungeonTutorial");
         mEventComponent = new EventComponent(mDBFacade);
         EventListeners.add(mDBFacade.stageRef,"keyDown",handleKeyDown);
         EventListeners.add(mDBFacade.stageRef,"mouseDown",handleMouseDown);
         mEventComponent.addListener("DungeonBusterControlActivatedEvent",handleBuster);
         mEventComponent.addListener("REVIVE_SPACEBAR_PRESSED",handleRevive);
         mEventComponent.addListener("OnSteamInputButtonPressedEvent",handleSteamInputButtonPressed);
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
         {
            mMovementTutorialDone = true;
         }
      }
      
      private static function isKeyboardArt(child:DisplayObject, hideUnnamedClips:Boolean) : Boolean
      {
         if(child is Shape)
         {
            return true;
         }
         var _loc3_:TextField = child as TextField;
         if(_loc3_ != null)
         {
            return _loc3_.text.replace(/\s/g,"").length <= 2;
         }
         return hideUnnamedClips && child is Sprite && child.name.indexOf("instance") == 0;
      }
      
      public function destroy() : void
      {
         stopGamepadMovementCheck();
         EventListeners.remove(mDBFacade.stageRef,"keyDown",handleKeyDown);
         EventListeners.remove(mDBFacade.stageRef,"mouseDown",handleMouseDown);
         this.destroyChestTutorial();
         this.destroyMovementTutorial();
         this.destroyAttackTutorial();
         this.destroyBusterTutorial();
         this.destroyChargeTutorial();
         this.destroyReviveTutorial();
         this.destroyLootSharingTutorial();
         this.destroySuperWeakTutorial();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
      }
      
      private function handleMouseDown(event:MouseEvent) : void
      {
         if(mMovementPopup && !mMovementTutorialDone)
         {
            this.advanceToAttackTutorial();
         }
      }
      
      private function handleKeyDown(event:KeyboardEvent) : void
      {
         if(event.keyCode == 27)
         {
            if(mAttackPopup && !mAttackTutorialDone)
            {
               this.finishAttackTutorial();
            }
            if(mMovementPopup && !mMovementTutorialDone)
            {
               this.advanceToAttackTutorial();
            }
            if(mChestPopup && !mChestTutorialDone)
            {
               this.finishChestTutorial();
            }
            if(mChestPopup && !mCooldownTutorialDone)
            {
               this.finishCooldownTutorial();
            }
            if(mChestPopup && !mScalingTutorialDone)
            {
               this.finishScalingTutorial();
            }
            if(mChestPopup && !mRepeaterTutorialDone)
            {
               this.finishRepeaterTutorial();
            }
            if(mBusterPopup && !mBusterTutorialDone)
            {
               this.finishBusterTutorial();
            }
            if(mChargePopup && !mChargeTutorialDone)
            {
               this.finishChargeTutorial();
            }
            return;
         }
         var _loc2_:String = mDBFacade.keyBindings.actionForKey(event.keyCode);
         if(_loc2_ == null)
         {
            return;
         }
         if(InputAction.isWeaponAttack(_loc2_))
         {
            handleAttackInput();
         }
         else if(_loc2_ == "useDungeonBuster")
         {
            if(mBusterPopup && !mBusterTutorialDone)
            {
               this.finishBusterTutorial();
            }
         }
         else if(InputAction.isMovement(_loc2_))
         {
            if(mMovementPopup && !mMovementTutorialDone)
            {
               this.advanceToAttackTutorial();
            }
         }
      }
      
      private function handleAttackInput() : void
      {
         if(mAttackPopup && !mAttackTutorialDone)
         {
            this.finishAttackTutorial();
         }
         if(mChestPopup && !mCooldownTutorialDone)
         {
            this.finishCooldownTutorial();
         }
         if(mChestPopup && !mScalingTutorialDone)
         {
            this.finishScalingTutorial();
         }
         if(mChestPopup && !mRepeaterTutorialDone)
         {
            this.finishRepeaterTutorial();
         }
         if(mChargePopup && !mChargeTutorialDone)
         {
            this.finishChargeTutorial();
         }
      }
      
      private function handleSteamInputButtonPressed(event:OnSteamInputButtonPressedEvent) : void
      {
         if(ATTACK_ACTIONS.indexOf(event.actionName) != -1)
         {
            handleAttackInput();
         }
         else if(event.actionName == "use_dungeon_buster")
         {
            if(mBusterPopup && !mBusterTutorialDone)
            {
               this.finishBusterTutorial();
            }
         }
      }
      
      private function checkGamepadMovement(gameClock:GameClock) : void
      {
         if(mMovementPopup == null || mMovementTutorialDone)
         {
            stopGamepadMovementCheck();
            return;
         }
         var _loc2_:Vector3D = mDBFacade.steamInputManager.getAnalogAction("game_movement");
         if(_loc2_.lengthSquared > 0.05)
         {
            stopGamepadMovementCheck();
            advanceToAttackTutorial();
         }
      }
      
      private function stopGamepadMovementCheck() : void
      {
         if(mGamepadMovementTask)
         {
            mGamepadMovementTask.destroy();
         }
         mGamepadMovementTask = null;
      }
      
      private function showControllerPrompts(popup:MovieClip, glyphFilePaths:Array, glyphSize:Number, hideUnnamedClips:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc14_:DisplayObject = null;
         var _loc12_:Rectangle = null;
         var _loc5_:int = 0;
         if(!mDBFacade.steamInputManager.wantsControllerPrompts)
         {
            return;
         }
         var _loc11_:Array = [];
         for each(var _loc7_:String in glyphFilePaths)
         {
            if(_loc7_ != null && _loc7_ != "" && _loc7_ != "error1" && _loc11_.indexOf(_loc7_) == -1)
            {
               _loc11_.push(_loc7_);
            }
         }
         if(_loc11_.length == 0)
         {
            return;
         }
         var _loc13_:Rectangle = null;
         _loc6_ = popup.getChildIndex(popup.title) + 1;
         while(_loc6_ < popup.numChildren)
         {
            _loc14_ = popup.getChildAt(_loc6_);
            if(isKeyboardArt(_loc14_,hideUnnamedClips))
            {
               _loc14_.visible = false;
               _loc12_ = _loc14_.getBounds(popup);
               _loc13_ = _loc13_ ? _loc13_.union(_loc12_) : _loc12_;
            }
            _loc6_++;
         }
         if(_loc13_ == null)
         {
            return;
         }
         var _loc8_:Number = glyphSize * 0.25;
         var _loc10_:Number = _loc13_.x + (_loc13_.width - (_loc11_.length * glyphSize + (_loc11_.length - 1) * _loc8_)) / 2;
         var _loc9_:Number = _loc13_.y + (_loc13_.height - glyphSize) / 2;
         _loc5_ = 0;
         while(_loc5_ < _loc11_.length)
         {
            addControllerGlyph(popup,_loc11_[_loc5_],_loc10_ + _loc5_ * (glyphSize + _loc8_),_loc9_,glyphSize);
            _loc5_++;
         }
      }
      
      private function addControllerGlyph(popup:MovieClip, glyphFilePath:String, x:Number, y:Number, size:Number) : void
      {
         mAssetLoadingComponent.getImageAsset(glyphFilePath,function(param1:ImageAsset):void
         {
            var _loc2_:Bitmap = new Bitmap(param1.image.bitmapData,param1.image.pixelSnapping,param1.image.smoothing);
            _loc2_.x = x;
            _loc2_.y = y;
            _loc2_.width = size;
            _loc2_.height = size;
            popup.addChild(_loc2_);
         });
      }
      
      private function getAttackGlyphFilePaths() : Array
      {
         var _loc1_:Array = [];
         if(!mDBFacade.steamInputManager.isSteamInputReady)
         {
            return _loc1_;
         }
         for each(var _loc2_:String in ATTACK_ACTIONS)
         {
            _loc1_.push(mDBFacade.steamInputManager.getGlyphFilePathForAction(_loc2_));
         }
         return _loc1_;
      }
      
      private function handleBuster(event:DungeonBusterControlActivatedEvent) : void
      {
         if(mBusterPopup && !mBusterTutorialDone)
         {
            this.finishBusterTutorial();
         }
      }
      
      private function handleRevive(event:Event) : void
      {
         if(mRevivePopup && !mReviveTutorialDone)
         {
            this.finishReviveTutorial();
         }
      }
      
      private function timelineAttackAdvance() : void
      {
         destroyMovementTutorial();
         showAttackTutorial();
      }
      
      public function advanceToAttackTutorial() : void
      {
         mMovementTutorialDone = true;
         mMovementPopup.check.visible = true;
         var _loc1_:Number = mMovementPopup.x;
         var _loc3_:Number = mDBFacade.viewWidth + mMovementPopup.width;
         var _loc2_:Number = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mMovementPopup,0.08333333333333333,{
               "delay":1,
               "x":_loc1_ - 20,
               "y":_loc2_
            }),mDBFacade.mTween.tweenMaxTo(mMovementPopup,0.3333333333333333,{
               "x":_loc3_,
               "y":_loc2_
            }),mDBFacade.mTween.delayedCall(1.5,timelineAttackAdvance)],
            "align":"sequence"
         });
      }
      
      private function destroyMovementTutorial() : void
      {
         stopGamepadMovementCheck();
         if(mMovementPopup)
         {
            mDBFacade.mTween.killDelayedCallsTo(timelineAttackAdvance);
            mDBFacade.mTween.killTweensOf(mMovementPopup);
            mSceneGraphComponent.removeChild(mMovementPopup);
            mMovementPopup = null;
         }
      }
      
      public function showMovementTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_movement");
            if(_loc3_ == null)
            {
               return;
            }
            mMovementPopup = new _loc3_();
            Locale.setText(mMovementPopup.title,"TUTORIAL_MOVEMENT_TITLE");
            mMovementPopup.check.visible = false;
            showControllerPrompts(mMovementPopup,[mDBFacade.steamInputManager.getGlyphFilePathForAnalogAction("game_movement")],80,true);
            stopGamepadMovementCheck();
            mGamepadMovementTask = mLogicalWorkComponent.doEveryFrame(checkGamepadMovement);
            mSceneGraphComponent.addChild(mMovementPopup,105);
            mMovementPopup.scaleX = mMovementPopup.scaleY = 1;
            var _loc2_:Number = mDBFacade.viewWidth - mMovementPopup.width * 0.5 - 50;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mMovementPopup.x = mDBFacade.viewWidth + mMovementPopup.width;
            mMovementPopup.y = _loc4_;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mMovementPopup,0.3333333333333333,{
                  "x":_loc2_ - 20,
                  "y":_loc4_
               }),mDBFacade.mTween.tweenMaxTo(mMovementPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishAttackTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mAttackTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setMovementTutorialParam();
         }
         mAttackTutorialDone = true;
         mAttackPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyAttackTutorial();
         };
         curX = mAttackPopup.x;
         offscreenX = -mAttackPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mAttackPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mAttackPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyAttackTutorial() : void
      {
         if(mAttackPopup)
         {
            mDBFacade.mTween.killTweensOf(mAttackPopup);
            mSceneGraphComponent.removeChild(mAttackPopup);
            mAttackPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showAttackTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_attack");
            if(_loc3_ == null)
            {
               return;
            }
            mAttackPopup = new _loc3_();
            Locale.setText(mAttackPopup.title,"TUTORIAL_ATTACK_TITLE");
            mAttackPopup.check.visible = false;
            showControllerPrompts(mAttackPopup,getAttackGlyphFilePaths(),56,false);
            mSceneGraphComponent.addChild(mAttackPopup,105);
            mAttackPopup.scaleX = mAttackPopup.scaleY = 1;
            var _loc2_:Number = mAttackPopup.width * 0.5 + 10;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mAttackPopup.x = -mAttackPopup.width;
            mAttackPopup.y = _loc4_;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mAttackPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),mDBFacade.mTween.tweenMaxTo(mAttackPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishReviveTutorial() : void
      {
         var advanceFunc:Function;
         var destX:Number;
         var bounceOffset:Number;
         var curX:Number;
         mReviveTutorialDone = true;
         mRevivePopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyReviveTutorial();
         };
         curX = mRevivePopup.x;
         if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
         {
            destX = mDBFacade.viewWidth + mRevivePopup.width;
            bounceOffset = -20;
         }
         else
         {
            destX = -mRevivePopup.width;
            bounceOffset = 20;
         }
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mRevivePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + bounceOffset
            }),mDBFacade.mTween.tweenMaxTo(mRevivePopup,0.3333333333333333,{
               "x":destX,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyReviveTutorial() : void
      {
         if(mRevivePopup)
         {
            mDBFacade.mTween.killTweensOf(mRevivePopup);
            mSceneGraphComponent.removeChild(mRevivePopup);
            mRevivePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showReviveTutorial(popupPosition:String) : void
      {
         if(mRevivePopup)
         {
            return;
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasReviveTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setReviveTutorialParam();
         }
         mRevivePopupPosition = popupPosition;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Number = NaN;
            var _loc2_:Number = NaN;
            var _loc4_:Class = param1.getClass("tutorial_revive");
            if(_loc4_ == null)
            {
               return;
            }
            mRevivePopup = new _loc4_();
            Locale.setText(mRevivePopup.title,"TUTORIAL_REVIVE_TITLE");
            Locale.setText(mRevivePopup.description,"TUTORIAL_REVIVE_DESCRIPTION");
            mRevivePopup.check.visible = false;
            mReviveCloseButton = new UIButton(mDBFacade,mRevivePopup.close);
            mReviveCloseButton.releaseCallback = finishReviveTutorial;
            mSceneGraphComponent.addChild(mRevivePopup,105);
            mRevivePopup.scaleX = mRevivePopup.scaleY = 1;
            mRevivePopup.y = mDBFacade.viewHeight * 0.5;
            if(mRevivePopupPosition == "TUTORIAL_PANEL_RIGHT")
            {
               mRevivePopup.x = mDBFacade.viewWidth + mRevivePopup.width / 2;
               _loc3_ = mDBFacade.viewWidth - mRevivePopup.width / 2 + 25;
               _loc2_ = -20;
            }
            else
            {
               mRevivePopup.x = 0 - mRevivePopup.width / 2;
               _loc3_ = mRevivePopup.width / 2;
               _loc2_ = 20;
            }
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mRevivePopup,0.3333333333333333,{"x":_loc3_ + _loc2_}),mDBFacade.mTween.tweenMaxTo(mRevivePopup,0.08333333333333333,{"x":_loc3_})],
               "align":"sequence"
            });
         });
      }
      
      private function finishLootSharingTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         mLootSharingTutorialDone = true;
         mLootSharingPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyLootSharingTutorial();
         };
         curX = mLootSharingPopup.x;
         offscreenX = mDBFacade.viewWidth;
         offscreenY = mDBFacade.viewHeight * 0.3;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mLootSharingPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - 40,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mLootSharingPopup,0.3333333333333333,{
               "x":offscreenX - 40,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyLootSharingTutorial() : void
      {
         if(mLootSharingChestRenderer)
         {
            mLootSharingChestRenderer.destroy();
            mLootSharingChestRenderer = null;
         }
         if(mLootSharingPopup)
         {
            mDBFacade.mTween.killTweensOf(mLootSharingPopup);
            mSceneGraphComponent.removeChild(mLootSharingPopup);
            mLootSharingPopup = null;
         }
         mTutorialComplete = true;
      }
      
      private function finishSuperWeakTutorial(className:String, isRight:Boolean = true) : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var sign:int;
         var offscreenX:Number;
         var offscreenY:Number;
         mSuperWeakPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroySuperWeakTutorial();
            if(className == "tutorial_enemy_defense1")
            {
               showSuperWeakTutorial("tutorial_enemy_defense2",false);
            }
            else if(className == "tutorial_enemy_defense2")
            {
               showSuperWeakTutorial("tutorial_enemy_defense3");
            }
            else if(className == "tutorial_enemy_defense3")
            {
               showSuperWeakTutorial("tutorial_enemy_defense4",false);
            }
            else
            {
               mSuperWeakTutorialDone = true;
            }
         };
         curX = mSuperWeakPopup.x;
         sign = isRight ? 1 : -1;
         offscreenX = isRight ? 900 : -100;
         offscreenY = mSuperWeakPopup.y;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup,0.08333333333333333,{
               "delay":1,
               "x":curX - sign * 40,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroySuperWeakTutorial() : void
      {
         if(mSuperWeakPopup)
         {
            mDBFacade.mTween.killTweensOf(mSuperWeakPopup);
            mSceneGraphComponent.removeChild(mSuperWeakPopup);
            mSuperWeakPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showLootSharingTutorial() : void
      {
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setLootSharingTutorialParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_loot_alt");
            if(popupClass == null)
            {
               return;
            }
            mLootSharingPopup = new popupClass();
            Locale.setText(mLootSharingPopup.title,"TUTORIAL_LOOT_TITLE");
            Locale.setText(mLootSharingPopup.shared_text,"TUTORIAL_LOOT_SHARED");
            Locale.setText(mLootSharingPopup.not_shared_text,"TUTORIAL_LOOT_NOT_SHARED");
            mLootSharingPopup.check.visible = false;
            mLootSharingCloseButton = new UIButton(mDBFacade,mLootSharingPopup.close);
            mLootSharingCloseButton.releaseCallback = finishLootSharingTutorial;
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset):void
            {
               var xpStar:MovieClip;
               var dbStar:MovieClip;
               var food:MovieClip;
               var treasureMC:MovieClip;
               var destX:Number;
               var destY:Number;
               var swfAsset2:SwfAsset = param1;
               var gold3:Class = swfAsset2.getClass("doober_currency_coin");
               var xp:Class = swfAsset2.getClass("doober_xp_star");
               var db:Class = swfAsset2.getClass("doober_db_star");
               var treasure:Class = swfAsset2.getClass("db_doobers_treasure_chest_basic");
               var foodClass:Class = swfAsset2.getClass("doober_health_burger");
               var gold:MovieClip = new gold3();
               gold.scaleX = gold.scaleY = 0.75;
               xpStar = new xp();
               xpStar.scaleX = xpStar.scaleY = 1;
               xpStar.x += 10;
               xpStar.y -= 10;
               dbStar = new db();
               dbStar.scaleX = dbStar.scaleY = 1.75;
               dbStar.x += 10;
               dbStar.y -= 10;
               food = new foodClass();
               food.scaleX = food.scaleY = 0.9;
               treasureMC = new treasure();
               treasureMC.scaleX = treasureMC.scaleY = 0.65;
               treasureMC.x += 10;
               treasureMC.y += 5;
               mLootSharingPopup.gold3.addChild(gold);
               mLootSharingPopup.xp.addChild(xpStar);
               mLootSharingPopup.db.addChild(dbStar);
               mLootSharingPopup.treasure.addChild(treasureMC);
               mLootSharingChestRenderer = new MovieClipRenderer(mDBFacade,treasureMC);
               mLootSharingChestRenderer.play(0,true);
               mLootSharingPopup.food.addChild(food);
               mSceneGraphComponent.addChild(mLootSharingPopup,105);
               mLootSharingPopup.scaleX = mLootSharingPopup.scaleY = 1.1764705882352942;
               destX = mDBFacade.viewWidth - mLootSharingPopup.width;
               destY = mDBFacade.viewHeight * 0.3;
               mLootSharingPopup.x = destX;
               mLootSharingPopup.y = destY;
               mDBFacade.mTween.createTimeline({
                  "tweens":[mDBFacade.mTween.tweenMaxTo(mLootSharingPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),mDBFacade.mTween.tweenMaxTo(mLootSharingPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.doLater(10,function(param1:GameClock):void
               {
                  if(!mLootSharingTutorialDone)
                  {
                     finishLootSharingTutorial();
                  }
               });
            });
         });
      }
      
      public function showSuperWeakTutorial(className:String, isRight:Boolean = true) : void
      {
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam())
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setSuperWeakParam();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass(className);
            if(popupClass == null)
            {
               return;
            }
            mSuperWeakPopup = new popupClass();
            Locale.setText(mSuperWeakPopup.title,"TUTORIAL_SUPER_WEAK_TITLE");
            mSuperWeakPopup.check.visible = false;
            mSuperWeakCloseButton = new UIButton(mDBFacade,mSuperWeakPopup.close);
            mSuperWeakCloseButton.releaseCallback = function():void
            {
               mLogicalWorkComponent.clear();
               finishSuperWeakTutorial(className,isRight);
            };
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset):void
            {
               var destXCaseRight:Number;
               var destXCaseLeft:Number;
               var destX:Number;
               var destY:Number;
               var swfAsset2:SwfAsset = param1;
               mSceneGraphComponent.addChild(mSuperWeakPopup,105);
               destXCaseRight = mDBFacade.viewWidth - mSuperWeakPopup.width / 1.6;
               destXCaseLeft = mSuperWeakPopup.width / 3;
               destX = isRight ? destXCaseRight : destXCaseLeft;
               destY = mDBFacade.viewHeight * 0.5;
               mSuperWeakPopup.x = destX;
               mSuperWeakPopup.y = destY;
               mDBFacade.mTween.createTimeline({
                  "tweens":[mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup,0.3333333333333333,{
                     "x":destX + 20,
                     "y":destY
                  }),mDBFacade.mTween.tweenMaxTo(mSuperWeakPopup,0.08333333333333333,{
                     "x":destX,
                     "y":destY
                  })],
                  "align":"sequence"
               });
               mLogicalWorkComponent.clear();
               mLogicalWorkComponent.doLater(5,function(param1:GameClock):void
               {
                  if(!mSuperWeakTutorialDone)
                  {
                     finishSuperWeakTutorial(className,isRight);
                  }
               });
            });
         });
      }
      
      public function finishChestTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         mDBFacade.dbAccountInfo.dbAccountParams.setChestCollectedTutorialParam();
         mChestTutorialDone = true;
         if(mChestPopup == null)
         {
            return;
         }
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishCooldownTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mCooldownTutorialReadyToClose)
         {
            return;
         }
         mCooldownTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishScalingTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mScalingTutorialReadyToClose)
         {
            return;
         }
         mScalingTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      public function finishRepeaterTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mRepeaterTutorialReadyToClose)
         {
            return;
         }
         mRepeaterTutorialDone = true;
         mChestPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChestTutorial();
         };
         curX = mChestPopup.x;
         offscreenX = mDBFacade.viewWidth + mChestPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function finishBusterTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mBusterTutorialDone)
         {
            mDBFacade.dbAccountInfo.dbAccountParams.setDungeonBusterTutorialParam();
         }
         mBusterTutorialDone = true;
         mBusterPopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyBusterTutorial();
         };
         curX = mBusterPopup.x;
         offscreenX = mDBFacade.viewWidth + mBusterPopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mBusterPopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mBusterPopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyChestTutorial() : void
      {
         if(mChestPopup)
         {
            mLogicalWorkComponent.clear();
            if(mCooldownRenderer)
            {
               mCooldownRenderer.destroy();
               mCooldownRenderer = null;
            }
            mDBFacade.mTween.killTweensOf(mChestPopup);
            mSceneGraphComponent.removeChild(mChestPopup);
            mChestCloseButton.destroy();
            mChestCloseButton = null;
            mChestPopup = null;
         }
         mTutorialComplete = true;
      }
      
      private function destroyBusterTutorial() : void
      {
         if(mBusterPopup)
         {
            mDBFacade.mTween.killTweensOf(mBusterPopup);
            mSceneGraphComponent.removeChild(mBusterPopup);
            mBusterCloseButton.destroy();
            mBusterCloseButton = null;
            mBusterPopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChestTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChestNearbyTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_chest");
            if(_loc3_ == null)
            {
               return;
            }
            mChestPopup = new _loc3_();
            Locale.setText(mChestPopup.title,"TUTORIAL_CHEST_TITLE");
            TextUtil.setText(mChestPopup.title1,Locale.getString("TUTORIAL_CHEST_DESC").toUpperCase());
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishChestTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 1;
            var _loc2_:Number = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = _loc2_;
            mChestPopup.y = _loc4_;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      public function showCooldownTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setCooldownTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_cooldown");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            Locale.setText(mChestPopup.title,"TUTORIAL_COOLDOWN_TITLE");
            TextUtil.setText(mChestPopup.description,Locale.getString("TUTORIAL_COOLDOWN_DESC").toUpperCase());
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishCooldownTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 1;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mCooldownTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mCooldownTutorialReadyToClose && !mCooldownTutorialDone)
               {
                  finishCooldownTutorial();
               }
            });
            mCooldownRenderer = new MovieClipRenderer(mDBFacade,mChestPopup.icon);
            mCooldownRenderer.play();
         });
      }
      
      public function showScalingTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setScalingTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_scaling");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            Locale.setText(mChestPopup.title,"TUTORIAL_SCALING_TITLE");
            TextUtil.setText(mChestPopup.description,Locale.getString("TUTORIAL_SCALING_DESC").toUpperCase());
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishScalingTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 1;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mScalingTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mScalingTutorialReadyToClose && !mScalingTutorialDone)
               {
                  finishScalingTutorial();
               }
            });
         });
      }
      
      public function showRepeaterTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setRepeaterTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_repeater");
            if(popupClass == null)
            {
               return;
            }
            mChestPopup = new popupClass();
            Locale.setText(mChestPopup.title,"TUTORIAL_REPEATER_TITLE");
            TextUtil.setText(mChestPopup.description,Locale.getString("TUTORIAL_REPEATER_DESC").toUpperCase());
            mChestPopup.check.visible = false;
            mChestCloseButton = new UIButton(mDBFacade,mChestPopup.close);
            mChestCloseButton.releaseCallback = finishRepeaterTutorial;
            mSceneGraphComponent.addChild(mChestPopup,105);
            mChestPopup.scaleX = mChestPopup.scaleY = 1;
            destX = mDBFacade.viewWidth - mChestPopup.width / 1.6;
            destY = mDBFacade.viewHeight * 0.5;
            mChestPopup.x = destX;
            mChestPopup.y = destY;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mChestPopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),mDBFacade.mTween.tweenMaxTo(mChestPopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mRepeaterTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mRepeaterTutorialReadyToClose && !mRepeaterTutorialDone)
               {
                  finishRepeaterTutorial();
               }
            });
         });
      }
      
      public function showBusterTutorial() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass("tutorial_db");
            if(_loc3_ == null)
            {
               return;
            }
            mBusterPopup = new _loc3_();
            Locale.setText(mBusterPopup.title,"TUTORIAL_BUSTER_TITLE");
            mBusterPopup.check.visible = false;
            showControllerPrompts(mBusterPopup,mDBFacade.steamInputManager.isSteamInputReady ? [mDBFacade.steamInputManager.getGlyphFilePathForAction("use_dungeon_buster")] : [],56,false);
            mBusterCloseButton = new UIButton(mDBFacade,mBusterPopup.close);
            mBusterCloseButton.releaseCallback = finishBusterTutorial;
            mSceneGraphComponent.addChild(mBusterPopup,105);
            mBusterPopup.scaleX = mBusterPopup.scaleY = 1;
            var _loc2_:Number = mDBFacade.viewWidth - mBusterPopup.width * 0.5 - 50;
            var _loc4_:Number = mDBFacade.viewHeight * 0.5;
            mBusterPopup.x = mDBFacade.viewWidth;
            mBusterPopup.y = _loc4_;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mBusterPopup,0.3333333333333333,{
                  "x":_loc2_ + 20,
                  "y":_loc4_
               }),mDBFacade.mTween.tweenMaxTo(mBusterPopup,0.08333333333333333,{
                  "x":_loc2_,
                  "y":_loc4_
               })],
               "align":"sequence"
            });
         });
      }
      
      private function finishChargeTutorial() : void
      {
         var advanceFunc:Function;
         var curX:Number;
         var offscreenX:Number;
         var offscreenY:Number;
         if(!mChargeTutorialReadyToClose)
         {
            return;
         }
         mChargeTutorialDone = true;
         mChargePopup.check.visible = true;
         advanceFunc = function():void
         {
            destroyChargeTutorial();
         };
         curX = mChargePopup.x;
         offscreenX = -mChargePopup.width;
         offscreenY = mDBFacade.viewHeight * 0.5;
         mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mChargePopup,0.08333333333333333,{
               "delay":1,
               "x":curX + 20,
               "y":offscreenY
            }),mDBFacade.mTween.tweenMaxTo(mChargePopup,0.3333333333333333,{
               "x":offscreenX,
               "y":offscreenY,
               "onComplete":advanceFunc
            })],
            "align":"sequence"
         });
      }
      
      private function destroyChargeTutorial() : void
      {
         if(mChargePopup)
         {
            mDBFacade.mTween.killTweensOf(mChargePopup);
            mSceneGraphComponent.removeChild(mChargePopup);
            mChargeCloseButton.destroy();
            mChargeCloseButton = null;
            mChargePopup = null;
         }
         mTutorialComplete = true;
      }
      
      public function showChargeTutorial() : void
      {
         mDBFacade.dbAccountInfo.dbAccountParams.setChargeTutorialParam();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),function(param1:SwfAsset):void
         {
            var destX:Number;
            var destY:Number;
            var swfAsset:SwfAsset = param1;
            var popupClass:Class = swfAsset.getClass("tutorial_charge");
            if(popupClass == null)
            {
               return;
            }
            mChargePopup = new popupClass();
            Locale.setText(mChargePopup.title,"TUTORIAL_CHARGE_TITLE");
            mChargePopup.check.visible = false;
            showControllerPrompts(mChargePopup,getAttackGlyphFilePaths(),56,false);
            mChargeCloseButton = new UIButton(mDBFacade,mChargePopup.close);
            mChargeCloseButton.releaseCallback = finishChargeTutorial;
            mSceneGraphComponent.addChild(mChargePopup,105);
            mChargePopup.scaleX = mChargePopup.scaleY = 1;
            destX = mChargePopup.width * 0.5 + 10;
            destY = mDBFacade.viewHeight * 0.5;
            mChargePopup.x = -mChargePopup.width;
            mChargePopup.y = destY;
            mDBFacade.mTween.createTimeline({
               "tweens":[mDBFacade.mTween.tweenMaxTo(mChargePopup,0.3333333333333333,{
                  "x":destX + 20,
                  "y":destY
               }),mDBFacade.mTween.tweenMaxTo(mChargePopup,0.08333333333333333,{
                  "x":destX,
                  "y":destY
               })],
               "align":"sequence"
            });
            mLogicalWorkComponent.doLater(3,function(param1:GameClock):void
            {
               mChargeTutorialReadyToClose = true;
            });
            mLogicalWorkComponent.doLater(6.5,function(param1:GameClock):void
            {
               if(mChargeTutorialReadyToClose && !mChargeTutorialDone)
               {
                  finishChargeTutorial();
               }
            });
         });
      }
      
      public function get isTutorialComplete() : Boolean
      {
         return mTutorialComplete;
      }
   }
}

