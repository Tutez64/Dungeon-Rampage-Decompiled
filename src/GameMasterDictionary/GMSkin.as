package GameMasterDictionary
{
   public class GMSkin extends GMItem
   {
      
      public var ForHero:String;
      
      public var AssetType:String;
      
      public var SpriteWidth:uint;
      
      public var SpriteHeight:uint;
      
      public var AssetClassName:String;
      
      public var PortraitName:String;
      
      public var IconSwfFilepath:String;
      
      public var IconName:String;
      
      public var CardName:String;
      
      public var SwfFilepath:String;
      
      public var HDSwfFilepath:String;
      
      public var UISwfFilepath:String;
      
      public var FeedPostPicture:String;
      
      public var Scale:Number;
      
      public var NametagY:Number;
      
      public var HealthbarScale:Number;
      
      public var ProjEmitOffset:Number;
      
      public var Hue:Number;
      
      public var Saturation:Number;
      
      public var Brightness:Number;
      
      public var Scale3DModel:Number;
      
      public var HitVol:Number;
      
      public var HitSound:String;
      
      public var DeathVol:Number;
      
      public var DeathSound:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var CharUnlockLocation:String;
      
      public var Description:String;
      
      public var StoreDescription:String;
      
      public var specialFXSwfPath_Back:String;
      
      public var specialFXName_Back:String;
      
      public var specialFXSwfPath_Front:String;
      
      public var specialFXName_Front:String;
      
      public function GMSkin(jsonAsset:Object)
      {
         super(jsonAsset);
         ForHero = jsonAsset.ForHero as String;
         AssetType = jsonAsset.AssetType as String;
         SpriteWidth = jsonAsset.SpriteWidth as uint;
         SpriteHeight = jsonAsset.SpriteHeight as uint;
         AssetClassName = jsonAsset.AssetClassName as String;
         PortraitName = jsonAsset.PortraitName as String;
         IconSwfFilepath = jsonAsset.IconSwfFilepath as String;
         IconName = jsonAsset.IconName as String;
         CardName = jsonAsset.CardName as String;
         SwfFilepath = jsonAsset.SwfFilepath as String;
         HDSwfFilepath = jsonAsset.HDSwfFilepath;
         UISwfFilepath = jsonAsset.UISwfFilepath as String;
         FeedPostPicture = jsonAsset.FeedPostPicture;
         Scale = jsonAsset.Scale as Number;
         NametagY = jsonAsset.NametagY as Number;
         HealthbarScale = jsonAsset.HealthbarScale as Number;
         ProjEmitOffset = jsonAsset.ProjEmitOffset as Number;
         Hue = jsonAsset.Hue;
         Saturation = jsonAsset.Saturation ? (100 + jsonAsset.Saturation) / 100 * 2 : 0;
         Brightness = jsonAsset.Brightness;
         if(jsonAsset.Scale3DModel == null)
         {
            Scale3DModel = 1;
         }
         else
         {
            Scale3DModel = jsonAsset.Scale3DModel;
         }
         HitVol = jsonAsset.HitVol as Number;
         HitSound = jsonAsset.HitSound as String;
         DeathVol = jsonAsset.DeathVol as Number;
         DeathSound = jsonAsset.DeathSound as String;
         CharNickname = jsonAsset.CharNickname as String;
         CharLikes = jsonAsset.CharLikes as String;
         CharDislikes = jsonAsset.CharDislikes as String;
         CharUnlockLocation = jsonAsset.CharUnlockLocation as String;
         Description = jsonAsset.Description as String;
         StoreDescription = jsonAsset.StoreDescription as String;
         specialFXSwfPath_Back = jsonAsset.SpecialFXSwfPath_Back;
         specialFXName_Back = jsonAsset.SpecialFXName_Back;
         specialFXSwfPath_Front = jsonAsset.SpecialFXSwfPath_Front;
         specialFXName_Front = jsonAsset.SpecialFXName_Front;
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
   }
}

