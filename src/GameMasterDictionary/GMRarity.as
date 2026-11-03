package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMRarity
   {
      
      public var Type:String;
      
      public var TextColor:uint;
      
      public var NumberOfModifiers:uint;
      
      public var ModifierWeight:Number;
      
      public var MinSellPercent:Number;
      
      public var MinModifierLevel:uint;
      
      public var MaxSellPercent:Number;
      
      public var MaxModifierLevel:uint;
      
      public var LevelWeight:Number;
      
      public var KeyOfferId:Number;
      
      public var Id:uint;
      
      public var HasGlow:Boolean;
      
      public var HasColoredBackground:Boolean;
      
      public var GlowStr:uint;
      
      public var GlowDist:uint;
      
      public var GlowColor:uint;
      
      public var Constant:String;
      
      public var BasePowerScale:Number;
      
      public var BasePowerConstant:Number;
      
      public var BackgroundSwf:String;
      
      public var BackgroundIconBorder:String;
      
      public var BackgroundIcon:String;
      
      public function GMRarity(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Id = uint(jsonAsset.Id);
         KeyOfferId = Number(jsonAsset.KeyOfferId);
         Type = jsonAsset.Type;
         Constant = Type;
         NumberOfModifiers = uint(jsonAsset.NumberOfModifiers);
         HasColoredBackground = Boolean(jsonAsset.HasColoredBackground);
         MaxModifierLevel = uint(jsonAsset.MaxModifierLevel);
         MinModifierLevel = uint(jsonAsset.MinModifierLevel);
         MinSellPercent = Number(jsonAsset.MinSellPercent);
         MaxSellPercent = Number(jsonAsset.MaxSellPercent);
         LevelWeight = Number(jsonAsset.LevelWeight);
         ModifierWeight = Number(jsonAsset.ModifierWeight);
         HasGlow = Boolean(jsonAsset.HasGlow);
         GlowColor = uint(jsonAsset.GlowColor);
         TextColor = uint(jsonAsset.TextColor);
         GlowDist = uint(jsonAsset.GlowDist);
         GlowStr = uint(jsonAsset.GlowStr);
         BasePowerScale = Number(jsonAsset.BasePowerScale);
         BasePowerConstant = Number(jsonAsset.BasePowerConstant);
         if(HasColoredBackground)
         {
            BackgroundIcon = jsonAsset.BackgroundIcon;
            BackgroundIconBorder = jsonAsset.BackgroundIconBorder != null ? jsonAsset.BackgroundIconBorder : "";
            BackgroundSwf = jsonAsset.BackgroundSwf;
         }
      }
   }
}

