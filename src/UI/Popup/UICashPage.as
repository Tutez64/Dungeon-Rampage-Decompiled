package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   
   public class UICashPage extends DBUIPopup
   {
      
      private var mContentMC:MovieClip;
      
      public function UICashPage(dbFacade:DBFacade)
      {
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("popup_coming_soon_content");
            mContentMC = new _loc2_() as MovieClip;
            mContentMC.message_label.text = Locale.getString("HOW_TO_GEMS_CONTENT");
         });
         super(dbFacade,Locale.getString("HOW_TO_GEMS_TITLE"),mContentMC,true,true,destroyPopup,true,true,"GEMS_HEADER_POPUP");
      }
      
      private function destroyPopup() : void
      {
         mContentMC = null;
         super.destroy();
      }
   }
}

