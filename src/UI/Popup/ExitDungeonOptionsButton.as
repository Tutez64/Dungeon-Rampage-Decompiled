package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class ExitDungeonOptionsButton
   {
      
      private static const OPTIONS_BUTTON_CLASS_NAME:String = "options_panel_button";
      
      private static const BUTTON_SCALE:Number = 0.45;
      
      private var mButton:UIButton;
      
      public function ExitDungeonOptionsButton(dbFacade:DBFacade, assetLoadingComponent:AssetLoadingComponent, popup:MovieClip, position:Point, closeButton:UIButton, downTarget:UIObject, releaseCallback:Function)
      {
         super();
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("options_panel_button");
            var _loc3_:MovieClip = new _loc2_() as MovieClip;
            _loc3_.name = "options_panel_button";
            _loc3_.x = position.x;
            _loc3_.y = position.y;
            _loc3_.scaleX = _loc3_.scaleY = 0.45;
            popup.addChild(_loc3_);
            mButton = new UIButton(dbFacade,_loc3_);
            mButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mButton.releaseCallback = releaseCallback;
            if(closeButton)
            {
               mButton.isToTheLeftOf(closeButton);
            }
            if(downTarget)
            {
               mButton.downNavigation = downTarget;
            }
         });
      }
      
      public function destroy() : void
      {
         if(mButton)
         {
            mButton.destroy();
            mButton = null;
         }
      }
   }
}

