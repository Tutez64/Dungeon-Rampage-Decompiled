package NetworkCode.Transport
{
   public class TransportCandidate
   {
      
      public var kind:String;
      
      public var host:String;
      
      public var port:int;
      
      public var url:String;
      
      public function TransportCandidate(kind:String, host:String = "", port:int = 0, url:String = "")
      {
         super();
         this.kind = kind;
         this.host = host;
         this.port = port;
         this.url = url;
      }
      
      public function get name() : String
      {
         return kind + " " + (url != "" ? url : host + ":" + port);
      }
   }
}

