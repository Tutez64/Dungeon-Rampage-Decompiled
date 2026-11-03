package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DBUIPopup extends UIObject
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      protected static const POPUP_CLASS_NAME:String = "popup";
      
      protected static const EMPTY_POPUP_CLASS_NAME:String = "UI_loading_popup";
      
      protected static const CURTAIN_ALPHA:Number = 0.75;
      
      private var mUseOriginalPopUp:Boolean = false;
      
      protected var mDBFacade:DBFacade;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mWantCurtain:Boolean;
      
      protected var mCurtainActive:Boolean = false;
      
      protected var mTitle:TextField;
      
      protected var mMessage:TextField;
      
      protected var mContent:Sprite;
      
      protected var mCloseButton:UIButton;
      
      protected var mCloseCallback:Function;
      
      protected var mPopup:MovieClip;
      
      protected var mSwfAsset:SwfAsset;
      
      protected var mScalePopup:Boolean;
      
      protected var mUILayerName:String;
      
      public function DBUIPopup(dbFacade:DBFacade, uiLayerName:String, titleText:String = "", content:* = null, allowClose:Boolean = true, wantCurtain:Boolean = true, closeCallback:Function = null, useOriginalPopUp:Boolean = false, scalePopup:Boolean = true)
      {
         mDBFacade = dbFacade;
         super(dbFacade,new MovieClip());
         mUseOriginalPopUp = useOriginalPopUp;
         mScalePopup = scalePopup;
         mWantCurtain = wantCurtain;
         makeCurtain();
         if(waitsOnPlayer() && mDBFacade.uiHideToggle)
         {
            mDBFacade.uiHideToggle.reveal();
         }
         if(allowClose)
         {
            mCloseCallback = closeCallback;
            EventListeners.add(mDBFacade.stageRef,"keyDown",handleKeyDown);
         }
         mUILayerName = uiLayerName;
         mDBFacade.sceneGraphManager.addChild(mRoot,105);
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(getSwfPath()),function(param1:SwfAsset):void
         {
            setupUI(param1,titleText,content,allowClose,closeCallback);
            completeMenuNavigationSetup();
         });
      }
      
      public function getPagination() : MovieClip
      {
         Logger.error("Pagination for UIPopup shouldn\'t be available here.");
         return null;
      }
      
      protected function useCurtain() : Boolean
      {
         return true;
      }
      
      protected function waitsOnPlayer() : Boolean
      {
         return true;
      }
      
      protected function makeCurtain() : void
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      protected function removeCurtain() : void
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mFacade.sceneGraphManager.removePopupCurtain();
         }
      }
      
      protected function animatedEntrance() : void
      {
         makeCurtain();
      }
      
      override public function destroy() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mUILayerName)
         {
            removeMenuNavigationLayer();
         }
         mDBFacade.mTween.killTweensOf(mRoot);
         mDBFacade.sceneGraphManager.removeChild(mRoot);
         removeCurtain();
         EventListeners.remove(mDBFacade.stageRef,"keyDown",handleKeyDown);
         mDBFacade = null;
         mCloseCallback = null;
         if(mCloseButton)
         {
            mCloseButton.destroy();
         }
         mAssetLoadingComponent.destroy();
         mPopup = null;
         super.destroy();
      }
      
      protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      protected function getClassName() : String
      {
         return mUseOriginalPopUp ? "popup" : "UI_loading_popup";
      }
      
      public function colorizeMessage(tf:TextFormat, start:int, end:int) : void
      {
         mMessage.setTextFormat(tf,start,end);
      }
      
      protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         mSwfAsset = swfAsset;
         var popupClass:Class = swfAsset.getClass(this.getClassName());
         mPopup = new popupClass() as MovieClip;
         mRoot.addChild(mPopup);
         if(mPopup.message_label)
         {
            mPopup.message_label.mouseEnabled = false;
         }
         if(mPopup.left_button)
         {
            mPopup.left_button.visible = false;
         }
         if(mPopup.center_button)
         {
            mPopup.center_button.visible = false;
         }
         if(mPopup.right_button)
         {
            mPopup.right_button.visible = false;
         }
         if(mPopup.title_label)
         {
            mTitle = mPopup.title_label;
            TextUtil.setText(mTitle,titleText);
         }
         if(mPopup.message_label)
         {
            mMessage = mPopup.message_label;
            mMessage.text = "";
         }
         if(content is MovieClip)
         {
            mContent = mPopup.content;
            mContent.addChild(content);
         }
         else if(content is String)
         {
            setMessageText(content);
         }
         if(mPopup.close)
         {
            if(allowClose)
            {
               mCloseButton = new UIButton(mDBFacade,mPopup.close);
               mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
               mCloseButton.releaseCallback = function():void
               {
                  close(closeCallback);
               };
            }
            else
            {
               mPopup.close.visible = false;
            }
         }
         if(mScalePopup)
         {
            scalePopup();
            centerPopup();
         }
         if(mWantCurtain)
         {
            animatedEntrance();
         }
      }
      
      private function setMessageText(text:String) : void
      {
         TextUtil.setText(mMessage,text,1.55);
         if(mMessage.bottomScrollV < mMessage.numLines)
         {
            TextUtil.setText(mMessage,text);
         }
      }
      
      protected function handleKeyDown(event:KeyboardEvent) : void
      {
      }
      
      protected function handleInputCalledClosed() : void
      {
         this.close(mCloseCallback);
      }
      
      protected function close(callback:Function, offer:GMOffer = null) : void
      {
         if(callback != null)
         {
            if(offer == null)
            {
               callback();
            }
            else
            {
               callback(offer.getDisplayName(mDBFacade.gameMaster,Locale.getString("GIFT_UNKNOWN_NAME")),offer.Id);
            }
         }
         this.destroy();
      }
      
      protected function scalePopup() : void
      {
         mPopup.scaleX = mPopup.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
      }
      
      protected function centerPopup() : void
      {
         var _loc1_:Rectangle = mPopup.getBounds(mDBFacade.scalingRoot);
         mPopup.x = mDBFacade.viewWidth / 2 - _loc1_.width / 2 - _loc1_.x;
         mPopup.y = mDBFacade.viewHeight / 2 - _loc1_.height / 2 - _loc1_.y;
      }
      
      protected function initializeMenuNavigationLayer() : void
      {
         mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,getNavigationExitCallback(),getDefaultNavigationObject(),getInitialFocusedNavigationObject());
      }
      
      protected function getNavigationExitCallback() : Function
      {
         return handleInputCalledClosed;
      }
      
      protected function getDefaultNavigationObject() : UIObject
      {
         return mCloseButton;
      }
      
      protected function getInitialFocusedNavigationObject() : UIObject
      {
         return null;
      }
      
      protected function completeMenuNavigationSetup() : void
      {
         setupMenuNavigation();
         if(mUILayerName)
         {
            initializeMenuNavigationLayer();
         }
      }
      
      protected function removeMenuNavigationLayer() : void
      {
         mDBFacade.menuNavigationController.removeLayer(mUILayerName);
      }
      
      protected function setupMenuNavigation() : void
      {
      }
   }
}

