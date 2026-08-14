package Combat.Attack
{
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class InputTypeTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "inputType";
      
      private var mHeroGameObjectOwner:HeroGameObjectOwner;
      
      private var mInputType:String;
      
      public function InputTypeTimelineAction(heroOwner:HeroGameObjectOwner, actorView:ActorView, dbFacade:DBFacade, inputType:String)
      {
         super(heroOwner,actorView,dbFacade);
         mHeroGameObjectOwner = heroOwner;
         mInputType = inputType;
         if(mHeroGameObjectOwner == null)
         {
            Logger.error("ActorGameObject passed into InputTypeTimelineAction is not a HeroGameObjectOwner.");
         }
      }
      
      public static function buildFromJson(heroOwner:HeroGameObjectOwner, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : InputTypeTimelineAction
      {
         var _loc5_:String = actionObj.inputType;
         return new InputTypeTimelineAction(heroOwner,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mHeroGameObjectOwner.inputController.inputType = mInputType;
      }
      
      override public function stop() : void
      {
         super.stop();
         if(mHeroGameObjectOwner && mHeroGameObjectOwner.inputController)
         {
            mHeroGameObjectOwner.inputController.inputType = "free";
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(mHeroGameObjectOwner && mHeroGameObjectOwner.inputController)
         {
            mHeroGameObjectOwner.inputController.inputType = "free";
         }
      }
   }
}

