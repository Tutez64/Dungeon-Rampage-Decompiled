package GameMasterDictionary
{
   import Brain.Logger.Logger;
   import DBGlobals.As3Compat;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   
   public class GMAttack extends GMItem
   {
      
      public static var g_melee:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.MELEE_SPD,DBGlobal.MELEE_ATK,DBGlobal.MELEE_DEF,DBGlobal.ATTTACK_TYPE_MELEE);
      
      public static var g_range:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.SHOOT_SPD,DBGlobal.SHOOT_ATK,DBGlobal.SHOOT_DEF,DBGlobal.ATTTACK_TYPE_RANGE);
      
      public static var g_magic:GMAttack_StateVectorOffsets = new GMAttack_StateVectorOffsets(DBGlobal.MAGIC_SPD,DBGlobal.MAGIC_ATK,DBGlobal.MAGIC_DEF,DBGlobal.ATTTACK_TYPE_MAGIC);
      
      public var WeaponReq:String;
      
      public var UseAutoAim:Boolean;
      
      public var Unblockable:Boolean;
      
      public var TrailTint:Number;
      
      public var TrailSaturation:Number;
      
      public var Team:String;
      
      public var Targeting:String;
      
      public var SwordTrailSizeF:Number;
      
      public var SwordTrail:String;
      
      public var StunChance:Number;
      
      public var StrafeControls:Number;
      
      public var StatOffsets:GMAttack_StateVectorOffsets;
      
      public var SpawnNPC:String;
      
      public var SetTeleport:Boolean;
      
      public var RecoveryTime:Number;
      
      public var Range:Number;
      
      public var Projectile:String;
      
      public var MoveDuration:Number;
      
      public var MoveAngle:Number;
      
      public var MoveAmount:Number;
      
      public var ManaCost:Number;
      
      public var LockControls:Number;
      
      public var LineOfSightReq:Number;
      
      public var KnockbackDur:Number;
      
      public var Knockback:Number;
      
      public var InvincibleDur:Number;
      
      public var ImpactVolume:Number;
      
      public var ImpactSound:String;
      
      public var IconName:String;
      
      public var IconFilepath:String;
      
      public var HitsPerCollision:Number;
      
      public var HitStunDur:Number;
      
      public var HitEffectToLerpToAttacker:String;
      
      public var HitEffectToLerpSpeed:Number;
      
      public var HitEffectToLerpGlowColor:uint;
      
      public var HitEffectToLerpFromAttacker:String;
      
      public var HitEffectStopRotation:Boolean;
      
      public var HitEffectLerpFilepath:String;
      
      public var HitEffectFilepath:String;
      
      public var HitEffectBehindAvatar:Boolean;
      
      public var HitEffect:String;
      
      public var Description:String;
      
      public var Defense:Number;
      
      public var DamageMod:Number;
      
      public var CrowdCost:uint;
      
      public var CooldownLength:Number;
      
      public var ComboWindow:Number;
      
      public var CombatUsage:String;
      
      public var ChargeTime:Number;
      
      public var AttackVolume:Number;
      
      public var AttackType:String;
      
      public var AttackTimeline:String;
      
      public var AttackSpdF:Number;
      
      public var AttackSound:String;
      
      public var AttackOnHit:String;
      
      public var AffectsSelf:Boolean;
      
      public var AffectsProps:Boolean;
      
      public var AffectsOthers:Boolean;
      
      public var AIRechargeT:Number;
      
      public function GMAttack(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Team = jsonAsset.Team;
            WeaponReq = jsonAsset.WeaponReq;
            AttackType = jsonAsset.AttackType;
            Targeting = jsonAsset.Targeting;
            AffectsOthers = Boolean(jsonAsset.AffectsOthers);
            AffectsProps = Boolean(jsonAsset.AffectsProps);
            AffectsSelf = Boolean(jsonAsset.AffectsSelf);
            CombatUsage = jsonAsset.CombatUsage;
            LineOfSightReq = Number(jsonAsset.LineOfSightReq);
            UseAutoAim = Boolean(jsonAsset.UseAutoAim);
            AttackTimeline = jsonAsset.AttackTimeline;
            DamageMod = Number(jsonAsset.DamageMod);
            StunChance = Number(jsonAsset.StunChance);
            HitStunDur = Number(jsonAsset.HitStunDur);
            InvincibleDur = Number(jsonAsset.InvincibleDur);
            Knockback = Number(jsonAsset.Knockback);
            KnockbackDur = Number(jsonAsset.KnockbackDur);
            AttackSpdF = Number(jsonAsset.AttackSpd);
            Range = Number(jsonAsset.Range);
            Defense = Number(jsonAsset.Defense);
            Projectile = jsonAsset.Projectile;
            ChargeTime = Number(jsonAsset.ChargeTime);
            CooldownLength = Number(jsonAsset.CooldownLength);
            LockControls = Number(jsonAsset.LockControls);
            StrafeControls = Number(jsonAsset.StrafeControls);
            HitsPerCollision = Number(jsonAsset.HitsPerCollision);
            MoveAmount = Number(jsonAsset.MoveAmount);
            MoveAngle = Number(jsonAsset.MoveAngle);
            MoveDuration = Number(jsonAsset.MoveDuration);
            AIRechargeT = Number(jsonAsset.AI_RechargeT);
            SwordTrail = jsonAsset.SwordTrail;
            TrailTint = Number(jsonAsset.TrailTint);
            var _loc2_:Number = Number(jsonAsset.TrailSaturation);
            TrailSaturation = _loc2_ / 100 + 1;
            HitEffect = jsonAsset.HitEffect;
            HitEffectStopRotation = Boolean(jsonAsset.HitEffectStopRotation);
            HitEffectFilepath = As3Compat.truthy(jsonAsset.HitEffectFilepath) ? jsonAsset.HitEffectFilepath : "Resources/Art2D/FX/db_fx_library.swf";
            HitEffectBehindAvatar = As3Compat.truthy(jsonAsset.HitEffectBehindAvatar) && Boolean(jsonAsset.HitEffectBehindAvatar);
            HitEffectLerpFilepath = As3Compat.truthy(jsonAsset.HitEffectLerpFilepath) ? jsonAsset.HitEffectLerpFilepath : "Resources/Art2D/FX/db_fx_library.swf";
            HitEffectToLerpToAttacker = jsonAsset.HitEffectToLerpToAttacker;
            HitEffectToLerpFromAttacker = jsonAsset.HitEffectToLerpFromAttacker;
            HitEffectToLerpSpeed = Number(jsonAsset.HitEffectToLerpSpeed);
            HitEffectToLerpGlowColor = uint(jsonAsset.HitEffectToLerpGlowColor);
            AttackSound = jsonAsset.AttackSound;
            AttackVolume = Number(jsonAsset.AttackVol);
            ImpactSound = jsonAsset.ImpactSound;
            ImpactVolume = Number(jsonAsset.ImpactVol);
            Description = jsonAsset.Description;
            ComboWindow = Number(jsonAsset.ComboWindow);
            RecoveryTime = Number(jsonAsset.RecoveryTime);
            ManaCost = Number(jsonAsset.ManaCost);
            IconFilepath = jsonAsset.IconFilepath;
            IconName = jsonAsset.IconName;
            CrowdCost = uint(jsonAsset.CrowdCost);
            Unblockable = Boolean(jsonAsset.Unblockable);
            SpawnNPC = jsonAsset.SpawnNPC;
            SetTeleport = Boolean(jsonAsset.SetTeleport);
            AttackOnHit = jsonAsset.AttackOnHit;
            var _loc3_:String = AttackType;
            while(true)
            {
               if(_loc3_ != "ANIMATION")
               {
                  if(_loc3_ != "SUPPORT")
                  {
                     if(_loc3_ == "MAGIC")
                     {
                        StatOffsets = GMAttack.g_magic;
                        break;
                     }
                     if(_loc3_ == "MELEE")
                     {
                        StatOffsets = GMAttack.g_melee;
                        break;
                     }
                     if(_loc3_ == "SHOOTING")
                     {
                        StatOffsets = GMAttack.g_range;
                        break;
                     }
                     Logger.warn("GMAttack: unknown AttackType: " + AttackType);
                     break;
                  }
               }
               break;
            }
         }
      }
   }
}

