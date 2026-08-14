package UI.Options
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIRadioButton;
   import Brain.UI.UISlider;
   import Events.UIHudChangeEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Sound.DBSoundManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class OptionsPanel
   {
      
      private static const GRAPHICS_QUALITY_RADIO_BUTTON_GROUP:String = "GRAPHICS_QUALITY_RADIO_BUTTON_GROUP";
      
      private static const HUD_CHOICE_RADIO_BUTTON_GROUP:String = "HUD_CHOICE_RADIO_BUTTON_GROUP";
      
      private static var GRAPHICS_DIRTY:Boolean = false;
      
      private static var MUSIC_VOLUME_DIRTY:Boolean = false;
      
      private static var SFX_VOLUME_DIRTY:Boolean = false;
      
      private static var HUD_STYLE_DIRTY:Boolean = false;
      
      public static const HIGH_GRAPHICS_QUALITY:String = "high";
      
      public static const LOW_GRAPHICS_QUALITY:String = "low";
      
      protected var mDBFacade:DBFacade;
      
      protected var mDBSoundManager:DBSoundManager;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mEventComponent:EventComponent;
      
      private var mCurtainActive:Boolean = false;
      
      private var mCloseButton:UIButton;
      
      private var mTitleLabel:TextField;
      
      private var mSfxLabel:TextField;
      
      private var mMusicLabel:TextField;
      
      private var mMusicButton:UIButton;
      
      private var mGraphicsLabel:TextField;
      
      private var mGraphicsLowLabel:TextField;
      
      private var mGraphicsHighLabel:TextField;
      
      private var mGraphicsLowRadioButton:UIRadioButton;
      
      private var mGraphicsHighRadioButton:UIRadioButton;
      
      private var mSfxSlider:UISlider;
      
      private var mMusicSlider:UISlider;
      
      private var mHudLabel:TextField;
      
      private var mHudDefaultLabel:TextField;
      
      private var mHudCondensedLabel:TextField;
      
      private var mHudCondensedBlurbLabel:TextField;
      
      private var mHudDefaultBlurbLabel:TextField;
      
      private var mHudDefaultRadioButton:UIRadioButton;
      
      private var mHudCondensedRadioButton:UIRadioButton;
      
      private var mHudStyle:uint = 0;
      
      private var mGraphicsQuality:String;
      
      private var mRoot:MovieClip;
      
      public function OptionsPanel(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"OptionsPanel");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mDBSoundManager = mDBFacade.soundManager as DBSoundManager;
         readAccountDeetsToSetInitialValues();
         loadSwf();
      }
      
      private function readAccountDeetsToSetInitialValues() : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:String = mDBFacade.dbAccountInfo.getAttribute("optionsSFXVolume");
         if(_loc1_ != null)
         {
            _loc5_ = Number(_loc1_);
            mDBSoundManager.sfxVolumeScale = _loc5_;
         }
         var _loc3_:String = mDBFacade.dbAccountInfo.getAttribute("optionsMusicVolume");
         if(_loc3_ != null)
         {
            _loc4_ = Number(_loc3_);
            mDBSoundManager.musicVolumeScale = _loc4_;
         }
         mGraphicsQuality = mDBFacade.dbAccountInfo.getAttribute("optionsGraphicsQuality");
         if(mGraphicsQuality == "high")
         {
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-zoom",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-dynamic-rarity-backgrounds",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-damage-floaters",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-town-animations",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-buster-background-fade",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-pickup-ui-pop",true);
         }
         else if(mGraphicsQuality == "low")
         {
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-zoom",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-dynamic-rarity-backgrounds",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-damage-floaters",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-town-animations",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-buster-background-fade",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-pickup-ui-pop",false);
         }
         var _loc2_:String = mDBFacade.dbAccountInfo.getAttribute("optionsHudStyle");
         if(_loc2_ != null)
         {
            mHudStyle = uint(_loc2_);
         }
         else
         {
            mHudStyle = 0;
         }
      }
      
      private function loadSwf() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      private function swfLoaded(swfAsset:SwfAsset) : void
      {
         var optionsPanelX:Number;
         var optionsPanelY:Number;
         var optionsClass:Class = swfAsset.getClass("popup_options_02");
         mRoot = new optionsClass();
         mRoot.scaleY = mRoot.scaleX = 1.8;
         mCloseButton = new UIButton(mDBFacade,mRoot.close);
         mCloseButton.releaseCallback = hide;
         mTitleLabel = mRoot.title_label as TextField;
         mTitleLabel.text = Locale.getString("OPTIONS_PANEL_TITLE");
         mMusicLabel = mRoot.music_label as TextField;
         mMusicLabel.text = Locale.getString("OPTIONS_PANEL_MUSIC");
         mMusicSlider = new UISlider(mDBFacade,mRoot.music_slider,1);
         mMusicSlider.minimum = 0;
         mMusicSlider.maximum = 1.1;
         mMusicSlider.tick = 0.1;
         mMusicSlider.value = mDBSoundManager.musicVolumeScale;
         mRoot.music_slider_value.text = int(mMusicSlider.value * 10);
         mMusicSlider.updateCallback = musicSliderCallback;
         mSfxLabel = mRoot.sfx_label as TextField;
         mSfxLabel.text = Locale.getString("OPTIONS_PANEL_SOUND_EFFECTS_LABEL");
         mSfxSlider = new UISlider(mDBFacade,mRoot.sfx_slider,1);
         mSfxSlider.minimum = 0;
         mSfxSlider.maximum = 1.1;
         mSfxSlider.tick = 0.1;
         mSfxSlider.value = mDBSoundManager.sfxVolumeScale;
         mRoot.sfx_slider_value.text = int(mSfxSlider.value * 10);
         mSfxSlider.updateCallback = sfxSliderCallback;
         mGraphicsLabel = mRoot.graphics_label as TextField;
         mGraphicsLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_LABEL");
         mGraphicsLowLabel = mRoot.gfx_low_label as TextField;
         mGraphicsLowLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_LOW_LABEL");
         mGraphicsHighLabel = mRoot.gfx_high_label as TextField;
         mGraphicsHighLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_HIGH_LABEL");
         mGraphicsLowRadioButton = new UIRadioButton(mDBFacade,mRoot.gfx_low_radio_button,"GRAPHICS_QUALITY_RADIO_BUTTON_GROUP");
         mGraphicsHighRadioButton = new UIRadioButton(mDBFacade,mRoot.gfx_high_radio_button,"GRAPHICS_QUALITY_RADIO_BUTTON_GROUP");
         if(mDBFacade.featureFlags.getFlagValue("quality-control-button"))
         {
            mGraphicsLowRadioButton.releaseCallback = function():void
            {
               setQuality("low");
            };
            mGraphicsHighRadioButton.releaseCallback = function():void
            {
               setQuality("high");
            };
         }
         mHudLabel = mRoot.hud_label as TextField;
         mHudLabel.text = Locale.getString("OPTIONS_PANEL_HUD_LABEL");
         mHudDefaultLabel = mRoot.legacy_label as TextField;
         mHudDefaultLabel.text = Locale.getString("OPTIONS_PANEL_DEFAULT_HUD_LABEL");
         mHudCondensedLabel = mRoot.new_label as TextField;
         mHudCondensedLabel.text = Locale.getString("OPTIONS_PANEL_CONDENSED_HUD_LABEL");
         mHudDefaultRadioButton = new UIRadioButton(mDBFacade,mRoot.legacy_radio_button,"HUD_CHOICE_RADIO_BUTTON_GROUP");
         mHudDefaultRadioButton.releaseCallback = function():void
         {
            setHud(0);
         };
         mHudCondensedRadioButton = new UIRadioButton(mDBFacade,mRoot.new_radio_button,"HUD_CHOICE_RADIO_BUTTON_GROUP");
         mHudCondensedRadioButton.releaseCallback = function():void
         {
            setHud(1);
         };
         optionsPanelX = mDBFacade.dbConfigManager.getConfigNumber("options_panel_x",1500);
         optionsPanelY = mDBFacade.dbConfigManager.getConfigNumber("options_panel_y",200);
         mRoot.x = optionsPanelX;
         mRoot.y = optionsPanelY;
      }
      
      private function musicSliderCallback(val:Number) : void
      {
         var _loc2_:int = mMusicSlider.value * 10;
         mRoot.music_slider_value.text = _loc2_;
         if(_loc2_ == 11 && mDBFacade.steamAchievementsManager)
         {
            mDBFacade.steamAchievementsManager.setAchievement("MUSIC_VOLUME_SET_TO_11");
         }
         setMusicVolume(val);
      }
      
      private function sfxSliderCallback(val:Number) : void
      {
         mRoot.sfx_slider_value.text = int(mSfxSlider.value * 10);
         setSfxVolume(val);
      }
      
      private function setQuality(value:String) : void
      {
         mGraphicsQuality = value;
         GRAPHICS_DIRTY = true;
         if(mGraphicsQuality == "high")
         {
            mDBFacade.featureFlags.setFlagOverrideValue("want-zoom",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-dynamic-rarity-backgrounds",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-damage-floaters",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-town-animations",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-buster-background-fade",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-pickup-ui-pop",true);
         }
         else if(mGraphicsQuality == "low")
         {
            mDBFacade.featureFlags.setFlagOverrideValue("want-zoom",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-dynamic-rarity-backgrounds",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-damage-floaters",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-town-animations",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-buster-background-fade",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-pickup-ui-pop",false);
         }
      }
      
      private function setHud(type:uint) : void
      {
         mHudStyle = type;
         HUD_STYLE_DIRTY = true;
         mEventComponent.dispatchEvent(new UIHudChangeEvent(mHudStyle));
      }
      
      private function setSfxVolume(val:Number) : void
      {
         mDBSoundManager.sfxVolumeScale = val;
         SFX_VOLUME_DIRTY = true;
      }
      
      private function setMusicVolume(val:Number) : void
      {
         mDBSoundManager.musicVolumeScale = val;
         MUSIC_VOLUME_DIRTY = true;
      }
      
      public function hide() : void
      {
         if(mRoot)
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
         removeCurtain();
         saveValuesToDB();
      }
      
      private function saveValuesToDB() : void
      {
         if(GRAPHICS_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsGraphicsQuality") != mGraphicsQuality)
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsGraphicsQuality",mGraphicsQuality);
            }
         }
         if(SFX_VOLUME_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsSFXVolume") != mDBSoundManager.sfxVolumeScale.toString())
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsSFXVolume",mDBSoundManager.sfxVolumeScale.toString());
            }
         }
         if(MUSIC_VOLUME_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsMusicVolume") != mDBSoundManager.musicVolumeScale.toString())
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsMusicVolume",mDBSoundManager.musicVolumeScale.toString());
            }
         }
         if(HUD_STYLE_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsHudStyle") as uint != mHudStyle)
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsHudStyle",mHudStyle.toString());
            }
         }
         GRAPHICS_DIRTY = false;
         SFX_VOLUME_DIRTY = false;
         MUSIC_VOLUME_DIRTY = false;
         HUD_STYLE_DIRTY = false;
      }
      
      public function show() : void
      {
         if(mRoot)
         {
            if(mGraphicsQuality == "high")
            {
               mGraphicsHighRadioButton.selected = true;
            }
            else
            {
               mGraphicsLowRadioButton.selected = true;
            }
            switch(int(mHudStyle))
            {
               case 0:
                  mHudDefaultRadioButton.selected = true;
                  break;
               case 1:
                  mHudCondensedRadioButton.selected = true;
            }
            mSceneGraphComponent.addChild(mRoot,105);
            showCurtain();
         }
      }
      
      private function showCurtain() : void
      {
         if(!mCurtainActive)
         {
            mCurtainActive = true;
            mSceneGraphComponent.showPopupCurtain();
         }
      }
      
      private function removeCurtain() : void
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mSceneGraphComponent.removePopupCurtain();
         }
      }
      
      public function toggleVisible() : Boolean
      {
         if(mRoot)
         {
            if(mSceneGraphComponent.contains(mRoot,50))
            {
               this.hide();
               return false;
            }
            this.show();
            return true;
         }
         return false;
      }
      
      public function destroy() : void
      {
         hide();
         mCloseButton.destroy();
         mSfxSlider.destroy();
         mMusicSlider.destroy();
         mGraphicsLowRadioButton.destroy();
         mGraphicsHighRadioButton.destroy();
         mRoot = null;
         mCloseButton = null;
         mSfxSlider = null;
         mMusicSlider = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         if(mHudDefaultRadioButton)
         {
            mHudDefaultRadioButton.destroy();
            mHudDefaultRadioButton = null;
         }
         if(mHudCondensedRadioButton)
         {
            mHudCondensedRadioButton.destroy();
            mHudCondensedRadioButton = null;
         }
         mDBFacade = null;
      }
   }
}

