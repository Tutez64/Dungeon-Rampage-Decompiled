package UI
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.MovieClipRenderer;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMSkin;
   import SteamAchievements.SteamAPINames;
   import Town.TownHeader;
   import UI.Popup.DBUIOneButtonPopup;
   import flash.display.MovieClip;
   
   public class UIBragFeedPost
   {
      
      public function UIBragFeedPost()
      {
         super();
      }
      
      public static function buyHeroSuccess(townHeader:TownHeader, gmHero:GMHero, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var popupTitle:String = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 0.4;
         facade.steamAchievementsHelper.unlockAchievement(SteamAPINames.getUnlockHeroAchievementAPIName(gmHero.Constant));
         popupCenterButtonText = Locale.getString("SWEET");
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClassName:String = "avatar_purchase_popup";
            var gloatPopupClass:Class = swfAsset.getClass(gloatPopupClassName);
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmHero.PortraitName),function(param1:SwfAsset):void
            {
               var TeamBonusUI:UIObject;
               var teamBonusUIMCRenderer:MovieClipRenderer;
               var TeamBonusUIHeader:UIObject;
               var teamBonusUIHeaderMCRenderer:MovieClipRenderer;
               var onCompleteFunc:Function;
               var onCompleteHeaderFunc:Function;
               var teamBonusUITween:TweenHandle;
               var teamBonusUIHeaderTween:TweenHandle;
               var cleanupFunc:Function;
               var popup:DBUIOneButtonPopup;
               var swfAsset:SwfAsset = param1;
               var picClass:Class = swfAsset.getClass(gmHero.PortraitClassName);
               var avatarPic:MovieClip = new picClass();
               var movieClipRenderer:MovieClipRenderController = new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(avatarPic,0);
               TextUtil.setText(gloatPopup.gloat_text,Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmHero.Name.toUpperCase());
               TeamBonusUI = new UIObject(facade,gloatPopup.crewbonus);
               Locale.setText(TeamBonusUI.tooltip.title_label,"TEAM_BONUS_TOOLTIP_TITLE");
               Locale.setText(TeamBonusUI.tooltip.description_label,"TEAM_BONUS_TOOLTIP_DESCRIPTION");
               TextUtil.setText(TeamBonusUI.root.header_crew_bonus_number,String(facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2),0.73);
               teamBonusUIMCRenderer = new MovieClipRenderer(facade,TeamBonusUI.root.header_crew_bonus_anim,onCompleteFunc);
               teamBonusUIMCRenderer.play();
               TeamBonusUIHeader = new UIObject(facade,gloatPopup.crewbonus_header);
               Locale.setText(TeamBonusUIHeader.tooltip.title_label,"TEAM_BONUS_TOOLTIP_TITLE");
               Locale.setText(TeamBonusUIHeader.tooltip.description_label,"TEAM_BONUS_TOOLTIP_DESCRIPTION");
               TextUtil.setText(TeamBonusUIHeader.root.header_crew_bonus_number,String(facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2),0.73);
               teamBonusUIHeaderMCRenderer = new MovieClipRenderer(facade,TeamBonusUIHeader.root.header_crew_bonus_anim,onCompleteHeaderFunc);
               teamBonusUIHeaderMCRenderer.play();
               onCompleteFunc = function():void
               {
                  TextUtil.setText(TeamBonusUI.root.header_crew_bonus_number,String(facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1),0.73);
               };
               onCompleteHeaderFunc = function():void
               {
                  TextUtil.setText(TeamBonusUIHeader.root.header_crew_bonus_number,String(facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1),0.73);
               };
               teamBonusUITween = facade.mTween.tweenMaxTo(TeamBonusUI.root.header_crew_bonus_number,1.4,{"onComplete":onCompleteFunc});
               teamBonusUIHeaderTween = facade.mTween.tweenMaxTo(TeamBonusUIHeader.root.header_crew_bonus_number,1.4,{"onComplete":onCompleteHeaderFunc});
               cleanupFunc = function():void
               {
                  facade.mTween.killTween(teamBonusUITween);
                  facade.mTween.killTween(teamBonusUIHeaderTween);
                  TeamBonusUI.destroy();
                  TeamBonusUI = null;
                  TeamBonusUIHeader.destroy();
                  TeamBonusUIHeader = null;
               };
               popup = new DBUIOneButtonPopup(facade,"BRAG_FEED_POPUP",popupTitle,gloatPopup,popupCenterButtonText,cleanupFunc,true,cleanupFunc);
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIBragFeedPost.buyHeroSuccess()");
               popup.root.x = 100;
               popup.root.y = -180;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x -= 150 * avatarPicScale;
               townHeader.updateTeamBonusUI();
            });
         });
      }
      
      public static function buySkinSuccess(gmSkin:GMSkin, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupTitle:String = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 0.45;
         var popupCenterButtonText:String = Locale.getString("SWEET");
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
            {
               var _loc5_:Class = param1.getClass(gmSkin.PortraitClassName);
               var _loc2_:MovieClip = new _loc5_();
               var _loc4_:MovieClipRenderController = new MovieClipRenderController(facade,_loc2_);
               _loc4_.play();
               _loc2_.scaleX = _loc2_.scaleY = avatarPicScale;
               _loc2_.y -= _loc2_.height / 2;
               _loc2_.x -= 150 * avatarPicScale;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(_loc2_,0);
               TextUtil.setText(gloatPopup.gloat_text,Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmSkin.Name.toUpperCase());
               var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(facade,"BRAG_FEED_POPUP",popupTitle,gloatPopup,popupCenterButtonText,null);
               MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in UIBragFeedPost.buySkinSuccess()");
            });
         });
      }
      
      public static function buyPetSuccess(gmPet:GMNpc, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupTitle:String = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 1;
         var popupCenterButtonText:String = Locale.getString("SWEET");
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmPet.IconSwfFilepath),function(param1:SwfAsset):void
            {
               var _loc5_:Class = param1.getClass(gmPet.IconName);
               var _loc2_:MovieClip = new _loc5_();
               var _loc4_:MovieClipRenderController = new MovieClipRenderController(facade,_loc2_);
               _loc4_.play();
               _loc2_.scaleX = _loc2_.scaleY = avatarPicScale;
               _loc2_.y -= _loc2_.height / 2;
               _loc2_.x = 0;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(_loc2_,0);
               TextUtil.setText(gloatPopup.gloat_text,Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TEXT") + gmPet.Name.toUpperCase());
               var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(facade,"BRAG_FEED_POPUP",popupTitle,gloatPopup,popupCenterButtonText,null);
               MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in UIBragFeedPost.buyPetSuccess()");
            });
         });
      }
   }
}

