package Floor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   
   public class FloorMessageView
   {
      
      private static const DESTROY_TIME:Number = 2;
      
      private var mDBFacade:DBFacade;
      
      private var mMessageKey:String;
      
      private var mMessageString:String;
      
      private var mMessageClip:MovieClip;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function FloorMessageView(dbFacade:DBFacade, messageKey:String, messageString:String = "")
      {
         super();
         mDBFacade = dbFacade;
         mMessageKey = messageKey;
         mMessageString = messageString;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"FloorMessageView");
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"FloorMessageView");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),assetLoaded);
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         var textClass:Class = swfAsset.getClass("floor_message");
         mMessageClip = new textClass();
         mMessageClip.message_text_01.autoSize = "center";
         mMessageClip.message_text_01.multiline = true;
         if(mMessageString != "")
         {
            mMessageClip.message_text_01.text = mMessageString;
         }
         else
         {
            mMessageClip.message_text_01.text = Locale.getString(mMessageKey);
         }
         if(mMessageClip.message_text_01.textWidth > 700)
         {
            mMessageClip.message_text_01.autoSize = "center";
         }
         mMessageClip.x = mDBFacade.viewWidth / 2;
         mMessageClip.y = mDBFacade.viewHeight / 2 + 100;
         mSceneGraphComponent.addChild(mMessageClip,105);
         mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
         {
            destroy();
         });
      }
      
      public function destroy() : void
      {
         mSceneGraphComponent.removeChild(mMessageClip);
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         mMessageClip = null;
         mDBFacade = null;
      }
   }
}

