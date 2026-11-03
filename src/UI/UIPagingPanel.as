package UI
{
   import Brain.UI.UIButton;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   
   public class UIPagingPanel
   {
      
      private static const PAGE_BUTTON_PAD:uint = 8;
      
      private static const MAX_PAGE_BUTTONS:uint = 8;
      
      private var mDBFacade:DBFacade;
      
      private var mRoot:MovieClip;
      
      private var mCallback:Function;
      
      private var mNumPages:uint;
      
      private var mCurrentPage:uint;
      
      private var mPageLeftButton:UIButton;
      
      private var mPageRightButton:UIButton;
      
      private var mPageButtonClass:Class;
      
      private var mPageButtons:Vector.<UIButton>;
      
      private var mVisiblePageButtonCount:uint;
      
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
         for each(var _loc1_:UIButton in mPageButtons)
         {
            _loc1_.detach();
            _loc1_.destroy();
         }
         mPageButtons.length = 0;
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
         if(mNumPages == 0)
         {
            mCurrentPage = 0;
         }
         else if(mCurrentPage >= mNumPages)
         {
            mCurrentPage = mNumPages - 1;
         }
         this.updatePageArrows();
      }
      
      public function get numPages() : uint
      {
         return mNumPages;
      }
      
      public function set currentPage(value:uint) : void
      {
         value = mNumPages == 0 ? 0 : Math.min(value,mNumPages - 1);
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
         this.currentPage = mNumPages == 0 ? 0 : Math.min(mNumPages - 1,mCurrentPage + 1);
         if(mCallback != null)
         {
            mCallback(mCurrentPage);
         }
      }
      
      private function updatePageArrows() : void
      {
         var pageButton:UIButton;
         var pageButtonMC:MovieClip;
         var maxStartPage:int;
         var centeredStartPage:int;
         var startPage:uint;
         var endPage:uint;
         var numPagesShowing:uint;
         var even:Boolean;
         var buttonIndex:uint;
         var pageIndex:uint;
         var buttonWidth:Number;
         var leftEdge:Number;
         var offset:Number;
         mPageLeftButton.enabled = mCurrentPage != 0;
         mPageRightButton.enabled = mNumPages > 0 && mCurrentPage < mNumPages - 1;
         maxStartPage = Math.max(0,int(mNumPages) - 8);
         centeredStartPage = int(mCurrentPage) - 4 + 1;
         startPage = Math.max(0,Math.min(maxStartPage,centeredStartPage));
         endPage = Math.min(startPage + 8,mNumPages);
         numPagesShowing = endPage - startPage;
         mVisiblePageButtonCount = numPagesShowing;
         even = numPagesShowing % 2 == 0;
         while(mPageButtons.length < numPagesShowing)
         {
            pageButtonMC = new mPageButtonClass();
            mRoot.addChild(pageButtonMC);
            pageButton = new UIButton(mDBFacade,pageButtonMC);
            pageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
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
         }
         buttonIndex = 0;
         while(buttonIndex < mPageButtons.length)
         {
            pageButton = mPageButtons[buttonIndex];
            pageButton.clearNavigationAndInteractions();
            pageButton.visible = buttonIndex < numPagesShowing;
            if(pageButton.visible)
            {
               pageIndex = startPage + buttonIndex;
               pageButton.root.scaleX = pageButton.root.scaleY = 1;
               TextUtil.setText(pageButton.label,(pageIndex + 1).toString());
               buttonWidth = pageButton.root.width + 8;
               leftEdge = numPagesShowing * buttonWidth * -0.5;
               offset = even ? buttonWidth * 0.5 : 0;
               pageButton.root.x = leftEdge + offset + buttonIndex * buttonWidth;
               pageButton.root.pageIndex = pageIndex;
               if(pageIndex == mCurrentPage)
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
            }
            buttonIndex = buttonIndex + 1;
         }
         if(mVisiblePageButtonCount > mCurrentPage - startPage)
         {
            mPageButtons[mCurrentPage - startPage].bringToFront();
         }
      }
      
      public function get getPageLeftButton() : UIButton
      {
         return mPageLeftButton;
      }
      
      public function get getPageRightButton() : UIButton
      {
         return mPageRightButton;
      }
      
      public function getPageButton(buttonIndex:int) : UIButton
      {
         if(mPageButtons[buttonIndex] == null)
         {
            return null;
         }
         return mPageButtons[buttonIndex];
      }
      
      public function get numPageButtons() : uint
      {
         return mVisiblePageButtonCount;
      }
      
      public function getNextPageButton() : UIButton
      {
         var _loc1_:uint = 0;
         if(mVisiblePageButtonCount < 2)
         {
            return null;
         }
         _loc1_ = 0;
         while(_loc1_ < mVisiblePageButtonCount)
         {
            if(mPageButtons[_loc1_].root.pageIndex == mCurrentPage)
            {
               return _loc1_ + 1 < mVisiblePageButtonCount ? mPageButtons[_loc1_ + 1] : mPageButtons[0];
            }
            _loc1_++;
         }
         return mPageButtons[0];
      }
   }
}

