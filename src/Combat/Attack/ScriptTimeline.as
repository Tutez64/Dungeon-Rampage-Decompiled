package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.CombatResult;
   import org.as3commons.collections.ArrayList;
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.ILinkedListIterator;
   import org.as3commons.collections.framework.IListIterator;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class ScriptTimeline
   {
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mTargetActor:ActorGameObject;
      
      protected var mActorView:ActorView;
      
      protected var mScriptJson:Object;
      
      protected var mDBFacade:DBFacade;
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      protected var mTimelineActions:Map;
      
      protected var mFinishedCallback:Function;
      
      protected var mStopCallback:Function;
      
      protected var mPlayHeadTime:Number = 0;
      
      protected var mLastExecutedFrame:int = -1;
      
      protected var mFinishedFrame:int = 0;
      
      protected var mLoop:Boolean;
      
      protected var mHasGoto:Boolean;
      
      protected var mAutoAim:Boolean;
      
      protected var mIsPlaying:Boolean = false;
      
      protected var mIsLooping:Boolean = false;
      
      protected var mTotalFrames:uint;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mPlayTimelineTask:Task;
      
      protected var mCurrentAttackType:uint;
      
      protected var mCurrentGMAttack:GMAttack;
      
      protected var mCurrentCombatResult:CombatResult;
      
      protected var mCurrentAttacker:ActorGameObject;
      
      protected var mPlaySpeed:Number = 1;
      
      private var mContinuousCollisions:ArrayList;
      
      private var mRemovalContinuous:ArrayList;
      
      public var mManagedEffects:ArrayList;
      
      public function ScriptTimeline(actorGameObject:ActorGameObject, actorView:ActorView, scriptJson:Object, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor)
      {
         super();
         mDBFacade = dbFacade;
         mDistributedDungeonFloor = distributedDungeonFloor;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"ScriptTimeline");
         mTimelineActions = new Map();
         mActorView = actorView;
         mActorGameObject = actorGameObject;
         mScriptJson = scriptJson;
         parseJson(mScriptJson);
         mContinuousCollisions = new ArrayList();
         mRemovalContinuous = new ArrayList();
         mManagedEffects = new ArrayList();
      }
      
      public function set playSpeed(val:Number) : void
      {
         mPlaySpeed = val;
      }
      
      public function get playSpeed() : Number
      {
         return mPlaySpeed;
      }
      
      public function getPercentageOfTimelinePlayed() : Number
      {
         return mLastExecutedFrame / mTotalFrames;
      }
      
      public function getTimeRemaining() : Number
      {
         var _loc1_:Number = mTotalFrames - mLastExecutedFrame;
         return _loc1_ * mDBFacade.gameClock.tickLength / playSpeed;
      }
      
      protected function parseJson(jsonObj:Object) : void
      {
         var _loc6_:AttackTimelineAction = null;
         var _loc11_:LinkedList = null;
         var _loc7_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:* = 0;
         var _loc10_:Array = null;
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         var _loc2_:Object = null;
         var _loc12_:Array = jsonObj.frames;
         mTotalFrames = jsonObj.totalFrames;
         var _loc4_:uint = _loc12_.length;
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            _loc5_ = _loc12_[_loc7_];
            _loc3_ = uint(_loc5_.frame);
            _loc10_ = _loc5_.actions;
            _loc8_ = _loc10_.length;
            _loc11_ = new LinkedList();
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc2_ = _loc10_[_loc9_] as Object;
               _loc6_ = parseAction(_loc2_);
               if(_loc6_ != null)
               {
                  if(_loc3_ >= jsonObj.totalFrames)
                  {
                     Logger.error("ScriptTimeline.as " + jsonObj.attackName + " action:" + _loc6_ + " at frame:" + _loc3_ + " after last frame:" + (jsonObj.totalFrames - 1));
                  }
                  _loc11_.add(_loc6_);
               }
               _loc9_++;
            }
            mTimelineActions.add(_loc3_,_loc11_);
            _loc7_++;
         }
         mFinishedFrame = jsonObj.totalFrames;
      }
      
      protected function parseAction(actionObj:Object) : AttackTimelineAction
      {
         mHasGoto = false;
         var _loc3_:String = actionObj.type as String;
         var _loc2_:AttackTimelineAction = null;
         switch(_loc3_)
         {
            case "attackSound":
               _loc2_ = SoundAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "sound":
               _loc2_ = SoundTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "animFrame":
               _loc2_ = AnimationFrameAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "playAnim":
               _loc2_ = PlayAnimationAttackTimelineAction.buildFromJson(this,mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "move":
               _loc2_ = MovementAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "runIdleMonitor":
               _loc2_ = RunIdleMonitorTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "goto":
               mHasGoto = true;
               _loc2_ = GotoTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj,gotoFrame);
               break;
            case "knockback":
               _loc2_ = KnockBackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade);
               break;
            case "shake":
               _loc2_ = CameraShakeTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "effect":
               _loc2_ = PlayEffectTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "color":
               _loc2_ = ColorShiftTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "glow":
               _loc2_ = GlowTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "fadebackground":
               _loc2_ = FadeBackgroundTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "visible":
               _loc2_ = HideTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "hideSpecialEffect":
               _loc2_ = HideSpecialEffectTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "scale":
               _loc2_ = ScaleAttackTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
            case "zoom":
            case "timeScale":
            case "circleCollider":
            case "rectangleCollider":
            case "inputType":
            case "sufferImmunity":
               _loc2_ = SufferImmunityTimeLineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "knockbackImmunity":
               _loc2_ = KnockbackImmunityTimeLineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            case "attemptRevive":
            case "proposeRevive":
            case "spawndoober":
            case "spawnnpc":
            case "invulnerable":
               break;
            case "teleport":
               _loc2_ = TeleportTimelineAction.buildFromJson(mActorGameObject,mActorView,mDBFacade,actionObj);
               break;
            default:
               if(_loc3_.charAt(0) != "#")
               {
                  Logger.debug("No handle for attack timeline action type: " + _loc3_);
               }
         }
         return _loc2_;
      }
      
      public function set currentAttackType(attackType:uint) : void
      {
         mCurrentAttackType = attackType;
         mCurrentGMAttack = mDBFacade.gameMaster.attackById.itemFor(attackType);
         if(mCurrentGMAttack == null)
         {
            Logger.error("Could not find GMAttack for id: " + attackType);
         }
      }
      
      public function get currentGMAttack() : GMAttack
      {
         return mCurrentGMAttack;
      }
      
      public function set currentCombatResult(combatResult:CombatResult) : void
      {
         mCurrentCombatResult = combatResult;
         currentAttackType = combatResult.attack.attackType;
      }
      
      public function set currentAttacker(attacker:ActorGameObject) : void
      {
         mCurrentAttacker = attacker;
      }
      
      public function get isPlaying() : Boolean
      {
         return mIsPlaying;
      }
      
      public function get loop() : Boolean
      {
         return mLoop || mHasGoto;
      }
      
      public function get autoAim() : Boolean
      {
         return mAutoAim;
      }
      
      public function set autoAim(value:Boolean) : void
      {
         mAutoAim = value;
      }
      
      public function play(playSpeed:Number, targetActor:ActorGameObject, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         mPlayHeadTime = 0;
         mTargetActor = targetActor;
         mIsPlaying = true;
         mLoop = loop;
         mPlaySpeed = playSpeed;
         if(mPlayTimelineTask != null)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask == null;
         }
         mFinishedCallback = finishedCallback;
         mStopCallback = stopCallback;
         mLastExecutedFrame = -1;
         applyCurrentTimelineValues();
         mPlayTimelineTask = mLogicalWorkComponent.doEveryFrame(update);
         update(mLogicalWorkComponent.gameClock);
      }
      
      protected function applyCurrentTimelineValues() : void
      {
         extractActionToUpdateCurrentValues(mTimelineActions);
      }
      
      protected function extractActionToUpdateCurrentValues(timelineActions:Map) : void
      {
         var _loc4_:LinkedList = null;
         var _loc5_:ILinkedListIterator = null;
         var _loc3_:AttackTimelineAction = null;
         var _loc2_:IMapIterator = timelineActions.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc4_ = _loc2_.next() as LinkedList;
            _loc5_ = _loc4_.iterator() as ILinkedListIterator;
            while(_loc5_.hasNext())
            {
               _loc3_ = _loc5_.next() as AttackTimelineAction;
               updateAction(_loc3_);
            }
         }
      }
      
      protected function updateAction(timelineAction:AttackTimelineAction) : void
      {
         timelineAction.combatResult = mCurrentCombatResult;
         timelineAction.attacker = mCurrentAttacker;
         timelineAction.attackType = mCurrentAttackType;
      }
      
      public function stop() : void
      {
         var _loc1_:* = 0;
         mIsPlaying = false;
         stopAllActions();
         if(mStopCallback != null)
         {
            mStopCallback();
            mStopCallback = null;
         }
         if(mPlayTimelineTask != null)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask = null;
         }
         var _loc2_:IListIterator = mManagedEffects.iterator() as IListIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next() as uint;
            mActorGameObject.distributedDungeonFloor.effectManager.endManagedEffect(_loc1_);
         }
         mManagedEffects.clear();
      }
      
      public function stopAndFinish() : void
      {
         if(!mIsPlaying)
         {
            return;
         }
         stop();
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
         }
         else
         {
            Logger.warn("the finished callback on the AttackTimeline was null during a non-loop attack.");
         }
      }
      
      private function stopAllActions() : void
      {
         var _loc4_:LinkedList = null;
         var _loc5_:ILinkedListIterator = null;
         var _loc3_:AttackTimelineAction = null;
         var _loc6_:AttackTimelineAction = null;
         var _loc2_:Array = [];
         var _loc1_:IMapIterator = mTimelineActions.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc4_ = _loc1_.next() as LinkedList;
            _loc5_ = _loc4_.iterator() as ILinkedListIterator;
            while(_loc5_.hasNext())
            {
               _loc3_ = _loc5_.next() as AttackTimelineAction;
               _loc2_.push(_loc3_);
            }
         }
         while(_loc2_.length > 0)
         {
            _loc6_ = _loc2_.pop();
            _loc6_.stop();
         }
      }
      
      private function gotoFrame(gotoFrame:int) : void
      {
         mPlayHeadTime = gotoFrame;
         mIsLooping = true;
      }
      
      protected function processTimelineFrame(timelineActionMap:Map, currentFrame:int, gameClock:GameClock) : void
      {
         var _loc5_:LinkedList = null;
         var _loc6_:ILinkedListIterator = null;
         var _loc4_:AttackTimelineAction = null;
         if(currentFrame == mLastExecutedFrame && !mIsLooping)
         {
            return;
         }
         if(timelineActionMap.hasKey(currentFrame))
         {
            _loc5_ = timelineActionMap.itemFor(currentFrame);
            _loc6_ = _loc5_.iterator() as ILinkedListIterator;
            while(_loc6_.hasNext())
            {
               _loc4_ = _loc6_.next() as AttackTimelineAction;
               _loc4_.execute(this);
            }
         }
      }
      
      protected function update(gameClock:GameClock) : void
      {
         var _loc3_:* = 0;
         if(mFinishedFrame <= mLastExecutedFrame && mFinishedFrame <= mPlayHeadTime)
         {
            timelineActionsFinished();
            return;
         }
         var _loc2_:uint = mLastExecutedFrame + 1;
         if(mPlayHeadTime < mLastExecutedFrame)
         {
            _loc2_ = mPlayHeadTime - 1;
         }
         _loc3_ = _loc2_;
         while(_loc3_ <= mPlayHeadTime)
         {
            processTimelineActions(_loc3_,gameClock);
            mLastExecutedFrame = _loc3_;
            _loc3_++;
         }
         updatePlayHead(gameClock);
      }
      
      protected function updatePlayHead(gameClock:GameClock) : void
      {
         mPlayHeadTime += mPlaySpeed * gameClock.timeScale;
      }
      
      protected function processTimelineActions(frame:int, gameClock:GameClock) : void
      {
         processTimelineFrame(mTimelineActions,frame,gameClock);
         processContinuousCollision();
      }
      
      protected function timelineActionsFinished() : void
      {
         if(mLoop)
         {
            mPlayHeadTime = 0;
            return;
         }
         stopAndFinish();
      }
      
      public function destroy() : void
      {
         var _loc1_:ILinkedListIterator = null;
         var _loc4_:LinkedList = null;
         var _loc2_:AttackTimelineAction = null;
         mActorGameObject = null;
         mActorView = null;
         mDBFacade = null;
         mDistributedDungeonFloor = null;
         var _loc3_:IMapIterator = mTimelineActions.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc1_ = _loc4_.iterator() as ILinkedListIterator;
            while(_loc1_.hasNext())
            {
               _loc2_ = _loc1_.next();
               _loc2_.destroy();
            }
            _loc4_.clear();
         }
         mTimelineActions.clear();
         mTimelineActions = null;
         mFinishedCallback = null;
         mStopCallback = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         if(mPlayTimelineTask)
         {
            mPlayTimelineTask.destroy();
            mPlayTimelineTask = null;
         }
         mCurrentGMAttack = null;
         mCurrentCombatResult = null;
         mCurrentAttacker = null;
         mContinuousCollisions.clear();
         mContinuousCollisions = null;
         mManagedEffects.clear();
         mManagedEffects = null;
      }
      
      public function get attackName() : String
      {
         return mScriptJson.attackName;
      }
      
      public function get currentFrame() : uint
      {
         return mLastExecutedFrame;
      }
      
      public function get targetActor() : ActorGameObject
      {
         return mTargetActor;
      }
      
      public function addContinuousCollision(collTA:ColliderTimelineAction) : void
      {
         mContinuousCollisions.add(collTA);
      }
      
      public function processContinuousCollision() : void
      {
         var _loc1_:IListIterator = null;
         var _loc2_:ColliderTimelineAction = null;
         if(mContinuousCollisions.size > 0)
         {
            _loc1_ = mContinuousCollisions.iterator() as IListIterator;
            while(_loc1_.hasNext())
            {
               _loc2_ = _loc1_.next() as ColliderTimelineAction;
               if(!_loc2_.perFrameUpCall(this))
               {
                  mRemovalContinuous.add(_loc2_);
               }
            }
            _loc1_ = mRemovalContinuous.iterator() as IListIterator;
            while(_loc1_.hasNext())
            {
               _loc2_ = _loc1_.next() as ColliderTimelineAction;
               mContinuousCollisions.remove(_loc2_);
            }
            mRemovalContinuous.clear();
         }
      }
   }
}

