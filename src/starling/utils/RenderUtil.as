package starling.utils
{
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.errors.AbstractClassError;
   import starling.textures.Texture;
   
   public class RenderUtil
   {
      
      public function RenderUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function clear(rgb:uint = 0, alpha:Number = 0, depth:Number = 1, stencil:uint = 0) : void
      {
         Starling.context.clear(Color.getRed(rgb) / 255,Color.getGreen(rgb) / 255,Color.getBlue(rgb) / 255,alpha,depth,stencil);
      }
      
      public static function getTextureLookupFlags(format:String, mipMapping:Boolean, repeat:Boolean = false, smoothing:String = "bilinear") : String
      {
         var _loc5_:Array = ["2d",repeat ? "repeat" : "clamp"];
         if(format == "compressed")
         {
            _loc5_.push("dxt1");
         }
         else if(format == "compressedAlpha")
         {
            _loc5_.push("dxt5");
         }
         if(smoothing == "none")
         {
            _loc5_.push("nearest",mipMapping ? "mipnearest" : "mipnone");
         }
         else if(smoothing == "bilinear")
         {
            _loc5_.push("linear",mipMapping ? "mipnearest" : "mipnone");
         }
         else
         {
            _loc5_.push("linear",mipMapping ? "miplinear" : "mipnone");
         }
         return "<" + _loc5_.join() + ">";
      }
      
      public static function getTextureVariantBits(texture:Texture) : uint
      {
         if(texture == null)
         {
            return 0;
         }
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         switch(texture.format)
         {
            case "compressedAlpha":
               _loc3_ = 3;
               break;
            case "compressed":
               _loc3_ = 2;
               break;
            default:
               _loc3_ = 1;
         }
         _loc2_ |= _loc3_;
         if(!texture.premultipliedAlpha)
         {
            _loc2_ |= 4;
         }
         return _loc2_;
      }
      
      public static function setSamplerStateAt(sampler:int, mipMapping:Boolean, smoothing:String = "bilinear", repeat:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = repeat ? "repeat" : "clamp";
         if(smoothing == "none")
         {
            _loc5_ = "nearest";
            _loc6_ = mipMapping ? "mipnearest" : "mipnone";
         }
         else if(smoothing == "bilinear")
         {
            _loc5_ = "linear";
            _loc6_ = mipMapping ? "mipnearest" : "mipnone";
         }
         else
         {
            _loc5_ = "linear";
            _loc6_ = mipMapping ? "miplinear" : "mipnone";
         }
         Starling.context.setSamplerStateAt(sampler,_loc7_,_loc5_,_loc6_);
      }
      
      public static function createAGALTexOperation(resultReg:String, uvReg:String, sampler:int, texture:Texture, convertToPmaIfRequired:Boolean = true, tempReg:String = "ft0") : String
      {
         var _loc8_:String = null;
         var _loc10_:String;
         switch(_loc10_ = texture.format)
         {
            case "compressed":
               _loc8_ = "dxt1";
               break;
            case "compressedAlpha":
               _loc8_ = "dxt5";
               break;
            default:
               _loc8_ = "rgba";
         }
         var _loc9_:Boolean = convertToPmaIfRequired && !texture.premultipliedAlpha;
         var _loc7_:String = _loc9_ && resultReg == "oc" ? tempReg : resultReg;
         var _loc11_:String = "tex " + _loc7_ + ", " + uvReg + ", fs" + sampler + " <2d, " + _loc8_ + ">\n";
         if(_loc9_)
         {
            if(resultReg == "oc")
            {
               _loc11_ += "mul " + _loc7_ + ".xyz, " + _loc7_ + ".xyz, " + _loc7_ + ".www\n";
               _loc11_ = _loc11_ + ("mov " + resultReg + ", " + _loc7_);
            }
            else
            {
               _loc11_ += "mul " + resultReg + ".xyz, " + _loc7_ + ".xyz, " + _loc7_ + ".www\n";
            }
         }
         return _loc11_;
      }
      
      public static function requestContext3D(stage3D:Stage3D, renderMode:String, profile:*) : void
      {
         var profiles:Array;
         var currentProfile:String;
         var requestNextProfile:* = function():void
         {
            currentProfile = profiles.shift();
            try
            {
               executeFunc(stage3D.requestContext3D,renderMode,currentProfile);
            }
            catch(error:Error)
            {
               if(profiles.length == 0)
               {
                  throw error;
               }
               setTimeout(requestNextProfile,1);
            }
         };
         var onCreated:* = function(param1:Event):void
         {
            var _loc2_:Context3D = stage3D.context3D;
            if(renderMode == "auto" && profiles.length != 0 && _loc2_.driverInfo.indexOf("Software") != -1)
            {
               onError(param1);
            }
            else
            {
               onFinished();
            }
         };
         var onError:* = function(param1:Event):void
         {
            if(profiles.length != 0)
            {
               param1.stopImmediatePropagation();
               setTimeout(requestNextProfile,1);
            }
            else
            {
               onFinished();
            }
         };
         var onFinished:* = function():void
         {
            stage3D.removeEventListener("context3DCreate",onCreated);
            stage3D.removeEventListener("error",onError);
         };
         var executeFunc:Function = SystemUtil.isDesktop ? execute : SystemUtil.executeWhenApplicationIsActive;
         if(profile == "auto")
         {
            profiles = ["enhanced","standardExtended","standard","standardConstrained","baselineExtended","baseline","baselineConstrained"];
         }
         else if(profile is String)
         {
            profiles = [profile as String];
         }
         else
         {
            if(!(profile is Array))
            {
               throw new ArgumentError("Profile must be of type \'String\' or \'Array\'");
            }
            profiles = profile as Array;
         }
         stage3D.addEventListener("context3DCreate",onCreated,false,100);
         stage3D.addEventListener("error",onError,false,100);
         requestNextProfile();
      }
   }
}

