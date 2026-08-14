package UI.Modifiers
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMLegendaryModifier;
   import GameMasterDictionary.GMModifier;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class UIModifier
   {
      
      public static const MODIFIER_UI_SWF_NAME:String = "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";
      
      public static const MODIFIER_UI_CLASS_NAME:String = "ui_modifier_template";
      
      private var mParentMC:MovieClip;
      
      private var mRoot:MovieClip;
      
      private var mGMModifier:GMModifier;
      
      private var mGMLegendaryModifier:GMLegendaryModifier;
      
      private var mToolTip:UIModifierTooltip;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function UIModifier(dbFacade:DBFacade, parentMC:MovieClip, constant:String, id:uint = 0, isLegendaryModifier:Boolean = false, legendaryModifierNum:uint = 0)
      {
         super();
         mDBFacade = dbFacade;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
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
                  Logger.error("Creating UIModifierRegular with invalid data");
                  return;
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
               Logger.error("Creating UIModifierLegendary with invalid data");
               return;
            }
            mGMLegendaryModifier = mDBFacade.gameMaster.legendaryModifiersByConstant.itemFor(constant);
         }
         mParentMC = parentMC;
         setupOnUI();
      }
      
      public function get gmModifier() : GMModifier
      {
         return mGMModifier;
      }
      
      public function setupOnUI() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Modifier/db_icons_modifier.swf"),function(param1:SwfAsset):void
         {
            var _loc4_:MovieClip = null;
            var _loc3_:int = 0;
            var _loc6_:int = 0;
            if(mParentMC == null)
            {
               return;
            }
            var _loc2_:Class = param1.getClass("ui_modifier_template");
            mRoot = new _loc2_() as MovieClip;
            mParentMC.addChild(mRoot);
            if(mParentMC.modifier_icon_frame)
            {
               mParentMC.modifier_icon_frame.visible = false;
            }
            var _loc7_:Class = param1.getClass(mGMLegendaryModifier != null ? mGMLegendaryModifier.IconName : mGMModifier.IconName);
            var _loc5_:MovieClip = new _loc7_() as MovieClip;
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
            mToolTip = new UIModifierTooltip(mDBFacade,mRoot,param1,mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_NAME",mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",mGMModifier.Constant),mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_DESCRIPTION",mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_DESCRIPTION",mGMModifier.Constant));
            mToolTip.hide();
            mRoot.addEventListener("rollOver",onMouseOver);
            mRoot.addEventListener("rollOut",onMouseOut);
         });
      }
      
      public function onMouseOver(mEvt:MouseEvent) : void
      {
         mToolTip.show();
      }
      
      public function onMouseOut(mEvt:MouseEvent) : void
      {
         mToolTip.hide();
      }
      
      public function destroy() : void
      {
         if(mParentMC.modifier_icon_frame)
         {
            mParentMC.modifier_icon_frame.visible = true;
         }
         if(mRoot)
         {
            mRoot.removeEventListener("rollOver",onMouseOver);
            mRoot.removeEventListener("rollOut",onMouseOut);
            mParentMC.removeChild(mRoot);
         }
         mRoot = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mParentMC = null;
         if(mToolTip)
         {
            mToolTip.destroy();
            mToolTip = null;
         }
      }
   }
}

