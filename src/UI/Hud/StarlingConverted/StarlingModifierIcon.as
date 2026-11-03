package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventListeners;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMLegendaryModifier;
   import GameMasterDictionary.GMModifier;
   import UI.Modifiers.UIModifierTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   internal class StarlingModifierIcon
   {
      
      internal static const MODIFIER_UI_SWF_NAME:String = "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";
      
      internal static const MODIFIER_UI_CLASS_NAME:String = "ui_modifier_template";
      
      internal static const MODIFIER_TOOLTIP_CLASS_NAME:String = "modifier_tooltip";
      
      private var mParentMC:MovieClip;
      
      private var mRoot:MovieClip;
      
      private var mGMModifier:GMModifier;
      
      private var mGMLegendaryModifier:GMLegendaryModifier;
      
      private var mToolTip:UIModifierTooltip;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function StarlingModifierIcon(dbFacade:DBFacade, parentMC:MovieClip, constant:String, id:uint = 0, isLegendaryModifier:Boolean = false, legendaryModifierNum:uint = 0)
      {
         super();
         mDBFacade = dbFacade;
         if(!isLegendaryModifier)
         {
            if(constant != "")
            {
               mGMModifier = mDBFacade.gameMaster.modifiersByConstant.itemFor(constant);
            }
            else
            {
               if(id <= 0)
               {
                  throw new Error("Invalid Starling modifier data");
               }
               mGMModifier = mDBFacade.gameMaster.modifiersById.itemFor(id);
            }
         }
         else if(legendaryModifierNum > 0)
         {
            mGMLegendaryModifier = mDBFacade.gameMaster.legendaryModifiersById.itemFor(legendaryModifierNum);
         }
         else
         {
            if(!constant)
            {
               throw new Error("Invalid Starling modifier data");
            }
            mGMLegendaryModifier = mDBFacade.gameMaster.legendaryModifiersByConstant.itemFor(constant);
         }
         if(parentMC == null || mGMModifier == null && mGMLegendaryModifier == null)
         {
            throw new Error("Missing Starling modifier data");
         }
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mParentMC = parentMC;
         setupOnUI();
      }
      
      private function setupOnUI() : void
      {
         var iconName:String = mGMLegendaryModifier != null ? mGMLegendaryModifier.IconName : mGMModifier.IconName;
         HudArt.loadRuntimeSwf(mAssetLoadingComponent,"Resources/Art2D/Icons/Modifier/db_icons_modifier.swf",iconName,function(param1:SwfAsset):void
         {
            var _loc4_:MovieClip = null;
            var _loc3_:int = 0;
            var _loc6_:int = 0;
            if(mParentMC == null)
            {
               return;
            }
            var _loc7_:Class = HudIconBake.symbol(param1,"Resources/Art2D/Icons/Modifier/db_icons_modifier.swf",iconName);
            var _loc2_:Class = HudIconBake.symbol(param1,"Resources/Art2D/Icons/Modifier/db_icons_modifier.swf","ui_modifier_template");
            mRoot = new _loc2_() as MovieClip;
            if(mRoot == null)
            {
               HudArt.fatal("Required HUD modifier template is not a MovieClip: Resources/Art2D/Icons/Modifier/db_icons_modifier.swf ui_modifier_template");
            }
            mParentMC.addChild(mRoot);
            if(mParentMC.modifier_icon_frame)
            {
               mParentMC.modifier_icon_frame.visible = false;
            }
            var _loc5_:MovieClip = new _loc7_() as MovieClip;
            if(_loc5_ == null)
            {
               HudArt.fatal("Required HUD modifier icon is not a MovieClip: Resources/Art2D/Icons/Modifier/db_icons_modifier.swf " + iconName);
            }
            _loc5_.scaleX = _loc5_.scaleY = 0.5;
            mRoot.modifier_icon.addChild(_loc5_);
            if(mGMLegendaryModifier)
            {
               mRoot.modifier_icon_slot.visible = false;
            }
            if(mGMLegendaryModifier == null)
            {
               _loc3_ = 5;
               _loc6_ = 0;
               while(_loc6_ < _loc3_)
               {
                  _loc4_ = mRoot.modifier_icon_slot.getChildByName("star" + (_loc6_ + 1).toString());
                  _loc4_.visible = false;
                  _loc6_++;
               }
               _loc6_ = 0;
               while(_loc6_ < mGMModifier.Level)
               {
                  _loc4_ = mRoot.modifier_icon_slot.getChildByName("star" + (_loc6_ + 1).toString());
                  _loc4_.visible = true;
                  _loc6_++;
               }
            }
            HudArt.requireClass(param1,"Resources/Art2D/Icons/Modifier/db_icons_modifier.swf","modifier_tooltip");
            mToolTip = new UIModifierTooltip(mDBFacade,mRoot,param1,mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_NAME",mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",mGMModifier.Constant),mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_DESCRIPTION",mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_DESCRIPTION",mGMModifier.Constant));
            mToolTip.hide();
            EventListeners.add(mRoot,"rollOver",onMouseOver);
            EventListeners.add(mRoot,"rollOut",onMouseOut);
         });
      }
      
      private function onMouseOver(mEvt:MouseEvent) : void
      {
         try
         {
            mToolTip.show();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      private function onMouseOut(mEvt:MouseEvent) : void
      {
         try
         {
            mToolTip.hide();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function destroy() : void
      {
         if(mParentMC == null)
         {
            return;
         }
         if(mParentMC.modifier_icon_frame)
         {
            mParentMC.modifier_icon_frame.visible = true;
         }
         if(mRoot)
         {
            EventListeners.remove(mRoot,"rollOver",onMouseOver);
            EventListeners.remove(mRoot,"rollOut",onMouseOut);
            if(mRoot.parent != null)
            {
               mRoot.parent.removeChild(mRoot);
            }
         }
         mRoot = null;
         StarlingHud.disposeResource(mAssetLoadingComponent,"destroy");
         mAssetLoadingComponent = null;
         mParentMC = null;
         if(mToolTip)
         {
            StarlingHud.disposeResource(mToolTip,"destroy");
            mToolTip = null;
         }
      }
   }
}

