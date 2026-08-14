package UI.Inventory
{
   import Account.ChestInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderer;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class DungeonRewardElement extends UIButton
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mChestInfo:ChestInfo;
      
      protected var mSelectedCallback:Function;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mChestEmptyPicMC:MovieClip;
      
      private var mChestRenderer:MovieClipRenderer;
      
      public function DungeonRewardElement(dbFacade:DBFacade, root:MovieClip, chestInfo:ChestInfo, selectedCallback:Function)
      {
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mChestInfo = chestInfo;
         mSelectedCallback = selectedCallback;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         releaseCallback = callSelectedCallback;
         ChestInfo.loadItemIconFromId(mChestInfo.gmId,mRoot,mDBFacade,60,100,mAssetLoadingComponent);
         mChestRenderer = new MovieClipRenderer(mDBFacade,mRoot);
         mChestRenderer.play(0,true);
         bgColoredExists = mChestInfo.hasColoredBackground;
         bgSwfPath = mChestInfo.backgroundSwfPath;
         bgIconName = mChestInfo.backgroundIconName;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
            {
               var _loc3_:MovieClip = null;
               var _loc2_:Class = param1.getClass(bgIconName);
               if(_loc2_)
               {
                  _loc3_ = new _loc2_() as MovieClip;
                  mRoot.addChildAt(_loc3_,1);
               }
            });
         }
      }
      
      public function get chestInfo() : ChestInfo
      {
         return mChestInfo;
      }
      
      public function callSelectedCallback() : void
      {
         mSelectedCallback(mChestInfo);
      }
      
      public function select() : void
      {
         (mRoot.parent as MovieClip).select.visible = true;
      }
      
      public function deSelect() : void
      {
         (mRoot.parent as MovieClip).select.visible = false;
      }
      
      public function empty() : void
      {
         deSelect();
         while(mRoot.numChildren > 1)
         {
            mRoot.removeChildAt(1);
         }
      }
      
      public function clear() : void
      {
         while(mRoot.numChildren > 1)
         {
            mRoot.removeChildAt(1);
         }
      }
      
      override public function destroy() : void
      {
         clear();
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mChestRenderer.destroy();
         mChestRenderer = null;
         mDBFacade = null;
         mChestInfo = null;
         mSelectedCallback = null;
         releaseCallback = null;
         super.destroy();
      }
   }
}

