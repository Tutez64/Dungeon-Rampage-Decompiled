package starling.extensions.animate
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.textures.SubTexture;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   import starling.utils.Pool;
   
   public class MultiTextureAtlas extends TextureAtlas
   {
      
      private static const UNNAMED_SHEET:String = "";
      
      private var _textures:Vector.<Texture>;
      
      private var _regions:Dictionary;
      
      private var _regionNames:Vector.<String>;
      
      private var _sheets:Dictionary;
      
      public var declaredSheets:int = 0;
      
      public function MultiTextureAtlas(texture:Texture = null, data:* = null)
      {
         super(texture,null);
         _textures = new Vector.<Texture>(0);
         _regions = new Dictionary();
         _sheets = new Dictionary();
         if(texture)
         {
            addTexture(texture);
         }
         if(data)
         {
            parseAtlasData(data);
         }
      }
      
      public function addTexture(texture:Texture) : void
      {
         if(texture == null)
         {
            throw new ArgumentError("texture must not be null");
         }
         if(_textures.indexOf(texture) == -1)
         {
            _textures[_textures.length] = texture;
         }
      }
      
      public function addSheet(name:String, texture:Texture, data:Object) : void
      {
         var _loc4_:Object = null;
         var _loc6_:String = null;
         if(texture == null)
         {
            throw new ArgumentError("texture must not be null");
         }
         if(data == null || data.ATLAS == null || data.ATLAS.SPRITES == null)
         {
            throw new ArgumentError("data is not texture atlas json");
         }
         removeSheet(name);
         addTexture(texture);
         var _loc5_:Vector.<String> = new Vector.<String>(0);
         var _loc7_:Rectangle = Pool.getRectangle();
         for each(var _loc8_:Object in data.ATLAS.SPRITES)
         {
            _loc4_ = _loc8_.SPRITE;
            _loc6_ = _loc4_.name;
            _loc7_.setTo(_loc4_.x,_loc4_.y,_loc4_.w,_loc4_.h);
            addSubTexture(_loc6_,new SubTexture(texture,_loc7_,false,null,_loc4_.rotated));
            _loc5_[_loc5_.length] = _loc6_;
         }
         Pool.putRectangle(_loc7_);
         _sheets[name] = {
            "texture":texture,
            "names":_loc5_
         };
      }
      
      public function removeSheet(name:String) : void
      {
         var _loc4_:Object = _sheets[name];
         if(_loc4_ == null)
         {
            return;
         }
         for each(var _loc2_:String in _loc4_.names)
         {
            removeRegion(_loc2_);
         }
         var _loc3_:int = _textures.indexOf(_loc4_.texture);
         if(_loc3_ != -1)
         {
            _textures.removeAt(_loc3_);
         }
         delete _sheets[name];
      }
      
      public function get numTextures() : int
      {
         return _textures.length;
      }
      
      public function getTextureAt(index:int) : Texture
      {
         return _textures[index];
      }
      
      override protected function parseAtlasData(data:*) : void
      {
         if(data is XML)
         {
            super.parseAtlasData(data);
         }
         else
         {
            addSheet("",texture,data as Object);
         }
      }
      
      override public function addSubTexture(name:String, subTexture:SubTexture) : void
      {
         if(!ownsRootOf(subTexture))
         {
            throw new ArgumentError("SubTexture\'s root must be one of the atlas textures; register it with addTexture() or addSheet() first.");
         }
         if(_regions[name] != null)
         {
         }
         _regions[name] = subTexture;
         _regionNames = null;
      }
      
      override public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Boolean = false) : void
      {
         if(texture == null)
         {
            throw new IllegalOperationError("no sheet to add the region to, this atlas was created without a texture");
         }
         addSubTexture(name,new SubTexture(texture,region,false,frame,rotated));
      }
      
      override public function getTexture(name:String) : Texture
      {
         return _regions[name];
      }
      
      override public function getNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         var _loc3_:String = null;
         if(out == null)
         {
            out = new Vector.<String>(0);
         }
         if(_regionNames == null)
         {
            _regionNames = new Vector.<String>(0);
            for(_loc3_ in _regions)
            {
               _regionNames[_regionNames.length] = _loc3_;
            }
            _regionNames.sort(1);
         }
         for each(_loc3_ in _regionNames)
         {
            if(_loc3_.indexOf(prefix) == 0)
            {
               out[out.length] = _loc3_;
            }
         }
         return out;
      }
      
      override public function getRegion(name:String) : Rectangle
      {
         var _loc2_:SubTexture = _regions[name];
         return _loc2_ ? _loc2_.region : null;
      }
      
      override public function getFrame(name:String) : Rectangle
      {
         var _loc2_:SubTexture = _regions[name];
         return _loc2_ ? _loc2_.frame : null;
      }
      
      override public function getRotation(name:String) : Boolean
      {
         var _loc2_:SubTexture = _regions[name];
         return _loc2_ ? _loc2_.rotated : false;
      }
      
      override public function removeRegion(name:String) : void
      {
         var _loc2_:SubTexture = _regions[name];
         if(_loc2_)
         {
            _loc2_.dispose();
         }
         delete _regions[name];
         _regionNames = null;
      }
      
      override public function removeRegions(prefix:String = "") : void
      {
         for(var _loc2_:String in _regions)
         {
            if(prefix == "" || _loc2_.indexOf(prefix) == 0)
            {
               removeRegion(_loc2_);
            }
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _textures.length)
         {
            _textures[_loc1_].dispose();
            _loc1_++;
         }
         _textures.length = 0;
      }
      
      private function ownsRootOf(subTexture:SubTexture) : Boolean
      {
         var _loc3_:int = 0;
         if(subTexture == null)
         {
            return false;
         }
         var _loc2_:Texture = subTexture.root;
         _loc3_ = 0;
         while(_loc3_ < _textures.length)
         {
            if(_textures[_loc3_].root == _loc2_)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
   }
}

