package Actor
{
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMSkin;
   
   public class HeroData extends ActorData
   {
      
      protected var mHeroGameObject:HeroGameObject;
      
      protected var mGMSkin:GMSkin;
      
      public function HeroData(facade:DBFacade, heroGameObject:HeroGameObject, gmSkin:GMSkin)
      {
         super(facade,heroGameObject);
         mHeroGameObject = heroGameObject;
         mGMSkin = gmSkin;
      }
      
      override public function getSwfFilePath() : String
      {
         if(mGMSkin.HDSwfFilepath)
         {
            return DBFacade.buildFullDownloadPath(mGMSkin.HDSwfFilepath);
         }
         return DBFacade.buildFullDownloadPath(mGMSkin.SwfFilepath);
      }
      
      override public function getSpriteSheetClassName(anim:String) : String
      {
         return mGMSkin.AssetClassName + "_" + anim + ".png";
      }
      
      override public function getMovieClipClassName() : String
      {
         return mGMSkin.AssetClassName;
      }
      
      override public function getOffSpriteSheetClassName(anim:String) : String
      {
         return mGMSkin.AssetClassName + "_off_" + anim + ".png";
      }
      
      override public function getOffMovieClipClassName() : String
      {
         return mGMSkin.AssetClassName ? mGMSkin.AssetClassName + "_off" : "";
      }
      
      override public function get assetClassName() : String
      {
         return mGMSkin.AssetClassName;
      }
      
      override public function get hue() : Number
      {
         return mGMSkin.Hue;
      }
      
      override public function get saturation() : Number
      {
         return mGMSkin.Saturation;
      }
      
      override public function get brightness() : Number
      {
         return mGMSkin.Brightness;
      }
      
      override public function get scale() : Number
      {
         return mGMSkin.Scale;
      }
      
      override public function get hitSound() : String
      {
         return mGMSkin.HitSound;
      }
      
      override public function get hitVolume() : Number
      {
         return mGMSkin.HitVol;
      }
      
      override public function get deathSound() : String
      {
         return mGMSkin.DeathSound;
      }
      
      override public function get deathVolume() : Number
      {
         return mGMSkin.DeathVol;
      }
      
      override public function get scale3DModel() : Number
      {
         return mGMSkin.Scale3DModel;
      }
   }
}

