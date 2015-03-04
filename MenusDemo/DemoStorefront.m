//
//  DemoStorefront.m
//  MCMenus
//
//  Created by xcode on 7/30/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "DemoStorefront.h"

@interface DemoStorefront()

  @property MCMenuFacade *facade;
  @property UIViewController *forViewController;
  @property id dataSource;
  @property UILabel *appTitle;

  // menus
  @property MCMenu *categoryBar;
  @property MCMenu *playlistBar;
  @property MCMenu *trashBar;

  @property MCMenu *displayMenu;
  @property MCMenu *commandBarRight;   // right side of footer
  @property MCMenu *commandBarLeft;    // left side of footer

  @property MCMenu *trashButtonEmbeddedMenuAndDropLocation;       // this is our trash can
  @property MCMenu *playlistButtonEmbeddedMenuAndDropLocation;    // let's allow people to drop on our playlist button

  // buttons (just icons)
  @property MCIconData *trashButton;
  @property MCIconData *categoryButton;
  @property MCIconData *playlistButton;
  @property MCIconData *addCustomCollectionButton;
  @property MCIconData *pauseButton;
  @property MCIconData *playButton;
  @property MCIconData *recsButton;

  // icons properties
  @property int spacingBetweenIcons;
  @property MCIconForMenu *defaultIconSmall;

  // menus properties
  @property CGRect menuScrollBarPadding;
  @property CGRect interiorPaddingAroundData;

  // layout
  @property CGRect viewWindowRect;
  @property float heightOfHeaderBar;
  @property float heightOfHeader;
  @property float heightOfFooter;

  // colors
  @property UIColor *colorMenus;
  @property UIColor *colorDefaultBlackScreen;
  @property UIColor *colorIlluminateOnDrag;
  @property UIColor *colorForIconsOnIlluminateOnDrag;
  @property UIColor *colorForDisplayScrollBarBorder;
  @property UIColor *colorForIcons;
  @property UIColor *colorIsSelected;

@end


@implementation DemoStorefront
  @synthesize forViewController, facade, displayMenu, commandBarRight, viewWindowRect, colorDefaultBlackScreen, colorIlluminateOnDrag, menuScrollBarPadding, interiorPaddingAroundData, dataSource, spacingBetweenIcons, heightOfFooter, heightOfHeaderBar, trashButton, categoryButton, playlistButton, addCustomCollectionButton, pauseButton, playButton, recsButton, commandBarLeft, trashButtonEmbeddedMenuAndDropLocation, playlistButtonEmbeddedMenuAndDropLocation, playlistBar, categoryBar, trashBar, appTitle, heightOfHeader, colorForIcons, colorIsSelected, defaultIconSmall, colorForDisplayScrollBarBorder, colorForIconsOnIlluminateOnDrag, colorMenus;



#pragma mark INIT AND SETUP

-(id)initForViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self){
    
        forViewController = viewController;
        
        [self setup];
        
    }
    
    return self;
}

-(void)setup
{

    facade = [[MCMenuFacade alloc]initWithViewController:forViewController];
    dataSource = self;
    [self setDefaultSettings];              // colors, layout
    [self addTitleAndBackgroundImage];

    // build basic menus
    [self createHeaderBars];
    [self createDisplayMenu];
    [self createCommandBarRightAndLeft];
    
    // populate menus
    [self createCategories];
    [self makeCommandBarItems];
    [self addSampleSongs];
    
    // setup views / shared data
    [self linkMenusWhichShareData];
    
    // set permissions
    [self setDragAndDropPermissions];
    
}

