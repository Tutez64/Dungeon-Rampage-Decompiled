package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorRenderer;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMActor;
   
   public class ActorDeadState extends ActorState
   {
      
      private static const ROT_ON_FLOOR_TIME:Number = 8;
      
      private static const ROT_ON_FLOOR_ALPHA:Number = 0.7;
      
      public static const NAME:String = "ActorDeadState";
      
      protected var mWorkComponent:LogicalWorkComponent;
      
      private var mFinishedDeathCallback:Task;
      
      private var mPendingDeathCallback:Function;
      
      public function ActorDeadState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView)
      {
         super(dbFacade,actorGameObject,actorView,"ActorDeadState");
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"ActorDeadState");
      }
      
      override public function destroy() : void
      {
         mDBFacade.mTween.killTweensOf(mActorGameObject.view);
         mDBFacade.mTween.killTweensOf(mActorGameObject.view.root);
         if(mFinishedDeathCallback != null)
         {
            mFinishedDeathCallback.destroy();
            mFinishedDeathCallback = null;
         }
         clearPendingDeathCallback();
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
      
      override public function enterState() : void
      {
         super.enterState();
         if(this.mActorGameObject.actorData.gMActor.CharType == GMActor.CHAR_TYPE_PROP)
         {
            propDeath();
         }
         else
         {
            enemyDeath();
         }
      }
      
      private function setupDeadActorCommon() : void
      {
         mActorView.removeFromStage();
         mActorView.layer = 10;
         mActorView.root.alpha = 0.7;
         mActorView.addToStage();
         mActorView.actionsForDeadState();
         if(mActorView.currentWeapon && mActorView.currentWeapon.weaponRenderer)
         {
            mActorView.currentWeapon.weaponRenderer.stop();
         }
         mActorGameObject.removeNavColliders();
         if(mActorGameObject.isPet && mActorGameObject.usePetUI)
         {
            mDBFacade.hud.unregisterPet(mActorGameObject as NPCGameObject);
         }
      }
      
      private function clearPendingDeathCallback() : void
      {
         if(mPendingDeathCallback == null)
         {
            return;
         }
         var _loc1_:ActorRenderer = mActorView.bodyAnimRenderer;
         if(_loc1_ != null)
         {
            _loc1_.removeLoadCompleteCallback(mPendingDeathCallback);
         }
         mPendingDeathCallback = null;
      }
      
      private function enemyDeath() : void
      {
         mActorView.root.visible = true;
         setupDeadActorCommon();
         mWorkComponent.doLater(8 * 0.8,function(param1:GameClock):void
         {
            mDBFacade.mTween.tweenMaxTo(mActorView.root,8 * 0.2,{"alpha":0});
         });
         tryScheduleEnemyDeathOrFallback();
      }
      
      private function tryScheduleEnemyDeathOrFallback() : void
      {
         var deathAnimDuration:Number;
         var bodyRenderer:ActorRenderer;
         var angle:Number;
         var actorView:ActorView = mActorGameObject.view as ActorView;
         if(actorView.hasAnim("death"))
         {
            deathAnimDuration = actorView.getAnimDurationInSeconds("death") + 8;
            mFinishedDeathCallback = mWorkComponent.doLater(deathAnimDuration,mFinishedCallback);
            actorView.playAnim("death",0,false,false);
            return;
         }
         bodyRenderer = actorView.bodyAnimRenderer;
         if(bodyRenderer != null && bodyRenderer.isStarlingLoading)
         {
            clearPendingDeathCallback();
            mPendingDeathCallback = function():void
            {
               mPendingDeathCallback = null;
               tryScheduleEnemyDeathOrFallback();
            };
            bodyRenderer.addLoadCompleteCallback(mPendingDeathCallback);
            return;
         }
         switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
         {
            case GMActor.DESTRUCTION_TIPOVER:
               angle = Math.random() < 0.5 ? -90 : 90;
               mDBFacade.mTween.tweenMaxTo(actorView,0.3,{"rotation":angle});
               break;
            case GMActor.DESTRUCTION_SMASH:
            default:
               actorView.root.visible = false;
               if(actorView.bodyAnimRenderer != null)
               {
                  actorView.bodyAnimRenderer.visible = false;
               }
         }
         mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
      }
      
      private function propDeath() : void
      {
         setupDeadActorCommon();
         trySchedulePropDeathOrFallback();
      }
      
      private function trySchedulePropDeathOrFallback() : void
      {
         var corpseAngle:Number;
         var propDeathDuration:Number;
         var fadeStart:Number;
         var bodyRenderer:ActorRenderer;
         var angle:Number;
         var actorView:ActorView = mActorGameObject.view as ActorView;
         if(actorView.hasAnim("death"))
         {
            corpseAngle = Math.random() < 0.5 ? -20 : 20;
            corpseAngle *= Math.random();
            mDBFacade.mTween.tweenMaxTo(actorView,0.3,{"rotation":corpseAngle});
            propDeathDuration = actorView.getAnimDurationInSeconds("death") + 8;
            mFinishedDeathCallback = mWorkComponent.doLater(propDeathDuration,mFinishedCallback);
            actorView.playAnim("death",0,false,false);
            fadeStart = propDeathDuration - 8 * 0.2;
            if(fadeStart < 0)
            {
               fadeStart = 0;
            }
            mWorkComponent.doLater(fadeStart,function(param1:GameClock):void
            {
               mDBFacade.mTween.tweenMaxTo(actorView.root,8 * 0.2,{"alpha":0});
            });
            return;
         }
         bodyRenderer = actorView.bodyAnimRenderer;
         if(bodyRenderer != null && bodyRenderer.isStarlingLoading)
         {
            clearPendingDeathCallback();
            mPendingDeathCallback = function():void
            {
               mPendingDeathCallback = null;
               trySchedulePropDeathOrFallback();
            };
            bodyRenderer.addLoadCompleteCallback(mPendingDeathCallback);
            return;
         }
         switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
         {
            case GMActor.DESTRUCTION_TIPOVER:
               angle = Math.random() < 0.5 ? -90 : 90;
               mDBFacade.mTween.tweenMaxTo(actorView,0.3,{"rotation":angle});
               break;
            case GMActor.DESTRUCTION_SMASH:
            default:
               actorView.root.visible = false;
               if(actorView.bodyAnimRenderer != null)
               {
                  actorView.bodyAnimRenderer.visible = false;
               }
         }
         mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
         if(actorView.root.visible)
         {
            mWorkComponent.doLater(8 * 0.8,function(param1:GameClock):void
            {
               mDBFacade.mTween.tweenMaxTo(actorView.root,8 * 0.2,{"alpha":0});
            });
         }
      }
      
      override public function exitState() : void
      {
         super.exitState();
         if(mFinishedDeathCallback != null)
         {
            mFinishedDeathCallback.destroy();
            mFinishedDeathCallback = null;
         }
         clearPendingDeathCallback();
      }
   }
}

