package GameMasterDictionary
{
   import DBGlobals.As3Compat;
   import DBGlobals.DBGlobal;
   import flash.Boot;
   
   public class GMBuff extends GMItem
   {
      
      public var VFXFilepath:String;
      
      public var VFX:String;
      
      public var Type:String;
      
      public var TintColor:Number;
      
      public var TintAmountF:Number;
      
      public var Team:String;
      
      public var SwapDisplay:Boolean;
      
      public var SortLayer:String;
      
      public var ShowInHUD:Boolean;
      
      public var ShakeLocalCamera:Boolean;
      
      public var ScaleUpIncrementTime:Number;
      
      public var ScaleUpIncrementScale:Number;
      
      public var ScaleStartDelay:Number;
      
      public var Scale:Number;
      
      public var LayerPriority:Number;
      
      public var IconSwf:String;
      
      public var IconName:String;
      
      public var Gold:Number;
      
      public var Exp:Number;
      
      public var EventExp:Number;
      
      public var Duration:Number;
      
      public var DescriptionPercentForEachStack:Number;
      
      public var Description:String;
      
      public var DeltaValues:StatVector;
      
      public var BuffFloaterColor:uint;
      
      public var AttackCooldownMultiplier:Number;
      
      public var Ability:uint;
      
      public function GMBuff(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            Team = jsonAsset.Team;
            Duration = Number(jsonAsset.Duration);
            LayerPriority = Number(jsonAsset.LayerPriority);
            SwapDisplay = jsonAsset.SwapDisplay != null;
            Type = jsonAsset.BuffType;
            Ability = 0;
            Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability1);
            Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability2);
            Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability3);
            DeltaValues = new StatVector();
            DeltaValues.SetFromJSON(jsonAsset);
            Exp = Number(jsonAsset.EXP);
            EventExp = Number(jsonAsset.EVENT_EXP);
            Gold = As3Compat.truthy(jsonAsset.Gold) ? Number(jsonAsset.Gold) : 1;
            VFX = jsonAsset.VFX;
            VFXFilepath = As3Compat.truthy(jsonAsset.VFXFilepath) ? jsonAsset.VFXFilepath : "Resources/Art2D/FX/db_fx_library.swf";
            SortLayer = jsonAsset.SortLayer;
            TintColor = -1;
            TintAmountF = 1;
            var _loc2_:String = jsonAsset.TintColor;
            if(_loc2_ != null)
            {
               TintColor = As3Compat.parseHex(_loc2_);
               TintAmountF = jsonAsset.TintAmount;
            }
            Description = jsonAsset.Description;
            BuffFloaterColor = uint(jsonAsset.BuffFloaterColor);
            Scale = Number(jsonAsset.Scale);
            ShakeLocalCamera = Boolean(jsonAsset.ShakeLocalCamera);
            ScaleStartDelay = Number(jsonAsset.ScaleUpStartDelay);
            ScaleUpIncrementTime = Number(jsonAsset.ScaleUpIncrementTime);
            ScaleUpIncrementScale = Number(jsonAsset.ScaleUpIncrementScale);
            ShowInHUD = Boolean(jsonAsset.ShowInHUD);
            IconSwf = jsonAsset.IconSwf;
            IconName = jsonAsset.IconName;
            DescriptionPercentForEachStack = As3Compat.truthy(jsonAsset.DescriptionPercentForEachStack) ? Number(jsonAsset.DescriptionPercentForEachStack) : 0;
            AttackCooldownMultiplier = 1;
            if(jsonAsset.AttackCooldownMultiplier != null)
            {
               AttackCooldownMultiplier = jsonAsset.AttackCooldownMultiplier;
            }
         }
      }
      
      public function getStacksDescription(stacks:int) : String
      {
         var _loc2_:Number = DescriptionPercentForEachStack * stacks;
         if(_loc2_ > 0)
         {
            return "" + _loc2_ + "%";
         }
         return "";
      }
   }
}

