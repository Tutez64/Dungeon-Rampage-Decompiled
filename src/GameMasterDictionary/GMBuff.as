package GameMasterDictionary
{
   import DBGlobals.DBGlobal;
   
   public class GMBuff extends GMItem
   {
      
      public var Team:String;
      
      public var Duration:Number;
      
      public var LayerPriority:Number;
      
      public var SwapDisplay:Boolean;
      
      public var Type:String;
      
      public var Ability:uint;
      
      public var DeltaValues:StatVector;
      
      public var Exp:Number;
      
      public var EventExp:Number;
      
      public var Gold:Number;
      
      public var VFX:String;
      
      public var VFXFilepath:String;
      
      public var TintColor:Number;
      
      public var TintAmountF:Number;
      
      public var Description:String;
      
      public var SortLayer:String;
      
      public var BuffFloaterColor:uint;
      
      public var Scale:Number;
      
      public var ScaleStartDelay:Number;
      
      public var ShakeLocalCamera:Boolean;
      
      public var ScaleUpIncrementTime:Number;
      
      public var ScaleUpIncrementScale:Number;
      
      public var ShowInHUD:Boolean;
      
      public var IconSwf:String;
      
      public var IconName:String;
      
      public var DescriptionPercentForEachStack:Number;
      
      public var AttackCooldownMultiplier:Number;
      
      public function GMBuff(jsonAsset:Object)
      {
         super(jsonAsset);
         Team = jsonAsset.Team;
         Duration = jsonAsset.Duration;
         LayerPriority = jsonAsset.LayerPriority;
         SwapDisplay = jsonAsset.SwapDisplay != null;
         Type = jsonAsset.BuffType;
         Ability = 0;
         Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability1);
         Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability2);
         Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability3);
         DeltaValues = new StatVector();
         DeltaValues.SetFromJSON(jsonAsset);
         Exp = jsonAsset.EXP;
         EventExp = jsonAsset.EVENT_EXP;
         Gold = jsonAsset.Gold ? jsonAsset.Gold : 1;
         VFX = jsonAsset.VFX;
         VFXFilepath = jsonAsset.VFXFilepath ? jsonAsset.VFXFilepath : "Resources/Art2D/FX/db_fx_library.swf";
         SortLayer = jsonAsset.SortLayer;
         TintColor = -1;
         TintAmountF = 1;
         var _loc2_:String = jsonAsset.TintColor;
         if(_loc2_ != null)
         {
            TintColor = parseInt(_loc2_,16);
            TintAmountF = jsonAsset.TintAmount;
         }
         Description = jsonAsset.Description;
         BuffFloaterColor = jsonAsset.BuffFloaterColor;
         Scale = jsonAsset.Scale;
         ShakeLocalCamera = jsonAsset.ShakeLocalCamera;
         ScaleStartDelay = jsonAsset.ScaleUpStartDelay;
         ScaleUpIncrementTime = jsonAsset.ScaleUpIncrementTime;
         ScaleUpIncrementScale = jsonAsset.ScaleUpIncrementScale;
         ShowInHUD = jsonAsset.ShowInHUD;
         IconSwf = jsonAsset.IconSwf;
         IconName = jsonAsset.IconName;
         DescriptionPercentForEachStack = jsonAsset.DescriptionPercentForEachStack ? jsonAsset.DescriptionPercentForEachStack : 0;
         AttackCooldownMultiplier = 1;
         if(jsonAsset.AttackCooldownMultiplier != null)
         {
            AttackCooldownMultiplier = jsonAsset.AttackCooldownMultiplier;
         }
      }
      
      public function getStacksDescription(stacks:int) : String
      {
         var _loc2_:Number = DescriptionPercentForEachStack * stacks;
         if(_loc2_ > 0)
         {
            return _loc2_.toString() + "%";
         }
         return "";
      }
   }
}

