package GameMasterDictionary
{
   import DBGlobals.As3Compat;
   import flash.Boot;
   
   public class GMWeaponAesthetic
   {
      
      public var WeaponItemConstant:String;
      
      public var TrailRAdd:Number;
      
      public var TrailR:Number;
      
      public var TrailGAdd:Number;
      
      public var TrailG:Number;
      
      public var TrailBAdd:Number;
      
      public var TrailB:Number;
      
      public var SwordTrailOverride:String;
      
      public var Release:String;
      
      public var Name:String;
      
      public var ModelName:String;
      
      public var MinLevel:uint;
      
      public var MaxLevel:uint;
      
      public var ItemRAdd:Number;
      
      public var ItemR:Number;
      
      public var ItemGAdd:Number;
      
      public var ItemG:Number;
      
      public var ItemBAdd:Number;
      
      public var ItemB:Number;
      
      public var IsLegendary:Boolean;
      
      public var IconSwf:String;
      
      public var IconName:String;
      
      public var HasTrailColor:Boolean;
      
      public var HasGlow:Boolean;
      
      public var HasColor:Boolean;
      
      public var GlowStr:Number;
      
      public var GlowDist:Number;
      
      public var GlowColor:uint;
      
      public var Description:String;
      
      public var Constant:String;
      
      public function GMWeaponAesthetic(jsonAsset:Object = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         Release = jsonAsset.Release;
         WeaponItemConstant = jsonAsset.WeaponItemConstant;
         Constant = jsonAsset.Constant;
         Name = jsonAsset.Name;
         MinLevel = uint(jsonAsset.MinLvl);
         MaxLevel = uint(jsonAsset.MaxLvl);
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
            GlowColor = As3Compat.toUInt(jsonAsset.GlowColor);
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
         IsLegendary = Boolean(jsonAsset.IsLegendary);
      }
   }
}

