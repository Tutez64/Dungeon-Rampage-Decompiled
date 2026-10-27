package NetworkCode.Transport
{
   public final class SessionCredential
   {
      
      private static const ACCOUNT:RegExp = /^[1-9][0-9]{0,19}$/;
      
      private static const TOKEN:RegExp = /^[0-9]{1,20}:[0-9a-f]{64}$/;
      
      private static const TRACE:RegExp = /^00-[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{2}$/;
      
      private var mAccount:String;
      
      private var mToken:String;
      
      private var mTrace:String;
      
      public function SessionCredential(account:String, token:String, trace:String)
      {
         super();
         mAccount = account;
         mToken = token;
         mTrace = trace;
      }
      
      private static function field(name:String, value:String, shape:RegExp) : String
      {
         return shape.test(value) ? ",\"" + name + "\":\"" + value + "\"" : "";
      }
      
      public function get jsonFields() : String
      {
         return field("account",mAccount,ACCOUNT) + field("token",mToken,TOKEN) + field("trace",mTrace,TRACE);
      }
      
      public function get omittedFields() : String
      {
         var _loc1_:Array = [];
         if(!ACCOUNT.test(mAccount))
         {
            _loc1_.push("account");
         }
         if(!TOKEN.test(mToken))
         {
            _loc1_.push("token");
         }
         if(mTrace != null && !TRACE.test(mTrace))
         {
            _loc1_.push("trace");
         }
         return _loc1_.join(", ");
      }
   }
}

