package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Utils.TextUtil;
   import Combat.Weapon.WeaponGameObject;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMModifier;
   import GameMasterDictionary.GMRarity;
   import UI.Inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   
   public class StarlingWeaponTooltip extends MovieClip
   {
      
      internal static const ABILITY_SWF:String = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
      
      private var mFacade:DBFacade;
      
      private var mRoot:MovieClip;
      
      private var mAssets:AssetLoadingComponent;
      
      private var mModifiers:Vector.<StarlingModifierIcon> = new Vector.<StarlingModifierIcon>(0);
      
      private var mGeneration:uint;
      
      public function StarlingWeaponTooltip(facade:DBFacade, template:Class)
      {
         super();
         mFacade = facade;
         mRoot = new template() as MovieClip;
         HudArtConverter.stopTree(mRoot);
         addChild(mRoot);
         mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(mRoot.title_label,1.09);
         Locale.setText(mRoot.power.attack_label,"POWER");
      }
      
      public function setWeaponItemFromWeaponGameObject(weapon:WeaponGameObject) : void
      {
         var _loc4_:int = 0;
         clearAllIcons();
         mAssets = new AssetLoadingComponent(mFacade);
         var _loc6_:GMRarity = mFacade.gameMaster.rarityById.itemFor(weapon.rarity);
         mRoot.title_label.textColor = _loc6_ != null && _loc6_.TextColor ? _loc6_.TextColor : 15463921;
         TextUtil.setText(mRoot.power.label,weapon.power.toString());
         TextUtil.setText(mRoot.level_label,Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + weapon.requiredLevel);
         var _loc3_:String = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",weapon.weaponAesthetic.Constant);
         var _loc2_:String = "";
         var _loc5_:Vector.<GMModifier> = weapon.modifierList;
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            mModifiers.push(new StarlingModifierIcon(mFacade,mRoot.getChildByName("modifier_icon_" + (_loc4_ + 1)) as MovieClip,_loc5_[_loc4_].Constant));
            _loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc5_[_loc4_].Constant).toUpperCase() + " ";
            _loc4_++;
         }
         _loc3_ = _loc2_ + _loc3_;
         if(weapon.legendaryModifier != null)
         {
            mModifiers.push(new StarlingModifierIcon(mFacade,mRoot.getChildByName("modifier_icon_3") as MovieClip,"",0,true,weapon.legendaryModifier.Id));
            _loc3_ = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",weapon.weaponData.getWeaponAesthetic(0,true).Constant);
         }
         TextUtil.setText(mRoot.title_label,_loc3_.toUpperCase());
         loadIcon(weapon.weaponData.TapIcon,mRoot.tap_icon);
         loadIcon(weapon.weaponData.HoldIcon,mRoot.icon);
      }
      
      private function loadIcon(name:String, parent:MovieClip) : void
      {
         var generation:uint;
         var swf:String;
         if(name == null || name.length == 0)
         {
            return;
         }
         generation = mGeneration;
         swf = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
         HudArt.loadRuntimeSwf(mAssets,swf,name,function(param1:SwfAsset):void
         {
            if(mRoot == null || generation != mGeneration)
            {
               return;
            }
            var _loc2_:Class = HudIconBake.symbol(param1,swf,name);
            var _loc3_:MovieClip = new _loc2_() as MovieClip;
            if(_loc3_ == null)
            {
               HudArt.fatal("Required HUD tooltip icon is not a MovieClip: " + swf + " " + name);
            }
            _loc3_.scaleX = _loc3_.scaleY = 0.5;
            parent.addChildAt(_loc3_,1);
         });
      }
      
      public function clearAllIcons() : void
      {
         var _loc1_:StarlingModifierIcon = null;
         mGeneration = mGeneration + 1;
         if(mAssets != null)
         {
            mAssets.destroy();
         }
         mAssets = null;
         while(mRoot.tap_icon.numChildren > 1)
         {
            mRoot.tap_icon.removeChildAt(1);
         }
         while(mRoot.icon.numChildren > 1)
         {
            mRoot.icon.removeChildAt(1);
         }
         for each(_loc1_ in mModifiers)
         {
            try
            {
               _loc1_.destroy();
            }
            catch(error:Error)
            {
               StarlingHud.reportError(error);
            }
         }
         mModifiers.length = 0;
      }
      
      public function destroy() : void
      {
         clearAllIcons();
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeChild(mRoot);
         mRoot = null;
         mFacade = null;
      }
   }
}

