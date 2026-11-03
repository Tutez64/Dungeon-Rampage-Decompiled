package UI.Popup
{
   import Account.ChestInfo;
   import Account.KeyInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMChest;
   import GameMasterDictionary.GMRarity;
   import UI.Hud.UIHud;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UITreasureFoundPopup extends DBUIPopup
   {
      
      private static const SCORE_REPORT_PATH:String = "Resources/Art2D/UI/db_UI_score_report.swf";
      
      private static const HERO_LABEL_MIN_WIDTH:Number = 130;
      
      private var mContentRenderer:MovieClipRenderer;
      
      private var mAbandonButton:UIButton;
      
      private var mKeepButton:UIButton;
      
      private var mOpenButton:UIButton;
      
      public function UITreasureFoundPopup(dbFacade:DBFacade, chest:GMChest, abandonCallback:Function, keepCallback:Function, openCallback:Function, refreshHeroInfoCallback:Function)
      {
         super(dbFacade,"POPUP_CHEST_LAYER","",{
            "chest":chest,
            "abandonCallback":abandonCallback,
            "keepCallback":keepCallback,
            "openCallback":openCallback,
            "refreshHeroInfoCallback":refreshHeroInfoCallback
         },false,true,null,false);
      }
      
      public static function fitHeroLabel(heroLabel:TextField) : void
      {
         var _loc2_:Number = 130 - heroLabel.width;
         if(_loc2_ > 0)
         {
            heroLabel.x -= _loc2_;
            heroLabel.width += _loc2_;
         }
         TextUtil.setText(heroLabel,heroLabel.text,1.55);
         TextUtil.fitToField(heroLabel);
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         mSwfAsset = swfAsset;
         var _loc6_:GMChest = content.chest as GMChest;
         var _loc7_:Class = UIHud.isThisAConsumbleChestId(_loc6_.Id) ? swfAsset.getClass("popup_itemBox") : swfAsset.getClass("popup_chest");
         mPopup = new _loc7_() as MovieClip;
         mRoot.addChild(mPopup);
         scalePopup();
         centerPopup();
         Locale.setText(mPopup.title_label,"TREASURE_FOUND");
         mPopup.close.visible = false;
         mAbandonButton = new UIButton(mDBFacade,mPopup.abandon_button);
         mAbandonButton.releaseCallback = content.abandonCallback;
         Locale.setText(mAbandonButton.label,"ABANDON");
         mKeepButton = new UIButton(mDBFacade,mPopup.keep_button);
         mKeepButton.releaseCallback = content.keepCallback;
         Locale.setText(mKeepButton.label,"KEEP");
         mOpenButton = new UIButton(mDBFacade,mPopup.open_button);
         mOpenButton.releaseCallback = content.openCallback;
         Locale.setText(mOpenButton.label,"UNLOCK");
         ChestInfo.loadItemIcon(_loc6_.IconSwf,_loc6_.IconName,mPopup.content,mDBFacade,150,150,mAssetLoadingComponent);
         loadRarityBackground(_loc6_);
         loadKeyAndHeroInfo(_loc6_,content.refreshHeroInfoCallback);
         mContentRenderer = new MovieClipRenderer(mDBFacade,mPopup.content);
         mContentRenderer.play(0,true);
      }
      
      override protected function setupMenuNavigation() : void
      {
         mOpenButton.isAbove(mKeepButton);
         mAbandonButton.isToTheLeftOf(mKeepButton);
         mAbandonButton.upNavigation = mOpenButton;
      }
      
      override protected function getDefaultNavigationObject() : UIObject
      {
         return mOpenButton;
      }
      
      override protected function getNavigationExitCallback() : Function
      {
         return rejectDismissal;
      }
      
      private function loadRarityBackground(chest:GMChest) : void
      {
         var rarity:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(chest.Rarity);
         if(rarity == null || !rarity.HasColoredBackground)
         {
            return;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(rarity.BackgroundSwf),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(rarity.BackgroundIcon);
            if(_loc3_ == null)
            {
               return;
            }
            var _loc2_:MovieClip = new _loc3_() as MovieClip;
            mPopup.content.addChildAt(_loc2_,0);
            _loc2_.scaleX = _loc2_.scaleY = 1.5;
         });
      }
      
      private function loadKeyAndHeroInfo(chest:GMChest, refreshHeroInfoCallback:Function) : void
      {
         var matchingKey:KeyInfo;
         var key:KeyInfo;
         if(UIHud.isThisAConsumbleChestId(chest.Id))
         {
            return;
         }
         for each(key in mDBFacade.dbAccountInfo.inventoryInfo.keys)
         {
            if(key.gmKey.ChestId == chest.Id)
            {
               matchingKey = key;
               break;
            }
         }
         if(matchingKey != null)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(matchingKey.gmKeyOffer.BundleSwfFilepath),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass(matchingKey.gmKeyOffer.BundleIcon);
               if(_loc3_ == null)
               {
                  return;
               }
               var _loc2_:MovieClip = new _loc3_() as MovieClip;
               _loc2_.scaleX = _loc2_.scaleY = 0.5;
               if(mOpenButton.root.pick.numChildren > 1)
               {
                  mOpenButton.root.pick.removeChildAt(1);
               }
               mOpenButton.root.pick.addChild(_loc2_);
            });
         }
         if(refreshHeroInfoCallback != null)
         {
            refreshHeroInfoCallback(mPopup);
            fitHeroLabel(mPopup.hero_label);
         }
      }
      
      private function rejectDismissal() : void
      {
      }
      
      override public function destroy() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mAbandonButton)
         {
            mAbandonButton.destroy();
         }
         if(mKeepButton)
         {
            mKeepButton.destroy();
         }
         if(mOpenButton)
         {
            mOpenButton.destroy();
         }
         if(mContentRenderer)
         {
            mContentRenderer.destroy();
         }
         mAbandonButton = null;
         mKeepButton = null;
         mOpenButton = null;
         mContentRenderer = null;
         super.destroy();
      }
   }
}

