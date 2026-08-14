package UI.Inventory.Chests
{
   import Account.AvatarInfo;
   import Account.ChestInfo;
   import Account.InventoryBaseInfo;
   import Account.KeyInfo;
   import Account.StoreServices;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.MovieClipRenderer;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMSkin;
   import UI.Hud.UIHud;
   import UI.Popup.DBUIPopup;
   import flash.display.MovieClip;
   
   public class ChestInfoCard extends UIObject
   {
      
      public static const UNLOCK_CHEST_COIN_EVENT:String = "ChestUnlockCoin";
      
      public static const UNLOCK_CHEST_COIN_TRY_EVENT:String = "ChestUnlockCoinTry";
      
      public static const UNLOCK_CHEST_GEM_EVENT:String = "ChestUnlockGem";
      
      public static const UNLOCK_CHEST_GEM_TRY_EVENT:String = "ChestUnlockGemTry";
      
      public static const UNLOCK_CHEST_KEY_EVENT:String = "ChestUnlockKey";
      
      public static const KEEP_CHEST_EVENT:String = "ChestKept";
      
      public static const ABANDON_CHEST:String = "ChestAbandoned";
      
      private var mDBFacade:DBFacade;
      
      private var mChestInfo:ChestInfo;
      
      private var mChestCardMC:MovieClip;
      
      private var mChestRenderer:MovieClipRenderer;
      
      private var mChestIconHolder:MovieClip;
      
      private var mChestIconUnequippable:MovieClip;
      
      private var mChestKeysMC:MovieClip;
      
      private var mChestKeySlots:Vector.<ChestKeySlot>;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mChestRevealPopUp:ChestRevealPopUp;
      
      private var mChestCanBeOpened:Boolean;
      
      private var mChestBuyKeysPopUp:ChestBuyKeysPopUp;
      
      private var mKeyThatCanOpenChest:KeyInfo;
      
      private var mPurchasingPopUp:DBUIPopup;
      
      private var mChestCardAbandonButton:UIButton;
      
      private var mChestCardOpenButton:UIButton;
      
      private var mChestCardOpenButtonDS:UIButton;
      
      private var mChestCardKeepButtonDS:UIButton;
      
      private var mChestCardAbandonButtonDS:UIButton;
      
      private var mAbandonChestCallback:Function;
      
      private var mOpenChestCallback:Function;
      
      private var mAbandonChestCallbackDS:Function;
      
      private var mOpenChestCallbackDS:Function;
      
      private var mKeepChestCallbackDS:Function;
      
      private var mDontUpdateChestInfo:Boolean;
      
      public var selectedHeroId:uint;
      
      public function ChestInfoCard(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent, root:MovieClip, abandonChestCallback:Function, openChestCallback:Function, abandonChestCallbackDS:Function, openChestCallbackDS:Function, keepChestCallbackDS:Function)
      {
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mSceneGraphComponent = sceneGraphComponent;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"ChestInfoCard");
         mOpenChestCallback = openChestCallback;
         mAbandonChestCallback = abandonChestCallback;
         mOpenChestCallbackDS = openChestCallbackDS;
         mAbandonChestCallbackDS = abandonChestCallbackDS;
         mKeepChestCallbackDS = keepChestCallbackDS;
         setupChestCardUI();
         setupKeyCardUI();
         hide();
      }
      
      private function setupChestCardUI() : void
      {
         mChestCardMC = root.chest_card;
         mChestCardMC.selection_01.visible = true;
         mChestCardMC.selection_02.visible = false;
         mChestCardAbandonButton = new UIButton(mDBFacade,mChestCardMC.selection_01.abandon);
         mChestCardAbandonButton.label.text = Locale.getString("ABANDON");
         mChestCardAbandonButton.releaseCallback = function():void
         {
            mAbandonChestCallback(mChestInfo);
         };
         mChestCardOpenButton = new UIButton(mDBFacade,mChestCardMC.selection_01.open);
         mChestCardOpenButton.label.text = Locale.getString("UNLOCK");
         mChestCardOpenButton.releaseCallback = function():void
         {
            mOpenChestCallback(mChestInfo);
         };
         mChestCardAbandonButtonDS = new UIButton(mDBFacade,mChestCardMC.selection_02.abandon);
         mChestCardAbandonButtonDS.label.text = Locale.getString("ABANDON");
         mChestCardAbandonButtonDS.releaseCallback = function():void
         {
            mAbandonChestCallbackDS(mChestInfo);
         };
         mChestCardOpenButtonDS = new UIButton(mDBFacade,mChestCardMC.selection_02.open);
         mChestCardOpenButtonDS.label.text = Locale.getString("UNLOCK");
         mChestCardOpenButtonDS.releaseCallback = function():void
         {
            mOpenChestCallbackDS(mChestInfo);
         };
         mChestCardKeepButtonDS = new UIButton(mDBFacade,mChestCardMC.selection_02.keep);
         mChestCardKeepButtonDS.label.text = Locale.getString("KEEP");
         mChestCardKeepButtonDS.releaseCallback = function():void
         {
            mKeepChestCallbackDS(mChestInfo);
         };
         mChestIconHolder = mChestCardMC.item_icon;
         mChestIconUnequippable = mChestCardMC.unequippable;
         mChestIconUnequippable.visible = false;
      }
      
      private function setupKeyCardUI() : void
      {
         if(root.chest_card_keys)
         {
            mChestKeysMC = root.chest_card_keys;
            mChestKeysMC.label.text = Locale.getString("KEYS_OWNED");
            mChestKeySlots = new Vector.<ChestKeySlot>();
         }
      }
      
      public function hide() : void
      {
         this.visible = false;
      }
      
      public function show() : void
      {
         this.visible = true;
      }
      
      public function set info(info:InventoryBaseInfo) : void
      {
         if(mDontUpdateChestInfo)
         {
            return;
         }
         mChestInfo = info as ChestInfo;
         if(mChestInfo == null)
         {
            hide();
         }
         else
         {
            show();
            refreshChestInfoUI();
            refreshKeyInfoUI();
            if(!UIHud.isThisAConsumbleChestId(mChestInfo.gmId))
            {
               refreshHeroInfoUI();
            }
         }
      }
      
      public function refreshChestInfoUI() : void
      {
         loadIcon();
         mChestCardMC.label.text = GameMasterLocale.getGameMasterSubString("CHEST_NAME",mChestInfo.gmChestInfo.Rarity);
         if(mChestInfo.isFromDungeonSummary())
         {
            mChestCardMC.selection_01.visible = false;
            mChestCardMC.selection_02.visible = true;
         }
         else
         {
            mChestCardMC.selection_01.visible = true;
            mChestCardMC.selection_02.visible = false;
         }
      }
      
      public function refreshKeyInfoUI() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:MovieClip = null;
         mChestCanBeOpened = false;
         if(mChestKeySlots)
         {
            _loc2_ = 0;
            while(_loc2_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc2_].destroy();
               _loc2_++;
            }
            mChestKeySlots.splice(0,mChestKeySlots.length);
         }
         _loc3_ = 0;
         while(_loc3_ < 6)
         {
            if(mChestKeySlots)
            {
               _loc1_ = mChestKeysMC.getChildByName("slot_" + _loc3_.toString()) as MovieClip;
               if(_loc1_)
               {
                  mChestKeySlots.push(new ChestKeySlot(mDBFacade,_loc1_,mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_],mAssetLoadingComponent));
               }
            }
            if(mChestInfo.gmChestInfo.Id == mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_].gmKey.ChestId)
            {
               mKeyThatCanOpenChest = mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_];
               if(_loc1_)
               {
                  mChestKeySlots[_loc3_].setSelected(true);
                  if(mChestKeySlots[_loc3_].keyInfo.count > 0)
                  {
                     mChestCanBeOpened = true;
                  }
                  mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mKeyThatCanOpenChest.gmKeyOffer.BundleSwfFilepath),loadKeyIconOnButton);
               }
            }
            else if(_loc1_)
            {
               mChestKeySlots[_loc3_].setSelected(false);
            }
            _loc3_++;
         }
      }
      
      public function refreshHeroInfoUI(mc:MovieClip = null) : void
      {
         var mSelectedHero:GMHero;
         var mHeroInfo:AvatarInfo;
         var gmSkin:GMSkin;
         if(mc == null)
         {
            mc = mChestCardMC;
         }
         mc.hero_label.text = Locale.getString("OPENING_WITH");
         mSelectedHero = mDBFacade.gameMaster.Heroes[selectedHeroId];
         mHeroInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
         if(mHeroInfo == null)
         {
            hide();
            return;
         }
         gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
         if(gmSkin == null)
         {
            Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.IconSwfFilepath),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass(gmSkin.IconName);
               if(_loc3_ == null)
               {
                  return;
               }
               var _loc4_:MovieClip = new _loc3_();
               var _loc2_:MovieClipRenderController = new MovieClipRenderController(mDBFacade,_loc4_);
               _loc2_.play();
               if(mc.avatar.numChildren > 0)
               {
                  mc.avatar.removeChildAt(0);
               }
               mc.avatar.addChildAt(_loc4_,0);
               _loc4_.scaleX = _loc4_.scaleY = 1;
            });
         }
      }
      
      private function loadKeyIconOnButton(swfAsset:SwfAsset) : void
      {
         var _loc3_:Class = swfAsset.getClass(mKeyThatCanOpenChest.gmKeyOffer.BundleIcon);
         var _loc2_:MovieClip = new _loc3_() as MovieClip;
         _loc2_.scaleX = _loc2_.scaleY = 0.5;
         if(!mChestInfo.isFromDungeonSummary())
         {
            if(mChestCardOpenButton.root.pick.numChildren > 0)
            {
               mChestCardOpenButton.root.pick.removeChildAt(0);
            }
            mChestCardOpenButton.root.pick.addChild(_loc2_);
         }
         else
         {
            if(mChestCardOpenButtonDS.root.pick.numChildren > 0)
            {
               mChestCardOpenButtonDS.root.pick.removeChildAt(0);
            }
            mChestCardOpenButtonDS.root.pick.addChild(_loc2_);
         }
      }
      
      public function canChestBeOpened() : Boolean
      {
         return mChestCanBeOpened;
      }
      
      public function loadIcon() : void
      {
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         var swfPath:String = mChestInfo.gmChestInfo.IconSwf;
         var iconName:String = mChestInfo.gmChestInfo.IconName;
         while(mChestIconHolder.numChildren > 1)
         {
            mChestIconHolder.removeChildAt(1);
         }
         ChestInfo.loadItemIcon(swfPath,iconName,mChestIconHolder,mDBFacade,70,mChestInfo.iconScale,mAssetLoadingComponent);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mChestIconHolder);
         mChestRenderer.play(0,true);
         bgColoredExists = mChestInfo.hasColoredBackground;
         bgSwfPath = mChestInfo.backgroundSwfPath;
         bgIconName = mChestInfo.backgroundIconName;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
            {
               var _loc3_:MovieClip = null;
               var _loc2_:Class = param1.getClass(bgIconName);
               if(_loc2_)
               {
                  _loc3_ = new _loc2_() as MovieClip;
                  mChestIconHolder.addChildAt(_loc3_,1);
               }
            });
         }
      }
      
      public function createRevealPopUp(closeRevealPopUp:Function, goToStorage:Function) : void
      {
         mSceneGraphComponent.fadeOut(0.5,0.75);
         mChestRevealPopUp = new ChestRevealPopUp(mDBFacade,mChestInfo.gmChestInfo,closeRevealPopUp,goToStorage);
      }
      
      public function closeChestRevealPopUp() : void
      {
         if(mChestRevealPopUp)
         {
            mDontUpdateChestInfo = false;
            mSceneGraphComponent.fadeIn(0.5);
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
      }
      
      public function updateRevealLoot(details:*) : void
      {
         if(mChestRevealPopUp)
         {
            mChestRevealPopUp.updateRevealLoot(details);
         }
      }
      
      public function showBuyKeysPopUp(swfAsset:SwfAsset) : void
      {
         mSceneGraphComponent.fadeOut(0.5,0.75);
         mChestBuyKeysPopUp = new ChestBuyKeysPopUp(mDBFacade,mAssetLoadingComponent,mSceneGraphComponent,swfAsset,mChestInfo.gmChestInfo,chestBuyCoinCallback,chestBuyGemCallback,closeBuyKeysPopUp,refreshHeroInfoUI);
      }
      
      private function chestBuyCoinCallback(val:Number) : Function
      {
         return function():void
         {
            var _loc1_:* = 0;
            mDBFacade.metrics.log("ChestUnlockCoinTry",{
               "chestId":mChestInfo.gmId,
               "rarity":mChestInfo.rarity,
               "category":"storage"
            });
            if(mDBFacade.dbAccountInfo.basicCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockCoin",{
                  "chestId":mChestInfo.gmId,
                  "rarity":mChestInfo.rarity,
                  "category":"storage"
               });
               closeBuyKeysPopUp();
               mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.chestBuyCoinCallback()");
               mSceneGraphComponent.addChild(mPurchasingPopUp.root,50);
               _loc1_ = mKeyThatCanOpenChest.gmKeyOffer.Id;
               StoreServices.purchaseOffer(mDBFacade,_loc1_,boughtKey,boughtKeyError,0,false);
            }
            else
            {
               mDontUpdateChestInfo = true;
               StoreServicesController.showCoinPage(mDBFacade);
            }
         };
      }
      
      private function chestBuyGemCallback(val:Number) : Function
      {
         return function():void
         {
            var _loc1_:* = 0;
            mDBFacade.metrics.log("ChestUnlockGemTry",{
               "chestId":mChestInfo.gmId,
               "rarity":mChestInfo.rarity,
               "category":"storage"
            });
            if(mDBFacade.dbAccountInfo.premiumCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockGem",{
                  "chestId":mChestInfo.gmId,
                  "rarity":mChestInfo.rarity,
                  "category":"storage"
               });
               closeBuyKeysPopUp();
               mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.chestBuyGemCallback()");
               mSceneGraphComponent.addChild(mPurchasingPopUp.root,50);
               _loc1_ = mKeyThatCanOpenChest.gmKeyOffer.Id;
               StoreServices.purchaseOffer(mDBFacade,_loc1_,boughtKey,boughtKeyError,0,false);
            }
            else
            {
               mDontUpdateChestInfo = true;
               StoreServicesController.showCashPage(mDBFacade,"chestOpenWithGemsAttemptStorage");
            }
         };
      }
      
      private function boughtKey(details:*) : void
      {
         mSceneGraphComponent.removeChild(mPurchasingPopUp.root);
         mPurchasingPopUp.destroy();
         mPurchasingPopUp = null;
         mChestCanBeOpened = true;
         mOpenChestCallback(mChestInfo);
      }
      
      private function boughtKeyError(err:*) : void
      {
         mPurchasingPopUp = new DBUIPopup(mDBFacade,Locale.getString("Error with Key Purchase. Server Error!"));
         MemoryTracker.track(mPurchasingPopUp,"DBUIPopup - created in ChestInfoCard.boughtKeyError()");
         mSceneGraphComponent.addChild(mPurchasingPopUp.root,50);
      }
      
      public function closeBuyKeysPopUp() : void
      {
         mDontUpdateChestInfo = false;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.fadeIn(0.5);
         }
         if(mChestBuyKeysPopUp)
         {
            mChestBuyKeysPopUp.destroy();
         }
         mChestBuyKeysPopUp = null;
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         if(mChestRevealPopUp)
         {
            mChestRevealPopUp.destroy();
         }
         mChestRevealPopUp = null;
         if(mChestKeySlots)
         {
            _loc1_ = 0;
            while(_loc1_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc1_].destroy();
               _loc1_++;
            }
         }
         mChestKeySlots = null;
         if(mPurchasingPopUp)
         {
            mSceneGraphComponent.removeChild(mPurchasingPopUp.root);
            mPurchasingPopUp.destroy();
         }
         mPurchasingPopUp = null;
         if(mChestBuyKeysPopUp)
         {
            closeBuyKeysPopUp();
         }
         mKeyThatCanOpenChest = null;
         mOpenChestCallback = null;
         mAbandonChestCallback = null;
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
         }
         mSceneGraphComponent = null;
         if(mChestRenderer)
         {
            mChestRenderer.destroy();
         }
         mChestRenderer = null;
         mDBFacade = null;
         mAssetLoadingComponent.destroy();
         if(mChestRevealPopUp)
         {
            mChestRevealPopUp.destroy();
         }
         mChestRevealPopUp = null;
         super.destroy();
      }
   }
}

