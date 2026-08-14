package GameMasterDictionary
{
   public class GMWeaponAesthetic
   {
      
      public var Release:String;
      
      public var WeaponItemConstant:String;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var MinLevel:uint;
      
      public var MaxLevel:uint;
      
      public var ModelName:String;
      
      public var IconName:String;
      
      public var IconSwf:String;
      
      public var SwordTrailOverride:String;
      
      public var ItemR:Number;
      
      public var ItemG:Number;
      
      public var ItemB:Number;
      
      public var ItemRAdd:Number;
      
      public var ItemGAdd:Number;
      
      public var ItemBAdd:Number;
      
      public var HasColor:Boolean;
      
      public var GlowDist:Number;
      
      public var GlowStr:Number;
      
      public var GlowColor:uint;
      
      public var HasGlow:Boolean;
      
      public var TrailR:Number;
      
      public var TrailG:Number;
      
      public var TrailB:Number;
      
      public var TrailRAdd:Number;
      
      public var TrailGAdd:Number;
      
      public var TrailBAdd:Number;
      
      public var HasTrailColor:Boolean;
      
      public var Description:String;
      
      public var IsLegendary:Boolean;
      
      public function GMWeaponAesthetic(jsonAsset:Object)
      {
         super();
         Release = jsonAsset.Release;
         WeaponItemConstant = jsonAsset.WeaponItemConstant;
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         MinLevel = jsonAsset.MinLvl as uint;
         MaxLevel = jsonAsset.MaxLvl as uint;
         ModelName = jsonAsset.ModelName;
         IconName = jsonAsset.IconName;
         IconSwf = jsonAsset.UISwfFilepath;
         SwordTrailOverride = jsonAsset.SwordTrailOverride;
         HasColor = jsonAsset.ItemR != null && jsonAsset.ItemG != null && jsonAsset.ItemB != null && jsonAsset.ItemRAdd != null && jsonAsset.ItemGAdd != null && jsonAsset.ItemBAdd != null;
         if(HasColor)
         {
            ItemR = jsonAsset.ItemR;
            ItemG = jsonAsset.ItemG;
            ItemB = jsonAsset.ItemB;
            ItemRAdd = jsonAsset.ItemRAdd;
            ItemGAdd = jsonAsset.ItemGAdd;
            ItemBAdd = jsonAsset.ItemBAdd;
         }
         HasGlow = jsonAsset.GlowDist != null && jsonAsset.GlowStr != null && jsonAsset.GlowColor != null;
         if(HasGlow)
         {
            GlowDist = jsonAsset.GlowDist;
            GlowStr = jsonAsset.GlowStr;
            GlowColor = uint(jsonAsset.GlowColor);
         }
         HasTrailColor = jsonAsset.TrailR != null && jsonAsset.TrailG != null && jsonAsset.TrailB != null && jsonAsset.TrailRAdd != null && jsonAsset.TrailGAdd != null && jsonAsset.TrailBAdd != null;
         if(HasTrailColor)
         {
            TrailR = jsonAsset.TrailR;
            TrailG = jsonAsset.TrailG;
            TrailB = jsonAsset.TrailB;
            TrailRAdd = jsonAsset.TrailRAdd;
            TrailGAdd = jsonAsset.TrailGAdd;
            TrailBAdd = jsonAsset.TrailBAdd;
         }
         Description = jsonAsset.Description;
         IsLegendary = jsonAsset.IsLegendary;
      }
   }
}