-(void)setDefaultSettings
{
    
    // menus
    menuScrollBarPadding = CGRectMake(15, 15, 15, 15);      // left, right, top, bottom
    interiorPaddingAroundData = CGRectMake(15, 15, 15, 15);
    spacingBetweenIcons = 2;

    // colors
    colorDefaultBlackScreen = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.4];
    colorMenus = [UIColor clearColor];
    colorForIcons = [UIColor lightGrayColor];
    colorForDisplayScrollBarBorder = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:.2];
    
    colorIlluminateOnDrag = [UIColor colorWithRed:153/255.0 green:0/255.0 blue:153/255.0 alpha:.4];
    colorForIconsOnIlluminateOnDrag = [UIColor purpleColor];
    colorIsSelected = [UIColor redColor];

    // layout
    viewWindowRect = forViewController.view.frame;
    heightOfHeaderBar = 160;  // height icon + menu padding + interior padding
    heightOfFooter = 160;
    
}

-(void)addTitleAndBackgroundImage
{
    
    // add image
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"n"]];
    backgroundView.frame = CGRectMake(0, 27, viewWindowRect.size.width, viewWindowRect.size.height - 27);
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    [forViewController.view addSubview:backgroundView];
    
    // add background screen
    UIView *screen = [[UIView alloc]initWithFrame:CGRectMake(0, 27, viewWindowRect.size.width, viewWindowRect.size.height - 27)];
    screen.backgroundColor = colorDefaultBlackScreen;
    [forViewController.view addSubview:screen];
    
    // add title
    appTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, viewWindowRect.size.width, 45)];
    appTitle.font = [UIFont systemFontOfSize:30.0f];
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.textColor = [UIColor lightGrayColor];
    //appTitle.backgroundColor = colorDefaultBlackScreen;
    appTitle.text = @"xTunes";
    
    [forViewController.view addSubview:appTitle];
    
}


#pragma mark HEADER BAR

