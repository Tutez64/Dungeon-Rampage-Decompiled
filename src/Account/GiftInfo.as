package Account
{
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GiftInfo
   {
      
      private var mFromAccountId:uint;
      
      private var mOfferId:uint;
      
      private var mRequestId:String;
      
      private var mProfilePic:DisplayObject;
      
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
      
      private function ignoreIOError(event:Event) : void
      {
      }
      
      public function get pic() : DisplayObject
      {
         return mProfilePic;
      }
      
      public function set pic(profilePic:DisplayObject) : void
      {
         mProfilePic = profilePic;
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

