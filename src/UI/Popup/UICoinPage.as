package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   
   public class UICoinPage extends DBUIPopup
   {
      
      private var mContentMC:MovieClip;
      
      public function UICoinPage(dbFacade:DBFacade)
      {
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("popup_coming_soon_content");
            mContentMC = new _loc2_() as MovieClip;
            Locale.setText(mContentMC.message_label,"HOW_TO_COINS_CONTENT",null,1.55);
            TextUtil.fitToField(mContentMC.message_label);
         });
         super(dbFacade,"COINS_HEADER_POPUP",Locale.getString("HOW_TO_COINS_TITLE"),mContentMC,true,true,destroyPopup,true);
      }
      
      private function destroyPopup() : void
      {
         mContentMC = null;
         super.destroy();
      }
   }
}