-(void)createHeaderBars
{
    
    // the header bar will be used to show category, trash, and playlist menus
    // in this case, we will just create three menus, and display the selected menu
    // the default will be the category bar
    // (we could have alternatively created one header bar and alternate between being used for the categoryBar, the playlist, and the trash - this approach has several advantages, but if you have to make substaintial changes to the menus everytime you switch, it can have disadvantages, as well)
    
    heightOfHeader = appTitle.frame.origin.y + appTitle.frame.size.height + heightOfHeaderBar;
    CGRect headerFrame = CGRectMake(0, appTitle.frame.origin.y + appTitle.frame.size.height, viewWindowRect.size.width, heightOfHeaderBar);
    
    // MAKE TRASH BAR
    
    defaultIconSmall = [facade makeIconToUseAsTemplateWithBackgroundColor:colorForIcons
                                                           highlightColor:colorForIcons
                                                         mainFrameWdAndHt:CGPointMake(100, 100)
                                                               imageFrame:CGRectMake(10, 10, 80, 70)
                                                                textFrame:CGRectMake(10, 82, 80, 15)];
    
    trashBar = [facade makeNewMenuWithTitle:@"trashBar"
                              withMainFrame:headerFrame
         paddingForScrollLeftRightTopBottom:menuScrollBarPadding
          interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                  menuColor:colorMenus
                             highlightColor:colorIlluminateOnDrag
                    secondaryHighlightColor:colorIlluminateOnDrag
                                layoutStyle:horizontal
       automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:trashBar
            dragAndDropGroupID:@"trash"
            optionalDataSource:dataSource
         templateForIconLayout:defaultIconSmall
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    [facade selectHandlersForMenu:trashBar withGestureHandlerSetting:singleSelectionDragAndOpen dragHandler:default_deleteMovedObjects dropHandler:automaticallyImportDataAtEndOfList];
    
    [facade hideMenu:trashBar];
    
    
    // MAKE CATEGORY BAR
    categoryBar = [facade makeNewMenuWithTitle:@"categoryBar"
                                 withMainFrame:headerFrame
            paddingForScrollLeftRightTopBottom:menuScrollBarPadding
             interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                     menuColor:colorMenus
                                highlightColor:colorIlluminateOnDrag
                       secondaryHighlightColor:colorIlluminateOnDrag
                                   layoutStyle:horizontal
          automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:categoryBar
            dragAndDropGroupID:@"categoryBar"
            optionalDataSource:dataSource
         templateForIconLayout:defaultIconSmall
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    // use default handling
    
    
    // MAKE PLAYLIST BAR
    
    MCIconForMenu *iconTemplateForPlaylist = [facade makeIconToUseAsTemplateWithBackgroundColor:colorForIcons
                                                          highlightColor:colorForIcons
                                                        mainFrameWdAndHt:CGPointMake(200, 100)
                                                              imageFrame:CGRectMake(10, 15, 80, 70)
                                                               textFrame:CGRectMake(95, 45, 80, 15)];
    
    playlistBar = [facade makeNewMenuWithTitle:@"playlistBar"
                                 withMainFrame:headerFrame
            paddingForScrollLeftRightTopBottom:menuScrollBarPadding
             interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                     menuColor:colorMenus
                                highlightColor:colorIlluminateOnDrag
                       secondaryHighlightColor:colorIlluminateOnDrag
                                   layoutStyle:horizontal
          automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:playlistBar
            dragAndDropGroupID:@"playlist"
            optionalDataSource:dataSource
         templateForIconLayout:iconTemplateForPlaylist
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    // use default handling
    
    [facade hideMenu:playlistBar];
    
}

-(void)switchBetweenHeaderMenus:(id)sender
{
    
    // UPDATE MENU
    if(sender == trashButton){

        [facade unhideMenu:trashBar];
        [facade hideMenu:categoryBar];
        [facade hideMenu:playlistBar];
        
    }else if(sender == categoryButton){
        
        [facade unhideMenu:categoryBar];
        [facade hideMenu:trashBar];
        [facade hideMenu:playlistBar];
        
    }else if(sender == playlistButton){
        
        [facade unhideMenu:playlistBar];
        [facade hideMenu:trashBar];
        [facade hideMenu:categoryBar];
        
    }else{}
    
    
}

-(void)linkMenusWhichShareData
{
    
    // when a menu receives a drop, it will send updates to every menu in its menu.sharedListWithMenuAndItsAliases property
    
    
    // the trashButtonEmbeddedMenuAndDropLocation should share data with the trashBar
    NSMutableArray *updateWithTrash = [NSMutableArray arrayWithObjects:trashBar, trashButtonEmbeddedMenuAndDropLocation, nil];
    
    // FOR UPGRADE: ADD FACADE METHOD
    trashBar.sharedListWithMenuAndItsAliases = updateWithTrash;
    trashButtonEmbeddedMenuAndDropLocation.sharedListWithMenuAndItsAliases = updateWithTrash;
    
    
    // the playlistButtonEmbeddedMenuAndDropLocation should share data with the playlistBar
    NSMutableArray *updateWithPlaylist = [NSMutableArray arrayWithObjects:playlistBar, playlistButtonEmbeddedMenuAndDropLocation, nil];
    
    playlistBar.sharedListWithMenuAndItsAliases = updateWithPlaylist;
    playlistButtonEmbeddedMenuAndDropLocation.sharedListWithMenuAndItsAliases = updateWithPlaylist;
    
}


#pragma mark COMMAND BAR

-(void)createCommandBarRightAndLeft
{
    commandBarLeft = [facade makeNewMenuWithTitle:@"commandBarLeft"
                                withMainFrame:CGRectMake(0, viewWindowRect.size.height - heightOfFooter,
                        4 *(defaultIconSmall.icon_frameForView.size.width + spacingBetweenIcons) + menuScrollBarPadding.origin.x + interiorPaddingAroundData.origin.x,
                                                heightOfFooter)
           paddingForScrollLeftRightTopBottom:CGRectMake(menuScrollBarPadding.origin.x,
                                                         0,
                                                         menuScrollBarPadding.size.width,
                                                         menuScrollBarPadding.size.height)
                interiorPaddingLeftRightTopBottom:CGRectMake(interiorPaddingAroundData.origin.x,
                                                             0,
                                                             interiorPaddingAroundData.size.width,
                                                             interiorPaddingAroundData.size.height)
                                   menuColor:colorMenus
                               highlightColor:colorIlluminateOnDrag
                      secondaryHighlightColor:colorIlluminateOnDrag
                                  layoutStyle:horizontal
         automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:commandBarLeft
            dragAndDropGroupID:@"commandBarLeft"
            optionalDataSource:dataSource
         templateForIconLayout:defaultIconSmall
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
                   backgroundCanvasColor:colorMenus
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    

    [facade selectHandlersForMenu:commandBarLeft withGestureHandlerSetting:buttonDefaultBehavior dragHandler:default_deleteMovedObjects dropHandler: defaultAutomaticallyImportData];
  
    
    // MAKE RIGHT MENU / BAR
    // (should be the same as defaultIconSmall, except for the highlight color; if change, will
    //  need to check alignment)
    MCIconForMenu *iconTemplate = [facade makeIconToUseAsTemplateWithBackgroundColor:colorForIcons
                                                                        highlightColor:colorIsSelected
                                                                      mainFrameWdAndHt:CGPointMake(100, 100)
                                                                            imageFrame:CGRectMake(10, 10, 80, 70)
                                                                             textFrame:CGRectMake(10, 82, 80, 15)];
    
    commandBarRight = [facade makeNewMenuWithTitle:@"commandBarRight"
                                     withMainFrame:CGRectMake(commandBarLeft.frame.size.width,
                                                        viewWindowRect.size.height - heightOfFooter,
                                                        viewWindowRect.size.width - commandBarLeft.frame.size.width,
                                                        heightOfFooter)
                paddingForScrollLeftRightTopBottom:CGRectMake(0,
                                                              menuScrollBarPadding.origin.y,
                                                              menuScrollBarPadding.size.width,
                                                              menuScrollBarPadding.size.height)
                 interiorPaddingLeftRightTopBottom:CGRectMake(0,
                                                              interiorPaddingAroundData.origin.y,
                                                              interiorPaddingAroundData.size.width,
                                                              interiorPaddingAroundData.size.height)
                                         menuColor:colorMenus
                                    highlightColor:colorForIconsOnIlluminateOnDrag
                           secondaryHighlightColor:colorForIconsOnIlluminateOnDrag
                                       layoutStyle:horizontal
              automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:commandBarRight
            dragAndDropGroupID:@"commandBarRight"
            optionalDataSource:dataSource
         templateForIconLayout:iconTemplate
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    [facade selectHandlersForMenu:commandBarRight withGestureHandlerSetting:buttonStaysSelected dragHandler:default_deleteMovedObjects dropHandler:defaultAutomaticallyImportData];
    
}

-(void) makeCommandBarItems
{
    
    // LEFT SIDE
    addCustomCollectionButton = [facade createIconDataObjectWithTitle:@"+Collection" image:[UIImage imageNamed:@"add"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    pauseButton = [facade createIconDataObjectWithTitle:@"Pause" image:[UIImage imageNamed:@"pause"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    playButton = [facade createIconDataObjectWithTitle:@"Play" image:[UIImage imageNamed:@"play"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    recsButton = [facade createIconDataObjectWithTitle:@"Recommendations" image:[UIImage imageNamed:@"recs"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    
    // add buttons in default order
    [facade updateMenu:commandBarLeft withIconData:[[NSMutableArray alloc]initWithObjects: recsButton, addCustomCollectionButton, playButton, pauseButton, nil]];
    
    // RIGHT SIDE
    trashButton = [facade createIconDataObjectWithTitle:@"Trash" image:[UIImage imageNamed:@"trash"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    categoryButton = [facade createIconDataObjectWithTitle:@"Categories" image:[UIImage imageNamed:@"categories"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    playlistButton = [facade createIconDataObjectWithTitle:@"Playlist" image:[UIImage imageNamed:@"playlist"] dataType:@"tellDelegateToRunCommand" dataObject:nil iconUniqueIdentifier:nil];
    
    [self createTrashCan];
    [self createPlayListDragLocation];

    // add buttons in default order
    [facade updateMenu:commandBarRight withIconData:[[NSMutableArray alloc]initWithObjects: playlistButton, categoryButton, trashButton, nil]];
    
    // the categoryButton is open in default, need to update menu to reflect this fact - update color
    for(MCIconForMenu *icon in commandBarRight.menuItemsBeingDisplayed){
    
        if(icon.iconData == categoryButton){
        
            icon.backgroundColor = colorIsSelected;
        }
    }

}

-(void)createTrashCan
{
    // put an embedded menu in the trash icon
    
    trashButtonEmbeddedMenuAndDropLocation = [facade makeNewMenuWithTitle:@"trashButtonMenuAndDropLocation"
                                     withMainFrame:CGRectMake(0,0,200,200)
                paddingForScrollLeftRightTopBottom:menuScrollBarPadding
                 interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                         menuColor:colorDefaultBlackScreen
                                    highlightColor:colorForIconsOnIlluminateOnDrag
                           secondaryHighlightColor:colorForIconsOnIlluminateOnDrag
                                       layoutStyle:horizontal
              automaticallyAddToViewControllerView:NO];
    
    
    [facade setSettingsForMenu:trashButtonEmbeddedMenuAndDropLocation
            dragAndDropGroupID:@"trash"
            optionalDataSource:dataSource
         templateForIconLayout:defaultIconSmall
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    [facade selectHandlersForMenu:trashButtonEmbeddedMenuAndDropLocation withGestureHandlerSetting:singleSelectionDragAndOpen dragHandler:default_deleteMovedObjects dropHandler:automaticallyImportDataAtEndOfList];  // cannot select, so dragHandler setting irrelevant
    
    trashButton.icon_pointerToDataObject = trashButtonEmbeddedMenuAndDropLocation;
    
}

-(void)createPlayListDragLocation
{
    // put an embedded menu in the trash icon
    
    playlistButtonEmbeddedMenuAndDropLocation = [facade makeNewMenuWithTitle:@"playlistDropLocation"
                                     withMainFrame:CGRectMake(0,0,200,200)
                paddingForScrollLeftRightTopBottom:menuScrollBarPadding
                 interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                         menuColor:colorDefaultBlackScreen
                                    highlightColor:colorForIconsOnIlluminateOnDrag
                           secondaryHighlightColor:colorForIconsOnIlluminateOnDrag
                                       layoutStyle:horizontal
              automaticallyAddToViewControllerView:NO];
    
    
    [facade setSettingsForMenu:playlistButtonEmbeddedMenuAndDropLocation
            dragAndDropGroupID:@"playlist"
            optionalDataSource:dataSource
         templateForIconLayout:defaultIconSmall
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
                   backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    playlistButton.icon_pointerToDataObject = playlistButtonEmbeddedMenuAndDropLocation;
    
}


#pragma mark DISPLAY MENU

-(void)createDisplayMenu
{
    
    MCIconForMenu *iconEmbeddedMenuForDisplayBar = [facade makeIconToUseAsTemplateWithBackgroundColor:colorForDisplayScrollBarBorder
        highlightColor:colorForDisplayScrollBarBorder
        mainFrameWdAndHt:CGPointMake(viewWindowRect.size.width - menuScrollBarPadding.origin.x - menuScrollBarPadding.origin.y - interiorPaddingAroundData.origin.x - interiorPaddingAroundData.origin.y, 260)
        imageFrame:CGRectMake(0,0,0,0)
        textFrame:CGRectMake(5, 0, 160,16)];
    
    displayMenu = [facade makeNewMenuWithTitle:@"displayMenu"
                                 withMainFrame:CGRectMake(0, heightOfHeader, viewWindowRect.size.width, viewWindowRect.size.height - heightOfHeader - heightOfFooter)
            paddingForScrollLeftRightTopBottom:menuScrollBarPadding
             interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                     menuColor:colorMenus
                                highlightColor:colorIlluminateOnDrag
                       secondaryHighlightColor:colorIlluminateOnDrag
                                   layoutStyle:vertical
          automaticallyAddToViewControllerView:YES];
    
    
    [facade setSettingsForMenu:displayMenu
            dragAndDropGroupID:@"displayMenu"
            optionalDataSource:dataSource
         templateForIconLayout:iconEmbeddedMenuForDisplayBar
          numberItemsToDisplay:100
           spacingBetweenIcons:2*spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:openFile];
    
}


#pragma mark DATA SOURCE DELEGATE

-(void)notifyDataSourceAboutToDropFromOrigin:(MCMenu *)origin toDestination:(MCMenu *)destination
{

    // when drop onto playlist, we do not want to delete the icon from the original menu
    // temporarily change handling
    if(destination == playlistBar){
    
        // add new items to drop location
        [facade temporarilyChangeHandlersToCustomizeDragAndDropBehaviorForMenusWithOrigin:origin dropDestination:destination originDragHandlerSetting:doNotDeleteMovedObjects dropDestinationHandlerSetting:defaultAutomaticallyImportData];
    
    }else if (destination == playlistButtonEmbeddedMenuAndDropLocation){
    
        // add new item to end of list
        [facade temporarilyChangeHandlersToCustomizeDragAndDropBehaviorForMenusWithOrigin:origin dropDestination:destination originDragHandlerSetting:doNotDeleteMovedObjects dropDestinationHandlerSetting:automaticallyImportDataAtEndOfList];
    
    }
    
}


-(void)notifyDataSourceOfDroppedData:(DropNotifications)currentDragProgress droppedObjects:(NSMutableArray *)droppedObjects indexNumberForInsertion:(int)indexNumber sender:(MCMenu *)sender;
{
    
    // DATASOURCE UNUSED
    
    // log changes
    int x = 1;
    for(id obj in droppedObjects){
        NSString *iconOrMenu;
        if([obj isKindOfClass:[MCMenu class]]){
            iconOrMenu = [(MCMenu *)obj menu_title];
        }else if([obj isKindOfClass:[MCIconData class]]){
            iconOrMenu = [(MCIconData *)obj icon_title];
        }else{  return;}
        NSLog(@"DATA RECEIVED: %x)  DATA OBJECT: %@    BY MENU: %@", x, iconOrMenu, sender.menu_title);
        x++;
    }
    
}

-(void)notifyDataSourceOfDeletedIcons:(NSArray *)objectsForRemoval fromMenu:(MCMenu *)fromMenu dropDestination:(MCMenu *)dropLoc
{
    
    // DATASOURCE UNUSED
    
    // log changes
    for(MCIconData *icon in objectsForRemoval){
        NSLog(@"DELETION = DATA OBJECT: %@  FROM MENU: %@", icon.icon_title, fromMenu.menu_title);}
    
}

-(void)notifyDataSourceCommandReceivedFromIcon:(id)iconDataObjectWithCommand sender:(id)sender
{
    
    
    if(sender == trashButton || sender == categoryButton || sender == playlistButton){
        
        [self switchBetweenHeaderMenus:sender];
        
    }else if (sender == addCustomCollectionButton){
        
        NSMutableArray *nwData = [NSMutableArray arrayWithArray:categoryBar.menu_rawMenuData];
        [nwData addObject:[self addCategory:@"My New Category" image:[UIImage imageNamed:@"My Category"]]];
        
        [facade updateMenu:categoryBar withIconData:nwData];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"need to implement command" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
    }
    
    
}


#pragma mark ADD DATA

-(void)createCategories
{
    
    // since demo, not going to load, download, save, etc.
    NSMutableArray *listOfIconsToAdd = [NSMutableArray new];
    
    [listOfIconsToAdd addObject:[self addCategory:@"Rock" image:[UIImage imageNamed:@"rock"]]];
    [listOfIconsToAdd addObject:[self addCategory:@"Hip Hop" image:[UIImage imageNamed:@"hip hop"]]];
    [listOfIconsToAdd addObject:[self addCategory:@"Classical" image:[UIImage imageNamed:@"classical"]]];
    [listOfIconsToAdd addObject:[self addCategory:@"Country" image:[UIImage imageNamed:@"country"]]];
    [listOfIconsToAdd addObject:[self addCategory:@"Jazz" image:[UIImage imageNamed:@"jazz"]]];
    [listOfIconsToAdd addObject:[self addCategory:@"80s" image:[UIImage imageNamed:@"80s"]]];
    
    [facade updateMenu:categoryBar withIconData:listOfIconsToAdd];
    
}

-(MCIconData *)addCategory:(NSString *)title image:(UIImage *)image
{
    
    // ie put an embedded menu in an icon and add it to the category bar
    
    // 1) BUILD MENU
    
    MCIconForMenu *iconTemplate = [facade makeIconToUseAsTemplateWithBackgroundColor:colorForIcons
                                                         highlightColor:colorForIcons
                                                       mainFrameWdAndHt:CGPointMake(200, 200)
                                                             imageFrame:CGRectMake(20, 20, 160, 140)
                                                              textFrame:CGRectMake(20, 164, 160, 30)];
    
    MCMenu *nwMenu =[facade makeNewMenuWithTitle:title
                                   withMainFrame:CGRectMake(0,0,260,260)
              paddingForScrollLeftRightTopBottom:menuScrollBarPadding
               interiorPaddingLeftRightTopBottom:interiorPaddingAroundData
                                       menuColor:colorDefaultBlackScreen
                                  highlightColor:colorForIconsOnIlluminateOnDrag
                         secondaryHighlightColor:colorForIconsOnIlluminateOnDrag
                                     layoutStyle:horizontal
            automaticallyAddToViewControllerView:NO];
    
    
    [facade setSettingsForMenu:nwMenu
            dragAndDropGroupID:@"showSingleCategory"
            optionalDataSource:dataSource
         templateForIconLayout:iconTemplate
          numberItemsToDisplay:100
           spacingBetweenIcons:spacingBetweenIcons
         backgroundCanvasColor:colorDefaultBlackScreen
             canvasBorderColor:colorDefaultBlackScreen
     embedOpenFilesInMenuItems:showIconNotEmbeddedFile];
    
    
    // 2) BUILD ICON
    return [facade createIconDataObjectWithTitle:title image:image dataType:@"MCMenu" dataObject:nwMenu iconUniqueIdentifier:nil];
    
}

-(void)addSampleSongs
{
    
    //our default categories: @"Rock", @"Hip Hop", @"Classical", @"Country", @"Jazz", @"80s"
    
    [self manuallyAddItemsToCategoryWithName:@"Rock"
                     arrayOfTitles_NSStrings:[NSMutableArray arrayWithObjects:@"song a", @"song b", @"c", @"d", @"e", nil]
                     parallelArrayOfUiImages:[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"a"], [UIImage imageNamed:@"b"], [UIImage imageNamed:@"c"], [UIImage imageNamed:@"d"], [UIImage imageNamed:@"e"], nil]];
    
    [self manuallyAddItemsToCategoryWithName:@"Hip Hop"
                     arrayOfTitles_NSStrings:[NSMutableArray arrayWithObjects:@"f", @"g", @"h", @"i", @"j", nil]
                     parallelArrayOfUiImages:[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"f"], [UIImage imageNamed:@"g"], [UIImage imageNamed:@"h"], [UIImage imageNamed:@"i"], [UIImage imageNamed:@"j"], nil]];
    
    [self manuallyAddItemsToCategoryWithName:@"Classical"
                     arrayOfTitles_NSStrings:[NSMutableArray arrayWithObjects:@"k", @"l", @"m", @"d", @"e", nil]
                     parallelArrayOfUiImages:[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"k"], [UIImage imageNamed:@"l"], [UIImage imageNamed:@"m"], [UIImage imageNamed:@"n"], [UIImage imageNamed:@"o"], nil]];
    
    [self manuallyAddItemsToCategoryWithName:@"80s"
                     arrayOfTitles_NSStrings:[NSMutableArray arrayWithObjects:@"a", @"b", nil]
                     parallelArrayOfUiImages:[NSMutableArray arrayWithObjects:[UIImage imageNamed:@"p"], [UIImage imageNamed:@"q"], nil]];
    
}

-(void)manuallyAddItemsToCategoryWithName:(NSString *)categoryName arrayOfTitles_NSStrings:(NSMutableArray *)titles parallelArrayOfUiImages:(NSMutableArray *)images
{
    
    // lookup menu want to work with, cycling through the icons in the iconsInCategoryBar

    MCMenu *menuWorkingWith;
    
    for(MCIconData *checkIcon in categoryBar.menu_rawMenuData){
        
        // all objects in the icons should be MCMenus, but let's put in a check anyway
        if(![checkIcon.icon_pointerToDataObject isKindOfClass:[MCMenu class]]){ break; }
        
        NSString *menuName = [(MCMenu *)checkIcon.icon_pointerToDataObject menu_title];
        
        if([menuName isEqualToString:categoryName]){
            
            menuWorkingWith = (MCMenu *)checkIcon.icon_pointerToDataObject;
            break;
            
        }
    }
    
    if(!menuWorkingWith){ NSLog(@"Add menu to category failed.  Check category name spelling.");}
    
    
    // make a copy of categories data (rem: we are letting the menu store the data for us)
    NSMutableArray *menuData = [NSMutableArray arrayWithArray:menuWorkingWith.menu_rawMenuData];
    
    // create new icons and add to menuData
    for(int x = 0; x < [titles count]; x++) {
        
        MCIconData *icon = [facade createIconDataObjectWithTitle:[titles objectAtIndex:x]
                                                           image:[images objectAtIndex:x]
                                                        dataType:nil dataObject:nil iconUniqueIdentifier:nil];
        [menuData addObject:icon];
        
    }
    
    // update the menu with new data
    [facade updateMenu:menuWorkingWith withIconData:menuData];
}


#pragma mark PERMISSIONS

-(void)setDragAndDropPermissions
{

    NSMutableArray *allGroups = [NSMutableArray arrayWithObjects:
                    @"categoryBar", @"playlist", @"trash", @"displayMenu", @"showSingleCategory", nil];
    

    // CATEGORIES - MAY DRAG TO SELF, MAIN DISPLAY
    [facade setPermissionsForMenusWithDragAndDropGroupID:@"categoryBar"
                           canDragToMenusWithIdentifiers:[NSMutableArray arrayWithObjects:@"categoryBar", @"displayMenu", nil]
          willAcceptDroppedItemsFromMenusWithIdentifiers:allGroups];
    
    // MAIN DISPLAY - MAY DRAG TO SELF, CATEGORIES, TRASH
    [facade setPermissionsForMenusWithDragAndDropGroupID:@"displayMenu"                            canDragToMenusWithIdentifiers:[NSMutableArray arrayWithObjects:@"displayMenu", @"categoryBar", nil]
          willAcceptDroppedItemsFromMenusWithIdentifiers:allGroups];
    
    // SUBCATEGORIES - MAY DRAG TO SELF, TRASH, PLAYLIST
    [facade setPermissionsForMenusWithDragAndDropGroupID:@"showSingleCategory"                            canDragToMenusWithIdentifiers:[NSMutableArray arrayWithObjects:@"showSingleCategory", @"trash", @"playlist", nil]
          willAcceptDroppedItemsFromMenusWithIdentifiers:allGroups];
    
    
    //- TRASH
    [facade setPermissionsForMenusWithDragAndDropGroupID:@"trash"
                           canDragToMenusWithIdentifiers:[NSMutableArray arrayWithObjects: @"playlist", @"trash", @"showSingleCategory", nil]
          willAcceptDroppedItemsFromMenusWithIdentifiers:allGroups];
    
    //- PLAYLIST
    [facade setPermissionsForMenusWithDragAndDropGroupID:@"playlist"                            canDragToMenusWithIdentifiers:[NSMutableArray arrayWithObjects:@"playlist",@"trash",@"showSingleCategory",nil]
          willAcceptDroppedItemsFromMenusWithIdentifiers:allGroups];
    
    
}



@end
