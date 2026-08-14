package Config
{
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Utils.ConfigManager;
   import Facade.DBFacade;
   
   public class DBConfigManager extends ConfigManager
   {
      
      private var mFilePathsToOpen:Array = ["./DbConfiguration/Config.json"];
      
      private var mConfigsToLoad:Array;
      
      protected var mEventComponent:EventComponent;
      
      protected var mDBFacade:DBFacade;
      
      public function DBConfigManager(dbFacade:DBFacade)
      {
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mConfigsToLoad = mDBFacade.mAdditionalConfigFilesToLoad.concat(mFilePathsToOpen);
         super(dbFacade,mConfigsToLoad,null,handleFailure);
      }
      
      override protected function finishedLoadingFiles() : void
      {
         super.finishedLoadingFiles();
         Logger.info("Build Version development");
         mEventComponent.dispatchEvent(new ConfigFileLoadedEvent(this));
      }
      
      private function handleFailure() : void
      {
         Logger.fatal("Failed to load config files: " + mConfigsToLoad);
      }
   }
}

