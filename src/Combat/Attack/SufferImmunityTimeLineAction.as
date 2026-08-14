package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class SufferImmunityTimeLineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "sufferImmunity";
      
      private var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      private var mCanSuffer:Boolean;
      
      private var mCanSuffer_original:Boolean;
      
      public function SufferImmunityTimeLineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, canSuffer:Boolean)
      {
         super(actorGameObject,actorView,dbFacade);
         mHeroGameObjectOwner = null;
         mCanSuffer = canSuffer;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : SufferImmunityTimeLineAction
      {
         var _loc5_:Boolean = Boolean(actionObj.value);
         return new SufferImmunityTimeLineAction(actorGameObject,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mHeroGameObjectOwner = mActorGameObject as HeroGameObjectOwner;
         if(mHeroGameObjectOwner != null)
         {
            mCanSuffer_original = mHeroGameObjectOwner.canSuffer;
            mHeroGameObjectOwner.canSuffer = mCanSuffer;
         }
      }
      
      override public function stop() : void
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canSuffer = mCanSuffer_original;
         }
         mHeroGameObjectOwner = null;
         super.stop();
      }
   }
}

