package starling.textures
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.utils.StringUtil;
   
   public class TextureAtlas
   {
      
      private static const NAME_REGEX:RegExp = /(.+?)\d+$/;
      
      private static var sNames:Vector.<String> = new Vector.<String>(0);
      
      private var _atlasTexture:Texture;
      
      private var _subTextures:Dictionary;
      
      private var _subTextureNames:Vector.<String>;
      
      public function TextureAtlas(texture:Texture, data:* = null)
      {
         super();
         _subTextures = new Dictionary();
         _atlasTexture = texture;
         if(data)
         {
            parseAtlasData(data);
         }
      }
      
      public function dispose() : void
      {
         _atlasTexture.dispose();
      }
      
      protected function parseAtlasData(data:*) : void
      {
         if(data is XML)
         {
            parseAtlasXml(data as XML);
            return;
         }
         throw new ArgumentError("TextureAtlas only supports XML data");
      }
      
      protected function parseAtlasXml(atlasXml:XML) : void
      {
         var _loc13_:String = null;
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc8_:Array = null;
         var _loc20_:String = null;
         var _loc17_:Point = null;
         var _loc3_:Number = _atlasTexture.scale;
         var _loc19_:Rectangle = new Rectangle();
         var _loc21_:Rectangle = new Rectangle();
         var _loc18_:Dictionary = new Dictionary();
         for each(var _loc12_:XML in atlasXml.SubTexture)
         {
            _loc13_ = StringUtil.clean(_loc12_.@name);
            _loc14_ = Number(parseFloat(_loc12_.@x) / _loc3_ || 0);
            _loc16_ = Number(parseFloat(_loc12_.@y) / _loc3_ || 0);
            _loc15_ = Number(parseFloat(_loc12_.@width) / _loc3_ || 0);
            _loc22_ = Number(parseFloat(_loc12_.@height) / _loc3_ || 0);
            _loc4_ = Number(parseFloat(_loc12_.@frameX) / _loc3_ || 0);
            _loc9_ = Number(parseFloat(_loc12_.@frameY) / _loc3_ || 0);
            _loc11_ = Number(parseFloat(_loc12_.@frameWidth) / _loc3_ || 0);
            _loc2_ = Number(parseFloat(_loc12_.@frameHeight) / _loc3_ || 0);
            _loc7_ = Number(parseFloat(_loc12_.@pivotX) / _loc3_ || 0);
            _loc6_ = Number(parseFloat(_loc12_.@pivotY) / _loc3_ || 0);
            _loc5_ = StringUtil.parseBoolean(_loc12_.@rotated);
            _loc19_.setTo(_loc14_,_loc16_,_loc15_,_loc22_);
            _loc21_.setTo(_loc4_,_loc9_,_loc11_,_loc2_);
            if(_loc11_ > 0 && _loc2_ > 0)
            {
               addRegion(_loc13_,_loc19_,_loc21_,_loc5_);
            }
            else
            {
               addRegion(_loc13_,_loc19_,null,_loc5_);
            }
            if(_loc7_ != 0 || _loc6_ != 0)
            {
               Image.bindPivotPointToTexture(getTexture(_loc13_),_loc7_,_loc6_);
               _loc18_[_loc13_] = new Point(_loc7_,_loc6_);
            }
         }
         for(var _loc10_:String in _loc18_)
         {
            _loc8_ = _loc10_.match(NAME_REGEX);
            if(_loc8_ && _loc8_.length > 0)
            {
               _loc20_ = _loc8_[1];
               _loc17_ = _loc18_[_loc10_];
               for(_loc13_ in _subTextures)
               {
                  if(_loc13_.indexOf(_loc20_) == 0 && !(_loc13_ in _loc18_))
                  {
                     Image.bindPivotPointToTexture(_subTextures[_loc13_],_loc17_.x,_loc17_.y);
                  }
               }
            }
         }
      }
      
      public function getTexture(name:String) : Texture
      {
         return _subTextures[name];
      }
      
      public function getTextures(prefix:String = "", out:Vector.<Texture> = null) : Vector.<Texture>
      {
         if(out == null)
         {
            out = new Vector.<Texture>(0);
         }
         for each(var _loc3_:String in getNames(prefix,sNames))
         {
            out[out.length] = getTexture(_loc3_);
         }
         sNames.length = 0;
         return out;
      }
      
      public function getNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         var _loc3_:String = null;
         if(out == null)
         {
            out = new Vector.<String>(0);
         }
         if(_subTextureNames == null)
         {
            _subTextureNames = new Vector.<String>(0);
            for(_loc3_ in _subTextures)
            {
               _subTextureNames[_subTextureNames.length] = _loc3_;
            }
            _subTextureNames.sort(1);
         }
         for each(_loc3_ in _subTextureNames)
         {
            if(_loc3_.indexOf(prefix) == 0)
            {
               out[out.length] = _loc3_;
            }
         }
         return out;
      }
      
      public function getRegion(name:String) : Rectangle
      {
         var _loc2_:SubTexture = _subTextures[name];
         return _loc2_ ? _loc2_.region : null;
      }
      
      public function getFrame(name:String) : Rectangle
      {
         var _loc2_:SubTexture = _subTextures[name];
         return _loc2_ ? _loc2_.frame : null;
      }
      
      public function getRotation(name:String) : Boolean
      {
         var _loc2_:SubTexture = _subTextures[name];
         return _loc2_ ? _loc2_.rotated : false;
      }
      
      public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Boolean = false) : void
      {
         addSubTexture(name,new SubTexture(_atlasTexture,region,false,frame,rotated));
      }
      
      public function addSubTexture(name:String, subTexture:SubTexture) : void
      {
         if(subTexture.root != _atlasTexture.root)
         {
            throw new ArgumentError("SubTexture\'s root must be atlas texture.");
         }
         _subTextures[name] = subTexture;
         _subTextureNames = null;
      }
      
      public function removeRegion(name:String) : void
      {
         var _loc2_:SubTexture = _subTextures[name];
         if(_loc2_)
         {
            _loc2_.dispose();
         }
         delete _subTextures[name];
         _subTextureNames = null;
      }
      
      public function removeRegions(prefix:String = "") : void
      {
         for(var _loc2_:String in _subTextures)
         {
            if(prefix == "" || _loc2_.indexOf(prefix) == 0)
            {
               removeRegion(_loc2_);
            }
         }
      }
      
      public function get texture() : Texture
      {
         return _atlasTexture;
      }
   }
}

