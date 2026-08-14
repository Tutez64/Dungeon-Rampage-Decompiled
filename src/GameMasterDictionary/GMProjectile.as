package GameMasterDictionary
{
   public class GMProjectile extends GMItem
   {
      
      public var ClassType:String;
      
      public var Element:String;
      
      public var FlightPattern:String;
      
      public var Range:Number;
      
      public var CollisionSize:Number;
      
      public var HitsPerActor:Number;
      
      public var HitRecurDelay:Number;
      
      public var MaxCollisions:uint;
      
      public var NoGenerations:Boolean;
      
      public var ProjSpeedF:Number;
      
      public var RotationSpeedF:Number;
      
      public var Proj_AOE:Number;
      
      public var OnImpactNPC:String;
      
      public var OnDeathNPC:String;
      
      public var OnImpactVFX:String;
      
      public var NumChains:uint;
      
      public var ChainDist:Number;
      
      public var CyclicChains:Boolean;
      
      public var NumBranches:uint;
      
      public var HomingDistWeight:Number;
      
      public var HomingAngleWeight:Number;
      
      public var SteeringRate:Number;
      
      public var Lifetime:uint;
      
      public var SwfFilepath:String;
      
      public var ImpactSound:String;
      
      public var ImpactVolume:Number;
      
      public var NoFade:Boolean;
      
      public var IgnoreWalls:Boolean;
      
      public var Tint:Number;
      
      public var Saturation:Number;
      
      public var TrailTint:Number;
      
      public var TrailSaturation:Number;
      
      public var ProjModel:String;
      
      public var IgnoreGlow:Boolean;
      
      public function GMProjectile(jsonAsset:Object)
      {
         super(jsonAsset);
         ClassType = jsonAsset.ClassType;
         Element = jsonAsset.Element;
         FlightPattern = jsonAsset.FlightPattern;
         Range = jsonAsset.Range;
         CollisionSize = jsonAsset.CollisionSize;
         HitsPerActor = jsonAsset.HitsPerActor;
         MaxCollisions = jsonAsset.MaxCollisions;
         HitRecurDelay = jsonAsset.HitRecurDelay;
         NoGenerations = jsonAsset.NoGenerations;
         ProjSpeedF = jsonAsset.ProjSpeed;
         RotationSpeedF = jsonAsset.RotationSpeed;
         Proj_AOE = jsonAsset.Proj_AOE;
         OnImpactNPC = jsonAsset.OnImpactNPC;
         OnImpactVFX = jsonAsset.OnImpactVFX;
         OnDeathNPC = jsonAsset.OnDeathNPC;
         NumChains = jsonAsset.NumChains;
         ChainDist = jsonAsset.ChainDist;
         CyclicChains = jsonAsset.CyclicChains;
         NumBranches = jsonAsset.NumBranches;
         HomingDistWeight = jsonAsset.hasOwnProperty("HomingDistWeight") ? jsonAsset.HomingDistWeight : 1;
         HomingAngleWeight = jsonAsset.hasOwnProperty("HomingAngleWeight") ? jsonAsset.HomingAngleWeight : 1;
         SteeringRate = jsonAsset.hasOwnProperty("SteeringRate") ? jsonAsset.SteeringRate : 1;
         Lifetime = jsonAsset.hasOwnProperty("Lifetime") ? Number(jsonAsset.Lifetime) * 1000 : 1000;
         NoFade = jsonAsset.hasOwnProperty("NoFade") ? Boolean(jsonAsset.NoFade) : false;
         IgnoreWalls = jsonAsset.hasOwnProperty("IgnoreWalls") ? true : false;
         Tint = jsonAsset.Tint;
         Saturation = jsonAsset.Saturation / 100 + 1;
         TrailTint = jsonAsset.TrailTint;
         TrailSaturation = jsonAsset.TrailSaturation / 100 + 1;
         ProjModel = jsonAsset.ProjModel;
         SwfFilepath = jsonAsset.SwfFilepath;
         ImpactSound = jsonAsset.ImpactSound;
         ImpactVolume = jsonAsset.ImpactVol;
         IgnoreGlow = jsonAsset.IgnoreGlow;
      }
   }
}

