package UI.Map
{
   import Facade.DBFacade;
   import com.maccherone.json.JSON;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLLoader;
   
   public class UIMapAvatar
   {
      
      private var mAvatar:MovieClip;
      
      private var mAvatarDropShadow:MovieClip;
      
      private var mAvatarMover:UIMapAvatarMover;
      
      private var mDBFacade:DBFacade;
      
      public function UIMapAvatar(dbFacade:DBFacade, avatar:MovieClip, avatarShadow:MovieClip, avatarMoverClass:Class)
      {
         super();
         mDBFacade = dbFacade;
         mAvatar = avatar;
         mAvatarDropShadow = avatarShadow;
         mAvatarMover = new avatarMoverClass(updatePosition) as UIMapAvatarMover;
         updatePlayerName();
      }
      
      public function moveTo(x:Number, y:Number) : void
      {
         mAvatarMover.moveTo(x,y);
      }
      
      public function destroy(parent:MovieClip) : void
      {
         if(mAvatar)
         {
            parent.removeChild(mAvatar);
         }
         if(mAvatarDropShadow)
         {
            parent.removeChild(mAvatarDropShadow);
         }
         if(mAvatarMover)
         {
            mAvatarMover.destroy();
            mAvatarMover = null;
         }
      }
      
      private function updatePosition(x:Number, y:Number) : void
      {
         mAvatar.x = x;
         mAvatar.y = y;
         mAvatarDropShadow.x = x;
         mAvatarDropShadow.y = y;
      }
      
      private function loadedPlayerName(e:Event) : void
      {
         var _loc3_:URLLoader = URLLoader(e.target);
         var _loc2_:Object = com.maccherone.json.JSON.decode(_loc3_.data);
         mAvatar.label.text = _loc2_["name"];
      }
      
      private function updatePlayerName() : void
      {
         mAvatar.label.text = mDBFacade.facebookAccountInfo.name ? mDBFacade.facebookAccountInfo.name : mDBFacade.dbAccountInfo.name;
      }
   }
}

