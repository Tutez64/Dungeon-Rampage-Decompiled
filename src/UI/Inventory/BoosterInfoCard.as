package UI.Inventory
{
   import Account.DBInventoryInfo;
   import Account.StackableInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Events.BoostersParsedEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMBuff;
   import UI.CountdownTextTimer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class BoosterInfoCard extends UIObject
   {
      
      public static const UI_ICON_SWF_PATH:String = "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      public static const UI_BOOSTER_SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      private var mCountdownTextTimer:CountdownTextTimer;
      
      private var mDBFacade:DBFacade;
      
      private var mInfo:StackableInfo;
      
      private var mIcon:MovieClip;
      
      private var mBoostIcon:MovieClip;
      
      private var mActivateButton:UIButton;
      
      private var mActivateAnotherButton:UIButton;
      
      private var mSparkleController:MovieClipRenderController;
      
      protected var mEventComponent:EventComponent;
      
      private var mFlagIcon:Boolean = false;
      
      private var mFlagBooster:Boolean = false;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function BoosterInfoCard(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent, root:MovieClip)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         setupBoosterCardUI();
         hide();
      }
      
      override public function destroy() : void
      {
         if(mCountdownTextTimer != null)
         {
            mCountdownTextTimer.destroy();
            mCountdownTextTimer = null;
         }
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
      
      private function setupBoosterCardUI() : void
      {
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",this.handleBoostersParsedEvent);
      }
      
      public function set info(info:StackableInfo) : void
      {
         var invInfo:DBInventoryInfo;
         mInfo = info;
         if(mInfo == null)
         {
            mRoot.visible = false;
            hide();
         }
         else
         {
            if(mIcon != null)
            {
               mRoot.booster_icon.removeChild(mIcon);
               mIcon = null;
            }
            if(mBoostIcon != null)
            {
               mRoot.booster_activated.removeChild(mBoostIcon);
               mBoostIcon = null;
            }
            invInfo = mDBFacade.dbAccountInfo.inventoryInfo;
            if(mAssetLoadingComponent == null)
            {
               mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
            }
            setupBoosterInfoUI(mInfo);
            mRoot.label.text = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",mInfo.gmStackable.Constant);
            mRoot.description.text = GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",mInfo.gmStackable.Constant);
            mRoot.button_activate.label.text = Locale.getString("BOOSTER_CARD_ACTIVATE");
            mRoot.booster_activated.visible = false;
            mRoot.booster_activated.label_time.text = "00:00:00";
            mActivateButton = new UIButton(mDBFacade,mRoot.button_activate);
            mActivateButton.releaseCallback = function():void
            {
               activateBooster();
            };
            mActivateAnotherButton = new UIButton(mDBFacade,mRoot.booster_activated.activate_another);
            mActivateAnotherButton.releaseCallback = function():void
            {
               activateBooster();
            };
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),iconsLoaded);
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),boostersLoaded);
            setupTimer();
         }
      }
      
      private function setupTimer() : void
      {
         mRoot.button_activate.visible = false;
         mRoot.booster_activated.visible = true;
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_:Date = _loc2_.dateBooster(mInfo.gmId);
         if(mCountdownTextTimer != null)
         {
            mCountdownTextTimer.destroy();
            mCountdownTextTimer = null;
         }
         if(_loc1_ == null)
         {
            timeUp();
         }
         else
         {
            mCountdownTextTimer = new CountdownTextTimer(mRoot.booster_activated.label_time,_loc1_,GameClock.getWebServerDate,timeUp,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mCountdownTextTimer.start();
         }
      }
      
      private function timeUp() : void
      {
         mRoot.button_activate.visible = true;
         mRoot.booster_activated.visible = false;
         if(mCountdownTextTimer != null)
         {
            mCountdownTextTimer.destroy();
            mCountdownTextTimer = null;
         }
      }
      
      private function handleBoostersParsedEvent(event:BoostersParsedEvent) : void
      {
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         if(mCountdownTextTimer != null)
         {
            mCountdownTextTimer.destroy();
            mCountdownTextTimer = null;
         }
         if(mInfo != null)
         {
            this.info = _loc2_.getStackableByStackId(mInfo.gmId);
            if(getTimeLeft() > 0)
            {
               setupTimer();
            }
         }
         if(mInfo == null && mRoot != null)
         {
            hide();
         }
      }
      
      private function iconsLoaded(swfAsset:SwfAsset) : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         var _loc2_:Class = swfAsset.getClass(mInfo.iconName);
         mIcon = new _loc2_();
         mRoot.booster_icon.addChild(mIcon);
         mFlagIcon = true;
         if(mFlagIcon && mFlagBooster)
         {
            mRoot.visible = true;
            show();
         }
      }
      
      private function boostersLoaded(swfAsset:SwfAsset) : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         var _loc3_:GMBuff = mDBFacade.gameMaster.buffByConstant.itemFor(mInfo.gmStackable.Buff);
         var _loc4_:String = "inv_itemCard_boosterXP";
         var _loc2_:String = _loc3_.Exp + "X";
         if(_loc3_.Exp < _loc3_.Gold)
         {
            _loc4_ = "inv_itemCard_boosterCoin";
            _loc2_ = _loc3_.Gold + "X";
         }
         var _loc5_:Class = swfAsset.getClass(_loc4_);
         mBoostIcon = new _loc5_();
         var _loc6_:TextField = mRoot.booster_activated.booster_icon_text;
         if(mSparkleController == null)
         {
            mSparkleController = new MovieClipRenderController(mDBFacade,mRoot.booster_activated.booster_icon_anim);
            mSparkleController.play();
            mSparkleController.loop = true;
         }
         mRoot.booster_activated.addChild(mBoostIcon);
         mBoostIcon.x = mRoot.booster_activated.booster_icon.x;
         mBoostIcon.y = mRoot.booster_activated.booster_icon.y;
         mRoot.booster_activated.booster_icon.visible = false;
         mRoot.booster_activated.removeChild(_loc6_);
         mRoot.booster_activated.addChild(_loc6_);
         mRoot.booster_activated.booster_icon_text.text = _loc2_;
         mFlagBooster = true;
         if(mFlagIcon && mFlagBooster)
         {
            mRoot.visible = true;
            show();
         }
      }
      
      public function getTimeLeft() : Number
      {
         if(mInfo == null)
         {
            return 0;
         }
         var _loc2_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         var _loc1_:Date = _loc2_.dateBooster(mInfo.gmId);
         if(_loc1_ == null)
         {
            return 0;
         }
         return _loc1_.getTime() - GameClock.getWebServerTime();
      }
      
      private function activateBooster() : void
      {
         var _loc1_:StackableInfo = mInfo as StackableInfo;
         StoreServicesController.useAccountBooster(mDBFacade,_loc1_);
      }
      
      private function setupBoosterInfoUI(info:StackableInfo) : void
      {
      }
      
      public function hide() : void
      {
         this.visible = false;
      }
      
      public function show() : void
      {
         this.visible = true;
      }
      
      public function isShowing() : Boolean
      {
         return this.visible;
      }
   }
}

