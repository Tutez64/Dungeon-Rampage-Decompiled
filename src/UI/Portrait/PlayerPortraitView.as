package UI.Portrait
{
   import Account.FriendInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import GameMasterDictionary.GMSkin;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class PlayerPortraitView extends MovieClip
   {
      
      public static const DEFAULT_SKIN_ID:uint = 151;
      
      public static const STEAM_READY:String = "PlayerPortraitSteamReady";
      
      private var mDBFacade:DBFacade;
      
      private var mAssets:AssetLoadingComponent;
      
      private var mFriend:FriendInfo;
      
      private var mSize:Number;
      
      private var mTopLeft:Boolean;
      
      private var mGeneration:uint = 0;
      
      private var mDestroyed:Boolean = false;
      
      private var mSteamReady:Boolean = false;
      
      public function PlayerPortraitView(dbFacade:DBFacade, size:Number = 0, topLeft:Boolean = false)
      {
         super();
         mDBFacade = dbFacade;
         mSize = size;
         mTopLeft = topLeft;
         mouseEnabled = mouseChildren = false;
         if(size > 0)
         {
            graphics.beginFill(0,0);
            graphics.drawRect(topLeft ? 0 : -size / 2,topLeft ? 0 : -size / 2,size,size);
            graphics.endFill();
         }
      }
      
      public function bindFriend(friend:FriendInfo) : void
      {
         if(mDestroyed)
         {
            return;
         }
         unbindFriend();
         mFriend = friend;
         if(mFriend)
         {
            mFriend.addEventListener("FriendPortraitChanged",friendChanged);
         }
         friendChanged(null);
      }
      
      private function unbindFriend() : void
      {
         if(mFriend)
         {
            mFriend.removeEventListener("FriendPortraitChanged",friendChanged);
         }
         mFriend = null;
      }
      
      private function friendChanged(event:Event) : void
      {
         if(mFriend)
         {
            update(mFriend.skinId,mFriend.steamAvatarUrl);
         }
      }
      
      public function update(skinId:uint, steamUrl:String = null) : void
      {
         var generation:uint;
         if(mDestroyed)
         {
            return;
         }
         generation = ++mGeneration;
         if(mAssets)
         {
            mAssets.destroy();
         }
         mAssets = new AssetLoadingComponent(mDBFacade);
         mSteamReady = false;
         clearImage();
         loadHero(skinId,generation,false);
         if(steamUrl != null && steamUrl != "")
         {
            try
            {
               mAssets.getImageAsset(steamUrl,function(param1:ImageAsset):void
               {
                  var _loc2_:Bitmap = null;
                  if(mDestroyed || generation != mGeneration)
                  {
                     return;
                  }
                  try
                  {
                     if(!param1 || !param1.image || !param1.image.bitmapData)
                     {
                        return;
                     }
                     _loc2_ = new Bitmap(param1.image.bitmapData);
                  }
                  catch(bitmapError:Error)
                  {
                     return;
                  }
                  mSteamReady = true;
                  showImage(_loc2_);
                  dispatchEvent(new Event("PlayerPortraitSteamReady"));
               },function():void
               {
               });
            }
            catch(error:Error)
            {
            }
         }
      }
      
      private function loadHero(skinId:uint, generation:uint, isFallback:Boolean) : void
      {
         var skin:GMSkin;
         var failed:Function;
         if(mDestroyed || generation != mGeneration || mSteamReady)
         {
            return;
         }
         skin = mDBFacade.gameMaster.getSkinByType(skinId);
         if(!skin || !skin.UISwfFilepath || !skin.IconName)
         {
            if(!isFallback)
            {
               loadHero(151,generation,true);
            }
            return;
         }
         failed = function():void
         {
            if(mDestroyed || generation != mGeneration || mSteamReady)
            {
               return;
            }
            if(!isFallback && skinId != 151)
            {
               loadHero(151,generation,true);
            }
            else
            {
               Logger.warn("Unable to load default player portrait");
            }
         };
         mAssets.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath),function(param1:SwfAsset):void
         {
            if(mDestroyed || generation != mGeneration || mSteamReady)
            {
               return;
            }
            var _loc3_:Class = param1.getClass(skin.IconName);
            if(!_loc3_)
            {
               failed();
               return;
            }
            var _loc2_:DisplayObject = new _loc3_() as DisplayObject;
            if(!_loc2_)
            {
               failed();
               return;
            }
            showImage(_loc2_);
         },failed);
      }
      
      private function showImage(image:DisplayObject) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Number = NaN;
         clearImage();
         if(mSize > 0)
         {
            _loc2_ = image.getBounds(image);
            if(_loc2_.width > 0 && _loc2_.height > 0)
            {
               _loc3_ = mSize / Math.max(_loc2_.width,_loc2_.height);
               image.scaleX = image.scaleY = _loc3_;
               image.x = -_loc2_.x * _loc3_ + (mSize - _loc2_.width * _loc3_) / 2;
               image.y = -_loc2_.y * _loc3_ + (mSize - _loc2_.height * _loc3_) / 2;
               if(!mTopLeft)
               {
                  image.x -= mSize / 2;
                  image.y -= mSize / 2;
               }
            }
         }
         addChild(image);
      }
      
      private function clearImage() : void
      {
         while(numChildren > 0)
         {
            removeChildAt(numChildren - 1);
         }
      }
      
      public function destroy() : void
      {
         if(mDestroyed)
         {
            return;
         }
         mDestroyed = true;
         mGeneration = mGeneration + 1;
         unbindFriend();
         if(mAssets)
         {
            mAssets.destroy();
         }
         mAssets = null;
         clearImage();
         if(parent)
         {
            parent.removeChild(this);
         }
         mDBFacade = null;
      }
   }
}

