package UI.Gifting
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   
   public class UIGift
   {
      
      public static const GIFT_POPUP_CLASS_NAME:String = "gift_popup";
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mTownRoot:MovieClip;
      
      private var mGiftPopup:MovieClip;
      
      private var mCurtainActive:Boolean = false;
      
      private var mCloseCallback:Function;
      
      private var mStoreCallback:Function;
      
      private var mCloseButton:UIButton;
      
      private var mAcceptAllGiftsButton:UIButton;
      
      private var mSendGiftButton:UIButton;
      
      private var mScrollUpButton:UIButton;
      
      private var mScrollDownButton:UIButton;
      
      private var mScrollIndex:int;
      
      private var mGiftsVector:Vector.<UIGiftMessage>;
      
      private var mInfoMessageTF:TextField;
      
      public function UIGift(dbFacade:DBFacade, townRoot:MovieClip, closeCallback:Function, callbackToStore:Function)
      {
         super();
         mDBFacade = dbFacade;
         mTownRoot = townRoot;
         mCloseCallback = closeCallback;
         mStoreCallback = callbackToStore;
         mGiftsVector = new Vector.<UIGiftMessage>();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIGift");
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),giftPopupLoaded);
         mDBFacade.stageRef.addEventListener("keyDown",handleKeyDown);
      }
      
      private function giftPopupLoaded(swfAsset:SwfAsset) : void
      {
         var popupClass:Class = swfAsset.getClass("gift_popup");
         mGiftPopup = new popupClass();
         mGiftPopup.title_label.text = Locale.getString("GIFT_POPUP_TITLE");
         mGiftPopup.scaleY = mGiftPopup.scaleX = 1.8;
         mGiftPopup.x = 300;
         mSendGiftButton = new UIButton(mDBFacade,mGiftPopup.left_button);
         mSendGiftButton.label.text = Locale.getString("GIFT_POPUP_SEND_GIFT");
         mSendGiftButton.releaseCallback = function():void
         {
            if(mStoreCallback != null)
            {
               mStoreCallback();
            }
         };
         mAcceptAllGiftsButton = new UIButton(mDBFacade,mGiftPopup.right_button);
         mAcceptAllGiftsButton.label.text = Locale.getString("GIFT_POPUP_ACCEPT_ALL");
         if(mDBFacade.dbAccountInfo.gifts.size > 0)
         {
            mAcceptAllGiftsButton.releaseCallback = function():void
            {
               mDBFacade.dbAccountInfo.acceptAllGifts(refresh);
            };
         }
         else
         {
            mAcceptAllGiftsButton.enabled = false;
            SceneGraphManager.setGrayScaleSaturation(mAcceptAllGiftsButton.root,10);
         }
         mCloseButton = new UIButton(mDBFacade,mGiftPopup.close);
         mCloseButton.releaseCallback = this.destroy;
         mGiftsVector.push(new UIGiftMessage(mDBFacade,mGiftPopup.message_1,this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,mGiftPopup.message_2,this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,mGiftPopup.message_3,this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,mGiftPopup.message_4,this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,mGiftPopup.message_5,this));
         mScrollUpButton = new UIButton(mDBFacade,mGiftPopup.up);
         mScrollDownButton = new UIButton(mDBFacade,mGiftPopup.down);
         if(mDBFacade.dbAccountInfo.gifts.size < mGiftsVector.length)
         {
            mScrollDownButton.visible = false;
            mScrollUpButton.visible = false;
         }
         mScrollUpButton.releaseCallback = function():void
         {
            scrollIndex = -1;
         };
         mScrollDownButton.releaseCallback = function():void
         {
            scrollIndex = 1;
         };
         mScrollIndex = 0;
         mSceneGraphComponent.addChild(mGiftPopup,105);
         showCurtain();
         scrollIndex = 0;
         mInfoMessageTF = mGiftPopup.message_label;
         mInfoMessageTF.text = Locale.getString("GIFT_POPUP_INFO_MESSAGE");
      }
      
      private function showCurtain() : void
      {
         if(!mCurtainActive)
         {
            mCurtainActive = true;
            mSceneGraphComponent.showPopupCurtain();
         }
      }
      
      private function removeCurtain() : void
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mSceneGraphComponent.removePopupCurtain();
         }
      }
      
      private function populateGiftMessages() : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc1_:Array = mDBFacade.dbAccountInfo.gifts.keysToArray();
         if(_loc1_.length < mGiftsVector.length)
         {
            hideGiftMessages();
         }
         _loc2_ = 0;
         while(_loc2_ < mGiftsVector.length)
         {
            _loc3_ = uint(_loc2_ + mScrollIndex);
            if(_loc3_ >= _loc1_.length)
            {
               break;
            }
            mGiftsVector[_loc2_].root.visible = true;
            mGiftsVector[_loc2_].populateGiftMessage(mDBFacade.dbAccountInfo.gifts.itemFor(_loc1_[_loc3_]));
            _loc2_++;
         }
      }
      
      public function set scrollIndex(value:int) : void
      {
         mScrollIndex += value;
         var _loc2_:uint = 0;
         if(mDBFacade.dbAccountInfo.gifts.size > mGiftsVector.length)
         {
            _loc2_ = mDBFacade.dbAccountInfo.gifts.size - mGiftsVector.length;
         }
         if(mScrollIndex <= 0)
         {
            mScrollIndex = 0;
         }
         if(mScrollIndex >= _loc2_)
         {
            mScrollIndex = _loc2_;
         }
         if(mScrollIndex == 0)
         {
            mScrollUpButton.enabled = false;
         }
         else
         {
            mScrollUpButton.enabled = true;
         }
         if(mScrollIndex == _loc2_)
         {
            mScrollDownButton.enabled = false;
         }
         else
         {
            mScrollDownButton.enabled = true;
         }
         populateGiftMessages();
      }
      
      private function hideGiftMessages() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < mGiftsVector.length)
         {
            mGiftsVector[_loc1_].root.visible = false;
            _loc1_++;
         }
      }
      
      public function refresh() : void
      {
         populateGiftMessages();
         if(mDBFacade.dbAccountInfo.gifts.size == 0)
         {
            destroy();
         }
      }
      
      private function handleKeyDown(event:KeyboardEvent) : void
      {
         if(event.keyCode == 27)
         {
            this.destroy();
         }
      }
      
      public function destroy() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",handleKeyDown);
         mDBFacade = null;
         if(mGiftPopup)
         {
            mSceneGraphComponent.removeChild(mGiftPopup);
         }
         removeCurtain();
         mGiftPopup = null;
         mTownRoot = null;
         mStoreCallback = null;
         if(mCloseButton)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mAcceptAllGiftsButton)
         {
            mAcceptAllGiftsButton.root.filters = [];
            mAcceptAllGiftsButton.destroy();
         }
         mAcceptAllGiftsButton = null;
         if(mSendGiftButton)
         {
            mSendGiftButton.destroy();
         }
         mSendGiftButton = null;
         for each(var _loc1_:UIGiftMessage in mGiftsVector)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         mGiftsVector.splice(0,mGiftsVector.length);
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         if(mCloseCallback != null)
         {
            mCloseCallback();
         }
         mCloseCallback = null;
      }
   }
}

