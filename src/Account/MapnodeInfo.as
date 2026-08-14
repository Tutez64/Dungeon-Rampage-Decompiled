package Account
{
   public class MapnodeInfo
   {
      
      public static const NODE_STATE_DEFEATED:uint = 1;
      
      public static const NODE_STATE_OPEN:uint = 2;
      
      public static const NODE_STATE_OPEN_NOT_DEFEATED:uint = 3;
      
      private var mMapnodeJson:Object;
      
      private var mMapnodeId:uint;
      
      private var mAccountId:uint;
      
      private var mId:uint;
      
      private var mMapnodeState:uint;
      
      private var mResponseCallback:Function;
      
      private var mCallbackSuccess:Function;
      
      private var mCallbackFailure:Function;
      
      public function MapnodeInfo()
      {
         super();
      }
      
      public function get id() : uint
      {
         return mId;
      }
      
      public function get nodeId() : uint
      {
         return mMapnodeId;
      }
      
      public function get MapnodeState() : uint
      {
         return mMapnodeState;
      }
      
      public function set MapnodeState(value:uint) : void
      {
         mMapnodeState = value;
      }
      
      public function init(MapnodeId:uint, MapnodeState:uint) : void
      {
         mMapnodeId = MapnodeId;
         mMapnodeState = MapnodeState;
      }
      
      private function parseMapnodeJson(MapnodeJson:Object) : void
      {
         if(MapnodeJson == null)
         {
            return;
         }
         mMapnodeId = MapnodeJson.node_id as uint;
         mAccountId = MapnodeJson.account_id as uint;
         mId = MapnodeJson.id as uint;
         mMapnodeState = MapnodeJson.node_state as uint;
      }
      
      public function parseResponse(MapnodeJson:Object) : void
      {
         if(MapnodeJson == null)
         {
            return;
         }
         mMapnodeId = MapnodeJson.node_id as uint;
         mAccountId = MapnodeJson.account_id as uint;
         mId = MapnodeJson.id as uint;
         mMapnodeState = MapnodeJson.node_state as uint;
         if(mCallbackSuccess != null)
         {
            mCallbackSuccess(this);
         }
      }
   }
}

