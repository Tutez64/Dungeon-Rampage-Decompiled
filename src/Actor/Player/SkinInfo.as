package Actor.Player
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import GameMasterDictionary.GMSkin;
   
   public class SkinInfo
   {
      
      private var mGMSkin:GMSkin;
      
      private var mSkinType:uint;
      
      private var mDBFacade:DBFacade;
      
      public function SkinInfo(dbFacade:DBFacade, skinJson:Object)
      {
         super();
         mDBFacade = dbFacade;
         mSkinType = skinJson.skin_type as uint;
         mGMSkin = mDBFacade.gameMaster.getSkinByType(mSkinType);
         if(mGMSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin with id: " + mSkinType);
         }
      }
      
      public function get skinType() : uint
      {
         return mSkinType;
      }
   }
}

