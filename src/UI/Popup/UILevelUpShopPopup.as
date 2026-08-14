package UI.Popup
{
   import Account.AvatarInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   public class UILevelUpShopPopup extends DBUIOneButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      protected static const POPUP_CLASS_NAME:String = "levelup_shop_popup";
      
      private var mAvatarInfo:AvatarInfo;
      
      private var mGMOffers:Vector.<GMOffer>;
      
      public function UILevelUpShopPopup(dbFacade:DBFacade, centerCallback:Function, avatarInfo:AvatarInfo, gmOffers:Vector.<GMOffer>)
      {
         mAvatarInfo = avatarInfo;
         mGMOffers = gmOffers;
         super(dbFacade,Locale.getString("LEVELUPSHOP_POPUP_TITLE"),Locale.getString("LEVELUPSHOP_POPUP_MESSAGE"),Locale.getString("LEVELUPSHOP_POPUP_BUTTON"),centerCallback,true,null);
         mDBFacade.metrics.log("LevelUpShopPopupPresented");
      }
      
      public static function getLevelUpWeaponUnlocks(dbFacade:DBFacade, avatarInfo:AvatarInfo) : Vector.<GMOffer>
      {
         var _loc10_:GMOffer = null;
         var _loc7_:* = null;
         var _loc11_:* = 0;
         var _loc8_:* = 0;
         var _loc6_:String = null;
         var _loc9_:* = 0;
         var _loc4_:Vector.<GMOffer> = new Vector.<GMOffer>();
         var _loc3_:uint = avatarInfo.level;
         var _loc5_:Vector.<GMOffer> = dbFacade.gameMaster.Offers;
         _loc9_ = 0;
         while(_loc9_ < _loc5_.length)
         {
            _loc10_ = _loc5_[_loc9_];
            if(_loc10_.Location == "STORE")
            {
               if(!_loc10_.Gift)
               {
                  if(!_loc10_.IsBundle)
                  {
                     if(_loc10_.Details[0].WeaponId)
                     {
                        _loc11_ = StoreServicesController.requiredHeroForWeapon(dbFacade,_loc10_);
                        if(!(_loc11_ && _loc11_ != avatarInfo.avatarType))
                        {
                           _loc8_ = StoreServicesController.getOfferLevelReq(dbFacade,_loc10_);
                           if(!(_loc8_ && _loc8_ != _loc3_))
                           {
                              _loc6_ = StoreServicesController.getWeaponMastertype(dbFacade,_loc10_);
                              if(!(_loc6_ && !avatarInfo.gmHero.AllowedWeapons.hasKey(_loc6_)))
                              {
                                 _loc4_.push(_loc10_);
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc9_++;
         }
         return _loc4_;
      }
      
      override public function destroy() : void
      {
         mGMOffers = null;
         mAvatarInfo = null;
         super.destroy();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "levelup_shop_popup";
      }
      
      override protected function centerButtonCallback() : void
      {
         mDBFacade.metrics.log("LevelUpShopPopupContinue");
         super.centerButtonCallback();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var offerUIs:Vector.<MovieClip>;
         var gmOffer:GMOffer;
         var offerUI:MovieClip;
         var gmWeaponItem:GMWeaponItem;
         var gmAesthetic:GMWeaponAesthetic;
         var i:uint;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mAvatarInfo.loadHeroIcon(function(param1:MovieClip):void
         {
            if(mPopup)
            {
               UIObject.scaleToFit(param1,60);
               mPopup.avatar.addChild(param1);
            }
         });
         mPopup.hero_level_star_label.text = mAvatarInfo.level.toString();
         offerUIs = new Vector.<MovieClip>();
         offerUIs.push(mPopup.weapon_0);
         offerUIs.push(mPopup.weapon_1);
         offerUIs.push(mPopup.weapon_2);
         for each(offerUI in offerUIs)
         {
            offerUI.visible = false;
         }
         i = 0;
         while(i < mGMOffers.length && i < offerUIs.length)
         {
            offerUI = offerUIs[i];
            offerUI.visible = true;
            gmOffer = mGMOffers[i];
            gmWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(gmOffer.Details[0].WeaponId);
            gmAesthetic = gmWeaponItem.getWeaponAesthetic(gmOffer.Details[0].Level);
            offerUI.weapon_label.text = gmAesthetic.Name.toUpperCase();
            this.loadWeaponIcon(offerUI.empty_slot,gmWeaponItem);
            offerUI.level_star_label.text = gmOffer.Details[0].Level.toString();
            i = i + 1;
         }
      }
      
      private function loadWeaponIcon(parent:DisplayObjectContainer, gmWeaponItem:GMWeaponItem) : void
      {
         var swfPath:String = gmWeaponItem.UISwfFilepath;
         var iconName:String = gmWeaponItem.IconName;
         if(swfPath && iconName)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
            {
               var _loc2_:MovieClip = null;
               var _loc3_:MovieClipRenderController = null;
               var _loc4_:Class = param1.getClass(iconName);
               if(_loc4_)
               {
                  _loc2_ = new _loc4_();
                  _loc3_ = new MovieClipRenderController(mDBFacade,_loc2_);
                  _loc3_.play(0,true);
                  _loc2_.scaleX = _loc2_.scaleY = 72 / 100;
                  parent.addChild(_loc2_);
               }
            });
         }
      }
   }
}

