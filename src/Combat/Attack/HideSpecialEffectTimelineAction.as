package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class HideSpecialEffectTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "hideSpecialEffect";
      
      public function HideSpecialEffectTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : HideSpecialEffectTimelineAction
      {
         return new HideSpecialEffectTimelineAction(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorView.hideSpecialEffect();
      }
      
      override public function stop() : void
      {
         mActorView.showSpecialEffect();
         super.stop();
      }
   }
}

