package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import com.greensock.TweenMax;
   
   public class ActorDeadState extends ActorState
   {
      
      private static const ROT_ON_FLOOR_TIME:Number = 8;
      
      private static const ROT_ON_FLOOR_ALPHA:Number = 0.7;
      
      public static const NAME:String = "ActorDeadState";
      
      protected var mWorkComponent:LogicalWorkComponent;
      
      private var mFinishedDeathCallback:Task;
      
      public function ActorDeadState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView)
      {
         super(dbFacade,actorGameObject,actorView,"ActorDeadState");
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"ActorDeadState");
      }
      
      override public function destroy() : void
      {
         TweenMax.killTweensOf(mActorGameObject.view);
         TweenMax.killTweensOf(mActorGameObject.view.root);
         if(mFinishedDeathCallback != null)
         {
            mFinishedDeathCallback.destroy();
            mFinishedDeathCallback = null;
         }
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
      
      override public function enterState() : void
      {
         super.enterState();
         if(this.mActorGameObject.actorData.gMActor.CharType == "PROP")
         {
            propDeath();
         }
         else
         {
            enemyDeath();
         }
      }
      
      private function enemyDeath() : void
      {
         var deathAnimDuration:Number;
         var angle:Number;
         var actorView:ActorView = mActorGameObject.view as ActorView;
         if(actorView.hasAnim("death"))
         {
            deathAnimDuration = actorView.getAnimDurationInSeconds("death") + 8;
            mFinishedDeathCallback = mWorkComponent.doLater(deathAnimDuration,mFinishedCallback);
            actorView.playAnim("death",0,false,false);
         }
         else
         {
            switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
            {
               case "TIPOVER":
                  angle = Math.random() < 0.5 ? -90 : 90;
                  TweenMax.to(actorView,0.3,{"rotation":angle});
                  break;
               case "SMASH":
               default:
                  actorView.root.visible = false;
            }
            mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
         }
         mActorView.actionsForDeadState();
         if(actorView.currentWeapon && actorView.currentWeapon.weaponRenderer)
         {
            actorView.currentWeapon.weaponRenderer.stop();
         }
         actorView.removeFromStage();
         actorView.layer = 10;
         actorView.root.alpha = 0.7;
         actorView.addToStage();
         mWorkComponent.doLater(8 * 0.8,function(param1:GameClock):void
         {
            TweenMax.to(actorView.root,8 * 0.2,{"alpha":0});
         });
         mActorGameObject.removeNavColliders();
         if(mActorGameObject.isPet && mActorGameObject.usePetUI)
         {
            mDBFacade.hud.unregisterPet(mActorGameObject as NPCGameObject);
         }
      }
      
      private function propDeath() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:ActorView = mActorGameObject.view as ActorView;
         _loc1_.removeFromStage();
         _loc1_.layer = 10;
         _loc1_.root.alpha = 0.7;
         _loc1_.addToStage();
         if(_loc1_.hasAnim("death"))
         {
            _loc2_ = Math.random() < 0.5 ? -20 : 20;
            _loc2_ *= Math.random();
            TweenMax.to(_loc1_,0.3,{"rotation":_loc2_});
            _loc1_.playAnim("death",0,false,false);
         }
         else
         {
            switch(mActorGameObject.actorData.gMActor.DefaultDestruct)
            {
               case "TIPOVER":
                  _loc3_ = Math.random() < 0.5 ? -90 : 90;
                  TweenMax.to(_loc1_,0.3,{"rotation":_loc3_});
                  break;
               case "SMASH":
               default:
                  _loc1_.root.visible = false;
            }
            mFinishedDeathCallback = mWorkComponent.doLater(8,mFinishedCallback);
         }
         mActorView.actionsForDeadState();
         if(_loc1_.currentWeapon && _loc1_.currentWeapon.weaponRenderer)
         {
            _loc1_.currentWeapon.weaponRenderer.stop();
         }
         mActorGameObject.removeNavColliders();
         if(mActorGameObject.isPet && mActorGameObject.usePetUI)
         {
            mDBFacade.hud.unregisterPet(mActorGameObject as NPCGameObject);
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
      }
   }
}

