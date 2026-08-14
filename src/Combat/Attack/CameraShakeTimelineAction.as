package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   
   public class CameraShakeTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "shake";
      
      private var mDuration:Number = 0;
      
      private var mNumShakes:uint = 0;
      
      private var mRotation:Number = 0;
      
      private var mX:Number = 0;
      
      private var mY:Number = 0;
      
      public function CameraShakeTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         if(parameterJson.duration == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify duration");
         }
         if(parameterJson.numShakes == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify numShakes");
         }
         if(parameterJson.rotation == null && parameterJson.x == null && parameterJson.y == null)
         {
            Logger.error("CameraShakeTimelineAction: Must specify at least one of rotation, x, or y");
         }
         var _loc5_:uint = 24;
         mDuration = parameterJson.duration / _loc5_;
         mNumShakes = parameterJson.numShakes;
         mRotation = parameterJson.rotation;
         mX = parameterJson.x;
         mY = parameterJson.y;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object) : CameraShakeTimelineAction
      {
         if(actorGameObject.isOwner || actorGameObject.actorData.gMActor.CanShakeCamera)
         {
            return new CameraShakeTimelineAction(actorGameObject,actorView,dbFacade,parameterJson);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            if(mRotation)
            {
               this.mDBFacade.camera.shakeRotation(mDuration,mRotation,mNumShakes);
            }
            if(mX)
            {
               this.mDBFacade.camera.shakeX(mDuration,mX,mNumShakes);
            }
            if(mY)
            {
               this.mDBFacade.camera.shakeY(mDuration,mY,mNumShakes);
            }
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
   }
}

