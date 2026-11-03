package Brain.Starling
{
   import Brain.Utils.MemoryTracker;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   
   public class StarlingSourceCache
   {
      
      private var mEntries:Dictionary;
      
      private var mAtlases:Dictionary;
      
      public function StarlingSourceCache()
      {
         super();
         mEntries = new Dictionary();
         mAtlases = new Dictionary();
      }
      
      public function getOrCreate(key:String, bitmapData:BitmapData) : Texture
      {
         var _loc3_:TextureCacheEntry = mEntries[key];
         if(_loc3_ != null)
         {
            _loc3_.refCount++;
            bitmapData.dispose();
            return _loc3_.texture;
         }
         var _loc4_:Texture = Texture.fromBitmapData(bitmapData,false);
         MemoryTracker.track(_loc4_,"StarlingSourceCache - Texture: " + key,"starling");
         mEntries[key] = new TextureCacheEntry(_loc4_,bitmapData,1);
         return _loc4_;
      }
      
      public function getOrCreateShared(key:String, bitmapData:BitmapData) : Texture
      {
         var _loc3_:TextureCacheEntry = mEntries[key];
         if(_loc3_ != null)
         {
            _loc3_.refCount++;
            return _loc3_.texture;
         }
         var _loc5_:BitmapData = bitmapData.clone();
         var _loc4_:Texture = Texture.fromBitmapData(_loc5_,false);
         MemoryTracker.track(_loc4_,"StarlingSourceCache - Texture: " + key,"starling");
         mEntries[key] = new TextureCacheEntry(_loc4_,_loc5_,1);
         return _loc4_;
      }
      
      public function peek(key:String) : Texture
      {
         var _loc2_:TextureCacheEntry = mEntries[key];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.texture;
      }
      
      public function has(key:String) : Boolean
      {
         return mEntries[key] != null;
      }
      
      public function get(key:String) : Texture
      {
         var _loc2_:TextureCacheEntry = mEntries[key];
         if(_loc2_ == null)
         {
            return null;
         }
         _loc2_.refCount++;
         return _loc2_.texture;
      }
      
      public function releaseRef(key:String) : void
      {
         var _loc2_:TextureCacheEntry = mEntries[key];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.refCount--;
         if(_loc2_.refCount <= 0)
         {
            _loc2_.texture.dispose();
            _loc2_.bitmapData.dispose();
            delete mEntries[key];
         }
      }
      
      public function registerAtlas(key:String, atlas:TextureAtlas, bitmapData:BitmapData) : void
      {
         var _loc4_:AtlasCacheEntry = mAtlases[key];
         if(_loc4_ != null)
         {
            _loc4_.refCount++;
            atlas.dispose();
            bitmapData.dispose();
            return;
         }
         MemoryTracker.track(atlas,"StarlingSourceCache - TextureAtlas: " + key,"starling");
         mAtlases[key] = new AtlasCacheEntry(atlas,bitmapData,1);
      }
      
      public function getAtlas(key:String) : TextureAtlas
      {
         var _loc2_:AtlasCacheEntry = mAtlases[key];
         if(_loc2_ == null)
         {
            return null;
         }
         _loc2_.refCount++;
         return _loc2_.atlas;
      }
      
      public function peekAtlas(key:String) : TextureAtlas
      {
         var _loc2_:AtlasCacheEntry = mAtlases[key];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_.atlas;
      }
      
      public function releaseAtlasRef(key:String) : void
      {
         var _loc2_:AtlasCacheEntry = mAtlases[key];
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.refCount--;
         if(_loc2_.refCount <= 0)
         {
            _loc2_.atlas.dispose();
            _loc2_.bitmapData.dispose();
            delete mAtlases[key];
         }
      }
      
      public function restoreSources() : void
      {
         var _loc1_:TextureCacheEntry = null;
         var _loc3_:AtlasCacheEntry = null;
         for(var _loc4_:String in mEntries)
         {
            _loc1_ = mEntries[_loc4_];
            if(_loc1_.bitmapData != null && _loc1_.texture != null)
            {
               _loc1_.texture.root.uploadBitmapData(_loc1_.bitmapData);
            }
         }
         for(var _loc2_:String in mAtlases)
         {
            _loc3_ = mAtlases[_loc2_];
            if(_loc3_.bitmapData != null && _loc3_.atlas != null)
            {
               _loc3_.atlas.texture.root.uploadBitmapData(_loc3_.bitmapData);
            }
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:TextureCacheEntry = null;
         var _loc3_:AtlasCacheEntry = null;
         for(var _loc4_:String in mEntries)
         {
            _loc1_ = mEntries[_loc4_];
            _loc1_.texture.dispose();
            _loc1_.bitmapData.dispose();
            delete mEntries[_loc4_];
         }
         for(var _loc2_:String in mAtlases)
         {
            _loc3_ = mAtlases[_loc2_];
            _loc3_.atlas.dispose();
            _loc3_.bitmapData.dispose();
            delete mAtlases[_loc2_];
         }
      }
   }
}

import flash.display.BitmapData;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class TextureCacheEntry
{
   
   public var texture:Texture;
   
   public var bitmapData:BitmapData;
   
   public var refCount:int;
   
   public function TextureCacheEntry(texture:Texture, bitmapData:BitmapData, refCount:int)
   {
      super();
      this.texture = texture;
      this.bitmapData = bitmapData;
      this.refCount = refCount;
   }
}

class AtlasCacheEntry
{
   
   public var atlas:TextureAtlas;
   
   public var bitmapData:BitmapData;
   
   public var refCount:int;
   
   public function AtlasCacheEntry(atlas:TextureAtlas, bitmapData:BitmapData, refCount:int)
   {
      super();
      this.atlas = atlas;
      this.bitmapData = bitmapData;
      this.refCount = refCount;
   }
}
