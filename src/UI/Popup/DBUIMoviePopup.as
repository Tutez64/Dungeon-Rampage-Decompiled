package UI.Popup
{
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import UI.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   
   public class DBUIMoviePopup extends DBUIOneButtonPopup
   {
      
      private static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      private var mContainerMC:MovieClip = new MovieClip();
      
      private var mLoader:Loader;
      
      private var mMoviePlayer:Object;
      
      private var mWidth:Number;
      
      private var mHeight:Number;
      
      private var mPopUpClassName:String;
      
      private var mLoadingPopUp:DBUIPopup;
      
      private var mUseCurtain:Boolean = true;
      
      public function DBUIMoviePopup(dbFacade:DBFacade, popUpClassName:String, titleText:String, contentText:String, moviePath:String, centerText:String, centerCallback:Function, width:Number, height:Number, showPagination:Boolean)
      {
         mPopUpClassName = popUpClassName;
         mWidth = width;
         mHeight = height;
         mUseCurtain = !showPagination;
         super(dbFacade,titleText,mContainerMC,centerText,centerCallback);
         mMessage.text = contentText;
         mLoadingPopUp = new DBUIPopup(mDBFacade,"LOADING",null,true,false);
         MemoryTracker.track(mLoadingPopUp,"DBUIPopup - created in DBUIMoviePopup.DBUIMoviePopup()");
         mLoader = new Loader();
         mLoader.contentLoaderInfo.addEventListener("init",onLoaderInit);
         mLoader.contentLoaderInfo.addEventListener("ioError",loaderIOErrorHandler);
         mLoader.load(new URLRequest(moviePath));
         if(!showPagination)
         {
            mPopup.center_button_news.visible = false;
            mPopup.pagination.visible = false;
         }
         else
         {
            mPopup.center_button.visible = false;
            mCenterButton = new UIButton(mDBFacade,mPopup.center_button_news);
            mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mCenterButton.label.text = mCenterText;
            mCenterButton.releaseCallback = function():void
            {
               close(mCenterCallback);
            };
         }
      }
      
      override protected function animatedEntrance() : void
      {
         super.animatedEntrance();
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
      
      private function loaderIOErrorHandler(e:IOErrorEvent) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         destroy();
      }
      
      private function onLoaderInit(event:Event) : void
      {
         mContainerMC.addChild(mLoader);
         mLoader.x = -mWidth / 2;
         mLoader.y = -mHeight / 2;
         mLoader.content.addEventListener("onReady",onPlayerReady);
         mLoader.content.addEventListener("onError",onPlayerError);
         mLoader.content.addEventListener("onStateChange",onPlayerStateChange);
         mLoader.content.addEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange);
      }
      
      private function onPlayerReady(event:Event) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
         mMoviePlayer = mLoader.content;
         mMoviePlayer.setSize(mWidth,mHeight);
      }
      
      private function onPlayerError(event:Event) : void
      {
         mLoadingPopUp.destroy();
         mLoadingPopUp = null;
      }
      
      private function onPlayerStateChange(event:Event) : void
      {
      }
      
      private function onVideoPlaybackQualityChange(event:Event) : void
      {
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mContainerMC = null;
         mLoader.contentLoaderInfo.removeEventListener("init",onLoaderInit);
         if(mLoader.content)
         {
            mLoader.content.removeEventListener("onReady",onPlayerReady);
            mLoader.content.removeEventListener("onError",onPlayerError);
            mLoader.content.removeEventListener("onStateChange",onPlayerStateChange);
            mLoader.content.removeEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange);
            mLoader.unloadAndStop();
         }
         mLoader = null;
      }
   }
}

