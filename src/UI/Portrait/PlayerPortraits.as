package UI.Portrait
{
   import Account.FriendInfo;
   import Facade.DBFacade;
   import flash.display.DisplayObjectContainer;
   import flash.utils.Dictionary;
   
   public class PlayerPortraits
   {
      
      private var mViews:Dictionary = new Dictionary();
      
      public function PlayerPortraits()
      {
         super();
      }
      
      public function show(container:DisplayObjectContainer, facade:DBFacade, skinId:uint, size:Number = 0, steamUrl:String = null, topLeft:Boolean = false) : PlayerPortraitView
      {
         var _loc7_:PlayerPortraitView = create(container,facade,size,topLeft);
         _loc7_.update(skinId,steamUrl);
         return _loc7_;
      }
      
      public function showFriend(container:DisplayObjectContainer, facade:DBFacade, friend:FriendInfo, size:Number = 50) : PlayerPortraitView
      {
         var _loc5_:PlayerPortraitView = create(container,facade,size,true);
         _loc5_.bindFriend(friend);
         return _loc5_;
      }
      
      private function create(container:DisplayObjectContainer, facade:DBFacade, size:Number, topLeft:Boolean) : PlayerPortraitView
      {
         remove(container);
         var _loc5_:PlayerPortraitView = new PlayerPortraitView(facade,size,topLeft);
         mViews[container] = _loc5_;
         container.addChild(_loc5_);
         return _loc5_;
      }
      
      public function remove(container:DisplayObjectContainer) : void
      {
         var _loc2_:PlayerPortraitView = mViews[container];
         if(_loc2_)
         {
            _loc2_.destroy();
         }
         delete mViews[container];
      }
      
      public function clear() : void
      {
         for each(var _loc1_:PlayerPortraitView in mViews)
         {
            _loc1_.destroy();
         }
         mViews = new Dictionary();
      }
      
      public function destroy() : void
      {
         clear();
      }
   }
}

