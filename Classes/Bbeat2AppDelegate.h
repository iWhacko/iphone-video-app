
#import <UIKit/UIKit.h>
#import "Bbeat2ViewController.h"
//#import "FlipSideViewController.h"
#import "XMLReader.h"
#import "MediaObject.h"

@interface Bbeat2AppDelegate : NSObject <UIApplicationDelegate> {
	
	IBOutlet UIWindow			*window;
	IBOutlet Bbeat2ViewController	*mViewController;
	IBOutlet UIScrollView *thumbGrid;
	IBOutlet UIScrollView *favsThumbGrid;
	IBOutlet UIBarButtonItem * refreshButton;
	IBOutlet UIButton * moreVideos;
	IBOutlet UIButton * plusButton;
	IBOutlet UIBarButtonItem * favsButton;
	IBOutlet UIBarButtonItem * playButton;
	IBOutlet UISegmentedControl * segmentedControl;
	IBOutlet UILabel * favText;
	IBOutlet UIImageView * staticy;
	
	NSMutableArray *playlist;
	NSMutableArray *tempPlaylist;
	NSInteger backgroundColor;
	NSInteger controlMode;
	NSInteger scalingMode;
	//int currentListSize;
	//NSString documentsDirectory;
	BOOL _isDataSourceAvailable;
	BOOL foundAtLeastOneVideo;
	BOOL WiFiMode;
	BOOL showingFavs;
}

-(void)setUserSettingsDefaults;
-(void)addToPlayList:(MediaObject *)newMediaObject;
-(void)getPlayList;
-(BOOL)saveThisFile:(NSString *)remotePath withFileName:(NSString *)fileName;
//-(void)documentsDirPath;
//-(void)getLocalPlaylist;
//-(void)downloadAndSavePlayList;
//-(BOOL)doesVideoExistInPlayList:(MediaObject*)mediaToTest;
-(BOOL)isDataSourceAvailable;
-(IBAction)updateClicked:(id)sender;
-(IBAction)moreVideosClicked:(id)sender;
-(IBAction)toggleStars:(id)sender;
-(void)renderGrid : (NSString*)dummyString;
-(void)download_all_videos : (NSString*)dummyString;
-(void)alertWithMessage:(NSString *)message;
-(void)initializePlayLists;
-(void)applicationDidFinishLaunching:(UIApplication *)application;
-(void)applicationWillTerminate:(UIApplication *)application;
-(void)dealloc;

@property (nonatomic, retain) NSMutableArray *playlist;
@property (nonatomic, retain) NSMutableArray *tempPlaylist;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *thumbGrid;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) UIButton *moreVideos;
@property (nonatomic, retain) UIButton *plusButton;
//@property (nonatomic, retain) UIButton *plusButton;
//@property (nonatomic, retain) int *currentListSize;
@property (nonatomic, assign) NSInteger backgroundColor;
@property (nonatomic, assign) NSInteger scalingMode;
@property (nonatomic, assign) NSInteger controlMode;
@property (nonatomic, assign) BOOL foundAtLeastOneVideo;
//@property (nonatomic, assign) NSString documentsDirectory;
@property (nonatomic, assign) BOOL WiFiMode;
@property (nonatomic,assign) BOOL showingFavs;

@end

