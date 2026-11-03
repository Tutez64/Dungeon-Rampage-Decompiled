package Facade
{
   import Brain.AssetRepository.AssetLoaderInfo;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Utils.TextUtil;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class Locale
   {
      
      public static const DEFAULT_NAMETAG:String = "DEFAULT_NAMETAG";
      
      private static var mDefaultStringTable:Object;
      
      private static var mOverrideStringTable:Object;
      
      private static var dbFacade:DBFacade;
      
      public static const MIN_FONT_SIZE_HIGH_RES:int = 9;
      
      public static const MIN_FONT_SIZE_HIGH_RES_LOCALIZED:int = 7;
      
      public static const MIN_FONT_SIZE_LOW_RES:int = 11;
      
      public static const MIN_FONT_SIZE_LOW_RES_LOCALIZED:int = 9;
      
      public static const LOW_RES_MAX_WIDTH:int = 1600;
      
      public static const LOW_RES_MAX_HEIGHT:int = 900;
      
      private static var mMinFontSizeHighRes:int = 9;
      
      private static var mMinFontSizeHighResLocalized:int = 7;
      
      private static var mMinFontSizeLowRes:int = 11;
      
      private static var mMinFontSizeLowResLocalized:int = 9;
      
      public static const NAMETAG_MIN_FONT_SIZE_PX:int = 18;
      
      private static var mNametagMinFontSizePx:int = 18;
      
      public static const SIZE_MODIFIER_UI:Number = 1;
      
      public static const SIZE_MODIFIER_WORLD:Number = 1.82;
      
      public static const RESCUE_ALERT_SIZE_MODIFIER:Number = 1.64;
      
      public static const SIZE_MODIFIER_OFFSCREEN:Number = 1.27;
      
      public static const OFFSCREEN_MARKER_SIZE_MODIFIER:Number = 1.82;
      
      public static const OFFSCREEN_RESCUE_SIZE_MODIFIER:Number = 1.36;
      
      public static const POPUP_MESSAGE_SIZE_MODIFIER:Number = 1.55;
      
      public static const GIFT_INFO_MESSAGE_SIZE_MODIFIER:Number = 1.55;
      
      public static const CREW_BONUS_TITLE_SIZE_MODIFIER:Number = 0.82;
      
      public static const CREW_BONUS_NUMBER_SIZE_MODIFIER:Number = 0.73;
      
      public static const HUD_CHAT_SIZE_MODIFIER:Number = 1.18;
      
      public static const STAT_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const STAT_UPGRADE_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const SHOP_TIMER_LABEL_SIZE_MODIFIER:Number = 1.55;
      
      public static const SHOP_COUNTDOWN_SIZE_MODIFIER:Number = 1.18;
      
      public static const SHOP_CARD_TIMER_SIZE_MODIFIER:Number = 1.55;
      
      public static const SHOP_OFFER_TITLE_SIZE_MODIFIER:Number = 1.45;
      
      public static const SHOP_OFFER_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const WEAPON_TOOLTIP_SIZE_MODIFIER:Number = 1.55;
      
      public static const WEAPON_ITEM_TOOLTIP_SIZE_MODIFIER:Number = 1.09;
      
      public static const SUMMARY_CHAT_SIZE_MODIFIER:Number = 1.55;
      
      public static const SUMMARY_NAME_LOW_RES_SIZE_MODIFIER:Number = 1.33;
      
      public static const SUMMARY_CHAT_BALLOON_SIZE_MODIFIER:Number = 1.47;
      
      public static const MAP_NODE_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const MAP_NODE_TITLE_SIZE_MODIFIER:Number = 1.73;
      
      public static const ULTIMATE_RAMPAGE_CYCLE_SIZE_MODIFIER:Number = 1.55;
      
      public static const HOW_TO_CURRENCY_SIZE_MODIFIER:Number = 1.55;
      
      public static const LOADING_HINT_SIZE_MODIFIER:Number = 1.55;
      
      public static const CHEST_HERO_LABEL_SIZE_MODIFIER:Number = 1.55;
      
      public static const DAILY_REWARD_COMEBACK_SIZE_MODIFIER:Number = 1.55;
      
      public static const TAVERN_STORY_SIZE_MODIFIER:Number = 1.55;
      
      public static const TAVERN_SKIN_STATUS_SIZE_MODIFIER:Number = 1.55;
      
      public static const FRIEND_MANAGER_DESCRIPTION_SIZE_MODIFIER:Number = 2.73;
      
      public static const FRIEND_INVITE_DESCRIPTION_SIZE_MODIFIER:Number = 2.73;
      
      public static const HERO_TOOLTIP_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const CHEST_REVEAL_DESCRIPTION_SIZE_MODIFIER:Number = 1.55;
      
      public static const NEWS_FEED_SIZE_MODIFIER:Number = 1.82;
      
      public function Locale()
      {
         super();
      }
      
      public static function get isDefaultLoaded() : Boolean
      {
         return mDefaultStringTable != null;
      }
      
      public static function get isOverrideActive() : Boolean
      {
         return mOverrideStringTable != null && mOverrideStringTable.strings != null;
      }
      
      public static function get isLowRes() : Boolean
      {
         var _loc1_:Stage = dbFacade != null ? dbFacade.stageRef : null;
         if(_loc1_ == null)
         {
            return true;
         }
         return _loc1_.stageWidth <= 1600 || _loc1_.stageHeight <= 900;
      }
      
      private static function configMinFontSize(key:String, fallback:int) : int
      {
         var _loc3_:int = dbFacade.dbConfigManager.getConfigNumber(key,fallback);
         return _loc3_ > 0 ? _loc3_ : fallback;
      }
      
      public static function applyMinFontSize() : void
      {
         var _loc1_:Boolean = isLowRes;
         var _loc3_:Boolean = isOverrideActive;
         var _loc2_:int = _loc1_ ? (_loc3_ ? mMinFontSizeLowResLocalized : mMinFontSizeLowRes) : (_loc3_ ? mMinFontSizeHighResLocalized : mMinFontSizeHighRes);
         TextUtil.minFontSize = _loc2_;
         Logger.debugch("Locale","Minimum font size " + _loc2_ + " (" + (_loc1_ ? "low-res" : "high-res") + (_loc3_ ? ", localized" : "") + ")");
      }
      
      public static function get summaryNameSizeModifier() : Number
      {
         return isLowRes ? 1.33 : 1;
      }
      
      public static function get nametagSizeModifier() : Number
      {
         var _loc1_:Number = dbFacade != null && dbFacade.viewScale > 0 ? dbFacade.viewScale : 1;
         return TextUtil.modifierForSize(Math.ceil(mNametagMinFontSizePx / _loc1_));
      }
      
      private static function onStageResize(event:Event) : void
      {
         applyMinFontSize();
      }
      
      public static function loadStrings(facade:DBFacade, callback:Function) : void
      {
         var overrideLanguageAssetInfo:AssetLoaderInfo;
         var defaultLanguageAssetInfo:AssetLoaderInfo;
         dbFacade = facade;
         mMinFontSizeHighRes = configMinFontSize("min_font_size_high_res",9);
         mMinFontSizeHighResLocalized = configMinFontSize("min_font_size_high_res_localized",7);
         mMinFontSizeLowRes = configMinFontSize("min_font_size_low_res",11);
         mMinFontSizeLowResLocalized = configMinFontSize("min_font_size_low_res_localized",9);
         mNametagMinFontSizePx = configMinFontSize("nametag_min_font_size_px",18);
         applyMinFontSize();
         if(facade.stageRef != null)
         {
            EventListeners.remove(facade.stageRef,"resize",onStageResize);
            EventListeners.add(facade.stageRef,"resize",onStageResize);
         }
         overrideLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.override.json"),false);
         facade.assetRepository.getJsonAsset(overrideLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Override Locale loaded!");
            mOverrideStringTable = param1.json;
            applyMinFontSize();
            callback();
         },function():void
         {
            Logger.warnch("Locale","Failed to load Override Locale JSON.");
         });
         defaultLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.default.json"),false);
         facade.assetRepository.getJsonAsset(defaultLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Default Locale loaded!");
            mDefaultStringTable = param1.json;
            callback();
         },function():void
         {
            Logger.fatal("Default Locale File \'Locale.default.json\' failed to Load, cannot proceed with loading the game. Please run \'Verify integrity of game files\' on Steam.");
         });
      }
      
      public static function getString(key:String) : String
      {
         var _loc4_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getString before load has finished: " + key);
            return key;
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc3_ = mOverrideStringTable.strings[key];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.strings[key];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized string not found: " + key);
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default string not found: " + key);
            return "mia:" + key;
         }
         return _loc2_;
      }
      
      public static function getSubString(key:String, subKey:String) : String
      {
         var _loc7_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getSubString before load has finished: " + key + " subKey: " + subKey);
            return key;
         }
         var _loc5_:Object = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc5_ = mOverrideStringTable.strings[key];
            _loc7_ = true;
         }
         var _loc3_:Object = mDefaultStringTable.strings[key];
         if(_loc5_ == null && _loc3_ == null)
         {
            Logger.error("Unable to find in the `strings` table a dictionary for key: " + key + " (when looking up subKey: " + subKey + ")");
            return "mia:" + key;
         }
         var _loc6_:String = null;
         if(_loc5_ != null)
         {
            _loc6_ = _loc5_[subKey];
            if(_loc6_ != null)
            {
               return _loc6_;
            }
         }
         var _loc4_:String = _loc3_ != null ? _loc3_[subKey] : null;
         if(_loc7_)
         {
            Logger.warnch("Locale","Localized sub string not found: " + key + " subKey: " + subKey + " Using English default value of: `" + _loc4_ + "`");
         }
         if(_loc4_ == null)
         {
            Logger.error("Default sub string not found: " + key + " subKey: " + subKey);
            return "mia:" + key;
         }
         return _loc4_;
      }
      
      public static function setText(field:TextField, key:String, params:Object = null, sizeModifier:Number = 1) : void
      {
         field.text = key == null || key == "" ? "" : format(key,params);
         TextUtil.fitToField(field,sizeModifier);
      }
      
      public static function setSubText(field:TextField, key:String, subKey:String, sizeModifier:Number = 1) : void
      {
         field.text = key == null || key == "" ? "" : getSubString(key,subKey);
         TextUtil.fitToField(field,sizeModifier);
      }
      
      public static function format(key:String, params:Object) : String
      {
         var _loc4_:RegExp = null;
         var _loc3_:String = getString(key);
         if(params == null)
         {
            return _loc3_;
         }
         for(var _loc5_:String in params)
         {
            _loc4_ = new RegExp("#" + _loc5_ + "(?:#|(?![A-Za-z0-9_]))","g");
            _loc3_ = _loc3_.split(_loc4_).join(String(params[_loc5_]));
         }
         return _loc3_;
      }
      
      public static function getError(key:int) : String
      {
         var _loc4_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getError before load has finished: " + key.toString());
            return "Error (" + key.toString() + ")";
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.errors != null)
         {
            _loc3_ = mOverrideStringTable.errors[key.toString()];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.errors[key.toString()];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized error string not found: " + key.toString());
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default error string not found: " + key.toString());
            _loc2_ = mDefaultStringTable.errors["DEF"];
            if(_loc2_ == null)
            {
               _loc2_ = "Error ";
            }
            _loc2_ += "(" + key.toString() + ")";
         }
         return _loc2_;
      }
   }
}

