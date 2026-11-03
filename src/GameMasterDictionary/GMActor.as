package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMActor extends GMItem
   {
      
      public static var DESTRUCTION_SMASH:String = "SMASH";
      
      public static var DESTRUCTION_TIPOVER:String = "TIPOVER";
      
      public static var CHAR_TYPE_PROP:String = "PROP";
      
      public var scaled_ProjEmitOffset:Number;
      
      public var mIconName:String;
      
      public var Weapon5:String;
      
      public var Weapon4:String;
      
      public var Weapon3:String;
      
      public var Weapon2:String;
      
      public var Weapon1:String;
      
      public var TeleportOutTimeline:String;
      
      public var TeleportInTimeline:String;
      
      public var SwfFilepath:String;
      
      public var SpriteWidth:Number;
      
      public var SpriteHeight:Number;
      
      public var Species:String;
      
      public var SpawnEffectFilePath:String;
      
      public var SpawnEffectClassName:String;
      
      public var Scale:Number;
      
      public var Saturation:Number;
      
      public var RespawnT:Number;
      
      public var Release:String;
      
      public var ProjEmitOffset:Number;
      
      public var PortraitName:String;
      
      public var NametagY:Number;
      
      public var MP:Number;
      
      public var LevelValues:StatVector;
      
      public var IsMover:Boolean;
      
      public var IconSwfFilepath:String;
      
      public var Hue:Number;
      
      public var HitVolume:Number;
      
      public var HitSound:String;
      
      public var HealthbarScale:Number;
      
      public var HasOffscreenIndicator:Boolean;
      
      public var HP:Number;
      
      public var Element:String;
      
      public var Description:String;
      
      public var DefaultDestruct:String;
      
      public var DeathVolume:Number;
      
      public var DeathSound:String;
      
      public var CollisionY:Number;
      
      public var CollisionX:Number;
      
      public var CollisionSize:Number;
      
      public var CollideWithTeam:Boolean;
      
      public var ClassType:String;
      
      public var CharType:String;
      
      public var CanShakeCamera:Boolean;
      
      public var Brightness:Number;
      
      public var BaseValues:StatVector;
      
      public var BaseMove:Number;
      
      public var AssetType:String;
      
      public var AssetClassName:String;
      
      public var Ability:uint;
      
      public function GMActor(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            HasOffscreenIndicator = false;
            IsMover = true;
            Release = "D";
            super(jsonAsset);
            if(Reflect.hasField(jsonAsset,"Release"))
            {
               Release = jsonAsset.Release;
            }
            Description = jsonAsset.Description;
            CharType = jsonAsset.CharType;
            ClassType = jsonAsset.ClassType;
            Species = jsonAsset.Species;
            Element = jsonAsset.Element;
            HP = Number(jsonAsset.HP);
            MP = Number(jsonAsset.MP);
            BaseValues = new StatVector();
            BaseValues.SetFromJSON(jsonAsset);
            LevelValues = new StatVector();
            LevelValues.SetFromJSON(jsonAsset,"LV_");
            AssetClassName = jsonAsset.AssetClassName;
            PortraitName = jsonAsset.PortraitName;
            IconSwfFilepath = jsonAsset.IconSwfFilepath;
            mIconName = jsonAsset.IconName;
            SwfFilepath = jsonAsset.SwfFilepath;
            Description = jsonAsset.Description;
            AssetType = jsonAsset.AssetType;
            SpriteWidth = Number(jsonAsset.SpriteWidth);
            SpriteHeight = Number(jsonAsset.SpriteHeight);
            NametagY = Number(jsonAsset.NametagY);
            HealthbarScale = Number(jsonAsset.HealthbarScale);
            IsMover = int(jsonAsset.IsMover) == 1;
            HasOffscreenIndicator = Boolean(jsonAsset.HasOffscreenIndicator);
            Ability = 0;
            Scale = Number(jsonAsset.Scale);
            Hue = Number(jsonAsset.Hue);
            var _loc2_:Number = Number(jsonAsset.Saturation);
            Saturation = _loc2_ > 0 ? (100 + _loc2_) / 100 * 2 : 0;
            Brightness = Number(jsonAsset.Brightness);
            BaseMove = Number(jsonAsset.BaseMove);
            HitSound = jsonAsset.HitSound;
            HitVolume = Number(jsonAsset.HitVol);
            DeathSound = jsonAsset.DeathSound;
            DeathVolume = Number(jsonAsset.DeathVol);
            SpawnEffectClassName = jsonAsset.SpawnEffectClassName;
            SpawnEffectFilePath = jsonAsset.SpawnEffectFilePath;
            CollisionX = Number(jsonAsset.CollisionX);
            CollisionY = Number(jsonAsset.CollisionY);
            CollisionSize = Number(jsonAsset.CollisionSize);
            CollideWithTeam = Boolean(jsonAsset.CollideWithTeam);
            TeleportInTimeline = jsonAsset.TeleportInTimeline;
            TeleportOutTimeline = jsonAsset.TeleportOutTimeline;
            RespawnT = Number(jsonAsset.RespawnT);
            ProjEmitOffset = Number(jsonAsset.ProjEmitOffset);
            scaled_ProjEmitOffset = ProjEmitOffset * Scale;
            DefaultDestruct = jsonAsset.DefaultDestruct;
            CanShakeCamera = Boolean(jsonAsset.CanShakeCamera);
         }
      }
      
      public function get_IconName() : String
      {
         return mIconName;
      }
      
      public function get IconName() : String
      {
         return get_IconName();
      }
   }
}

