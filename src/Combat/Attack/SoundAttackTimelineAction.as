package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Sound.SoundAsset;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import Sound.DBSoundComponent;
   
   public class SoundAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "attackSound";
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSoundComponent:DBSoundComponent;
      
      public function SoundAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSoundComponent = new DBSoundComponent(mDBFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : SoundAttackTimelineAction
      {
         return new SoundAttackTimelineAction(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         var gmAttack:GMAttack;
         super.execute(timeline);
         gmAttack = mDBFacade.gameMaster.attackById.itemFor(mAttackType);
         if(gmAttack && gmAttack.AttackSound)
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),gmAttack.AttackSound,function(param1:SoundAsset):void
            {
               mSoundComponent.playSfxOneShot(param1,mActorView.worldCenter,0,gmAttack.AttackVolume);
            });
         }
      }
      
      override public function destroy() : void
      {
         mSoundComponent.destroy();
         mSoundComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         super.destroy();
      }
   }
}

