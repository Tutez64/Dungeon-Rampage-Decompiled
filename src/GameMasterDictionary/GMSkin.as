package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMSkin extends GMItem
   {
      
      public var specialFXSwfPath_Front:String;
      
      public var specialFXSwfPath_Back:String;
      
      public var specialFXName_Front:String;
      
      public var specialFXName_Back:String;
      
      public var UISwfFilepath:String;
      
      public var SwfFilepath:String;
      
      public var StoreDescription:String;
      
      public var SpriteWidth:uint;
      
      public var SpriteHeight:uint;
      
      public var Scale:Number;
      
      public var Saturation:Number;
      
      public var ProjEmitOffset:Number;
      
      public var PortraitName:String;
      
      public var PortraitClassName:String;
      
      public var NametagY:Number;
      
      public var IconSwfFilepath:String;
      
      public var IconName:String;
      
      public var Hue:Number;
      
      public var HitVol:Number;
      
      public var HitSound:String;
      
      public var HealthbarScale:Number;
      
      public var ForHero:String;
      
      public var Description:String;
      
      public var DeathVol:Number;
      
      public var DeathSound:String;
      
      public var CharUnlockLocation:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var Brightness:Number;
      
      public var BackgroundClassName:String;
      
      public var AssetType:String;
      
      public var AssetClassName:String;
      
      public function GMSkin(jsonAsset:Object = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(jsonAsset);
            ForHero = jsonAsset.ForHero;
            AssetType = jsonAsset.AssetType;
            SpriteWidth = uint(jsonAsset.SpriteWidth);
            SpriteHeight = uint(jsonAsset.SpriteHeight);
            AssetClassName = jsonAsset.AssetClassName;
            PortraitName = jsonAsset.PortraitName;
            IconSwfFilepath = jsonAsset.IconSwfFilepath;
            IconName = jsonAsset.IconName;
            BackgroundClassName = jsonAsset.BackgroundClassName;
            PortraitClassName = jsonAsset.PortraitClassName;
            SwfFilepath = jsonAsset.SwfFilepath;
            UISwfFilepath = jsonAsset.UISwfFilepath;
            Scale = Number(jsonAsset.Scale);
            NametagY = Number(jsonAsset.NametagY);
            HealthbarScale = Number(jsonAsset.HealthbarScale);
            ProjEmitOffset = Number(jsonAsset.ProjEmitOffset);
            Hue = Number(jsonAsset.Hue);
            var _loc2_:Number = Number(jsonAsset.Saturation);
            Saturation = _loc2_ != 0 && _loc2_ == _loc2_ ? (100 + _loc2_) / 100 * 2 : 0;
            Brightness = Number(jsonAsset.Brightness);
            HitVol = Number(jsonAsset.HitVol);
            HitSound = jsonAsset.HitSound;
            DeathVol = Number(jsonAsset.DeathVol);
            DeathSound = jsonAsset.DeathSound;
            CharNickname = jsonAsset.CharNickname;
            CharLikes = jsonAsset.CharLikes;
            CharDislikes = jsonAsset.CharDislikes;
            CharUnlockLocation = jsonAsset.CharUnlockLocation;
            Description = jsonAsset.Description;
            StoreDescription = jsonAsset.StoreDescription;
            specialFXSwfPath_Back = jsonAsset.SpecialFXSwfPath_Back;
            specialFXName_Back = jsonAsset.SpecialFXName_Back;
            specialFXSwfPath_Front = jsonAsset.SpecialFXSwfPath_Front;
            specialFXName_Front = jsonAsset.SpecialFXName_Front;
         }
      }
      
      public function doesSpecialFXFrontExist() : Boolean
      {
         if(specialFXSwfPath_Front == null || specialFXSwfPath_Front == "")
         {
            return false;
         }
         if(specialFXName_Front == null || specialFXName_Front == "")
         {
            return false;
         }
         return true;
      }
      
      public function doesSpecialFXBackExist() : Boolean
      {
         if(specialFXSwfPath_Back == null || specialFXSwfPath_Back == "")
         {
            return false;
         }
         if(specialFXName_Back == null || specialFXName_Back == "")
         {
            return false;
         }
         return true;
      }
   }
}

