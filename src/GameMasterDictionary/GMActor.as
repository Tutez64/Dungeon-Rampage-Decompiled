package GameMasterDictionary
{
   public class GMActor extends GMItem
   {
      
      public static const DESTRUCTION_SMASH:String = "SMASH";
      
      public static const DESTRUCTION_TIPOVER:String = "TIPOVER";
      
      public static const CHAR_TYPE_PROP:String = "PROP";
      
      public var Release:String = "D";
      
      public var CharType:String;
      
      public var ClassType:String;
      
      public var Species:String;
      
      public var Element:String;
      
      public var HP:Number;
      
      public var MP:Number;
      
      public var BaseMove:Number;
      
      public var BaseValues:StatVector;
      
      public var LevelValues:StatVector;
      
      public var AssetClassName:String;
      
      public var SwfFilepath:String;
      
      public var HDSwfFilepath:String;
      
      public var PortraitName:String;
      
      public var IconSwfFilepath:String;
      
      protected var mIconName:String;
      
      public var Description:String;
      
      public var AssetType:String;
      
      public var SpriteWidth:Number;
      
      public var SpriteHeight:Number;
      
      public var NametagY:Number;
      
      public var HealthbarScale:Number;
      
      public var Scale:Number;
      
      public var Hue:Number;
      
      public var Saturation:Number;
      
      public var Brightness:Number;
      
      public var Scale3DModel:Number;
      
      public var Ability:uint;
      
      public var HitSound:String;
      
      public var HitVolume:Number;
      
      public var DeathSound:String;
      
      public var DeathVolume:Number;
      
      public var SpawnEffectClassName:String;
      
      public var SpawnEffectFilePath:String;
      
      public var CollisionX:Number;
      
      public var CollisionY:Number;
      
      public var CollisionSize:Number;
      
      public var CollideWithTeam:Boolean;
      
      public var TeleportInTimeline:String;
      
      public var TeleportOutTimeline:String;
      
      public var RespawnT:Number;
      
      public var ProjEmitOffset:Number;
      
      public var DefaultDestruct:String;
      
      public var Weapon1:String;
      
      public var Weapon2:String;
      
      public var Weapon3:String;
      
      public var Weapon4:String;
      
      public var Weapon5:String;
      
      public var CanShakeCamera:Boolean;
      
      public var IsMover:Boolean = true;
      
      public var HasOffscreenIndicator:Boolean = false;
      
      public var scaled_ProjEmitOffset:Number;
      
      public function GMActor(jsonAsset:Object)
      {
         super(jsonAsset);
         if(jsonAsset.hasOwnProperty("Release"))
         {
            Release = jsonAsset.Release;
         }
         Description = jsonAsset.Description;
         CharType = jsonAsset.CharType;
         ClassType = jsonAsset.ClassType;
         Species = jsonAsset.Species;
         Element = jsonAsset.Element;
         HP = jsonAsset.HP;
         MP = jsonAsset.MP;
         BaseValues = new StatVector();
         BaseValues.SetFromJSON(jsonAsset);
         LevelValues = new StatVector();
         LevelValues.SetFromJSON(jsonAsset,"LV_");
         AssetClassName = jsonAsset.AssetClassName;
         PortraitName = jsonAsset.PortraitName;
         IconSwfFilepath = jsonAsset.IconSwfFilepath;
         mIconName = jsonAsset.IconName;
         SwfFilepath = jsonAsset.SwfFilepath;
         HDSwfFilepath = jsonAsset.HDSwfFilepath;
         Description = jsonAsset.Description;
         AssetType = jsonAsset.AssetType;
         SpriteWidth = jsonAsset.SpriteWidth;
         SpriteHeight = jsonAsset.SpriteHeight;
         NametagY = jsonAsset.NametagY;
         HealthbarScale = jsonAsset.HealthbarScale;
         IsMover = jsonAsset.IsMover == 1;
         HasOffscreenIndicator = jsonAsset.HasOffscreenIndicator;
         Ability = 0;
         Scale = jsonAsset.Scale;
         Hue = jsonAsset.Hue;
         Saturation = jsonAsset.Saturation > 0 ? (100 + jsonAsset.Saturation) / 100 * 2 : 0;
         Brightness = jsonAsset.Brightness;
         if(jsonAsset.Scale3DModel == null)
         {
            Scale3DModel = 1;
         }
         else
         {
            Scale3DModel = jsonAsset.Scale3DModel;
         }
         BaseMove = jsonAsset.BaseMove;
         HitSound = jsonAsset.HitSound;
         HitVolume = jsonAsset.HitVol;
         DeathSound = jsonAsset.DeathSound;
         DeathVolume = jsonAsset.DeathVol;
         SpawnEffectClassName = jsonAsset.SpawnEffectClassName;
         SpawnEffectFilePath = jsonAsset.SpawnEffectFilePath;
         CollisionX = jsonAsset.CollisionX;
         CollisionY = jsonAsset.CollisionY;
         CollisionSize = jsonAsset.CollisionSize;
         CollideWithTeam = jsonAsset.CollideWithTeam;
         TeleportInTimeline = jsonAsset.TeleportInTimeline;
         TeleportOutTimeline = jsonAsset.TeleportOutTimeline;
         RespawnT = jsonAsset.RespawnT;
         ProjEmitOffset = jsonAsset.ProjEmitOffset;
         scaled_ProjEmitOffset = jsonAsset.ProjEmitOffset * Scale;
         DefaultDestruct = jsonAsset.DefaultDestruct;
         CanShakeCamera = jsonAsset.CanShakeCamera;
      }
      
      public function get IconName() : String
      {
         return mIconName;
      }
   }
}

