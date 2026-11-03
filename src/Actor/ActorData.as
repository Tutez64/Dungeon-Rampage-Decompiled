package Actor
{
   import Facade.DBFacade;
   import GameMasterDictionary.GMActor;
   import GameMasterDictionary.GMMap;
   import GameMasterDictionary.StatVector;
   
   public class ActorData
   {
      
      protected var mFacade:DBFacade;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mData:GMActor;
      
      public function ActorData(facade:DBFacade, actorGameObject:ActorGameObject)
      {
         super();
         mFacade = facade;
         mActorGameObject = actorGameObject;
         var _loc3_:GMMap = mFacade.gameMaster.getActorMap(mActorGameObject.type);
         mData = _loc3_.itemFor(mActorGameObject.type);
         if(mData == null)
         {
            throw new Error("type not found in GameMaster");
         }
      }
      
      public static function offMovieClipClassName(assetClassName:String) : String
      {
         return assetClassName ? assetClassName + "_off" : "";
      }
      
      public static function deathMovieClipClassName(assetClassName:String) : String
      {
         return assetClassName ? assetClassName + "_death" : "";
      }
      
      public function destroy() : void
      {
         mFacade = null;
         mActorGameObject = null;
         mData = null;
      }
      
      public function get gMActor() : GMActor
      {
         return mData;
      }
      
      public function getSwfFilePath() : String
      {
         return DBFacade.buildFullDownloadPath(mData.SwfFilepath);
      }
      
      public function getSpriteSheetClassName(anim:String) : String
      {
         return mData.AssetClassName + "_" + anim + ".png";
      }
      
      public function getMovieClipClassName() : String
      {
         return mData.AssetClassName;
      }
      
      public function getOffSpriteSheetClassName(anim:String) : String
      {
         return mData.AssetClassName + "_off_" + anim + ".png";
      }
      
      public function getOffMovieClipClassName() : String
      {
         return offMovieClipClassName(mData.AssetClassName);
      }
      
      public function getDeathMovieClipClassName() : String
      {
         return deathMovieClipClassName(mData.AssetClassName);
      }
      
      public function get constant() : String
      {
         return mData.Constant;
      }
      
      public function get hp() : Number
      {
         return mData.HP;
      }
      
      public function get mp() : Number
      {
         return mData.MP;
      }
      
      public function get movment() : Number
      {
         return mData.BaseMove;
      }
      
      public function get baseValues() : StatVector
      {
         return mData.BaseValues;
      }
      
      public function get levelValues() : StatVector
      {
         return mData.LevelValues;
      }
      
      public function get isMover() : Boolean
      {
         return mData.IsMover;
      }
      
      public function get assetType() : String
      {
         return mData.AssetType;
      }
      
      public function get spriteWidth() : Number
      {
         return mData.SpriteWidth;
      }
      
      public function get spriteHeight() : Number
      {
         return mData.SpriteHeight;
      }
      
      public function get assetClassName() : String
      {
         return mData.AssetClassName;
      }
      
      public function get hue() : Number
      {
         return mData.Hue;
      }
      
      public function get saturation() : Number
      {
         return mData.Saturation;
      }
      
      public function get brightness() : Number
      {
         return mData.Brightness;
      }
      
      public function get scale() : Number
      {
         return mData.Scale;
      }
      
      public function get hitSound() : String
      {
         return mData.HitSound;
      }
      
      public function get hitVolume() : Number
      {
         return mData.HitVolume;
      }
      
      public function get deathSound() : String
      {
         return mData.DeathSound;
      }
      
      public function get deathVolume() : Number
      {
         return mData.DeathVolume;
      }
   }
}

