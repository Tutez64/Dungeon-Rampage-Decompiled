package starling.display
{
   import starling.core.Starling;
   
   public class BlendMode
   {
      
      private static var sBlendModes:Object;
      
      public static const AUTO:String = "auto";
      
      public static const NONE:String = "none";
      
      public static const NORMAL:String = "normal";
      
      public static const ADD:String = "add";
      
      public static const MULTIPLY:String = "multiply";
      
      public static const SCREEN:String = "screen";
      
      public static const ERASE:String = "erase";
      
      public static const MASK:String = "mask";
      
      public static const BELOW:String = "below";
      
      private var _name:String;
      
      private var _sourceFactor:String;
      
      private var _destinationFactor:String;
      
      public function BlendMode(name:String, sourceFactor:String, destinationFactor:String)
      {
         super();
         _name = name;
         _sourceFactor = sourceFactor;
         _destinationFactor = destinationFactor;
      }
      
      public static function get(modeName:String) : BlendMode
      {
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         if(modeName in sBlendModes)
         {
            return sBlendModes[modeName];
         }
         throw new ArgumentError("Blend mode not found: " + modeName);
      }
      
      public static function register(name:String, srcFactor:String, dstFactor:String) : BlendMode
      {
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         var _loc4_:BlendMode = new BlendMode(name,srcFactor,dstFactor);
         sBlendModes[name] = _loc4_;
         return _loc4_;
      }
      
      private static function registerDefaults() : void
      {
         if(sBlendModes)
         {
            return;
         }
         sBlendModes = {};
         register("none","one","zero");
         register("normal","one","oneMinusSourceAlpha");
         register("add","one","one");
         register("multiply","destinationColor","oneMinusSourceAlpha");
         register("screen","one","oneMinusSourceColor");
         register("erase","zero","oneMinusSourceAlpha");
         register("mask","zero","sourceAlpha");
         register("below","oneMinusDestinationAlpha","destinationAlpha");
      }
      
      public static function getAll(out:Array = null) : Array
      {
         if(!out)
         {
            out = [];
         }
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         for each(var _loc2_:BlendMode in sBlendModes)
         {
            out.insertAt(0,_loc2_);
         }
         return out;
      }
      
      public static function isRegistered(modeName:String) : Boolean
      {
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         return modeName in sBlendModes;
      }
      
      public function activate() : void
      {
         Starling.context.setBlendFactors(_sourceFactor,_destinationFactor);
      }
      
      public function toString() : String
      {
         return _name;
      }
      
      public function get sourceFactor() : String
      {
         return _sourceFactor;
      }
      
      public function get destinationFactor() : String
      {
         return _destinationFactor;
      }
      
      public function get name() : String
      {
         return _name;
      }
   }
}

