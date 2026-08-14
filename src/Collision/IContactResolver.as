package Collision
{
   public interface IContactResolver
   {
      
      function enterContact(actorId:uint) : void;
      
      function exitContact(actorId:uint) : void;
   }
}

