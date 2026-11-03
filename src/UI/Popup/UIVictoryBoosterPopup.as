package UI.Popup
{
   import Account.StackableInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import Collections.IMapIterator;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMStackable;
   import flash.display.MovieClip;
   
   public class UIVictoryBoosterPopup extends DBUIPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_score_report.swf";
      
      protected static const POPUP_CLASS_NAME:String = "boosterBonusPopup";
      
      public var expStack:GMStackable;
      
      public var goldStack:GMStackable;
      
      private var mExpObject:UIObject;
      
      private var mGoldObject:UIObject;
      
      public function UIVictoryBoosterPopup(dbFacade:DBFacade, titleText:String = "", content:* = null, allowClose:Boolean = true, closeCallback:Function = null)
      {
         super(dbFacade,"VICTORY_BOOSTER_POPUP",titleText,content,allowClose,false,closeCallback);
         if(mCurtainActive)
         {
            removeCurtain();
         }
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_score_report.swf";
      }
      
      override protected function getClassName() : String
      {
         return "boosterBonusPopup";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         findEquippedBoosters();
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mPopup.visible = true;
         mPopup.potion_slot_A.visible = false;
         mPopup.potion_slot_B.visible = false;
         mPopup.star.visible = false;
         mPopup.coins.visible = false;
         mPopup.text_value_slot_A.visible = false;
         mPopup.text_value_slot_B.visible = false;
         mPopup.text_value_slot_A.text = "";
         mPopup.text_value_slot_B.text = "";
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),function(param1:SwfAsset):void
         {
            setupStackIcons(param1);
         });
      }
      
      private function findEquippedBoosters() : void
      {
         var _loc1_:StackableInfo = null;
         var _loc2_:GMStackable = null;
         var _loc3_:IMapIterator = mDBFacade.dbAccountInfo.inventoryInfo.stackables.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc1_ = _loc3_.next();
            if(_loc1_.isEquipped)
            {
               _loc2_ = _loc1_.gmStackable;
               if(_loc2_.ExpMult > 0)
               {
                  expStack = _loc2_;
               }
               else if(_loc2_.GoldMult > 0)
               {
                  goldStack = _loc2_;
               }
            }
         }
      }
      
      protected function setupStackIcons(swfAsset:SwfAsset) : void
      {
         var _loc3_:Class = null;
         var _loc2_:MovieClip = null;
         if(expStack)
         {
            mExpObject = new UIObject(mDBFacade,mPopup.potion_slot_A,105);
            _loc3_ = swfAsset.getClass(expStack.IconName);
            _loc2_ = new _loc3_();
            _loc2_.scaleX = _loc2_.scaleY = 72 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
            _loc2_.y -= 8;
            mExpObject.root.addChild(_loc2_);
            TextUtil.setText(mExpObject.tooltip.title_label,GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",expStack.Constant).toUpperCase());
            TextUtil.setText(mExpObject.tooltip.description_label,GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",expStack.Constant));
            mPopup.visible = true;
            mPopup.potion_slot_A.visible = true;
            mPopup.star.visible = true;
            mPopup.text_value_slot_A.visible = true;
         }
         if(goldStack)
         {
            mGoldObject = new UIObject(mDBFacade,mPopup.potion_slot_B);
            _loc3_ = swfAsset.getClass(goldStack.IconName);
            _loc2_ = new _loc3_();
            _loc2_.scaleX = _loc2_.scaleY = 72 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
            _loc2_.y -= 8;
            mGoldObject.root.addChild(_loc2_);
            TextUtil.setText(mGoldObject.tooltip.title_label,GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",goldStack.Constant).toUpperCase());
            TextUtil.setText(mGoldObject.tooltip.description_label,GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",goldStack.Constant));
            mPopup.visible = true;
            mPopup.potion_slot_B.visible = true;
            mPopup.coins.visible = true;
            mPopup.text_value_slot_B.visible = true;
         }
      }
      
      public function setExp(value:int) : void
      {
         TextUtil.setText(mPopup.text_value_slot_A,"+" + value.toString());
      }
      
      public function setGold(value:int) : void
      {
         TextUtil.setText(mPopup.text_value_slot_B,"+" + value.toString());
      }
      
      override public function destroy() : void
      {
         if(mDBFacade)
         {
            super.destroy();
         }
         if(mExpObject)
         {
            mExpObject.destroy();
            mExpObject = null;
            expStack = null;
         }
         if(mGoldObject)
         {
            mGoldObject.destroy();
            mGoldObject = null;
            goldStack = null;
         }
      }
   }
}

