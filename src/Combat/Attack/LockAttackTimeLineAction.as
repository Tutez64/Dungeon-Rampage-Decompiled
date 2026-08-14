package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class LockAttackTimeLineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "lockAttack";
      
      private var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      public function LockAttackTimeLineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
         mHeroGameObjectOwner = null;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) : LockAttackTimeLineAction
      {
         return new LockAttackTimeLineAction(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mHeroGameObjectOwner = mActorGameObject as HeroGameObjectOwner;
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canInitiateAnAttack = false;
         }
      }
      
      override public function stop() : void
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canInitiateAnAttack = true;
         }
         super.stop();
      }
   }
}

