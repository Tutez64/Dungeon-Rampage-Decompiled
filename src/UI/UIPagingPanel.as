package UI
{
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class UIPagingPanel
   {
      
      private var mDBFacade:DBFacade;
      
      private var mRoot:MovieClip;
      
      private var mCallback:Function;
      
      private var mNumPages:uint;
      
      private var mCurrentPage:uint;
      
      private var mPageLeftButton:UIButton;
      
      private var mPageRightButton:UIButton;
      
      private var mPageButtonClass:Class;
      
      private var mPageButtons:Vector.<UIButton>;
      
      public function UIPagingPanel(dbFacade:DBFacade, numPages:uint, rootClip:MovieClip, pageButtonClass:Class, callback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mNumPages = numPages;
         mRoot = rootClip;
         mPageButtonClass = pageButtonClass;
         mPageButtons = new Vector.<UIButton>();
         mCurrentPage = 0;
         mCallback = callback;
         this.setupUI(rootClip);
         updatePageArrows();
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mCallback = null;
         mPageLeftButton.destroy();
         mPageRightButton.destroy();
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function set visible(value:Boolean) : void
      {
         mRoot.visible = value;
      }
      
      public function get visible() : Boolean
      {
         return mRoot.visible;
      }
      
      public function set numPages(value:uint) : void
      {
         mNumPages = value;
         this.updatePageArrows();
      }
      
      public function get numPages() : uint
      {
         return mNumPages;
      }
      
      public function set currentPage(value:uint) : void
      {
         if(value == mCurrentPage)
         {
            return;
         }
         mCurrentPage = value;
         this.updatePageArrows();
      }
      
      public function get currentPage() : uint
      {
         return mCurrentPage;
      }
      
      public function dontKillUI() : void
      {
         mPageLeftButton.dontKillMyChildren = true;
         mPageRightButton.dontKillMyChildren = true;
      }
      
      private function setupUI(rootClip:MovieClip) : void
      {
         mRoot = rootClip;
         mPageLeftButton = new UIButton(mDBFacade,mRoot.page_left);
         mPageRightButton = new UIButton(mDBFacade,mRoot.page_right);
         mPageLeftButton.releaseCallback = pageLeft;
         mPageRightButton.releaseCallback = pageRight;
         mPageLeftButton.enabled = false;
         mPageRightButton.enabled = false;
      }
      
      private function pageLeft() : void
      {
         this.currentPage = Math.max(0,mCurrentPage - 1);
         if(mCallback != null)
         {
            mCallback(mCurrentPage);
         }
      }
      
      private function pageRight() : void
      {
         this.currentPage = Math.min(mNumPages,mCurrentPage + 1);
         if(mCallback != null)
         {
            mCallback(mCurrentPage);
         }
      }
      
      private function updatePageArrows() : void
      {
         var pageButton:UIButton;
         var pageButtonMC:MovieClip;
         var PAD:uint;
         var MAX_BUTTONS:uint;
         var startPage:uint;
         var endPage:uint;
         var numPagesShowing:uint;
         var even:Boolean;
         var i:uint;
         var buttonWidth:Number;
         var leftEdge:Number;
         var offset:Number;
         mPageLeftButton.enabled = mCurrentPage != 0;
         mPageRightButton.enabled = mCurrentPage < mNumPages - 1;
         for each(pageButton in mPageButtons)
         {
            pageButton.detach();
            pageButton.destroy();
         }
         mPageButtons.length = 0;
         PAD = 8;
         MAX_BUTTONS = 9;
         startPage = Math.max(0,Math.min(mNumPages - MAX_BUTTONS,mCurrentPage - MAX_BUTTONS / 2 + 1));
         endPage = Math.min(startPage + MAX_BUTTONS,mNumPages);
         numPagesShowing = endPage - startPage;
         even = numPagesShowing % 2 == 0;
         i = startPage;
         while(i < endPage)
         {
            pageButtonMC = new mPageButtonClass();
            mRoot.addChild(pageButtonMC);
            pageButton = new UIButton(mDBFacade,pageButtonMC);
            pageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            pageButton.label.text = (i + 1).toString();
            buttonWidth = pageButton.root.width + PAD;
            leftEdge = numPagesShowing * buttonWidth * -0.5;
            offset = even ? buttonWidth * 0.5 : 0;
            pageButton.root.x = leftEdge + offset + (i - startPage) * buttonWidth;
            pageButton.root.pageIndex = i;
            pageButton.releaseCallbackThis = function(param1:UIButton):void
            {
               param1.bringToFront();
               currentPage = param1.root.pageIndex;
               if(mCallback != null)
               {
                  mCallback(mCurrentPage);
               }
            };
            mPageButtons.push(pageButton);
            if(i == mCurrentPage)
            {
               pageButton.enabled = false;
               pageButton.root.scaleX = pageButton.root.scaleY = 1.2;
               pageButton.root.filters = [DBGlobal.UI_SELECTED_FILTER];
            }
            else
            {
               pageButton.enabled = true;
               pageButton.root.scaleX = pageButton.root.scaleY = 1;
               pageButton.root.filters = [];
            }
            i = i + 1;
         }
         if(mPageButtons.length > mCurrentPage - startPage)
         {
            mPageButtons[mCurrentPage - startPage].bringToFront();
         }
      }
   }
}

