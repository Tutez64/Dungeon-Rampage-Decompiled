package UI.Inventory.Chests
{
   import Account.ChestInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMRarity;
   import UI.Hud.UIHud;
   import UI.Popup.DBUIPopup;
   import UI.Popup.UITreasureFoundPopup;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
   public class ChestBuyKeysPopUp extends DBUIPopup
   {
      
      private static const SCORE_REPORT_PATH:String = "Resources/Art2D/UI/db_UI_score_report.swf";
      
      private var mBuyCoinButton:UIButton;
      
      private var mBuyGemButton:UIButton;
      
      private var mRenderer:MovieClipRenderer;
      
      private var mChestKeySlots:Vector.<ChestKeySlot>;
      
      private var mCoinButtonCenteredPosition:int = 1;
      
      private var mCoinIconCenteredPosition:int = -50;
      
      public function ChestBuyKeysPopUp(dbFacade:DBFacade, selectedGMChest:GMChest, chestBuyCoinCallback:Function, chestBuyGemCallback:Function, closeKeylessChestPopup:Function, refreshHeroInfoCallback:Function, isFromSummary:Boolean = false)
      {
         super(dbFacade,"POPUP_KEYLESS","",{
            "chest":selectedGMChest,
            "buyCoinCallback":chestBuyCoinCallback,
            "buyGemCallback":chestBuyGemCallback,
            "refreshHeroInfoCallback":refreshHeroInfoCallback,
            "isFromSummary":isFromSummary
         },true,true,closeKeylessChestPopup,false,false);
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
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
         mSwfAsset = swfAsset;
         var selectedGMChest:GMChest = content.chest as GMChest;
         var openKeyChestClass:Class = UIHud.isThisAConsumbleChestId(selectedGMChest.Id) ? swfAsset.getClass("popup_itemBox_open") : swfAsset.getClass("popup_chest_keyless");
         mPopup = new openKeyChestClass();
         mRoot.addChild(mPopup);
         mPopup.scaleX = mPopup.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         bounds = mPopup.getBounds(mDBFacade.scalingRoot);
         mPopup.x = mDBFacade.viewWidth / 2 - bounds.width / 2 - bounds.x;
         mPopup.y = mDBFacade.viewHeight / 2 - bounds.height / 2 - bounds.y;
         TextUtil.setText(mPopup.title_label,content.isFromSummary ? Locale.getString("TREASURE_FOUND") : GameMasterLocale.getGameMasterSubString("CHEST_NAME",selectedGMChest.Rarity));
         if(mPopup.description_label)
         {
            Locale.setText(mPopup.description_label,"BUY_KEY_TO_OPEN",{"CHEST":GameMasterLocale.getGameMasterSubString("CHEST_NAME",selectedGMChest.Rarity)});
         }
         swfPath = selectedGMChest.IconSwf;
         iconName = selectedGMChest.IconName;
         ChestInfo.loadItemIcon(swfPath,iconName,mPopup.content,mDBFacade,150,150,mAssetLoadingComponent);
         mPopup.content.y = UIHud.isThisAConsumbleChestId(selectedGMChest.Id) ? -6 : -35;
         mRenderer = new MovieClipRenderer(mDBFacade,mPopup.content);
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
                  mPopup.content.addChildAt(_loc3_,0);
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
         mPopup.coin_button.x = mCoinButtonCenteredPosition;
         mPopup.coin_icon.x = mCoinIconCenteredPosition;
         mBuyCoinButton = new UIButton(mDBFacade,mPopup.coin_button);
         mBuyCoinButton.releaseCallback = content.buyCoinCallback(coinCostForChestKey);
         TextUtil.setText(mBuyCoinButton.label,coinCostForChestKey.toString());
         mBuyGemButton = new UIButton(mDBFacade,mPopup.gem_button);
         mPopup.gem_icon.visible = false;
         mBuyGemButton.visible = false;
         mCloseButton = new UIButton(mDBFacade,mPopup.close);
         mCloseButton.releaseCallback = handleInputCalledClosed;
         mPopup.coin_icon.mouseEnabled = false;
         mPopup.coin_icon.mouseChildren = false;
         mPopup.gem_icon.mouseEnabled = false;
         mPopup.gem_icon.mouseChildren = false;
         if(!UIHud.isThisAConsumbleChestId(selectedGMChest.Id))
         {
            createKeySlots(selectedGMChest);
            content.refreshHeroInfoCallback(mPopup);
            UITreasureFoundPopup.fitHeroLabel(mPopup.hero_label);
         }
      }
      
      override protected function setupMenuNavigation() : void
      {
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
            _loc2_ = mPopup.getChildByName("slot_" + _loc3_.toString()) as MovieClip;
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
      
      override protected function getDefaultNavigationObject() : UIObject
      {
         return mCloseButton;
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         return mBuyCoinButton;
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         if(mDBFacade == null)
         {
            return;
         }
         if(mBuyCoinButton)
         {
            mBuyCoinButton.destroy();
         }
         mBuyCoinButton = null;
         if(mBuyGemButton)
         {
            mBuyGemButton.destroy();
         }
         mBuyGemButton = null;
         if(mRenderer)
         {
            mRenderer.destroy();
         }
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
         super.destroy();
      }
   }
}

