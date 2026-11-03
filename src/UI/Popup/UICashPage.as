package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Utils.TextUtil;
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
            Locale.setText(mContentMC.message_label,"HOW_TO_GEMS_CONTENT",null,1.55);
            TextUtil.fitToField(mContentMC.message_label);
         });
         super(dbFacade,"GEMS_HEADER_POPUP",Locale.getString("HOW_TO_GEMS_TITLE"),mContentMC,true,true,destroyPopup,true);
      }
      
      private function destroyPopup() : void
      {
         mContentMC = null;
         super.destroy();
      }
   }
}

