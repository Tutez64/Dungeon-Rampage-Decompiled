package FacebookAPI
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMFeedPosts;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMMapNode;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMSkin;
   import Town.TownHeader;
   import UI.Popup.DBUIOneButtonPopup;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   
   public class DBFacebookBragFeedPost
   {
      
      public function DBFacebookBragFeedPost()
      {
         super();
      }
      
      public static function buyHeroSuccess(townHeader:TownHeader, gmHero:GMHero, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var popupTitle:String = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 0.4;
         if(facade.isDRPlayer)
         {
            if(facade.steamAchievementsManager)
            {
               facade.steamAchievementsManager.setAchievement(facade.steamAchievementsManager.findUnlockHeroAchievementAPIName(gmHero));
            }
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_BUTTON");
         }
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
               var popup:DBUIOneButtonPopup;
               var swfAsset:SwfAsset = param1;
               var picClass:Class = swfAsset.getClass(gmHero.IconName);
               var avatarPic:MovieClip = new picClass();
               var movieClipRenderer:MovieClipRenderController = new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(avatarPic,0);
               gloatPopup.gloat_text.text = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmHero.Name.toUpperCase();
               TeamBonusUI = new UIObject(facade,gloatPopup.crewbonus);
               TeamBonusUI.tooltip.title_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_TITLE");
               TeamBonusUI.tooltip.description_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION");
               TeamBonusUI.root.header_crew_bonus_number.text = facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2;
               teamBonusUIMCRenderer = new MovieClipRenderer(facade,TeamBonusUI.root.header_crew_bonus_anim,onCompleteFunc);
               teamBonusUIMCRenderer.play();
               TeamBonusUIHeader = new UIObject(facade,gloatPopup.crewbonus_header);
               TeamBonusUIHeader.tooltip.title_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_TITLE");
               TeamBonusUIHeader.tooltip.description_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION");
               TeamBonusUIHeader.root.header_crew_bonus_number.text = facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 2;
               teamBonusUIHeaderMCRenderer = new MovieClipRenderer(facade,TeamBonusUIHeader.root.header_crew_bonus_anim,onCompleteHeaderFunc);
               teamBonusUIHeaderMCRenderer.play();
               onCompleteFunc = function():void
               {
                  TeamBonusUI.root.header_crew_bonus_number.text = facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1;
               };
               onCompleteHeaderFunc = function():void
               {
                  TeamBonusUIHeader.root.header_crew_bonus_number.text = facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1;
               };
               TweenMax.to(TeamBonusUI.root.header_crew_bonus_number,1.4,{"onComplete":onCompleteFunc});
               TweenMax.to(TeamBonusUIHeader.root.header_crew_bonus_number,1.4,{"onComplete":onCompleteHeaderFunc});
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function():void
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmHero.Id);
                  }
                  TeamBonusUI.destroy();
                  TeamBonusUI = null;
                  TeamBonusUIHeader.destroy();
                  TeamBonusUIHeader = null;
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buyHeroSuccess()");
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
         var popupCenterButtonText:String;
         var popupTitle:String = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 0.45;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset):void
            {
               var popup:DBUIOneButtonPopup;
               var swfAsset:SwfAsset = param1;
               var picClass:Class = swfAsset.getClass(gmSkin.IconName);
               var avatarPic:MovieClip = new picClass();
               var movieClipRenderer:MovieClipRenderController = new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x -= 150 * avatarPicScale;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(avatarPic,0);
               gloatPopup.gloat_text.text = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmSkin.Name.toUpperCase();
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function():void
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmSkin.Id);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buySkinSuccess()");
            });
         });
      }
      
      public static function buyPetSuccess(gmPet:GMNpc, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var popupTitle:String = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TITLE");
         var avatarPicScale:Number = 1;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmPet.IconSwfFilepath),function(param1:SwfAsset):void
            {
               var popup:DBUIOneButtonPopup;
               var swfAsset:SwfAsset = param1;
               var picClass:Class = swfAsset.getClass(gmPet.IconName);
               var avatarPic:MovieClip = new picClass();
               var movieClipRenderer:MovieClipRenderController = new MovieClipRenderController(facade,avatarPic);
               movieClipRenderer.play();
               avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
               avatarPic.y -= avatarPic.height / 2;
               avatarPic.x = 0;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(avatarPic,0);
               gloatPopup.gloat_text.text = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TEXT") + gmPet.Name.toUpperCase();
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function():void
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.purchaseFeedPost(gmPet.Id);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.buyPetSuccess()");
            });
         });
      }
      
      public static function openChestBrag(facade:DBFacade, shortItemName:String, fullItemName:String, itemPic:MovieClip, imagePath:String, itemType:uint, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupCenterButtonText:String;
         var popupTitle:String = Locale.getString("BRAG_CHEST_OPEN_POPUP_TITLE");
         var picScale:Number = 1;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_CHEST_OPEN_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var movieClipRenderer:MovieClipRenderController;
            var popup:DBUIOneButtonPopup;
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            movieClipRenderer = new MovieClipRenderController(facade,itemPic);
            movieClipRenderer.play();
            itemPic.scaleX = itemPic.scaleY = picScale;
            itemPic.y = 0;
            itemPic.x = 0;
            if(gloatPopup.avatar.numChildren > 0)
            {
               gloatPopup.avatar.removeChildAt(0);
            }
            gloatPopup.avatar.addChildAt(itemPic,0);
            gloatPopup.gloat_text.text = Locale.getString("BRAG_CHEST_OPEN_POPUP_TEXT") + fullItemName.toUpperCase();
            popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function():void
            {
               if(!facade.isDRPlayer)
               {
                  facade.facebookController.chestUnlockFeedPost(itemType,shortItemName,fullItemName,imagePath);
               }
            });
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.openChestBrag()");
         });
      }
      
      public static function defeatMapNodeBrag(facade:DBFacade, gmMapNode:GMMapNode, assetLoadingComponent:AssetLoadingComponent) : void
      {
         var gloatPopup:MovieClip;
         var popupTitle:String;
         var popupCenterButtonText:String;
         var picScale:Number;
         var itemPic:Bitmap;
         var feedPosts:Vector.<GMFeedPosts> = DBFacebookAPIController.getFeedPosts(facade,gmMapNode.Id,"MAP_NODE_DEFEATED");
         if(feedPosts.length == 0)
         {
            return;
         }
         popupTitle = Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_TITLE");
         picScale = 1.25;
         if(facade.isDRPlayer)
         {
            popupCenterButtonText = Locale.getString("SWEET");
         }
         else
         {
            popupCenterButtonText = Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_BUTTON");
         }
         assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var feedPosts:Vector.<GMFeedPosts>;
            var swfAsset:SwfAsset = param1;
            var tooltipClass:Class = swfAsset.getClass("weapon_tavern_tooltip");
            var gloatPopupClass:Class = swfAsset.getClass("tavern_gloat");
            gloatPopup = new gloatPopupClass();
            gloatPopup.x += 40;
            feedPosts = DBFacebookAPIController.getFeedPosts(facade,gmMapNode.Id,"MAP_NODE_DEFEATED");
            assetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath(feedPosts[0].FeedImageLink),function(param1:ImageAsset):void
            {
               var popup:DBUIOneButtonPopup;
               var imageAsset:ImageAsset = param1;
               itemPic = imageAsset.image;
               itemPic.scaleX = itemPic.scaleY = picScale;
               itemPic.y = -itemPic.height * 0.5;
               itemPic.x = -itemPic.width * 0.5;
               if(gloatPopup.avatar.numChildren > 0)
               {
                  gloatPopup.avatar.removeChildAt(0);
               }
               gloatPopup.avatar.addChildAt(itemPic,0);
               gloatPopup.gloat_text.text = Locale.getString("BRAG_MAP_NODE_DEFEATED_POPUP_TEXT") + gmMapNode.Name.toUpperCase();
               popup = new DBUIOneButtonPopup(facade,popupTitle,gloatPopup,popupCenterButtonText,function():void
               {
                  if(!facade.isDRPlayer)
                  {
                     facade.facebookController.mapNodeDefeatedFeedPost(gmMapNode.Id,gmMapNode.Name);
                  }
               });
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in DBFacebookBragFeedPost.defeatMapNodeBrag()");
            });
         });
      }
   }
}

