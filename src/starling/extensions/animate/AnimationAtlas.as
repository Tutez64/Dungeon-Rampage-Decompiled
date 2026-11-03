package starling.extensions.animate
{
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.extensions.animate.styles.ColorTransformStyle;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   
   public class AnimationAtlas
   {
      
      public static const ASSET_TYPE:String = "animationAtlas";
      
      private static const STD_MATRIX3D_DATA:Object = {
         "m00":1,
         "m01":0,
         "m02":0,
         "m03":0,
         "m10":0,
         "m11":1,
         "m12":0,
         "m13":0,
         "m20":0,
         "m21":0,
         "m22":1,
         "m23":0,
         "m30":0,
         "m31":0,
         "m32":0,
         "m33":1
      };
      
      private static const JsonKeys:Object = {
         "ANIMATION":"animation",
         "ATLAS_SPRITE_instance":"atlasSpriteInstance",
         "DecomposedMatrix":"decomposedMatrix",
         "Frames":"frames",
         "framerate":"frameRate",
         "Instance_Name":"instanceName",
         "Layer_name":"layerName",
         "LAYERS":"layers",
         "Matrix":"matrix3D",
         "Matrix3D":"matrix3D",
         "Position":"position",
         "Rotation":"rotation",
         "Scaling":"scaling",
         "SYMBOL_DICTIONARY":"symbolDictionary",
         "SYMBOL_Instance":"symbolInstance",
         "SYMBOL_name":"symbolName",
         "Symbols":"symbols",
         "TIMELINE":"timeline",
         "AN":"animation",
         "AM":"alphaMultiplier",
         "ASI":"atlasSpriteInstance",
         "B":"blend",
         "BM":"bitmap",
         "C":"color",
         "DU":"duration",
         "E":"elements",
         "FF":"firstFrame",
         "FR":"frames",
         "FRT":"frameRate",
         "I":"index",
         "IN":"instanceName",
         "L":"layers",
         "LN":"layerName",
         "LP":"loop",
         "M3D":"matrix3D",
         "MX":"matrix3D",
         "MD":"metadata",
         "M":"mode",
         "N":"name",
         "POS":"position",
         "S":"symbols",
         "SD":"symbolDictionary",
         "SI":"symbolInstance",
         "SN":"symbolName",
         "ST":"symbolType",
         "TL":"timeline",
         "TRP":"transformationPoint",
         "A":"angle",
         "AO":"alphaOffset",
         "BLX":"blurX",
         "BLY":"blurY",
         "BO":"blueOffset",
         "BRT":"brightness",
         "CT":"contrast",
         "D":"distance",
         "F":"filters",
         "GM":"greenMultiplier",
         "GO":"greenOffset",
         "HO":"hideObject",
         "KK":"knockout",
         "Q":"quality",
         "RM":"redMultiplier",
         "RO":"redOffset",
         "SAT":"saturation",
         "STR":"strength",
         "TC":"tintColor",
         "TM":"tintMultiplier"
      };
      
      private var _atlas:TextureAtlas;
      
      private var _symbolData:Dictionary;
      
      private var _sourceWidth:Number = 0;
      
      private var _sourceHeight:Number = 0;
      
      private var _symbolPool:Dictionary;
      
      private var _imagePool:Array;
      
      private var _frameRate:Number;
      
      private var _defaultSymbolName:String;
      
      private var _labelSymbols:Dictionary;
      
      private var _labelTables:Dictionary = new Dictionary();
      
      public function AnimationAtlas(data:Object, atlas:TextureAtlas)
      {
         super();
         if(data == null)
         {
            throw new ArgumentError("data must not be null");
         }
         if(atlas == null)
         {
            throw new ArgumentError("atlas must not be null");
         }
         data = normalizeJsonKeys(data);
         parseData(data);
         _atlas = atlas;
         _symbolPool = new Dictionary();
         _imagePool = [];
      }
      
      private static function preprocessSymbolData(symbolData:Object) : Object
      {
         var _loc5_:int = 0;
         var _loc12_:Object = null;
         var _loc2_:Array = null;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:Array = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc13_:Object = null;
         var _loc10_:Object = symbolData.timeline;
         var _loc9_:Array = _loc10_.layers;
         if(!_loc10_.sortedForRender)
         {
            _loc10_.sortedForRender = true;
            _loc9_.reverse();
         }
         var _loc7_:int = int(_loc9_.length);
         _loc5_ = 0;
         while(_loc5_ < _loc7_)
         {
            _loc12_ = _loc9_[_loc5_];
            _loc2_ = _loc12_.frames as Array;
            _loc8_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc8_)
            {
               _loc11_ = _loc2_[_loc4_].elements as Array;
               _loc6_ = int(_loc11_.length);
               _loc3_ = 0;
               while(_loc3_ < _loc6_)
               {
                  _loc13_ = _loc11_[_loc3_];
                  if(_loc13_ == null || !("atlasSpriteInstance" in _loc13_) && !("symbolInstance" in _loc13_))
                  {
                     _loc11_.splice(_loc3_,1);
                     _loc3_--;
                     _loc6_--;
                  }
                  else
                  {
                     if("atlasSpriteInstance" in _loc13_)
                     {
                        _loc13_ = _loc11_[_loc3_] = {"symbolInstance":{
                           "symbolName":"___atlas_sprite___",
                           "instanceName":"InstName",
                           "bitmap":_loc13_.atlasSpriteInstance,
                           "symbolType":"graphic",
                           "firstFrame":0,
                           "loop":"loop",
                           "transformationPoint":{
                              "x":0,
                              "y":0
                           },
                           "matrix3D":_loc13_.atlasSpriteInstance.matrix3D || STD_MATRIX3D_DATA
                        }};
                     }
                     if("decomposedMatrix" in _loc13_.symbolInstance)
                     {
                        delete _loc13_.symbolInstance.decomposedMatrix;
                     }
                  }
                  _loc3_++;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         return symbolData;
      }
      
      private static function normalizeJsonKeys(data:Object) : Object
      {
         var _loc3_:Array = null;
         var _loc2_:uint = 0;
         var _loc4_:int = 0;
         var _loc7_:Object = null;
         var _loc5_:Object = null;
         if(data is String || data is Number || data is int)
         {
            return data;
         }
         if(data is Array)
         {
            _loc3_ = [];
            _loc2_ = uint(data.length);
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_[_loc4_] = normalizeJsonKeys(data[_loc4_]);
               _loc4_++;
            }
            return _loc3_;
         }
         _loc7_ = {};
         for(var _loc6_:String in data)
         {
            _loc5_ = normalizeJsonKeys(data[_loc6_]);
            if(_loc6_ in JsonKeys)
            {
               _loc6_ = JsonKeys[_loc6_];
            }
            _loc7_[_loc6_] = _loc5_;
         }
         return _loc7_;
      }
      
      public function hasAnimation(name:String) : Boolean
      {
         return hasSymbol(name);
      }
      
      public function createAnimation(name:String = null) : Animation
      {
         if(!name)
         {
            name = _defaultSymbolName;
         }
         if(!hasSymbol(name))
         {
            throw new ArgumentError("Animation not found: " + name);
         }
         return new Animation(name,this);
      }
      
      public function getLabelSymbolName(label:String) : String
      {
         return _labelSymbols[label] as String;
      }
      
      public function getClipLabels(out:Vector.<String>) : Vector.<String>
      {
         if(!out)
         {
            out = new Vector.<String>();
         }
         for(var _loc2_:String in _labelSymbols)
         {
            out[out.length] = _loc2_;
         }
         return out;
      }
      
      public function get hasClipLabels() : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Dictionary = _labelSymbols;
         for(var _loc1_:String in _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function getAnimationNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         if(!out)
         {
            out = new Vector.<String>();
         }
         for(var _loc3_:String in _symbolData)
         {
            if(_loc3_ != "___atlas_sprite___" && _loc3_.indexOf(prefix) == 0)
            {
               out[out.length] = _loc3_;
            }
         }
         out.sort(1);
         return out;
      }
      
      internal function getTexture(name:String) : Texture
      {
         return _atlas.getTexture(name);
      }
      
      internal function getImage(texture:Texture) : Image
      {
         var _loc2_:Image = null;
         if(_imagePool.length == 0)
         {
            return new Image(texture);
         }
         _loc2_ = _imagePool.pop() as Image;
         _loc2_.x = _loc2_.y = 0;
         _loc2_.pivotX = _loc2_.pivotY = 0;
         _loc2_.scaleX = _loc2_.scaleY = 1;
         _loc2_.skewX = _loc2_.skewY = 0;
         _loc2_.rotation = 0;
         _loc2_.texture = texture;
         _loc2_.readjustSize();
         return _loc2_;
      }
      
      internal function putImage(image:Image) : void
      {
         if(image.style is ColorTransformStyle)
         {
            image.setStyle();
         }
         _imagePool[_imagePool.length] = image;
      }
      
      internal function hasSymbol(name:String) : Boolean
      {
         return name in _symbolData;
      }
      
      internal function getFallbackSymbolName(name:String) : String
      {
         if(name == null || hasSymbol(name))
         {
            return null;
         }
         var _loc4_:int = name.indexOf("/");
         if(_loc4_ < 0)
         {
            return null;
         }
         var _loc3_:String = name.substr(0,_loc4_ + 1);
         var _loc2_:String = null;
         for(var _loc5_:String in _symbolData)
         {
            if(_loc5_ != "___atlas_sprite___")
            {
               if(_loc5_.indexOf(_loc3_) == 0 && _loc5_.length >= 4 && _loc5_.indexOf(".png",_loc5_.length - 4) != -1)
               {
                  if(_loc2_ != null)
                  {
                     return null;
                  }
                  _loc2_ = _loc5_;
               }
            }
         }
         return _loc2_;
      }
      
      internal function getSymbol(name:String) : Symbol
      {
         var _loc2_:Array = getSymbolPool(name);
         if(_loc2_.length == 0)
         {
            return new Symbol(getSymbolData(name),this);
         }
         return _loc2_.pop();
      }
      
      internal function putSymbol(symbol:Symbol) : void
      {
         symbol.releaseLayers();
         symbol.reset();
         var _loc2_:Array = getSymbolPool(symbol.symbolName);
         _loc2_[_loc2_.length] = symbol;
      }
      
      internal function getSymbolData(name:String) : Object
      {
         return _symbolData[name];
      }
      
      internal function getLabelTable(data:Object) : LabelTable
      {
         var _loc2_:LabelTable = _labelTables[data] as LabelTable;
         if(_loc2_ == null)
         {
            _loc2_ = _labelTables[data] = new LabelTable(data);
         }
         return _loc2_;
      }
      
      private function parseData(data:Object) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc2_:Object = data.metadata;
         if(_loc2_)
         {
            if(_loc2_.W)
            {
               _sourceWidth = Number(_loc2_.W);
            }
            if(_loc2_.H)
            {
               _sourceHeight = Number(_loc2_.H);
            }
            if(_loc2_.frameRate > 0)
            {
               _frameRate = int(_loc2_.frameRate);
            }
            else
            {
               _frameRate = 24;
            }
         }
         else
         {
            _frameRate = 24;
         }
         _symbolData = new Dictionary();
         for each(var _loc4_:Object in data.symbolDictionary.symbols)
         {
            _symbolData[_loc4_.symbolName] = preprocessSymbolData(_loc4_);
         }
         var _loc8_:Object = preprocessSymbolData(data.animation);
         _defaultSymbolName = _loc8_.symbolName;
         _symbolData[_defaultSymbolName] = _loc8_;
         _symbolData["___atlas_sprite___"] = {
            "symbolName":"___atlas_sprite___",
            "timeline":{"layers":[]}
         };
         _labelSymbols = new Dictionary();
         for each(var _loc7_:Object in _loc8_.timeline.layers)
         {
            for each(var _loc3_:Object in _loc7_.frames)
            {
               if(!(!("name" in _loc3_) || _loc3_.name in _labelSymbols))
               {
                  _loc5_ = _loc3_.elements as Array;
                  if(!(_loc5_ == null || _loc5_.length != 1))
                  {
                     _loc6_ = _loc5_[0].symbolInstance.symbolName;
                     if(_loc6_ != "___atlas_sprite___" && _loc6_ != _defaultSymbolName && hasSymbol(_loc6_))
                     {
                        _labelSymbols[_loc3_.name] = _loc6_;
                     }
                  }
               }
            }
         }
      }
      
      private function getSymbolPool(name:String) : Array
      {
         var _loc2_:Array = _symbolPool[name];
         if(_loc2_ == null)
         {
            _loc2_ = _symbolPool[name] = [];
         }
         return _loc2_;
      }
      
      public function get frameRate() : Number
      {
         return _frameRate;
      }
      
      public function set frameRate(value:Number) : void
      {
         _frameRate = value;
      }
      
      public function get sourceWidth() : Number
      {
         return _sourceWidth;
      }
      
      public function get sourceHeight() : Number
      {
         return _sourceHeight;
      }
   }
}

