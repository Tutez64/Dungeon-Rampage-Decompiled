package GameMasterDictionary
{
   import DBGlobals.As3Compat;
   import flash.Boot;
   
   public class GMProjectile extends GMItem
   {
      
      public var TrailTint:Number;
      
      public var TrailSaturation:Number;
      
      public var Tint:Number;
      
      public var SwfFilepath:String;
      
      public var SteeringRate:Number;
      
      public var Saturation:Number;
      
      public var RotationSpeedF:Number;
      
      public var Range:Number;
      
      public var Proj_AOE:Number;
      
      public var ProjSpeedF:Number;
      
      public var ProjModel:String;
      
      public var OnImpactVFX:String;
      
      public var OnImpactNPC:String;
      
      public var OnDeathNPC:String;
      
      public var NumChains:uint;
      
      public var NumBranches:uint;
      
      public var NoGenerations:Boolean;
      
      public var NoFade:Boolean;
      
      public var MaxCollisions:uint;
      
      public var Lifetime:uint;
      
      public var ImpactVolume:Number;
      
      public var ImpactSound:String;
      
      public var IgnoreWalls:Boolean;
      
      public var IgnoreGlow:Boolean;
      
      public var HomingDistWeight:Number;
      
      public var HomingAngleWeight:Number;
      
      public var HitsPerActor:Number;
      
      public var HitRecurDelay:Number;
      
      public var FlightPattern:String;
      
      public var Element:String;
      
      public var CyclicChains:Boolean;
      
      public var CollisionSize:Number;
      
      public var ClassType:String;
      
      public var ChainDist:Number;
      
      public function GMProjectile(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            ClassType = jsonAsset.ClassType;
            Element = jsonAsset.Element;
            FlightPattern = jsonAsset.FlightPattern;
            Range = Number(jsonAsset.Range);
            CollisionSize = Number(jsonAsset.CollisionSize);
            HitsPerActor = Number(jsonAsset.HitsPerActor);
            MaxCollisions = uint(jsonAsset.MaxCollisions);
            HitRecurDelay = Number(jsonAsset.HitRecurDelay);
            NoGenerations = Boolean(jsonAsset.NoGenerations);
            ProjSpeedF = Number(jsonAsset.ProjSpeed);
            RotationSpeedF = Number(jsonAsset.RotationSpeed);
            Proj_AOE = Number(jsonAsset.Proj_AOE);
            OnImpactNPC = jsonAsset.OnImpactNPC;
            OnImpactVFX = jsonAsset.OnImpactVFX;
            OnDeathNPC = jsonAsset.OnDeathNPC;
            NumChains = uint(jsonAsset.NumChains);
            ChainDist = Number(jsonAsset.ChainDist);
            CyclicChains = Boolean(jsonAsset.CyclicChains);
            NumBranches = uint(jsonAsset.NumBranches);
            HomingDistWeight = Reflect.hasField(jsonAsset,"HomingDistWeight") ? Number(jsonAsset.HomingDistWeight) : 1;
            HomingAngleWeight = Reflect.hasField(jsonAsset,"HomingAngleWeight") ? Number(jsonAsset.HomingAngleWeight) : 1;
            SteeringRate = Reflect.hasField(jsonAsset,"SteeringRate") ? Number(jsonAsset.SteeringRate) : 1;
            Lifetime = Reflect.hasField(jsonAsset,"Lifetime") ? uint(int(As3Compat.toFloat(jsonAsset.Lifetime) * 1000)) : 1000;
            NoFade = Reflect.hasField(jsonAsset,"NoFade") && As3Compat.truthy(jsonAsset.NoFade);
            IgnoreWalls = Reflect.hasField(jsonAsset,"IgnoreWalls");
            Tint = Number(jsonAsset.Tint);
            var _loc2_:Number = Number(jsonAsset.Saturation);
            Saturation = _loc2_ / 100 + 1;
            TrailTint = Number(jsonAsset.TrailTint);
            var _loc3_:Number = Number(jsonAsset.TrailSaturation);
            TrailSaturation = _loc3_ / 100 + 1;
            ProjModel = jsonAsset.ProjModel;
            SwfFilepath = jsonAsset.SwfFilepath;
            ImpactSound = jsonAsset.ImpactSound;
            ImpactVolume = Number(jsonAsset.ImpactVol);
            IgnoreGlow = Boolean(jsonAsset.IgnoreGlow);
         }
      }
   }
}

