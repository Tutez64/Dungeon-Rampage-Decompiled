package UI.InfiniteIsland
{
   import Account.FriendInfo;
   import Account.ItemInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMRarity;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import UI.Inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class II_UIChampionsboardSlot
   {
      
      public static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      public static const LINKAGE_NAME:String = "leaderboard_slot";
      
      private var mDBFacade:DBFacade;
      
      private var mNum:int;
      
      private var mRoot:MovieClip;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mIconMC:MovieClip;
      
      private var mWeaponSlotA:UIObject;
      
      private var mWeaponSlotB:UIObject;
      
      private var mWeaponSlotC:UIObject;
      
      public function II_UIChampionsboardSlot(dbFacade:DBFacade, num:int)
      {
         super();
         mDBFacade = dbFacade;
         mNum = num;
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_screens.swf"),setupUI);
      }
      
      public function setupUI(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass("leaderboard_slot");
         mRoot = new _loc2_() as MovieClip;
         mRoot.x = 10;
         mWeaponSlotA = new UIObject(mDBFacade,mRoot.loot_slot_A1);
         mWeaponSlotB = new UIObject(mDBFacade,mRoot.loot_slot_A2);
         mWeaponSlotC = new UIObject(mDBFacade,mRoot.loot_slot_A3);
         mRoot.y = mNum * mRoot.height;
         if(mNum % 2)
         {
            mRoot.dark_row_2.visible = false;
         }
         else
         {
            mRoot.dark_row_1.visible = false;
         }
      }
      
      public function setDungeonDetails(nodeId:int, friendInfo:FriendInfo, isLocalPlayer:Boolean) : void
      {
         mRoot.friend_name.text = friendInfo.name;
         mRoot.player01_number.text = friendInfo.getIILeaderboardScoreForNode(nodeId);
         mRoot.friend_pic.you_online.visible = isLocalPlayer;
         loadAvatarSkinPic(friendInfo.getIILeaderboardAvatarSkinForNode(nodeId));
         loadWeaponsUsed(friendInfo.getWeaponsUsedForNode(nodeId));
      }
      
      private function loadWeaponsUsed(weapons:Vector.<Object>) : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc5_:UIWeaponTooltip = null;
            var _loc4_:UIWeaponTooltip = null;
            var _loc3_:UIWeaponTooltip = null;
            var _loc2_:Class = param1.getClass("DR_weapon_tooltip");
            while(mWeaponSlotA.root.numChildren > 1)
            {
               mWeaponSlotA.root.removeChildAt(1);
            }
            if(mWeaponSlotA.tooltip != null)
            {
               mWeaponSlotA.tooltip = null;
            }
            while(mWeaponSlotB.root.numChildren > 1)
            {
               mWeaponSlotB.root.removeChildAt(1);
            }
            if(mWeaponSlotB.tooltip != null)
            {
               mWeaponSlotB.tooltip = null;
            }
            while(mWeaponSlotC.root.numChildren > 1)
            {
               mWeaponSlotC.root.removeChildAt(1);
            }
            if(mWeaponSlotC.tooltip != null)
            {
               mWeaponSlotC.tooltip = null;
            }
            if(weapons.length > 0 && weapons[0] != null)
            {
               _loc5_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[0],_loc5_,mWeaponSlotA);
            }
            if(weapons.length > 1 && weapons[1] != null)
            {
               _loc4_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[1],_loc4_,mWeaponSlotB);
            }
            if(weapons.length > 2 && weapons[2] != null)
            {
               _loc3_ = new UIWeaponTooltip(mDBFacade,_loc2_);
               weaponTooltipHelper(weapons[2],_loc3_,mWeaponSlotC);
            }
         });
      }
      
      private function weaponTooltipHelper(weaponJson:Object, weaponToolTip:UIWeaponTooltip, weaponSlot:UIObject) : void
      {
         var _loc7_:uint = uint(weaponJson.type);
         var _loc4_:GMWeaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(weaponJson.type);
         if(_loc4_ == null)
         {
            Logger.warn("Unable to determine gmWeapon from type: " + weaponJson.type);
            return;
         }
         var _loc6_:GMRarity = mDBFacade.gameMaster.rarityById.itemFor(weaponJson.rarity);
         var _loc5_:GMWeaponAesthetic = _loc4_.getWeaponAesthetic(weaponJson.requiredLevel,weaponJson.rarity == 4);
         ItemInfo.loadItemIcon(_loc5_.IconSwf,_loc5_.IconName,weaponSlot.root,mDBFacade,weaponSlot.root.width * 2,0,mAssetLoadingComponent);
         weaponToolTip.setWeaponItemFromData(_loc5_.Name,weaponJson.power,_loc4_.TapIcon,_loc4_.HoldIcon,weaponJson.modifier1,weaponJson.modifier2,weaponJson.legendaryModifier,weaponJson.rarity,weaponJson.requiredLevel,_loc5_);
         weaponSlot.tooltip = weaponToolTip;
         weaponSlot.tooltipPos = new Point(0,0);
      }
      
      public function setDungeonDetailsForTopTwenty(playerName:String, playerScore:int, playerAvatarSkin:int, weaponsJson:Vector.<Object>) : void
      {
         mRoot.friend_name.text = playerName;
         mRoot.player01_number.text = playerScore;
         loadAvatarSkinPic(playerAvatarSkin);
         loadWeaponsUsed(weaponsJson);
      }
      
      private function loadAvatarSkinPic(skinId:int) : void
      {
         var gmSkin:GMSkin = mDBFacade.gameMaster.getSkinByType(skinId);
         var swfPath:String = gmSkin.UISwfFilepath;
         var iconName:String = gmSkin.IconName;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(iconName);
            mIconMC = new _loc2_() as MovieClip;
            mRoot.friend_pic.default_pic.addChild(mIconMC);
            mIconMC.scaleX = mIconMC.scaleY = 0.5;
         });
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function destroy() : void
      {
         if(mIconMC)
         {
            mRoot.friend_pic.default_pic.removeChild(mIconMC);
            mIconMC = null;
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mRoot = null;
      }
   }
}

