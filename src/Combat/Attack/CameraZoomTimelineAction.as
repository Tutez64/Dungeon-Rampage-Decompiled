package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   
   public class CameraZoomTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "zoom";
      
      private var mTask:Task;
      
      private var mDuration:Number = 0;
      
      private var mZoomFactor:Number = 1;
      
      private var mLerpInDuration:Number = 0;
      
      private var mLerpOutDuration:Number = 0;
      
      public function CameraZoomTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         if(parameterJson.duration == null)
         {
            Logger.error("CameraZoomTimelineAction: Must specify duration");
         }
         if(parameterJson.zoomFactor == null)
         {
            Logger.error("CameraZoomTimelineAction: Must specify zoomFactor");
         }
         var _loc5_:uint = 24;
         mDuration = parameterJson.duration / _loc5_;
         mZoomFactor = parameterJson.zoomFactor;
         mLerpInDuration = parameterJson.lerpInDuration != null ? parameterJson.lerpInDuration / _loc5_ : 0;
         mLerpOutDuration = parameterJson.lerpOutDuration != null ? parameterJson.lerpOutDuration / _loc5_ : 0;
         if(mDuration < mLerpInDuration + mLerpOutDuration)
         {
            Logger.error("CameraZoomTimelineAction: duration must be >= lerp in + lerp out");
            mDuration = mLerpInDuration + mLerpOutDuration;
         }
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object) : CameraZoomTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new CameraZoomTimelineAction(actorGameObject,actorView,dbFacade,parameterJson);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mLerpInDuration > 0)
         {
            this.mDBFacade.camera.tweenZoom(mLerpInDuration,mZoomFactor);
         }
         else
         {
            this.mDBFacade.camera.zoom = mZoomFactor;
         }
         mTask = mWorkComponent.doLater(mDuration - mLerpOutDuration,resetZoom);
      }
      
      private function resetZoom(gameClock:GameClock) : void
      {
         if(mLerpOutDuration > 0)
         {
            this.mDBFacade.camera.tweenToDefaultZoom(mLerpOutDuration);
         }
         else
         {
            this.mDBFacade.camera.zoom = this.mDBFacade.camera.defaultZoom;
         }
      }
      
      override public function destroy() : void
      {
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
   }
}

