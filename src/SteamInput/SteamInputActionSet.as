package SteamInput
{
   import com.amanitadesign.steam.FRESteamWorks;
   
   public class SteamInputActionSet
   {
      
      public var actionSetName:String;
      
      public var actionSetHandle:String;
      
      private var mAnalogActions:Vector.<SteamInputAction>;
      
      private var mDigitalActions:Vector.<SteamInputAction>;
      
      public function SteamInputActionSet(inActionSetName:String, inActionSetHandle:String)
      {
         super();
         actionSetName = inActionSetName;
         actionSetHandle = inActionSetHandle;
      }
      
      public function get analogActionHandles() : Vector.<SteamInputAction>
      {
         return mAnalogActions;
      }
      
      public function get digitalActionHandles() : Vector.<SteamInputAction>
      {
         return mDigitalActions;
      }
      
      public function tryLoadAnalogActions(analogActionNames:Vector.<String>, mSteamworks:FRESteamWorks) : Boolean
      {
         var _loc4_:Vector.<SteamInputAction> = tryLoadActionHandles(analogActionNames,false,mSteamworks);
         var _loc3_:Boolean = validateSteamInputActions(_loc4_);
         if(!_loc3_)
         {
            return false;
         }
         mAnalogActions = _loc4_;
         return true;
      }
      
      public function tryLoadDigitalActions(digitalActionNames:Vector.<String>, mSteamworks:FRESteamWorks) : Boolean
      {
         var _loc4_:Vector.<SteamInputAction> = tryLoadActionHandles(digitalActionNames,true,mSteamworks);
         var _loc3_:Boolean = validateSteamInputActions(_loc4_);
         if(!_loc3_)
         {
            return false;
         }
         mDigitalActions = _loc4_;
         return true;
      }
      
      private function tryLoadActionHandles(actionNames:Vector.<String>, isDigitalAction:Boolean, mSteamworks:FRESteamWorks) : Vector.<SteamInputAction>
      {
         var _loc6_:String = null;
         var _loc4_:SteamInputAction = null;
         var _loc5_:Vector.<SteamInputAction> = new Vector.<SteamInputAction>();
         for each(var _loc7_:String in actionNames)
         {
            if(isDigitalAction)
            {
               _loc6_ = mSteamworks.getDigitalActionHandle(_loc7_);
            }
            else
            {
               _loc6_ = mSteamworks.getAnalogActionHandle(_loc7_);
            }
            _loc4_ = new SteamInputAction(_loc7_,_loc6_);
            _loc5_.push(_loc4_);
         }
         return _loc5_;
      }
      
      private function validateSteamInputActions(actions:Vector.<SteamInputAction>) : Boolean
      {
         for each(var _loc2_:SteamInputAction in actions)
         {
            if(_loc2_.actionHandle == "0")
            {
               return false;
            }
         }
         return true;
      }
   }
}

