package starling.extensions.animate
{
   import starling.assets.AssetFactoryHelper;
   import starling.assets.AssetManager;
   import starling.assets.AssetReference;
   import starling.assets.JsonFactory;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   
   internal class AnimationAtlasFactory extends JsonFactory
   {
      
      public static const ANIMATION_SUFFIX:String = "_animation";
      
      public static const SPRITEMAP_SUFFIX:String = "_spritemap";
      
      private static const SPRITEMAP_REGEX:RegExp = /^spritemap(\d*)$/;
      
      private static const ANIMATION_SUFFIX_REGEX:RegExp = /_animation$/;
      
      private static const SPRITEMAP_SUFFIX_REGEX:RegExp = /_spritemap\d*$/;
      
      public function AnimationAtlasFactory()
      {
         super();
      }
      
      internal static function getName(url:String, stdName:String, addSuffix:Boolean) : String
      {
         var _loc5_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = "/";
         if(url == null)
         {
            if(addSuffix)
            {
               return stdName;
            }
            stdName = stdName.replace(ANIMATION_SUFFIX_REGEX,"");
            stdName = stdName.replace(SPRITEMAP_SUFFIX_REGEX,"");
         }
         var _loc4_:Boolean = stdName == "Animation";
         var _loc6_:Array = _loc4_ ? null : stdName.match(SPRITEMAP_REGEX);
         if((_loc4_ || _loc6_) && url.indexOf(_loc8_) != -1)
         {
            _loc5_ = url.split(_loc8_);
            _loc7_ = _loc5_[_loc5_.length - 2];
            if(!addSuffix)
            {
               return _loc7_;
            }
            return _loc4_ ? _loc7_ + "_animation" : _loc7_ + "_spritemap" + _loc6_[1];
         }
         return stdName;
      }
      
      internal static function isSpritemapName(stdName:String) : Boolean
      {
         return SPRITEMAP_REGEX.test(stdName);
      }
      
      private static function describeMissingSheets(baseName:String, json:Object, atlas:TextureAtlas) : String
      {
         var _loc5_:int = declaredSheetCount(json);
         if(_loc5_ <= 0)
         {
            return null;
         }
         var _loc4_:int = int(atlas is MultiTextureAtlas ? MultiTextureAtlas(atlas).numTextures : 1);
         if(_loc4_ == _loc5_)
         {
            return null;
         }
         return "\'" + baseName + "\' expected " + _loc5_ + " spritemap(s) but the atlas holds " + _loc4_;
      }
      
      private static function declaredSheetCount(json:Object) : int
      {
         var _loc2_:Object = json.MD || json.metadata;
         return _loc2_ != null ? int(_loc2_.SMC || _loc2_.spritemapCount || 0) : 0;
      }
      
      override public function create(asset:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var onObjectComplete:* = function(param1:String, param2:Object):void
         {
            var name:String = param1;
            var json:Object = param2;
            var baseName:String = getName(asset.url,name,false);
            var fullName:String = getName(asset.url,name,true);
            if(json.ATLAS && json.meta)
            {
               helper.addPostProcessor(function(param1:AssetManager):void
               {
                  var _loc2_:Texture = param1.getTexture(fullName);
                  if(_loc2_ == null)
                  {
                     onError("Missing texture " + fullName);
                     return;
                  }
                  var _loc3_:MultiTextureAtlas = param1.getTextureAtlas(baseName) as MultiTextureAtlas;
                  if(_loc3_ == null)
                  {
                     _loc3_ = new MultiTextureAtlas();
                     param1.addAsset(baseName,_loc3_);
                  }
                  try
                  {
                     _loc3_.addSheet(fullName,_loc2_,json);
                  }
                  catch(e:Error)
                  {
                     _loc3_.removeSheet(fullName);
                     onError("Failed to add sheet \'" + fullName + "\': " + e.message);
                     return;
                  }
                  param1.removeObject(fullName);
               },100);
            }
            else if(json.ANIMATION && json.SYMBOL_DICTIONARY || json.AN && json.SD)
            {
               helper.addPostProcessor(function(param1:AssetManager):void
               {
                  var _loc2_:TextureAtlas = param1.getTextureAtlas(baseName);
                  if(_loc2_ == null)
                  {
                     onError("Missing texture atlas " + baseName);
                     return;
                  }
                  var _loc3_:String = describeMissingSheets(baseName,json,_loc2_);
                  if(_loc3_ != null)
                  {
                     onError(_loc3_);
                     return;
                  }
                  if(_loc2_ is MultiTextureAtlas)
                  {
                     MultiTextureAtlas(_loc2_).declaredSheets = declaredSheetCount(json);
                  }
                  try
                  {
                     param1.addAsset(baseName,new AnimationAtlas(json,_loc2_),"animationAtlas");
                  }
                  catch(e:Error)
                  {
                     onError("Failed to create animation atlas \'" + baseName + "\': " + e.message);
                  }
               });
            }
            onComplete(fullName,json);
         };
         super.create(asset,helper,onObjectComplete,onError);
      }
   }
}

