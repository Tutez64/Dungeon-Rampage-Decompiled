package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import SteamInput.RumbleEffect;
   
   public class RumbleTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "rumbleEffect";
      
      private var mRumbleEffect:RumbleEffect;
      
      public function RumbleTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         if(parameterJson.intensity == null)
         {
            Logger.error("RumbleTimelineAction: Must specify intensity");
         }
         if(parameterJson.duration == null)
         {
            Logger.error("RumbleTimelineAction: Must specify duration");
         }
         mRumbleEffect = new RumbleEffect("AttackEffect",parameterJson.intensity,parameterJson.intensity,parameterJson.duration);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object) : RumbleTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new RumbleTimelineAction(actorGameObject,actorView,dbFacade,parameterJson);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mDBFacade.steamInputManager.playRumble(mRumbleEffect);
      }
      
      override public function destroy() : void
      {
         mWorkComponent.destroy();
         mWorkComponent = null;
         super.destroy();
      }
   }
}

