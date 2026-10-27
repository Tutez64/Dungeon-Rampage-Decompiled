package GameMasterDictionary
{
   public class GMRarity
   {
      
      public var Id:uint;
      
      public var Constant:String;
      
      public var Type:String;
      
      public var NumberOfModifiers:uint;
      
      public var MaxModifierLevel:uint;
      
      public var MinModifierLevel:uint;
      
      public var HasColoredBackground:Boolean;
      
      public var BackgroundIcon:String;
      
      public var BackgroundIconBorder:String;
      
      public var BackgroundSwf:String;
      
      public var KeyOfferId:Number;
      
      public var MinSellPercent:Number;
      
      public var MaxSellPercent:Number;
      
      public var LevelWeight:Number;
      
      public var ModifierWeight:Number;
      
      public var BasePowerScale:Number;
      
      public var BasePowerConstant:Number;
      
      public var HasGlow:Boolean;
      
      public var GlowColor:uint;
      
      public var GlowStr:uint;
      
      public var GlowDist:uint;
      
      public var TextColor:uint;
      
      public function GMRarity(jsonAsset:Object)
      {
         super();
         Id = jsonAsset.Id;
         KeyOfferId = jsonAsset.KeyOfferId;
         Constant = Type = jsonAsset.Type;
         NumberOfModifiers = jsonAsset.NumberOfModifiers;
         HasColoredBackground = jsonAsset.HasColoredBackground;
         MaxModifierLevel = jsonAsset.MaxModifierLevel;
         MinModifierLevel = jsonAsset.MinModifierLevel;
         MinSellPercent = jsonAsset.MinSellPercent;
         MaxSellPercent = jsonAsset.MaxSellPercent;
         LevelWeight = jsonAsset.LevelWeight;
         ModifierWeight = jsonAsset.ModifierWeight;
         HasGlow = jsonAsset.HasGlow;
         GlowColor = jsonAsset.GlowColor;
         TextColor = jsonAsset.TextColor;
         GlowDist = jsonAsset.GlowDist;
         GlowStr = jsonAsset.GlowStr;
         BasePowerScale = jsonAsset.BasePowerScale;
         BasePowerConstant = jsonAsset.BasePowerConstant;
         if(HasColoredBackground)
         {
            BackgroundIcon = jsonAsset.BackgroundIcon;
            BackgroundIconBorder = jsonAsset.BackgroundIconBorder ?? "";
            BackgroundSwf = jsonAsset.BackgroundSwf;
         }
      }
   }
}

