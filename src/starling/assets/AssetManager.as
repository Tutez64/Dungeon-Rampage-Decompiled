package starling.assets
{
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.events.EventDispatcher;
   import starling.text.BitmapFont;
   import starling.textures.Texture;
   import starling.textures.TextureAtlas;
   import starling.textures.TextureOptions;
   import starling.utils.MathUtil;
   import starling.utils.execute;
   
   public class AssetManager extends EventDispatcher
   {
      
      private static const NO_NAME:String = "unnamed";
      
      private static var sNoNameCount:int = 0;
      
      private static const NAME_REGEX:RegExp = /(([^?\/\\]+?)(?:\.([\w\-]+))?)(?:\?.*)?$/;
      
      private static var sNames:Vector.<String> = new Vector.<String>(0);
      
      private var _starling:Starling;
      
      private var _assets:Dictionary;
      
      private var _verbose:Boolean;
      
      private var _numConnections:int;
      
      private var _dataLoader:DataLoader;
      
      private var _textureOptions:TextureOptions;
      
      private var _queue:Vector.<AssetReference>;
      
      private var _registerBitmapFontsWithFontFace:Boolean;
      
      private var _assetFactories:Vector.<AssetFactory>;
      
      private var _numRestoredTextures:int;
      
      private var _numLostTextures:int;
      
      public function AssetManager(scaleFactor:Number = 1)
      {
         super();
         _assets = new Dictionary();
         _verbose = true;
         _textureOptions = new TextureOptions(scaleFactor);
         _queue = new Vector.<AssetReference>(0);
         _numConnections = 3;
         _dataLoader = new DataLoader();
         _assetFactories = new Vector.<AssetFactory>(0);
         registerFactory(new BitmapTextureFactory());
         registerFactory(new AtfTextureFactory());
         registerFactory(new SoundFactory());
         registerFactory(new JsonFactory());
         registerFactory(new XmlFactory());
         registerFactory(new ByteArrayFactory(),-100);
      }
      
      private static function comparePriorities(a:Object, b:Object) : int
      {
         if(a.priority == b.priority)
         {
            return 0;
         }
         return a.priority > b.priority ? -1 : 1;
      }
      
      private static function getDictionaryKeys(dictionary:Dictionary, prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         if(out == null)
         {
            out = new Vector.<String>(0);
         }
         if(dictionary)
         {
            for(var _loc4_:String in dictionary)
            {
               if(_loc4_.indexOf(prefix) == 0)
               {
                  out[out.length] = _loc4_;
               }
            }
            out.sort(1);
         }
         return out;
      }
      
      private static function getUniqueName() : String
      {
         return "unnamed-" + sNoNameCount++;
      }
      
      public function dispose() : void
      {
         purgeQueue();
         for each(var _loc1_:Dictionary in _assets)
         {
            for each(var _loc2_:Object in _loc1_)
            {
               disposeAsset(_loc2_);
            }
         }
      }
      
      public function purge() : void
      {
         log("Purging all assets, emptying queue");
         purgeQueue();
         dispose();
         _assets = new Dictionary();
      }
      
      public function enqueue(... rest) : void
      {
         var asset:Object;
         var typeXml:XML;
         var childNode:XML;
         var url:String;
         var mimeType:String;
         var processNode:*;
         var assets:Array = rest;
         for each(asset in assets)
         {
            if(asset is Array)
            {
               enqueue.apply(this,asset);
            }
            else if(asset is Class)
            {
               processNode = function(param1:XML):void
               {
                  url = findUrlInVariableMetadata(param1);
                  mimeType = findMimeTypeInVariableMetadata(param1);
                  if(_verbose && (url || mimeType))
                  {
                     log("Found class with embed information. URL: \'" + url + "\', mimeType: \'" + mimeType + "\'");
                  }
                  enqueueSingle(asset[param1.@name],param1.@name,null,getExtensionFromUrl(url),mimeType);
               };
               typeXml = describeType(asset);
               if(_verbose)
               {
                  log("Looking for static embedded assets in \'" + typeXml.@name.split("::").pop() + "\'");
               }
               for each(childNode in typeXml.constant.(@type == "Class"))
               {
                  processNode(childNode);
               }
               for each(childNode in typeXml.variable.(@type == "Class"))
               {
                  processNode(childNode);
               }
            }
            else if(getQualifiedClassName(asset) == "flash.filesystem::File")
            {
               if(!asset["exists"])
               {
                  log("File or directory not found: \'" + asset["url"] + "\'");
               }
               else if(!asset["isHidden"])
               {
                  if(asset["isDirectory"])
                  {
                     enqueue.apply(this,asset["getDirectoryListing"]());
                  }
                  else
                  {
                     enqueueSingle(asset);
                  }
               }
            }
            else if(asset is String || asset is URLRequest || asset is AssetManager)
            {
               enqueueSingle(asset);
            }
            else
            {
               log("Ignoring unsupported asset type: " + getQualifiedClassName(asset));
            }
         }
      }
      
      private function findUrlInVariableMetadata(variableDeclarationNode:XML) : String
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         for each(_loc2_ in variableDeclarationNode.metadata.(@name == "Embed"))
         {
            var _loc11_:int = 0;
            var _loc10_:* = _loc2_.arg.(@key == "source");
            for each(_loc3_ in _loc10_)
            {
               return _loc3_.@value;
            }
         }
         return null;
      }
      
      private function findMimeTypeInVariableMetadata(variableDeclarationNode:XML) : String
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         for each(_loc2_ in variableDeclarationNode.metadata.(@name == "Embed"))
         {
            var _loc11_:int = 0;
            var _loc10_:* = _loc2_.arg.(@key == "mimeType");
            for each(_loc3_ in _loc10_)
            {
               return _loc3_.@value;
            }
         }
         return null;
      }
      
      public function enqueueSingle(asset:Object, name:String = null, options:TextureOptions = null, customExtension:String = null, customMimeType:String = null) : String
      {
         if(asset is Class)
         {
            asset = new asset();
         }
         var _loc7_:AssetReference = new AssetReference(asset);
         _loc7_.name = name || getNameFromUrl(_loc7_.url) || getUniqueName();
         _loc7_.extension = customExtension || getExtensionFromUrl(_loc7_.url);
         _loc7_.mimeType = customMimeType;
         _loc7_.textureOptions = options || _textureOptions;
         var _loc6_:String = getFilenameFromUrl(_loc7_.url) || _loc7_.name;
         _queue.push(_loc7_);
         log("Enqueuing \'" + _loc6_ + "\'");
         return _loc7_.name;
      }
      
      public function dequeue(... rest) : void
      {
         var assetNames:Array = rest;
         _queue = _queue.filter(function(param1:AssetReference, param2:int, param3:*):Boolean
         {
            return assetNames.indexOf(param1.name) == -1;
         });
      }
      
      public function purgeQueue() : void
      {
         _queue.length = 0;
         _dataLoader.close();
         dispatchEventWith("cancel");
      }
      
      public function loadQueue(onComplete:Function, onError:Function = null, onProgress:Function = null) : void
      {
         var factoryHelper:AssetFactoryHelper;
         var i:int;
         var self:AssetManager;
         var canceled:Boolean;
         var queue:Vector.<AssetReference>;
         var numAssets:int;
         var numComplete:int;
         var numConnections:int;
         var assetProgress:Vector.<Number>;
         var postProcessors:Vector.<AssetPostProcessor>;
         var loadNextAsset:* = function():void
         {
            var _loc1_:int = 0;
            if(canceled)
            {
               return;
            }
            _loc1_ = 0;
            while(_loc1_ < numAssets)
            {
               if(assetProgress[_loc1_] < 0)
               {
                  loadFromQueue(queue,assetProgress,_loc1_,factoryHelper,onAssetLoaded,onAssetProgress,onAssetLoadError,onError);
                  break;
               }
               _loc1_++;
            }
         };
         var onAssetLoaded:* = function(param1:String = null, param2:Object = null, param3:String = null):void
         {
            if(canceled && param2)
            {
               disposeAsset(param2);
            }
            else
            {
               if(param1 && param2)
               {
                  addAsset(param1,param2,param3);
               }
               numComplete = numComplete + 1;
               if(numComplete == numAssets)
               {
                  postProcessors.sort(comparePriorities);
                  setTimeout(runPostProcessors,1);
               }
               else
               {
                  setTimeout(loadNextAsset,1);
               }
            }
         };
         var onAssetLoadError:* = function(param1:String, param2:AssetReference):void
         {
            if(!canceled)
            {
               starling.utils.execute(onError,param1,param2);
               onAssetLoaded();
            }
         };
         var onAssetProgress:* = function(param1:Number):void
         {
            if(!canceled)
            {
               starling.utils.execute(onProgress,param1 * 0.95);
            }
         };
         var addPostProcessor:* = function(param1:Function, param2:int):void
         {
            postProcessors.push(new AssetPostProcessor(param1,param2));
         };
         var runPostProcessors:* = function():void
         {
            if(!canceled)
            {
               if(postProcessors.length)
               {
                  try
                  {
                     postProcessors.shift().execute(self);
                  }
                  catch(e:Error)
                  {
                     starling.utils.execute(onError,e.message);
                  }
                  setTimeout(runPostProcessors,1);
               }
               else
               {
                  finish();
               }
            }
         };
         var onCanceled:* = function():void
         {
            canceled = true;
            removeEventListener("cancel",onCanceled);
         };
         var finish:* = function():void
         {
            onCanceled();
            starling.utils.execute(onProgress,1);
            starling.utils.execute(onComplete,self);
         };
         if(_queue.length == 0)
         {
            finish();
            return;
         }
         addEventListener("cancel",onCanceled);
         factoryHelper = new AssetFactoryHelper();
         factoryHelper.getNameFromUrlFunc = getNameFromUrl;
         factoryHelper.getExtensionFromUrlFunc = getExtensionFromUrl;
         factoryHelper.addPostProcessorFunc = addPostProcessor;
         factoryHelper.addAssetFunc = addAsset;
         factoryHelper.onRestoreFunc = onAssetRestored;
         factoryHelper.dataLoader = _dataLoader;
         factoryHelper.logFunc = log;
         self = this;
         canceled = false;
         queue = _queue.concat();
         numAssets = int(queue.length);
         numComplete = 0;
         numConnections = MathUtil.min(_numConnections,numAssets);
         assetProgress = new Vector.<Number>(numAssets,true);
         postProcessors = new Vector.<AssetPostProcessor>(0);
         _starling = Starling.current;
         _queue.length = 0;
         i = 0;
         while(i < numAssets)
         {
            assetProgress[i] = -1;
            i = i + 1;
         }
         i = 0;
         while(i < numConnections)
         {
            loadNextAsset();
            i = i + 1;
         }
      }
      
      private function loadFromQueue(queue:Vector.<AssetReference>, progressRatios:Vector.<Number>, index:int, helper:AssetFactoryHelper, onComplete:Function, onProgress:Function, onError:Function, onIntermediateError:Function) : void
      {
         var onLoadComplete:* = function(param1:Object, param2:String = null, param3:String = null, param4:String = null):void
         {
            if(_starling)
            {
               _starling.makeCurrent();
            }
            onLoadProgress(1);
            if(param1)
            {
               reference.data = param1;
            }
            if(param3)
            {
               reference.name = param3;
            }
            if(param4)
            {
               reference.extension = param4;
            }
            if(param2)
            {
               reference.mimeType = param2;
            }
            var _loc5_:AssetFactory = getFactoryFor(reference);
            if(_loc5_ == null)
            {
               starling.utils.execute(onAnyError,"Warning: no suitable factory found for \'" + reference.name + "\'");
            }
            else
            {
               _loc5_.create(reference,helper,onComplete,onFactoryError);
            }
         };
         var onLoadProgress:* = function(param1:Number):void
         {
            var _loc5_:int = 0;
            var _loc2_:Number = NaN;
            progressRatios[index] = param1;
            var _loc3_:Number = 0;
            var _loc4_:Number = 1 / referenceCount;
            _loc5_ = 0;
            while(_loc5_ < referenceCount)
            {
               _loc2_ = progressRatios[_loc5_];
               if(_loc2_ > 0)
               {
                  _loc3_ += _loc4_ * _loc2_;
               }
               _loc5_++;
            }
            starling.utils.execute(onProgress,MathUtil.min(_loc3_,1));
         };
         var onLoadError:* = function(param1:String):void
         {
            onLoadProgress(1);
            starling.utils.execute(onAnyError,"Error loading " + reference.name + ": " + param1);
         };
         var onAnyError:* = function(param1:String):void
         {
            log(param1);
            starling.utils.execute(onError,param1,reference);
         };
         var onFactoryError:* = function(param1:String):void
         {
            starling.utils.execute(onAnyError,"Error creating " + reference.name + ": " + param1);
         };
         var onManagerComplete:* = function():void
         {
            onComplete(reference.name,reference.data);
         };
         var referenceCount:int = int(queue.length);
         var reference:AssetReference = queue[index];
         progressRatios[index] = 0;
         if(reference.url)
         {
            _dataLoader.load(reference.url,onLoadComplete,onLoadError,onLoadProgress);
         }
         else if(reference.data is AssetManager)
         {
            (reference.data as AssetManager).loadQueue(onManagerComplete,onIntermediateError,onLoadProgress);
         }
         else
         {
            setTimeout(onLoadComplete,1,reference.data);
         }
      }
      
      private function getFactoryFor(asset:AssetReference) : AssetFactory
      {
         var _loc4_:int = 0;
         var _loc2_:AssetFactory = null;
         var _loc3_:int = int(_assetFactories.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = _assetFactories[_loc4_];
            if(_loc2_.canHandle(asset))
            {
               return _loc2_;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function onAssetRestored(finished:Boolean) : void
      {
         if(finished)
         {
            _numRestoredTextures = _numRestoredTextures + 1;
            if(_starling)
            {
               _starling.stage.setRequiresRedraw();
            }
            if(_numRestoredTextures == _numLostTextures)
            {
               dispatchEventWith("texturesRestored");
            }
         }
         else
         {
            _numLostTextures = _numLostTextures + 1;
         }
      }
      
      public function addAsset(name:String, asset:Object, type:String = null) : void
      {
         if(!type)
         {
            type = AssetType.fromAsset(asset);
         }
         var _loc4_:Dictionary = _assets[type];
         if(_loc4_ == null)
         {
            _loc4_ = new Dictionary();
            _assets[type] = _loc4_;
         }
         log("Adding " + type + " \'" + name + "\'");
         var _loc5_:Object = _loc4_[name];
         if(_loc5_ && _loc5_ != asset)
         {
            log("Warning: name was already in use; disposing the previous " + type);
            disposeAsset(_loc5_);
         }
         _loc4_[name] = asset;
      }
      
      public function getAsset(type:String, name:String, recursive:Boolean = true) : Object
      {
         var _loc5_:Dictionary = null;
         var _loc10_:Object = null;
         var _loc4_:Dictionary = null;
         var _loc8_:Texture = null;
         if(recursive)
         {
            _loc5_ = _assets["assetManager"];
            if(_loc5_)
            {
               for each(var _loc6_:AssetManager in _loc5_)
               {
                  _loc10_ = _loc6_.getAsset(type,name,true);
                  if(_loc10_)
                  {
                     return _loc10_;
                  }
               }
            }
            if(type == "texture")
            {
               _loc4_ = _assets["textureAtlas"];
               if(_loc4_)
               {
                  for each(var _loc7_:TextureAtlas in _loc4_)
                  {
                     _loc8_ = _loc7_.getTexture(name);
                     if(_loc8_)
                     {
                        return _loc8_;
                     }
                  }
               }
            }
         }
         var _loc9_:Dictionary = _assets[type];
         if(_loc9_)
         {
            return _loc9_[name];
         }
         return null;
      }
      
      public function getAssetNames(assetType:String, prefix:String = "", recursive:Boolean = true, out:Vector.<String> = null) : Vector.<String>
      {
         var _loc6_:Dictionary = null;
         var _loc5_:Dictionary = null;
         if(!out)
         {
            out = new Vector.<String>();
         }
         if(recursive)
         {
            _loc6_ = _assets["assetManager"];
            if(_loc6_)
            {
               for each(var _loc7_:AssetManager in _loc6_)
               {
                  _loc7_.getAssetNames(assetType,prefix,true,out);
               }
            }
            if(assetType == "texture")
            {
               _loc5_ = _assets["textureAtlas"];
               if(_loc5_)
               {
                  for each(var _loc8_:TextureAtlas in _loc5_)
                  {
                     _loc8_.getNames(prefix,out);
                  }
               }
            }
         }
         getDictionaryKeys(_assets[assetType],prefix,out);
         out.sort(1);
         return out;
      }
      
      public function removeAsset(assetType:String, name:String, dispose:Boolean = true) : void
      {
         var _loc5_:Object = null;
         var _loc4_:Dictionary = _assets[assetType];
         if(_loc4_)
         {
            _loc5_ = _loc4_[name];
            if(_loc5_)
            {
               log("Removing " + assetType + " \'" + name + "\'");
               if(dispose)
               {
                  disposeAsset(_loc5_);
               }
               delete _loc4_[name];
            }
         }
      }
      
      public function getTexture(name:String) : Texture
      {
         return getAsset("texture",name) as Texture;
      }
      
      public function getTextures(prefix:String = "", out:Vector.<Texture> = null) : Vector.<Texture>
      {
         if(out == null)
         {
            out = new Vector.<Texture>(0);
         }
         for each(var _loc3_:String in getTextureNames(prefix,sNames))
         {
            out[out.length] = getTexture(_loc3_);
         }
         sNames.length = 0;
         return out;
      }
      
      public function getTextureNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("texture",prefix,true,out);
      }
      
      public function getTextureAtlas(name:String) : TextureAtlas
      {
         return getAsset("textureAtlas",name) as TextureAtlas;
      }
      
      public function getTextureAtlasNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("textureAtlas",prefix,true,out);
      }
      
      public function getSound(name:String) : Sound
      {
         return getAsset("sound",name) as Sound;
      }
      
      public function getSoundNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("sound",prefix,true,out);
      }
      
      public function playSound(name:String, startTime:Number = 0, loops:int = 0, transform:SoundTransform = null) : SoundChannel
      {
         var _loc5_:Sound = getSound(name);
         if(_loc5_)
         {
            return _loc5_.play(startTime,loops,transform);
         }
         return null;
      }
      
      public function getXml(name:String) : XML
      {
         return getAsset("xml",name) as XML;
      }
      
      public function getXmlNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("xml",prefix,true,out);
      }
      
      public function getObject(name:String) : Object
      {
         return getAsset("object",name);
      }
      
      public function getObjectNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("object",prefix,true,out);
      }
      
      public function getByteArray(name:String) : ByteArray
      {
         return getAsset("byteArray",name) as ByteArray;
      }
      
      public function getByteArrayNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("byteArray",prefix,true,out);
      }
      
      public function getBitmapFont(name:String) : BitmapFont
      {
         return getAsset("bitmapFont",name) as BitmapFont;
      }
      
      public function getBitmapFontNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("bitmapFont",prefix,true,out);
      }
      
      public function getAssetManager(name:String) : AssetManager
      {
         return getAsset("assetManager",name) as AssetManager;
      }
      
      public function getAssetManagerNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String>
      {
         return getAssetNames("assetManager",prefix,true,out);
      }
      
      public function removeTexture(name:String, dispose:Boolean = true) : void
      {
         removeAsset("texture",name,dispose);
      }
      
      public function removeTextureAtlas(name:String, dispose:Boolean = true) : void
      {
         removeAsset("textureAtlas",name,dispose);
      }
      
      public function removeSound(name:String) : void
      {
         removeAsset("sound",name);
      }
      
      public function removeXml(name:String, dispose:Boolean = true) : void
      {
         removeAsset("xml",name,dispose);
      }
      
      public function removeObject(name:String) : void
      {
         removeAsset("object",name);
      }
      
      public function removeByteArray(name:String, dispose:Boolean = true) : void
      {
         removeAsset("byteArray",name,dispose);
      }
      
      public function removeBitmapFont(name:String, dispose:Boolean = true) : void
      {
         removeAsset("bitmapFont",name,dispose);
      }
      
      public function removeAssetManager(name:String, dispose:Boolean = true) : void
      {
         removeAsset("assetManager",name,dispose);
      }
      
      public function registerFactory(factory:AssetFactory, priority:int = 0) : void
      {
         factory.priority = priority;
         _assetFactories.push(factory);
         _assetFactories.sort(comparePriorities);
      }
      
      public function unregisterFactory(factory:AssetFactory) : void
      {
         var _loc2_:int = _assetFactories.indexOf(factory);
         if(_loc2_ != -1)
         {
            _assetFactories.removeAt(_loc2_);
         }
      }
      
      private function getFilenameFromUrl(url:String) : String
      {
         var _loc2_:Array = null;
         if(url)
         {
            _loc2_ = matchRegEx(url);
            if(_loc2_ && _loc2_.length > 1)
            {
               return _loc2_[1];
            }
         }
         return null;
      }
      
      protected function getNameFromUrl(url:String) : String
      {
         var _loc2_:Array = null;
         if(url)
         {
            _loc2_ = matchRegEx(url);
            if(_loc2_ && _loc2_.length > 2)
            {
               return _loc2_[2];
            }
         }
         return null;
      }
      
      protected function getExtensionFromUrl(url:String) : String
      {
         var _loc2_:Array = null;
         if(url)
         {
            _loc2_ = matchRegEx(url);
            if(_loc2_ && _loc2_.length > 3)
            {
               return _loc2_[3];
            }
         }
         return "";
      }
      
      protected function matchRegEx(url:String) : Array
      {
         return NAME_REGEX.exec(decodeURIComponent(url));
      }
      
      protected function disposeAsset(asset:Object) : void
      {
         if(asset is ByteArray)
         {
            (asset as ByteArray).clear();
         }
         if(asset is XML)
         {
            System.disposeXML(asset as XML);
         }
         if("dispose" in asset)
         {
            asset["dispose"]();
         }
      }
      
      protected function log(message:String) : void
      {
         if(_verbose)
         {
         }
      }
      
      public function get verbose() : Boolean
      {
         return _verbose;
      }
      
      public function set verbose(value:Boolean) : void
      {
         _verbose = value;
      }
      
      public function get numQueuedAssets() : int
      {
         return _queue.length;
      }
      
      public function get numConnections() : int
      {
         return _numConnections;
      }
      
      public function set numConnections(value:int) : void
      {
         _numConnections = MathUtil.max(1,value);
      }
      
      public function get textureOptions() : TextureOptions
      {
         return _textureOptions;
      }
      
      public function set textureOptions(value:TextureOptions) : void
      {
         _textureOptions.copyFrom(value);
      }
      
      public function get dataLoader() : DataLoader
      {
         return _dataLoader;
      }
      
      public function set dataLoader(value:DataLoader) : void
      {
         _dataLoader = value;
      }
      
      public function get registerBitmapFontsWithFontFace() : Boolean
      {
         return _registerBitmapFontsWithFontFace;
      }
      
      public function set registerBitmapFontsWithFontFace(value:Boolean) : void
      {
         _registerBitmapFontsWithFontFace = value;
      }
   }
}

import starling.assets.AssetManager;

class AssetPostProcessor
{
   
   private var _priority:int;
   
   private var _callback:Function;
   
   public function AssetPostProcessor(callback:Function, priority:int)
   {
      super();
      if(callback == null || callback.length != 1)
      {
         throw new ArgumentError("callback must be a function accepting one \'AssetStore\' parameter");
      }
      _callback = callback;
      _priority = priority;
   }
   
   internal function execute(store:AssetManager) : void
   {
      _callback(store);
   }
   
   public function get priority() : int
   {
      return _priority;
   }
}
