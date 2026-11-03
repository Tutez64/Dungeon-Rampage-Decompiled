package starling.utils
{
   import flash.display3D.Context3D;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.text.Font;
   import flash.utils.getDefinitionByName;
   import starling.errors.AbstractClassError;
   
   public class SystemUtil
   {
      
      private static var sInitialized:Boolean = false;
      
      private static var sApplicationActive:Boolean = true;
      
      private static var sPlatform:String;
      
      private static var sVersion:String;
      
      private static var sAIR:Boolean;
      
      private static var sEmbeddedFonts:Array = null;
      
      private static var sSupportsDepthAndStencil:Boolean = true;
      
      private static var sWaitingCalls:Array = [];
      
      public function SystemUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function initialize() : void
      {
         var _loc4_:Object = null;
         var _loc3_:EventDispatcher = null;
         var _loc1_:XML = null;
         var _loc2_:Namespace = null;
         var _loc5_:String = null;
         if(sInitialized)
         {
            return;
         }
         sInitialized = true;
         sPlatform = Capabilities.version.substr(0,3);
         sVersion = Capabilities.version.substr(4);
         try
         {
            _loc4_ = getDefinitionByName("flash.desktop::NativeApplication");
            _loc3_ = _loc4_["nativeApplication"] as EventDispatcher;
            _loc3_.addEventListener("activate",onActivate,false,0,true);
            _loc3_.addEventListener("deactivate",onDeactivate,false,0,true);
            _loc1_ = _loc3_["applicationDescriptor"];
            _loc2_ = _loc1_.namespace();
            _loc5_ = _loc1_._loc2_::initialWindow._loc2_::depthAndStencil.toString().toLowerCase();
            sSupportsDepthAndStencil = _loc5_ == "true";
            sAIR = true;
         }
         catch(e:Error)
         {
            sAIR = false;
         }
      }
      
      private static function onActivate(event:Object) : void
      {
         sApplicationActive = true;
         for each(var _loc2_:Array in sWaitingCalls)
         {
            try
            {
               _loc2_[0].apply(null,_loc2_[1]);
            }
            catch(e:Error)
            {
            }
         }
         sWaitingCalls = [];
      }
      
      private static function onDeactivate(event:Object) : void
      {
         sApplicationActive = false;
      }
      
      public static function executeWhenApplicationIsActive(call:Function, ... rest) : void
      {
         initialize();
         if(sApplicationActive)
         {
            call.apply(null,rest);
         }
         else
         {
            sWaitingCalls.push([call,rest]);
         }
      }
      
      public static function get isApplicationActive() : Boolean
      {
         initialize();
         return sApplicationActive;
      }
      
      public static function get isAIR() : Boolean
      {
         initialize();
         return sAIR;
      }
      
      public static function get version() : String
      {
         initialize();
         return sVersion;
      }
      
      public static function get platform() : String
      {
         initialize();
         return sPlatform;
      }
      
      public static function set platform(value:String) : void
      {
         initialize();
         sPlatform = value;
      }
      
      public static function get supportsDepthAndStencil() : Boolean
      {
         return sSupportsDepthAndStencil;
      }
      
      public static function get supportsVideoTexture() : Boolean
      {
         return Context3D["supportsVideoTexture"];
      }
      
      public static function updateEmbeddedFonts() : void
      {
         sEmbeddedFonts = null;
      }
      
      public static function isEmbeddedFont(fontName:String, bold:Boolean = false, italic:Boolean = false, fontType:String = "embedded") : Boolean
      {
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc5_:Boolean = false;
         if(sEmbeddedFonts == null)
         {
            sEmbeddedFonts = Font.enumerateFonts(false);
         }
         for each(var _loc8_:Font in sEmbeddedFonts)
         {
            _loc6_ = _loc8_.fontStyle;
            _loc7_ = _loc6_ == "bold" || _loc6_ == "boldItalic";
            _loc5_ = _loc6_ == "italic" || _loc6_ == "boldItalic";
            if(fontName == _loc8_.fontName && bold == _loc7_ && italic == _loc5_ && fontType == _loc8_.fontType)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function get isIOS() : Boolean
      {
         return platform == "IOS";
      }
      
      public static function get isAndroid() : Boolean
      {
         return platform == "AND";
      }
      
      public static function get isMac() : Boolean
      {
         return platform == "MAC";
      }
      
      public static function get isWindows() : Boolean
      {
         return platform == "WIN";
      }
      
      public static function get isDesktop() : Boolean
      {
         return platform == "WIN" || platform == "MAC" || platform == "LNX";
      }
   }
}

