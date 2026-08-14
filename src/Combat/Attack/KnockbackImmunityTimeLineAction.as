package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class KnockbackImmunityTimeLineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "knockbackImmunity";
      
      private var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      private var mCanBeKnockedBack:Boolean;
      
      private var mCanBeKnockedBack_original:Boolean;
      
      public function KnockbackImmunityTimeLineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, canBeKnockedBack:Boolean)
      {
         super(actorGameObject,actorView,dbFacade);
         mHeroGameObjectOwner = null;
         mCanBeKnockedBack = canBeKnockedBack;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : KnockbackImmunityTimeLineAction
      {
         var _loc5_:Boolean = Boolean(actionObj.value);
         return new KnockbackImmunityTimeLineAction(actorGameObject,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mHeroGameObjectOwner = mActorGameObject as HeroGameObjectOwner;
         if(mHeroGameObjectOwner != null)
         {
            mCanBeKnockedBack_original = mHeroGameObjectOwner.canBeKnockedBack;
            mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack;
         }
      }
      
      override public function stop() : void
      {
         if(mHeroGameObjectOwner != null)
         {
            mHeroGameObjectOwner.canBeKnockedBack = mCanBeKnockedBack_original;
         }
         mHeroGameObjectOwner = null;
         super.stop();
      }
   }
}

