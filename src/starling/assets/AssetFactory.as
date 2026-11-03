package starling.assets
{
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   import starling.errors.AbstractClassError;
   
   public class AssetFactory
   {
      
      private var _priority:int;
      
      private var _mimeTypes:Vector.<String>;
      
      private var _extensions:Vector.<String>;
      
      public function AssetFactory()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.assets::AssetFactory")
         {
            throw new AbstractClassError();
         }
         _mimeTypes = new Vector.<String>(0);
         _extensions = new Vector.<String>(0);
      }
      
      public function canHandle(reference:AssetReference) : Boolean
      {
         var _loc3_:String = reference.mimeType;
         var _loc2_:String = reference.extension;
         return reference.data is ByteArray && (_loc3_ && _mimeTypes.indexOf(reference.mimeType.toLowerCase()) != -1 || _loc2_ && _extensions.indexOf(reference.extension.toLowerCase()) != -1);
      }
      
      public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
      }
      
      public function addMimeTypes(... rest) : void
      {
         for each(var _loc2_:String in rest)
         {
            _loc2_ = _loc2_.toLowerCase();
            if(_mimeTypes.indexOf(_loc2_) == -1)
            {
               _mimeTypes[_mimeTypes.length] = _loc2_;
            }
         }
      }
      
      public function addExtensions(... rest) : void
      {
         for each(var _loc2_:String in rest)
         {
            _loc2_ = _loc2_.toLowerCase();
            if(_extensions.indexOf(_loc2_) == -1)
            {
               _extensions[_extensions.length] = _loc2_;
            }
         }
      }
      
      public function getMimeTypes(out:Vector.<String> = null) : Vector.<String>
      {
         var _loc2_:int = 0;
         if(!out)
         {
            out = new Vector.<String>();
         }
         _loc2_ = 0;
         while(_loc2_ < _mimeTypes.length)
         {
            out[_loc2_] = _mimeTypes[_loc2_];
            _loc2_++;
         }
         return out;
      }
      
      public function getExtensions(out:Vector.<String> = null) : Vector.<String>
      {
         var _loc2_:int = 0;
         if(!out)
         {
            out = new Vector.<String>();
         }
         _loc2_ = 0;
         while(_loc2_ < _extensions.length)
         {
            out[_loc2_] = _extensions[_loc2_];
            _loc2_++;
         }
         return out;
      }
      
      internal function get priority() : int
      {
         return _priority;
      }
      
      internal function set priority(value:int) : void
      {
         _priority = value;
      }
   }
}

