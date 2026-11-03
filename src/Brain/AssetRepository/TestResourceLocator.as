package Brain.AssetRepository
{
   import flash.display.Loader;
   import flash.filesystem.File;
   import flash.system.LoaderContext;
   
   public class TestResourceLocator
   {
      
      public function TestResourceLocator()
      {
         super();
      }
      
      public static function apply(arguments:Array) : void
      {
      }
      
      public static function file(path:String) : File
      {
         return null;
      }
      
      public static function url(path:String) : String
      {
         return path;
      }
      
      public static function loadBytes(loader:Loader, path:String, context:LoaderContext) : Boolean
      {
         return false;
      }
   }
}

