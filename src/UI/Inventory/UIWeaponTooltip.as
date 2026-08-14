package UI.Inventory
{
   import Account.ItemInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Combat.Weapon.WeaponGameObject;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMWeaponAesthetic;
   import UI.Modifiers.UIModifier;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIWeaponTooltip extends MovieClip
   {
      
      public static const TAP_HOLD_ICONS_SWF:String = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mNameLabel:TextField;
      
      protected var mPowerLabel:TextField;
      
      protected var mLevelLabel:TextField;
      
      protected var mTapIcon:MovieClip;
      
      protected var mHoldIcon:MovieClip;
      
      protected var mModifiersList:Vector.<UIModifier>;
      
      public function UIWeaponTooltip(dbFacade:DBFacade, templateClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mRoot = new templateClass();
         this.addChild(mRoot);
         mNameLabel = mRoot.title_label;
         mPowerLabel = mRoot.power.label;
         mRoot.power.attack_label.text = Locale.getString("POWER");
         mTapIcon = mRoot.tap_icon;
         mHoldIcon = mRoot.icon;
         mLevelLabel = mRoot.level_label;
         mModifiersList = new Vector.<UIModifier>();
      }
      
      public function destroy() : void
      {
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function setWeaponItemFromWeaponGameObject(weaponGameObject:WeaponGameObject) : void
      {
         var _loc3_:int = 0;
         clearAllIcons();
         mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",weaponGameObject.weaponAesthetic.Constant).toUpperCase();
         var _loc6_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(weaponGameObject.rarity);
         var _loc4_:uint = uint(_loc6_ != null && _loc6_.TextColor ? _loc6_.TextColor : 15463921);
         mNameLabel.textColor = _loc4_;
         mPowerLabel.text = weaponGameObject.power.toString();
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + weaponGameObject.requiredLevel;
         loadIcon(weaponGameObject.weaponData.TapIcon,mTapIcon);
         loadIcon(weaponGameObject.weaponData.HoldIcon,mHoldIcon);
         var _loc2_:String = "";
         var _loc5_:Vector.<GMModifier> = weaponGameObject.modifierList;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_" + (_loc3_ + 1).toString()) as MovieClip,_loc5_[_loc3_].Constant));
            _loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc5_[_loc3_].Constant).toUpperCase() + " ";
            _loc3_++;
         }
         mNameLabel.text = _loc2_ + mNameLabel.text;
         if(weaponGameObject.legendaryModifier)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_3") as MovieClip,"",0,true,weaponGameObject.legendaryModifier.Id));
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",weaponGameObject.weaponData.getWeaponAesthetic(0,true).Constant);
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      public function setWeaponItemFromItemInfo(itemInfo:ItemInfo) : void
      {
         var _loc3_:int = 0;
         clearAllIcons();
         mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",itemInfo.gmWeaponAesthetic.Constant).toUpperCase();
         mNameLabel.textColor = itemInfo.getTextColor();
         mPowerLabel.text = itemInfo.power.toString();
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + itemInfo.requiredLevel;
         loadIcon(itemInfo.gmWeaponItem.TapIcon,mTapIcon);
         loadIcon(itemInfo.gmWeaponItem.HoldIcon,mHoldIcon);
         var _loc2_:String = "";
         var _loc4_:Vector.<GMModifier> = itemInfo.modifiers;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_" + (_loc3_ + 1).toString()) as MovieClip,_loc4_[_loc3_].Constant));
            _loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc4_[_loc3_].Constant).toUpperCase() + " ";
            _loc3_++;
         }
         mNameLabel.text = _loc2_ + mNameLabel.text;
         if(itemInfo.legendaryModifier)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_3") as MovieClip,"",0,true,itemInfo.legendaryModifier));
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",itemInfo.gmWeaponItem.getWeaponAesthetic(0,true).Constant);
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      public function setWeaponItemFromData(name:String, power:uint, tapIcon:String, holdIcon:String, mod1:uint, mod2:uint, legendaryMod:uint, rarityVal:uint, level:uint, gmWeaponAesthetic:GMWeaponAesthetic = null) : void
      {
         var _loc11_:int = 0;
         clearAllIcons();
         mNameLabel.text = name.toUpperCase();
         if(gmWeaponAesthetic != null)
         {
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",gmWeaponAesthetic.Constant).toUpperCase();
         }
         var _loc15_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(rarityVal);
         var _loc12_:uint = uint(_loc15_ != null && _loc15_.TextColor ? _loc15_.TextColor : 15463921);
         mNameLabel.textColor = _loc12_;
         mPowerLabel.text = power.toString();
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + level;
         loadIcon(tapIcon,mTapIcon);
         loadIcon(holdIcon,mHoldIcon);
         var _loc14_:String = "";
         var _loc13_:Vector.<GMModifier> = new Vector.<GMModifier>();
         if(mod1 > 0)
         {
            _loc13_.push(mDBFacade.gameMaster.modifiersById.itemFor(mod1));
         }
         if(mod2 > 0)
         {
            _loc13_.push(mDBFacade.gameMaster.modifiersById.itemFor(mod2));
         }
         _loc11_ = 0;
         while(_loc11_ < _loc13_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_" + (_loc11_ + 1).toString()) as MovieClip,_loc13_[_loc11_].Constant));
            _loc14_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc13_[_loc11_].Constant).toUpperCase() + " ";
            _loc11_++;
         }
         if(legendaryMod)
         {
            mModifiersList.push(new UIModifier(mDBFacade,mRoot.getChildByName("modifier_icon_3") as MovieClip,"",0,true,legendaryMod));
         }
         else
         {
            mNameLabel.text = _loc14_ + mNameLabel.text;
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      private function clearAllIcons() : void
      {
         var _loc1_:int = 0;
         if(mTapIcon.numChildren > 1)
         {
            mTapIcon.removeChildAt(1);
         }
         if(mHoldIcon.numChildren > 1)
         {
            mHoldIcon.removeChildAt(1);
         }
         if(mModifiersList.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < mModifiersList.length)
            {
               mModifiersList[_loc1_].destroy();
               _loc1_++;
            }
            mModifiersList.splice(0,mModifiersList.length);
         }
      }
      
      private function loadIcon(iconName:String, parentMC:MovieClip) : void
      {
         var swfPath:String;
         if(iconName == null || iconName == "")
         {
            return;
         }
         swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
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
                  parentMC.addChildAt(_loc2_,1);
               }
            });
         }
      }
   }
}

