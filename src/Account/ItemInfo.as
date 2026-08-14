package Account
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMInventoryBase;
   import GameMasterDictionary.GMLegendaryModifier;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
   public class ItemInfo extends InventoryBaseInfo
   {
      
      private var mAvatarId:uint;
      
      private var mAvatarSlot:uint;
      
      private var mCreated:String;
      
      private var mPower:uint;
      
      private var mGMWeapon:GMWeaponItem;
      
      private var mModifiers:Vector.<GMModifier> = new Vector.<GMModifier>();
      
      private var mLegendaryModifier:uint = 0;
      
      private var mRarity:Number;
      
      private var mGMRarity:GMRarity;
      
      private var mRequiredLevel:Number;
      
      public function ItemInfo(dbFacade:DBFacade, json:Object)
      {
         super(dbFacade,json);
         mGMWeapon = mDBFacade.gameMaster.weaponItemById.itemFor(mGMId);
         if(mGMWeapon == null)
         {
            Logger.error("GMWeapon is null cannot find item for ID: " + mGMId);
         }
         mGMInventoryBase = mGMWeapon;
         mGMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
      }
      
      public static function loadItemIconFromId(itemId:uint, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:uint, iconsNativeSize:uint, assetLoadingComponent:AssetLoadingComponent = null) : void
      {
         var _loc7_:GMNpc = null;
         var _loc8_:GMInventoryBase = dbFacade.gameMaster.stackableById.itemFor(itemId);
         if(_loc8_ == null)
         {
            _loc7_ = dbFacade.gameMaster.npcById.itemFor(itemId);
            if(_loc7_ == null)
            {
               Logger.error("Unable to find gmItem for item id: " + itemId);
               return;
            }
            loadItemIcon(_loc7_.IconSwfFilepath,_loc7_.IconName,container,dbFacade,desiredSize,iconsNativeSize,assetLoadingComponent);
            return;
         }
         loadItemIcon(_loc8_.UISwfFilepath,_loc8_.IconName,container,dbFacade,desiredSize,iconsNativeSize,assetLoadingComponent);
      }
      
      public static function loadItemIconFromItemInfo(itemInfo:ItemInfo, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:uint, iconsNativeSize:uint, assetLoadingComponent:AssetLoadingComponent = null) : void
      {
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         loadItemIcon(itemInfo.uiSwfFilepath,itemInfo.iconName,container,dbFacade,desiredSize,iconsNativeSize,assetLoadingComponent);
         bgColoredExists = itemInfo.hasColoredBackground;
         bgSwfPath = itemInfo.backgroundSwfPath;
         bgIconName = itemInfo.backgroundIconName;
         if(bgColoredExists)
         {
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
            {
               var _loc3_:MovieClip = null;
               var _loc2_:Class = param1.getClass(bgIconName);
               if(_loc2_)
               {
                  _loc3_ = new _loc2_() as MovieClip;
                  _loc3_.scaleX = _loc3_.scaleY = 0.85;
                  container.addChildAt(_loc3_,0);
               }
            });
         }
      }
      
      public static function loadItemIcon(swfPath:String, iconName:String, container:DisplayObjectContainer, dbFacade:DBFacade, desiredSize:uint, iconsNativeSize:uint, assetLoadingComponent:AssetLoadingComponent = null, onCompletionCallback:Function = null) : void
      {
         var destroyAssetLoaderOnCompletion:Boolean = false;
         if(assetLoadingComponent == null)
         {
            assetLoadingComponent = new AssetLoadingComponent(dbFacade);
            destroyAssetLoaderOnCompletion = true;
         }
         if(swfPath == null || swfPath == "")
         {
            Logger.error("swfPath provided to ItemInfo::loadItemIcon is empty or null.");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(iconName);
            if(_loc3_ == null)
            {
               Logger.error("Unable to get iconClass for iconName: " + iconName);
               return;
            }
            var _loc2_:MovieClip = new _loc3_();
            if(iconsNativeSize == 0)
            {
               iconsNativeSize = _loc2_.width;
            }
            _loc2_.scaleX = _loc2_.scaleY = desiredSize / iconsNativeSize;
            container.addChild(_loc2_);
            if(destroyAssetLoaderOnCompletion)
            {
               assetLoadingComponent.destroy();
            }
            if(onCompletionCallback != null)
            {
               onCompletionCallback();
            }
         });
      }
      
      override public function get Description() : String
      {
         var _loc1_:GMWeaponAesthetic = this.gmWeaponAesthetic;
         return _loc1_ ? GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",_loc1_.WeaponItemConstant) : "";
      }
      
      override public function get iconScale() : Number
      {
         return 100;
      }
      
      public function get power() : uint
      {
         return mPower;
      }
      
      public function get gmWeaponItem() : GMWeaponItem
      {
         return mGMWeapon;
      }
      
      public function get gmWeaponAesthetic() : GMWeaponAesthetic
      {
         return mGMWeapon.getWeaponAesthetic(requiredLevel,mLegendaryModifier > 0);
      }
      
      public function get requiredLevel() : uint
      {
         return mRequiredLevel;
      }
      
      public function get rarity() : GMRarity
      {
         return mGMRarity;
      }
      
      override public function get uiSwfFilepath() : String
      {
         var _loc1_:GMWeaponAesthetic = this.gmWeaponAesthetic;
         return _loc1_ ? _loc1_.IconSwf : null;
      }
      
      override public function get iconName() : String
      {
         var _loc1_:GMWeaponAesthetic = this.gmWeaponAesthetic;
         return _loc1_ ? _loc1_.IconName : null;
      }
      
      override public function get isEquipped() : Boolean
      {
         return this.gmWeaponItem && this.avatarId != 0;
      }
      
      public function get avatarId() : uint
      {
         return mAvatarId;
      }
      
      public function set avatarId(id:uint) : void
      {
         mAvatarId = id;
      }
      
      public function get avatarSlot() : uint
      {
         return mAvatarSlot;
      }
      
      public function set avatarSlot(slot:uint) : void
      {
         mAvatarSlot = slot;
      }
      
      override protected function parseJson(json:Object) : void
      {
         var _loc4_:GMModifier = null;
         var _loc2_:GMModifier = null;
         var _loc3_:GMLegendaryModifier = null;
         if(json == null)
         {
            return;
         }
         mGMId = json.item_id as uint;
         mAccountId = json.account_id as uint;
         mAvatarId = json.avatar_id as uint;
         mDatabaseId = json.id as uint;
         mAvatarSlot = json.avatar_slot as uint;
         mCreated = json.created as String;
         mPower = json.power as uint;
         mIsNew = false;
         mRarity = json.rarity;
         mRequiredLevel = json.requiredlevel;
         if(json.modifier1 > 0)
         {
            _loc4_ = mDBFacade.gameMaster.modifiersById.itemFor(json.modifier1);
            if(_loc4_)
            {
               mModifiers.push(_loc4_);
            }
            else
            {
               Logger.error("Bad modifier id: " + json.modifier1);
            }
         }
         if(json.modifier2 > 0)
         {
            _loc2_ = mDBFacade.gameMaster.modifiersById.itemFor(json.modifier2);
            if(_loc2_)
            {
               mModifiers.push(_loc2_);
            }
            else
            {
               Logger.error("Bad modifier id: " + json.modifier2);
            }
         }
         if(json.legendarymodifier > 0)
         {
            _loc3_ = mDBFacade.gameMaster.legendaryModifiersById.itemFor(json.legendarymodifier);
            if(_loc3_)
            {
               mLegendaryModifier = _loc3_.Id;
            }
            else
            {
               Logger.error("Bad modifier id: " + json.legendarymodifier);
            }
         }
      }
      
      override public function get sellCoins() : int
      {
         var _loc1_:Number = NaN;
         var _loc7_:GMWeaponItem = mGMWeapon;
         var _loc3_:GMRarity = mGMRarity;
         var _loc8_:GMOffer = mDBFacade.gameMaster.offerById.itemFor(_loc3_.KeyOfferId);
         if(_loc8_)
         {
            if(_loc8_.CoinOffer)
            {
               _loc8_ = _loc8_.CoinOffer;
            }
         }
         var _loc2_:Number = 0;
         var _loc4_:Number = 1;
         if(_loc3_.NumberOfModifiers > 0)
         {
            _loc4_ = _loc3_.NumberOfModifiers * 3;
            for each(var _loc5_:GMModifier in mModifiers)
            {
               _loc2_ += _loc5_.MODIFIER_LEVEL;
            }
         }
         var _loc6_:Number = mRequiredLevel / 100 * _loc3_.LevelWeight + _loc2_ * 1 / _loc4_ * _loc3_.ModifierWeight;
         if(_loc8_)
         {
            _loc1_ = _loc8_.Price;
         }
         return Math.round(((_loc3_.MaxSellPercent - _loc3_.MinSellPercent) * _loc6_ + _loc3_.MinSellPercent) * _loc1_);
      }
      
      public function hasModifier(constant:String) : Boolean
      {
         for each(var _loc2_:GMModifier in mModifiers)
         {
            if(_loc2_.Constant == constant)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get modifiers() : Vector.<GMModifier>
      {
         return mModifiers;
      }
      
      public function get legendaryModifier() : uint
      {
         return mLegendaryModifier;
      }
      
      override public function getTextColor() : uint
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
         return _loc1_ != null && _loc1_.TextColor ? _loc1_.TextColor : 15463921;
      }
      
      override public function get hasColoredBackground() : Boolean
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
         return _loc1_ != null ? _loc1_.HasColoredBackground : false;
      }
      
      override public function get backgroundIconName() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
         return _loc1_ != null ? _loc1_.BackgroundIcon : "";
      }
      
      override public function get backgroundSwfPath() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
         return _loc1_ != null ? _loc1_.BackgroundSwf : "";
      }
      
      override public function get backgroundIconBorderName() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(mRarity);
         return _loc1_ != null ? _loc1_.BackgroundIconBorder : "";
      }
      
      override public function get Name() : String
      {
         return gmWeaponAesthetic.Name;
      }
      
      override public function get weaponAestheticConstant() : String
      {
         return gmWeaponAesthetic.Constant;
      }
   }
}

