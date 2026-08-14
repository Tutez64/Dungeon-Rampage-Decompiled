package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class AnimationFrameAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "animFrame";
      
      protected var mAnimName:String;
      
      public var mFrameNumber:uint;
      
      public function AnimationFrameAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, animName:String, frameNumber:uint)
      {
         super(actorGameObject,actorView,dbFacade);
         mFrameNumber = frameNumber;
         mAnimName = animName;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : AnimationFrameAttackTimelineAction
      {
         var _loc6_:String = actionObj.animName;
         var _loc5_:uint = uint(actionObj.frame);
         return new AnimationFrameAttackTimelineAction(actorGameObject,actorView,dbFacade,_loc6_,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorView.setAnimAt(mAnimName,mFrameNumber);
      }
   }
}

