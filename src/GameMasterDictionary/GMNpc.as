package GameMasterDictionary
{
   import DBGlobals.DBGlobal;
   
   public class GMNpc extends GMActor
   {
      
      public var IsNavigable:Boolean;
      
      public var IsAttackable:Boolean;
      
      public var HasHealthbar:Boolean;
      
      public var UsePetUI:Boolean;
      
      public var IsBoss:Boolean;
      
      public var ActivateSound:String;
      
      public var ActivateVolume:Number;
      
      public var DeactivateSound:String;
      
      public var DeactivateVolume:Number;
      
      public var DefaultHeading:int;
      
      public var DefaultLayer:String;
      
      public var UseFlashRotation:Boolean;
      
      public var PermCorpse:Boolean;
      
      public var ArchwayAlpha:Boolean;
      
      public var ViolentDeathClassName:String;
      
      public var ViolentDeathFilePath:String;
      
      public var BlockingDotProduct:Number;
      
      public var SellCoins:int;
      
      public var AttackRating:uint;
      
      public var DefenseRating:uint;
      
      public var SpeedRating:uint;
      
      public var TileTheme:String;
      
      public var UseTeleportAI:Boolean;
      
      public var ShowHealNumbers:Boolean;
      
      public function GMNpc(jsonAsset:Object)
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
         SellCoins = jsonAsset.SellCoin;
         AttackRating = jsonAsset.AttackRating;
         DefenseRating = jsonAsset.DefenseRating;
         SpeedRating = jsonAsset.SpeedRating;
         IsNavigable = jsonAsset.IsNavigable == 1;
         if(Constant == "GARLIC_PLACEABLE_L2")
         {
            IsNavigable = true;
         }
         IsAttackable = jsonAsset.IsAttackable == 1;
         IsBoss = jsonAsset.IsBoss == 1;
         HasHealthbar = jsonAsset.HasHealthbar;
         UsePetUI = jsonAsset.UsePetUI;
         UseTeleportAI = jsonAsset.Aggro_AI_Type == "TELEPORT_AI";
         ActivateSound = jsonAsset.ActivateSound;
         ActivateVolume = jsonAsset.ActivateVol;
         DeactivateSound = jsonAsset.DeactivateSound;
         DeactivateVolume = jsonAsset.DeactivateVol;
         DefaultHeading = jsonAsset.DefaultHeading;
         DefaultLayer = jsonAsset.DefaultLayer;
         TileTheme = jsonAsset.TileTheme;
         UseFlashRotation = jsonAsset.UseFlashRotation;
         PermCorpse = jsonAsset.PermCorpse;
         ArchwayAlpha = jsonAsset.ArchwayAlpha;
         ViolentDeathClassName = jsonAsset.ViolentDeathClassName;
         ViolentDeathFilePath = jsonAsset.ViolentDeathFilePath;
         BlockingDotProduct = jsonAsset.BlockingDotProduct;
         ShowHealNumbers = jsonAsset.ShowHealNumbers;
      }
      
      public function blocksNatively() : Boolean
      {
         return BlockingDotProduct > -1.1;
      }
   }
}

