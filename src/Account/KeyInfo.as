package Account
{
   import GameMasterDictionary.GMKey;
   import GameMasterDictionary.GMOffer;
   
   public class KeyInfo
   {
      
      private var mGMKey:GMKey;
      
      private var mGMKeyOffer:GMOffer;
      
      private var mCount:uint;
      
      public function KeyInfo(gmKey:GMKey, gmKeyOffer:GMOffer, num:uint)
      {
         super();
         mGMKey = gmKey;
         mGMKeyOffer = gmKeyOffer;
         mCount = num;
      }
      
      public function get gmKey() : GMKey
      {
         return mGMKey;
      }
      
      public function get gmKeyOffer() : GMOffer
      {
         return mGMKeyOffer;
      }
      
      public function get count() : uint
      {
         return mCount;
      }
      
      public function set count(val:uint) : void
      {
         mCount = val;
      }
   }
}

