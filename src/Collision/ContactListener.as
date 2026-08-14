package Collision
{
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2ContactListener;
   import Box2D.Dynamics.b2Fixture;
   import Facade.DBFacade;
   
   public class ContactListener extends b2ContactListener
   {
      
      protected var mDBFacade:DBFacade;
      
      private var mContactList:Vector.<collisionHelper> = new Vector.<collisionHelper>();
      
      public function ContactListener(dbFacade:DBFacade)
      {
         mDBFacade = dbFacade;
         super();
      }
      
      override public function BeginContact(contact:b2Contact) : void
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         var _loc2_:IContactResolver = null;
         var _loc7_:IContactResolver = null;
         var _loc6_:b2Fixture = contact.GetFixtureA();
         var _loc5_:b2Fixture = contact.GetFixtureB();
         if(_loc6_.IsSensor() && _loc5_.IsSensor())
         {
            return;
         }
         if(_loc6_.IsSensor())
         {
            if(_loc6_.GetUserData() is IContactResolver)
            {
               _loc2_ = _loc6_.GetUserData() as IContactResolver;
            }
            else
            {
               _loc4_ = _loc6_.GetUserData() as uint;
               _loc2_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc4_) as IContactResolver;
            }
            _loc3_ = _loc5_.GetBody().GetUserData() as uint;
            mContactList.push(new collisionHelper(_loc2_,_loc3_,_loc2_.enterContact));
         }
         if(_loc5_.IsSensor())
         {
            if(_loc5_.GetUserData() is IContactResolver)
            {
               _loc7_ = _loc5_.GetUserData() as IContactResolver;
            }
            else
            {
               _loc3_ = _loc5_.GetUserData() as uint;
               _loc7_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc3_) as IContactResolver;
            }
            _loc4_ = _loc6_.GetBody().GetUserData() as uint;
            mContactList.push(new collisionHelper(_loc7_,_loc4_,_loc7_.enterContact));
         }
      }
      
      override public function EndContact(contact:b2Contact) : void
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         var _loc2_:IContactResolver = null;
         var _loc7_:IContactResolver = null;
         var _loc6_:b2Fixture = contact.GetFixtureA();
         var _loc5_:b2Fixture = contact.GetFixtureB();
         if(_loc6_.IsSensor() && _loc5_.IsSensor())
         {
            return;
         }
         if(_loc6_.IsSensor())
         {
            if(_loc6_.GetUserData() is IContactResolver)
            {
               _loc2_ = _loc6_.GetUserData() as IContactResolver;
            }
            else
            {
               _loc4_ = _loc6_.GetUserData() as uint;
               _loc2_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc4_) as IContactResolver;
            }
            _loc3_ = _loc5_.GetBody().GetUserData() as uint;
            mContactList.push(new collisionHelper(_loc2_,_loc3_,_loc2_.exitContact));
         }
         if(_loc5_.IsSensor())
         {
            if(_loc5_.GetUserData() is IContactResolver)
            {
               _loc7_ = _loc5_.GetUserData() as IContactResolver;
            }
            else
            {
               _loc3_ = _loc5_.GetUserData() as uint;
               _loc7_ = mDBFacade.gameObjectManager.getReferenceFromId(_loc3_) as IContactResolver;
            }
            _loc4_ = _loc6_.GetBody().GetUserData() as uint;
            mContactList.push(new collisionHelper(_loc7_,_loc4_,_loc7_.exitContact));
         }
      }
      
      public function processCollisions() : void
      {
         for each(var _loc1_:collisionHelper in mContactList)
         {
            _loc1_.functionToExecute(_loc1_.actorId);
         }
         mContactList.length = 0;
      }
   }
}

import Collision.IContactResolver;

class collisionHelper
{
   
   public var contactResolver:IContactResolver;
   
   public var actorId:uint;
   
   public var functionToExecute:Function;
   
   public function collisionHelper(contactRes:IContactResolver, theActorId:uint, func:Function)
   {
      super();
      contactResolver = contactRes;
      actorId = theActorId;
      functionToExecute = func;
   }
}
