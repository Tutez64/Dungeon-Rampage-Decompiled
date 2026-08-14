package Combat.Attack
{
   import Actor.ActorGameObject;
   import Brain.AssetRepository.JsonAsset;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import avmplus.getQualifiedClassName;
   import org.as3commons.collections.Map;
   
   public class TimelineFactory
   {
      
      private static const TIMELINE_FILE_PATH:String = "Resources/Combat/AttackTimeline.json";
      
      protected var mDBFacade:DBFacade;
      
      protected var mJsonAsset:JsonAsset;
      
      protected var mTimelines:Map;
      
      private var mSecurityValue:int;
      
      public function TimelineFactory(dbFacade:DBFacade, jsonAsset:JsonAsset)
      {
         var _loc3_:String = null;
         super();
         mDBFacade = dbFacade;
         mJsonAsset = jsonAsset;
         mTimelines = new Map();
         var _loc5_:int = 0;
         mSecurityValue = 0;
         for each(var _loc4_:Object in jsonAsset.json.attacks)
         {
            _loc3_ = _loc4_.attackName;
            mTimelines.add(_loc3_,_loc4_);
            _loc5_ += GetSecurityValue(_loc4_);
         }
         _loc5_ %= 1097;
         mSecurityValue += _loc5_;
         _loc5_ = 0;
      }
      
      public function GetSecurityValue(jsonAsset:Object) : int
      {
         var _loc2_:int = 0;
         for each(var _loc3_:Object in jsonAsset)
         {
            if(getQualifiedClassName(_loc3_) == "int")
            {
               _loc2_ += Math.abs(int(_loc3_)) % 17 + Math.abs(int(_loc3_)) / 19;
            }
         }
         return _loc2_ % 541;
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mTimelines.clear();
         mTimelines = null;
         mJsonAsset = null;
      }
      
      public function get securityChecksum() : int
      {
         return mSecurityValue;
      }
      
      public function createAttackTimeline(timelineName:String, weapon:WeaponGameObject, actor:ActorGameObject, floor:DistributedDungeonFloor) : AttackTimeline
      {
         var _loc6_:AttackTimeline = null;
         var _loc5_:Object = mTimelines.itemFor(timelineName);
         if(actor.isOwner)
         {
            _loc6_ = new OwnerAttackTimeline(weapon,actor as HeroGameObjectOwner,actor.actorView,_loc5_,mDBFacade,floor);
         }
         else
         {
            _loc6_ = new AttackTimeline(weapon,actor,actor.actorView,_loc5_,mDBFacade,floor);
         }
         return _loc6_;
      }
      
      public function createScriptTimeline(timelineName:String, actor:ActorGameObject, floor:DistributedDungeonFloor) : ScriptTimeline
      {
         var _loc5_:* = null;
         var _loc4_:Object = mTimelines.itemFor(timelineName);
         return new ScriptTimeline(actor,actor.actorView,_loc4_,mDBFacade,floor);
      }
   }
}

