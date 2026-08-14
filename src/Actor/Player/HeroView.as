package Actor.Player
{
   import Actor.ActorView;
   import Brain.Sound.SoundAsset;
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class HeroView extends ActorView
   {
      
      protected var mHeroPlayerObject:HeroGameObject;
      
      public function HeroView(dbFacade:DBFacade, heroGameObject:HeroGameObject)
      {
         mWantNametag = true;
         mHeroPlayerObject = heroGameObject;
         super(dbFacade,heroGameObject);
      }
      
      override public function destroy() : void
      {
         mHeroPlayerObject = null;
         super.destroy();
      }
      
      public function playHeroLevelUpEffects() : void
      {
         mHeroPlayerObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"db_fx_levelup",new Vector3D(),mHeroPlayerObject);
         mHeroPlayerObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"db_fx_levelup_background",new Vector3D(),mHeroPlayerObject,true,1,0,0,0,0,false,"background");
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"LevelUp2",function(param1:SoundAsset):void
         {
            mSoundComponent.playSfxOneShot(param1,null);
         });
      }
   }
}

