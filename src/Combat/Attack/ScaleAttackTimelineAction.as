package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class ScaleAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "scale";
      
      private var originalScaleValue:Number;
      
      private var scaleValue:Number;
      
      public function ScaleAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, scale:Number, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
         scaleValue = scale;
         originalScaleValue = actorView.root.scaleX;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : ScaleAttackTimelineAction
      {
         var _loc5_:Number = Number(actionObj.value);
         return new ScaleAttackTimelineAction(actorGameObject,actorView,_loc5_,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorView.root.scaleX = mActorView.root.scaleY = scaleValue;
      }
      
      override public function stop() : void
      {
         mActorView.root.scaleX = mActorView.root.scaleY = originalScaleValue;
         super.stop();
      }
   }
}

