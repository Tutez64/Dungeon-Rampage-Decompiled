package UI.Shop
{
   import Account.AvatarInfo;
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMWeaponItem;
   import UI.Inventory.UITapHoldTooltip;
   import UI.Inventory.UIWeaponDescTooltip;
   import UI.Modifiers.UIModifier;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class UIShopWeaponOffer extends UIShopOffer
   {
      
      public static const WEAPON_CARD_ROLL_OVER_SCALE:Number = 1.845;
      
      protected var mTapIcon:UIObject;
      
      protected var mTapTooltip:UITapHoldTooltip;
      
      protected var mHoldIcon:UIObject;
      
      protected var mHoldTooltip:UITapHoldTooltip;
      
      protected var mPower:MovieClip;
      
      protected var mPowerLabel:TextField;
      
      protected var mGMOfferDetail:GMOfferDetail;
      
      protected var mGMWeaponItem:GMWeaponItem;
      
      protected var mRollOverCallback:Function;
      
      protected var mRollOutCallback:Function;
      
      protected var mWeaponDescTooltip:UIWeaponDescTooltip;
      
      protected var mUIModifierList:Vector.<UIModifier>;
      
      protected var mRibbonA:MovieClip;
      
      protected var mRibbonB:MovieClip;
      
      public function UIShopWeaponOffer(dbFacade:DBFacade, templateClass:Class, descTooltipClass:Class, chargeTooltipClass:Class, buyCallback:Function = null)
      {
         super(dbFacade,templateClass,buyCallback);
         mRibbonA = mRoot.ribbon_A;
         mRibbonB = mRoot.ribbon_B;
         mRibbonA.visible = false;
         mRibbonB.visible = false;
         mPower = mRoot.power;
         if(mPower != null)
         {
            mPowerLabel = mPower.label;
            mPower.attack_label.text = Locale.getString("POWER");
         }
         mTapIcon = new UIObject(mDBFacade,mRoot.tap_icon);
         mTapTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mTapIcon.tooltip = mTapTooltip;
         mTapTooltip.visible = false;
         mHoldIcon = new UIObject(mDBFacade,mRoot.hit_icon);
         mHoldTooltip = new UITapHoldTooltip(mDBFacade,chargeTooltipClass);
         mHoldIcon.tooltip = mHoldTooltip;
         mHoldTooltip.visible = false;
         mWeaponDescTooltip = new UIWeaponDescTooltip(mDBFacade,descTooltipClass);
         mIconParent.tooltip = mWeaponDescTooltip;
         mWeaponDescTooltip.visible = false;
         mRoot.label_tap.text = Locale.getString("TAP");
         mRoot.label_charge.text = Locale.getString("HOLD");
         mRoot.label_modifier.text = Locale.getString("MODIFIERS");
         mUIModifierList = new Vector.<UIModifier>();
      }
      
      override public function destroy() : void
      {
         mTapTooltip.destroy();
         mTapIcon.destroy();
         mTapIcon = null;
         mHoldTooltip.destroy();
         mHoldIcon.destroy();
         mHoldIcon = null;
         mRollOverCallback = null;
         mRollOutCallback = null;
         mWeaponDescTooltip.destroy();
         if(mUIModifierList)
         {
            for each(var _loc1_:UIModifier in mUIModifierList)
            {
               _loc1_.destroy();
            }
         }
         mUIModifierList = null;
         super.destroy();
      }
      
      override protected function get nativeIconSize() : Number
      {
         return 100;
      }
      
      public function setRolloverCallbacks(over:Function, out:Function) : void
      {
         mRollOverCallback = over;
         mRollOutCallback = out;
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(mRollOverCallback != null)
         {
            mRollOverCallback(mGMWeaponItem,mGMOfferDetail.WeaponPower);
         }
         mRoot.scaleX = mRoot.scaleY = 1.845;
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         if(mRollOutCallback != null)
         {
            mRollOutCallback(mGMWeaponItem,mGMOfferDetail.WeaponPower);
         }
      }
      
      override protected function shouldGreyOffer(gmHero:GMHero) : Boolean
      {
         return false;
      }
      
      override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) : void
      {
         var stagePos:Point;
         var weaponName:String;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var preNameModifiers:String;
         var i:int;
         var avatarInfo:AvatarInfo;
         var format:TextFormat;
         var sizeMult:Number;
         var rarity:GMRarity;
         this.offer = gmOffer;
         mGMOfferDetail = this.offer.Details[0];
         mGMWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(mGMOfferDetail.WeaponId);
         super.showOffer(gmOffer,gmHero);
         weaponName = "";
         weaponName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmOffer.getOfferItemConstant(mDBFacade.gameMaster));
         mWeaponDescTooltip.setWeaponItem(mGMWeaponItem,mGMOfferDetail.Level);
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            mWeaponDescTooltip.setWeaponItem(mGMWeaponItem,mGMOfferDetail.Level,true);
         }
         mWeaponDescTooltip.visible = true;
         stagePos = new Point();
         stagePos.y = mPower.height * 1.93;
         mIconParent.tooltipPos = stagePos;
         if(mGMWeaponItem.TapIcon && mGMWeaponItem.TapIcon != "")
         {
            mTapIcon.visible = true;
            swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName = mGMWeaponItem.TapIcon;
            if(swfPath && iconName)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
               {
                  var _loc2_:MovieClip = null;
                  var _loc3_:Class = param1.getClass(iconName);
                  if(_loc3_)
                  {
                     _loc2_ = new _loc3_();
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mTapIcon.root.addChild(_loc2_);
                     mTapTooltip.setValues(GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_TITLE",mGMWeaponItem.Constant),GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_TAP_DESCRIPTION",mGMWeaponItem.Constant));
                     mTapTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mTapIcon.root.height * 0.5;
                     mTapIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         if(mGMWeaponItem.HoldIcon && mGMWeaponItem.HoldIcon != "")
         {
            mHoldIcon.visible = true;
            swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName1 = mGMWeaponItem.HoldIcon;
            if(swfPath1 && iconName1)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1),function(param1:SwfAsset):void
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:String = null;
                  var _loc3_:Class = param1.getClass(iconName1);
                  if(_loc3_)
                  {
                     _loc2_ = new _loc3_();
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mHoldIcon.root.addChild(_loc2_);
                     _loc4_ = mGMWeaponItem.WeaponController != null ? GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_CONTROLLER",mGMWeaponItem.WeaponController) : mGMWeaponItem.HoldTitle;
                     mHoldTooltip.setValues(_loc4_,GameMasterLocale.getGameMasterSubString("WEAPON_ITEM_HOLD_DESCRIPTION",mGMWeaponItem.Constant));
                     mHoldTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         mPower.visible = true;
         mPowerLabel.text = mGMOfferDetail.WeaponPower.toString();
         if(mGMOfferDetail.Modifier1 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,mRoot.modifier_icon_1,mGMOfferDetail.Modifier1));
         }
         if(mGMOfferDetail.Modifier2 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,mRoot.modifier_icon_2,mGMOfferDetail.Modifier2));
         }
         if(mGMOfferDetail.Modifier3 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,mRoot.modifier_icon_3,mGMOfferDetail.Modifier3,0,true));
         }
         preNameModifiers = "";
         i = 0;
         while(i < mUIModifierList.length)
         {
            if(mGMOfferDetail.Rarity == "LEGENDARY")
            {
               break;
            }
            preNameModifiers += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",mUIModifierList[i].gmModifier.Constant).toUpperCase() + " ";
            i = i + 1;
         }
         weaponName = preNameModifiers + GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmOffer.getOfferItemConstant(mDBFacade.gameMaster)).toUpperCase();
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            weaponName = mTitle.text;
         }
         if(this.offer.EndDate || this.offer.StartDate)
         {
            if(this.offer.LimitedQuantity > 0)
            {
               mRibbonA.visible = false;
               mRibbonB.visible = true;
               mRibbonB.timer.text = getDateString();
               mRibbonB.limit_label.text = getQuantityString();
            }
            else
            {
               mRibbonA.visible = true;
               mRibbonB.visible = false;
               mRibbonA.timer.text = getDateString();
            }
         }
         avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(!avatarInfo || avatarInfo.level < mGMOfferDetail.Level)
         {
            mLevelStarLabel.textColor = mRequiresLabel.textColor = 15535124;
         }
         format = new TextFormat();
         sizeMult = 0.1;
         if(weaponName.length <= 32)
         {
            format.size = 13;
            sizeMult = weaponName.length < 16 ? 0.2 : 0.1;
            mTitle.y = mTitleY + mTitle.height * sizeMult;
         }
         else
         {
            format.size = 11;
            mTitle.y = mTitleY;
         }
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            weaponName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmOffer.getOfferItemConstant(mDBFacade.gameMaster,"LEGENDARY",true)).toUpperCase();
         }
         mTitle.defaultTextFormat = format;
         mTitle.text = weaponName;
         rarity = mDBFacade.gameMaster.rarityByConstant.itemFor(mGMOfferDetail.Rarity);
         if(rarity != null && rarity.TextColor)
         {
            mTitle.textColor = rarity.TextColor;
         }
      }
      
      override protected function get offerDescription() : String
      {
         return mGMWeaponItem ? GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).WeaponItemConstant) : "";
      }
      
      override protected function get offerIconName() : String
      {
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            return mGMWeaponItem ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level,true).IconName : "";
         }
         return mGMWeaponItem ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).IconName : "";
      }
      
      override protected function get offerSwfPath() : String
      {
         return mGMWeaponItem ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).IconSwf : "";
      }
      
      override protected function hasRequirements() : Boolean
      {
         if(mGMOfferDetail)
         {
            if(mGMOfferDetail.Level > 0)
            {
               mRequiresLabel.appendText(mGMOfferDetail.Level.toString());
               return true;
            }
         }
         return false;
      }
      
      override protected function requirementsMetForPurchase() : Boolean
      {
         return true;
      }
   }
}

