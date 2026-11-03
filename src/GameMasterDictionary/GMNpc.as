package GameMasterDictionary
{
   import DBGlobals.DBGlobal;
   import flash.Boot;
   
   public class GMNpc extends GMActor
   {
      
      public var ViolentDeathFilePath:String;
      
      public var ViolentDeathClassName:String;
      
      public var UseTeleportAI:Boolean;
      
      public var UsePetUI:Boolean;
      
      public var UseFlashRotation:Boolean;
      
      public var TileTheme:String;
      
      public var SpeedRating:uint;
      
      public var ShowHealNumbers:Boolean;
      
      public var SellCoins:int;
      
      public var PermCorpse:Boolean;
      
      public var IsNavigable:Boolean;
      
      public var IsBoss:Boolean;
      
      public var IsAttackable:Boolean;
      
      public var HasHealthbar:Boolean;
      
      public var DefenseRating:uint;
      
      public var DefaultLayer:String;
      
      public var DefaultHeading:int;
      
      public var DeactivateVolume:Number;
      
      public var DeactivateSound:String;
      
      public var BlockingDotProduct:Number;
      
      public var AttackRating:uint;
      
      public var ArchwayAlpha:Boolean;
      
      public var ActivateVolume:Number;
      
      public var ActivateSound:String;
      
      public function GMNpc(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            if(jsonAsset.Ability1 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability1);
            }
            if(jsonAsset.Ability2 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability2);
            }
            if(jsonAsset.Ability3 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability3);
            }
            if(jsonAsset.Ability4 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability4);
            }
            if(jsonAsset.Ability5 != null)
            {
               Ability |= DBGlobal.mapAbilityMask(jsonAsset.Ability5);
            }
            Weapon1 = jsonAsset.Weapon1;
            Weapon2 = jsonAsset.Weapon2;
            Weapon3 = jsonAsset.Weapon3;
            Weapon4 = jsonAsset.Weapon4;
            Weapon5 = jsonAsset.Weapon5;
            SellCoins = int(jsonAsset.SellCoin);
            AttackRating = uint(jsonAsset.AttackRating);
            DefenseRating = uint(jsonAsset.DefenseRating);
            SpeedRating = uint(jsonAsset.SpeedRating);
            IsNavigable = int(jsonAsset.IsNavigable) == 1;
            if(Constant == "GARLIC_PLACEABLE_L2")
            {
               IsNavigable = true;
            }
            IsAttackable = int(jsonAsset.IsAttackable) == 1;
            IsBoss = int(jsonAsset.IsBoss) == 1;
            HasHealthbar = Boolean(jsonAsset.HasHealthbar);
            UsePetUI = Boolean(jsonAsset.UsePetUI);
            UseTeleportAI = jsonAsset.Aggro_AI_Type == "TELEPORT_AI";
            ActivateSound = jsonAsset.ActivateSound;
            ActivateVolume = Number(jsonAsset.ActivateVol);
            DeactivateSound = jsonAsset.DeactivateSound;
            DeactivateVolume = Number(jsonAsset.DeactivateVol);
            DefaultHeading = int(jsonAsset.DefaultHeading);
            DefaultLayer = jsonAsset.DefaultLayer;
            TileTheme = jsonAsset.TileTheme;
            UseFlashRotation = Boolean(jsonAsset.UseFlashRotation);
            PermCorpse = Boolean(jsonAsset.PermCorpse);
            ArchwayAlpha = Boolean(jsonAsset.ArchwayAlpha);
            ViolentDeathClassName = jsonAsset.ViolentDeathClassName;
            ViolentDeathFilePath = jsonAsset.ViolentDeathFilePath;
            BlockingDotProduct = Number(jsonAsset.BlockingDotProduct);
            ShowHealNumbers = Boolean(jsonAsset.ShowHealNumbers);
         }
      }
      
      public function blocksNatively() : Boolean
      {
         return BlockingDotProduct > -1.1;
      }
   }
}

