package UI.Inventory.Chests
{
   import Account.ChestInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMRarity;
   import UI.Hud.UIHud;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
   public class ChestBuyKeysPopUp
   {
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mRoot:MovieClip;
      
      private var mBuyCoinButton:UIButton;
      
      private var mBuyGemButton:UIButton;
      
      private var mCloseButton:UIButton;
      
      private var mRenderer:MovieClipRenderer;
      
      private var mChestKeySlots:Vector.<ChestKeySlot>;
      
      private var mCoinButtonCenteredPosition:int = 1;
      
      private var mCoinIconCenteredPosition:int = -50;
      
      public function ChestBuyKeysPopUp(dbFacade:DBFacade, assetLoadingComponent:AssetLoadingComponent, sceneGraphComponent:SceneGraphComponent, swfAsset:SwfAsset, selectedGMChest:GMChest, chestBuyCoinCallback:Function, chestBuyGemCallback:Function, closeKeylessChestPopup:Function, refreshHeroInfoCallback:Function, isFromSummary:Boolean = false)
      {
         var openKeyChestClass:Class;
         var bounds:Rectangle;
         var swfPath:String;
         var iconName:String;
         var rarity:GMRarity;
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         var coinCostForChestKey:Number;
         var cashCostForChestKey:Number;
         var i:int;
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = assetLoadingComponent;
         mSceneGraphComponent = sceneGraphComponent;
         openKeyChestClass = UIHud.isThisAConsumbleChestId(selectedGMChest.Id) ? swfAsset.getClass("popup_itemBox_open") : swfAsset.getClass("popup_chest_keyless");
         mRoot = new openKeyChestClass();
         mRoot.scaleX = mRoot.scaleY = 1.8;
         bounds = mRoot.getBounds(mDBFacade.stageRef);
         mRoot.x = mDBFacade.stageRef.stageWidth / 2 - bounds.width / 2 - bounds.x;
         mRoot.y = mDBFacade.stageRef.stageHeight / 2 - bounds.height / 2 - bounds.y;
         mRoot.title_label.text = isFromSummary ? Locale.getString("TREASURE_FOUND") : GameMasterLocale.getGameMasterSubString("CHEST_NAME",selectedGMChest.Rarity);
         if(mRoot.description_label)
         {
            mRoot.description_label.text = Locale.getString("BUY_KEY_TO_OPEN") + selectedGMChest.Rarity + Locale.getString("CHEST_!");
         }
         swfPath = selectedGMChest.IconSwf;
         iconName = selectedGMChest.IconName;
         ChestInfo.loadItemIcon(swfPath,iconName,mRoot.content,mDBFacade,150,150,mAssetLoadingComponent);
         mRoot.content.y = UIHud.isThisAConsumbleChestId(selectedGMChest.Id) ? -6 : -35;
         mRenderer = new MovieClipRenderer(mDBFacade,mRoot.content);
         mRenderer.play(0,true);
         rarity = mDBFacade.gameMaster.rarityByConstant.itemFor(selectedGMChest.Rarity);
         bgColoredExists = rarity.HasColoredBackground;
         bgSwfPath = rarity.BackgroundSwf;
         bgIconName = rarity.BackgroundIcon;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
            {
               var _loc3_:MovieClip = null;
               var _loc2_:Class = param1.getClass(bgIconName);
               if(_loc2_)
               {
                  _loc3_ = new _loc2_() as MovieClip;
                  mRoot.content.addChildAt(_loc3_,0);
                  _loc3_.scaleX = _loc3_.scaleY = 1.5;
               }
            });
         }
         coinCostForChestKey = 0;
         cashCostForChestKey = 0;
         i = 0;
         while(i < 6)
         {
            if(mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKey.ChestId == selectedGMChest.Id)
            {
               coinCostForChestKey = mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKeyOffer.Price;
            }
            i = i + 1;
         }
         mRoot.coin_button.x = mCoinButtonCenteredPosition;
         mRoot.coin_icon.x = mCoinIconCenteredPosition;
         mBuyCoinButton = new UIButton(mDBFacade,mRoot.coin_button);
         mBuyCoinButton.releaseCallback = chestBuyCoinCallback(coinCostForChestKey);
         mBuyCoinButton.label.text = coinCostForChestKey.toString();
         mBuyGemButton = new UIButton(mDBFacade,mRoot.gem_button);
         mRoot.gem_icon.visible = false;
         mBuyGemButton.visible = false;
         mCloseButton = new UIButton(mDBFacade,mRoot.close);
         mCloseButton.releaseCallback = closeKeylessChestPopup;
         mRoot.coin_icon.mouseEnabled = false;
         mRoot.coin_icon.mouseChildren = false;
         mRoot.gem_icon.mouseEnabled = false;
         mRoot.gem_icon.mouseChildren = false;
         if(!UIHud.isThisAConsumbleChestId(selectedGMChest.Id))
         {
            createKeySlots(selectedGMChest);
            refreshHeroInfoCallback(mRoot);
         }
         mSceneGraphComponent.addChild(mRoot,105);
         mDBFacade.menuNavigationController.pushNewLayer("POPUP_KEYLESS",closeKeylessChestPopup,mCloseButton,mBuyCoinButton);
         mCloseButton.isAbove(mBuyCoinButton);
         mBuyCoinButton.isToTheLeftOf(mBuyGemButton);
      }
      
      private function createKeySlots(selectedGMChest:GMChest) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         mChestKeySlots = new Vector.<ChestKeySlot>();
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc2_ = mRoot.getChildByName("slot_" + _loc3_.toString()) as MovieClip;
            mChestKeySlots.push(new ChestKeySlot(mDBFacade,_loc2_,mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_],mAssetLoadingComponent));
            if(selectedGMChest.Id == mChestKeySlots[_loc3_].keyInfo.gmKey.ChestId)
            {
               mChestKeySlots[_loc3_].setSelected(true);
            }
            else
            {
               mChestKeySlots[_loc3_].setSelected(false);
            }
            _loc3_++;
         }
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         mSceneGraphComponent.removeChild(mRoot);
         mDBFacade.menuNavigationController.popLayer("POPUP_KEYLESS");
         mDBFacade = null;
         mAssetLoadingComponent = null;
         mBuyCoinButton.destroy();
         mBuyCoinButton = null;
         mBuyGemButton.destroy();
         mBuyGemButton = null;
         mRenderer.destroy();
         mRenderer = null;
         if(mChestKeySlots)
         {
            _loc1_ = 0;
            while(_loc1_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc1_].destroy();
               _loc1_++;
            }
            mChestKeySlots.splice(0,mChestKeySlots.length);
            mChestKeySlots = null;
         }
         mRoot = null;
      }
   }
}

