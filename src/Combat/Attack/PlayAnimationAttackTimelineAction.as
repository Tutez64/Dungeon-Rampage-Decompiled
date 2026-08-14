package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class PlayAnimationAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "playAnim";
      
      protected var mAnimName:String;
      
      public var mStartFrame:uint;
      
      protected var mScriptTimeline:ScriptTimeline;
      
      public function PlayAnimationAttackTimelineAction(scriptTimeline:ScriptTimeline, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, animName:String, startFrame:uint)
      {
         super(actorGameObject,actorView,dbFacade);
         mStartFrame = startFrame;
         mAnimName = animName;
         mScriptTimeline = scriptTimeline;
      }
      
      public static function buildFromJson(attackTimeline:ScriptTimeline, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : PlayAnimationAttackTimelineAction
      {
         var _loc7_:String = actionObj.animName;
         var _loc6_:uint = uint(actionObj.startFrame);
         return new PlayAnimationAttackTimelineAction(attackTimeline,actorGameObject,actorView,dbFacade,_loc7_,_loc6_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorView.playAnim(mAnimName,mStartFrame,true,false,mScriptTimeline.playSpeed);
      }
   }
}

