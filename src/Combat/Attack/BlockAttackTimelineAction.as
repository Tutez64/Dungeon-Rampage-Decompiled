package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class BlockAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "block";
      
      private var mMaximumDotForBlocking:Number;
      
      private var mPreviousBlockValue:Number;
      
      public function BlockAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, blockDot:Number)
      {
         super(actorGameObject,actorView,dbFacade);
         mMaximumDotForBlocking = blockDot;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : BlockAttackTimelineAction
      {
         var _loc5_:Number = Number(actionObj.blockDot);
         return new BlockAttackTimelineAction(actorGameObject,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         mActorGameObject.isBlocking = true;
         mActorGameObject.maximumDotForBlocking = mMaximumDotForBlocking;
         mPreviousBlockValue = mActorGameObject.maximumDotForBlocking;
      }
      
      override public function stop() : void
      {
         if(mActorGameObject)
         {
            mActorGameObject.maximumDotForBlocking = mPreviousBlockValue;
            mActorGameObject.isBlocking = false;
         }
         super.stop();
      }
   }
}

