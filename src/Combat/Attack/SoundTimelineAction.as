package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Facade.DBFacade;
   import Sound.DBSoundComponent;
   
   public class SoundTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "sound";
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSoundComponent:DBSoundComponent;
      
      protected var mSwfPath:String;
      
      protected var mSoundName:String;
      
      public function SoundTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, swfPath:String, soundName:String)
      {
         super(actorGameObject,actorView,dbFacade);
         mSwfPath = swfPath;
         mSoundName = soundName;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSoundComponent = new DBSoundComponent(mDBFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : SoundTimelineAction
      {
         return new SoundTimelineAction(actorGameObject,actorView,dbFacade,actionObj.path,actionObj.name);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         if(mSwfPath && mSoundName)
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(mSwfPath),mSoundName,function(param1:SoundAsset):void
            {
               mSoundComponent.playSfxOneShot(param1,mActorView.worldCenter);
            });
         }
         else
         {
            Logger.error("SoundTimelineAction: invalid sound: swfPath: " + mSwfPath + " soundName: " + mSoundName);
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

