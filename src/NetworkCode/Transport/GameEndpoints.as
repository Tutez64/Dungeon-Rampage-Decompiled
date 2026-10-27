package NetworkCode.Transport
{
   public class GameEndpoints
   {
      
      public var address:String;
      
      public var port:int;
      
      public var wssPath:String;
      
      public var enforceServerCertificate:Boolean;
      
      public var tlsOffered:Boolean;
      
      public function GameEndpoints(address:String, port:int, wssPath:String = "", enforceServerCertificate:Boolean = true, tlsOffered:Boolean = true)
      {
         super();
         this.address = address;
         this.port = port;
         this.wssPath = normalizePath(wssPath);
         this.enforceServerCertificate = enforceServerCertificate;
         this.tlsOffered = tlsOffered;
      }
      
      private static function describePath(path:String) : String
      {
         return path == "" ? "(not offered)" : path;
      }
      
      private static function normalizePath(path:String) : String
      {
         if(path == null || path == "")
         {
            return "";
         }
         return path.charAt(0) == "/" ? path : "/" + path;
      }
      
      public function get wssUrl() : String
      {
         return wssPath == "" ? "" : "wss://" + authority + wssPath;
      }
      
      public function get authority() : String
      {
         return port == 443 ? address : address + ":" + port;
      }
      
      public function toString() : String
      {
         return "GameEndpoints(" + address + ":" + port + " tlsSocket=" + (tlsOffered ? "offered" : "not offered") + " wssPath=" + describePath(wssPath) + " enforceCert=" + enforceServerCertificate + ")";
      }
   }
}

