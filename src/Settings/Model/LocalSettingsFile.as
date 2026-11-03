package Settings.Model
{
   import Brain.Logger.Logger;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   
   public class LocalSettingsFile
   {
      
      private static const FILE_NAME:String = "settings.json";
      
      public function LocalSettingsFile()
      {
         super();
      }
      
      private static function resolveFile() : File
      {
         return File.applicationStorageDirectory.resolvePath("settings.json");
      }
      
      public function read() : Object
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc1_:File = resolveFile();
         if(!_loc1_.exists)
         {
            return null;
         }
         var _loc2_:FileStream = new FileStream();
         try
         {
            _loc2_.open(_loc1_,"read");
            _loc3_ = _loc2_.readUTFBytes(_loc2_.bytesAvailable);
         }
         catch(error:Error)
         {
            Logger.warn("Could not read settings.json, falling back to defaults: " + error.message);
            return null;
         }
         finally
         {
            _loc2_.close();
         }
         try
         {
            _loc4_ = JSON.parse(_loc3_);
            if(_loc4_ != null)
            {
               return _loc4_;
            }
         }
         catch(parseError:Error)
         {
            Logger.warn("Could not parse settings.json, falling back to defaults: " + parseError.message);
         }
         return null;
      }
      
      public function write(blob:Object) : void
      {
         var _loc2_:FileStream = new FileStream();
         try
         {
            _loc2_.open(resolveFile(),"write");
            _loc2_.writeUTFBytes(JSON.stringify(blob));
         }
         catch(error:Error)
         {
            Logger.error("Could not write settings.json: " + error.message);
         }
         finally
         {
            _loc2_.close();
         }
      }
   }
}

