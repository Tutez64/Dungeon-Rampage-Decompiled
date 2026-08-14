package GameMasterDictionary
{
   import Brain.Logger.Logger;
   
   public class GMAttack extends GMItem
   {
      
      public static const g_melee:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(8,2,5,0);
      
      public static const g_range:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(9,3,6,1);
      
      public static const g_magic:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(10,4,7,2);
      
      public var Team:String;
      
      public var WeaponReq:String;
      
      public var AttackType:String;
      
      public var AffectsOthers:Boolean;
      
      public var AffectsProps:Boolean;
      
      public var AffectsSelf:Boolean;
      
      public var Targeting:String;
      
      public var CombatUsage:String;
      
      public var LineOfSightReq:Number;
      
      public var UseAutoAim:Boolean;
      
      public var AttackTimeline:String;
      
      public var DamageMod:Number;
      
      public var StunChance:Number;
      
      public var HitStunDur:Number;
      
      public var InvincibleDur:Number;
      
      public var Knockback:Number;
      
      public var KnockbackDur:Number;
      
      public var AttackSpdF:Number;
      
      public var Range:Number;
      
      public var Defense:Number;
      
      public var Projectile:String;
      
      public var ChargeTime:Number;
      
      public var CooldownLength:Number;
      
      public var LockControls:Number;
      
      public var StrafeControls:Number;
      
      public var HitsPerCollision:Number;
      
      public var MoveAmount:Number;
      
      public var MoveAngle:Number;
      
      public var MoveDuration:Number;
      
      public var AIRechargeT:Number;
      
      public var SwordTrail:String;
      
      public var SwordTrailSizeF:Number;
      
      public var TrailTint:Number;
      
      public var TrailSaturation:Number;
      
      public var HitEffect:String;
      
      public var HitEffectFilepath:String;
      
      public var HitEffectStopRotation:Boolean;
      
      public var HitEffectBehindAvatar:Boolean;
      
      public var HitEffectLerpFilepath:String;
      
      public var HitEffectToLerpToAttacker:String;
      
      public var HitEffectToLerpFromAttacker:String;
      
      public var HitEffectToLerpSpeed:Number;
      
      public var HitEffectToLerpGlowColor:uint;
      
      public var AttackSound:String;
      
      public var AttackVolume:Number;
      
      public var ImpactSound:String;
      
      public var ImpactVolume:Number;
      
      public var Description:String;
      
      public var ComboWindow:Number;
      
      public var RecoveryTime:Number;
      
      public var IconFilepath:String;
      
      public var IconName:String;
      
      public var ManaCost:Number;
      
      public var StatOffsets:GMAttack_StateVectorOffsets;
      
      public var CrowdCost:uint;
      
      public var Unblockable:Boolean;
      
      public var SpawnNPC:String;
      
      public var SetTeleport:Boolean;
      
      public var AttackOnHit:String;
      
      public function GMAttack(jsonAsset:Object)
      {
         super(jsonAsset);
         Team = jsonAsset.Team;
         WeaponReq = jsonAsset.WeaponReq;
         AttackType = jsonAsset.AttackType;
         Targeting = jsonAsset.Targeting;
         AffectsOthers = jsonAsset.AffectsOthers;
         AffectsProps = jsonAsset.AffectsProps;
         AffectsSelf = jsonAsset.AffectsSelf;
         CombatUsage = jsonAsset.CombatUsage;
         LineOfSightReq = jsonAsset.LineOfSightReq;
         UseAutoAim = jsonAsset.UseAutoAim;
         AttackTimeline = jsonAsset.AttackTimeline;
         DamageMod = jsonAsset.DamageMod;
         StunChance = jsonAsset.StunChance;
         HitStunDur = jsonAsset.HitStunDur;
         InvincibleDur = jsonAsset.InvincibleDur;
         Knockback = jsonAsset.Knockback;
         KnockbackDur = jsonAsset.KnockbackDur;
         AttackSpdF = jsonAsset.AttackSpd;
         Range = jsonAsset.Range;
         Defense = jsonAsset.Defense;
         Projectile = jsonAsset.Projectile;
         ChargeTime = jsonAsset.ChargeTime;
         CooldownLength = jsonAsset.CooldownLength;
         LockControls = jsonAsset.LockControls;
         StrafeControls = jsonAsset.StrafeControls;
         HitsPerCollision = jsonAsset.HitsPerCollision;
         MoveAmount = jsonAsset.MoveAmount;
         MoveAngle = jsonAsset.MoveAngle;
         MoveDuration = jsonAsset.MoveDuration;
         AIRechargeT = jsonAsset.AI_RechargeT;
         SwordTrail = jsonAsset.SwordTrail;
         TrailTint = jsonAsset.TrailTint;
         TrailSaturation = jsonAsset.TrailSaturation / 100 + 1;
         HitEffect = jsonAsset.HitEffect;
         HitEffectStopRotation = jsonAsset.HitEffectStopRotation;
         HitEffectFilepath = jsonAsset.HitEffectFilepath ? jsonAsset.HitEffectFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         HitEffectBehindAvatar = jsonAsset.HitEffectBehindAvatar ? jsonAsset.HitEffectBehindAvatar : false;
         HitEffectLerpFilepath = jsonAsset.HitEffectLerpFilepath ? jsonAsset.HitEffectLerpFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         HitEffectToLerpToAttacker = jsonAsset.HitEffectToLerpToAttacker;
         HitEffectToLerpFromAttacker = jsonAsset.HitEffectToLerpFromAttacker;
         HitEffectToLerpSpeed = jsonAsset.HitEffectToLerpSpeed;
         HitEffectToLerpGlowColor = jsonAsset.HitEffectToLerpGlowColor;
         AttackSound = jsonAsset.AttackSound;
         AttackVolume = jsonAsset.AttackVol;
         ImpactSound = jsonAsset.ImpactSound;
         ImpactVolume = jsonAsset.ImpactVol;
         Description = jsonAsset.Description;
         ComboWindow = jsonAsset.ComboWindow;
         RecoveryTime = jsonAsset.RecoveryTime;
         ManaCost = jsonAsset.ManaCost;
         IconFilepath = jsonAsset.IconFilepath;
         IconName = jsonAsset.IconName;
         CrowdCost = jsonAsset.CrowdCost;
         Unblockable = jsonAsset.Unblockable;
         SpawnNPC = jsonAsset.SpawnNPC;
         SetTeleport = jsonAsset.SetTeleport;
         AttackOnHit = jsonAsset.AttackOnHit;
         switch(AttackType)
         {
            case "MELEE":
               StatOffsets = g_melee;
               break;
            case "SHOOTING":
               StatOffsets = g_range;
               break;
            case "MAGIC":
               StatOffsets = g_magic;
               break;
            case "SUPPORT":
            case "ANIMATION":
               break;
            default:
               Logger.warn("GMAttack: unknown AttackType: " + AttackType);
         }
      }
   }
}

