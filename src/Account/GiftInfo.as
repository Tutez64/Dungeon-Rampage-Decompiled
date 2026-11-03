package Account
{
   import Facade.DBFacade;
   
   public class GiftInfo
   {
      
      private var mFromAccountId:uint;
      
      private var mOfferId:uint;
      
      private var mRequestId:String;
      
      private var mDBFacade:DBFacade;
      
      private var mResponseCallback:Function;
      
      public function GiftInfo(dbFacade:DBFacade, giftJson:Object, responseCallback:Function = null)
      {
         super();
         mDBFacade = dbFacade;
         mResponseCallback = responseCallback;
         parseJson(giftJson);
      }
      
      private function parseJson(giftJson:Object) : void
      {
         if(giftJson == null)
         {
            return;
         }
         mFromAccountId = giftJson.from_account_id as uint;
         mOfferId = giftJson.offer_id as uint;
         mRequestId = giftJson.request_id as String;
         if(mResponseCallback != null)
         {
            mResponseCallback();
         }
      }
      
      public function get fromAccountId() : uint
      {
         return mFromAccountId;
      }
      
      public function get requestId() : String
      {
         return mRequestId;
      }
      
      public function get offerId() : uint
      {
         return mOfferId;
      }
   }
}

