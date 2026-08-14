package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class UIWhatsNewPopup extends DBUITwoButtonPopup
   {
      
      private static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      private var mPopUpClassName:String = "whatsnew_popup";
      
      private var mImageURL:String;
      
      private var mImageLocator:MovieClip;
      
      private var massetLoadingComponent:AssetLoadingComponent;
      
      private var mLoadingPopUp:DBUIPopup;
      
      private var mImageRetreived:Boolean = false;
      
      private var mUseCurtain:Boolean = true;
      
      public function UIWhatsNewPopup(dbFacade:DBFacade, popupClassName:String, titleText:String, messageText:String, imageURL:String, mainText:String, mainCallback:Function, webText:String, webURL:String, showPagination:Boolean)
      {
         var webCallback:Function;
         massetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mImageURL = imageURL;
         mPopUpClassName = popupClassName;
         if(webURL)
         {
            webCallback = function():void
            {
               var _loc1_:URLRequest = new URLRequest(webURL);
               navigateToURL(_loc1_,"_blank");
            };
         }
         mUseCurtain = !showPagination;
         super(dbFacade,titleText,messageText,mainText,mainCallback,webText,webCallback);
         if(!mImageRetreived)
         {
            mLoadingPopUp = new DBUIPopup(mDBFacade,"LOADING");
            MemoryTracker.track(mLoadingPopUp,"DBUIPopup - created in UIWhatsNewPopup.UIWhatsNewPopup()");
         }
         if(!showPagination)
         {
            mPopup.left_button_news.visible = false;
            mPopup.pagination.visible = false;
         }
         else
         {
            mPopup.left_button.visible = false;
            mLeftButton = new UIButton(mDBFacade,mPopup.left_button_news);
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mLeftButton.label.text = mLeftText;
            mLeftButton.releaseCallback = function():void
            {
               close(mLeftCallback);
            };
         }
      }
      
      override protected function animatedEntrance() : void
      {
         if(mUseCurtain)
         {
            super.animatedEntrance();
         }
      }
      
      override public function getPagination() : MovieClip
      {
         return mPopup.pagination;
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return mPopUpClassName;
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText.toLocaleUpperCase(),content,allowClose,closeCallback);
         Logger.debug("MOD: mPopup: " + mPopup);
         mImageLocator = mPopup.whatsnew_image;
         Logger.debug("MOD: ImageLocator: " + mImageLocator);
         massetLoadingComponent.getImageAsset(mImageURL,function(param1:ImageAsset):void
         {
            if(mLoadingPopUp)
            {
               mLoadingPopUp.destroy();
               mLoadingPopUp = null;
            }
            Logger.debug("MOD: ImageAsset: " + param1);
            mImageLocator.addChild(param1.image);
            param1.image.x = param1.image.width * -0.5;
            param1.image.y = param1.image.height * -0.5;
            mImageRetreived = true;
         },function():void
         {
            if(mLoadingPopUp)
            {
               mLoadingPopUp.destroy();
               mLoadingPopUp = null;
            }
         });
      }
      
      override public function destroy() : void
      {
         if(massetLoadingComponent != null)
         {
            massetLoadingComponent.destroy();
            massetLoadingComponent = null;
         }
         super.destroy();
         mImageLocator = null;
      }
   }
}

