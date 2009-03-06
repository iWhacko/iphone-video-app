
#import "Bbeat2AppDelegate.h"
#import "FlipSideView.h"
#import "videoIcon.h"
#import <SystemConfiguration/SystemConfiguration.h>



//NSString *feedURLString = @"http://www.blinkx.com/api3/start.php?action=query&text=ITN&totalresults=true&maxresults=10&random=true";
//NSString *feedURLString = @"http://api.blinkx.com/api3/start?text=channel:screensaverentertainment&staging=true&maxresults=49&random=true&timeoutms=30000";
//NSString *feedURLString = @"http://api.blinkx.com/api3/start?channelid=1001&staging=true&maxresults=80&random=true&timeoutms=30000&printfields=staticpreview,media_location";
//NSString *feedURLString = @"http://api.blinkx.com/api3/start?text=channel:associatedpress&staging=true&maxresults=80&random=true&timeoutms=30000&printfields=staticpreview,media_location";
NSString *feedURLString = @"http://api.blinkx.com/api3/start?text=channel:screensaverentertainment&staging=true&random=true&maxresults=%d&timeoutms=30000&printfields=staticpreview,media_location";
NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";
NSString *kListSizeKey= @"20";

int currentMaxResultInt = 232;

BOOL *WiFiMode;

BOOL *foundAtLeastOneVideo;
BOOL *shouldAutoPlay = YES;

NSString *sCellNetwork;

int currentListSize = 20;
//int foundFavorites = 0;

BOOL isDownloadingVideos=NO;
BOOL isDownloadingThumbnails=NO;
BOOL shouldStopDownloading = NO;
BOOL missingThumbnailsFlag = YES;
BOOL needsGridUpdate = NO;

BOOL shouldRestoreFavMode = NO;

BOOL scrollingEnabled =NO;

BOOL shouldPlayVideoOnLaunch = YES;

BOOL isRendering = NO;

@implementation Bbeat2AppDelegate

@synthesize window;
@synthesize scalingMode;
@synthesize controlMode;
@synthesize backgroundColor;
@synthesize playlist;
@synthesize tempPlaylist;
@synthesize foundAtLeastOneVideo;
@synthesize WiFiMode;
@synthesize thumbGrid;
@synthesize moreVideos;
@synthesize refreshButton;
@synthesize plusButton;
@synthesize showingFavs;
//@synthesize segmentedControl;


-(void)setUserSettingsDefaults
{
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kScalingModeKey];
    if (testValue == nil)
    {
        // No default movie player settings values have been set, create them here based on our 
        // settings bundle info.
        //
        // The values to be set for movie playback are:
        //
        //    - scaling mode (None, Aspect Fill, Aspect Fit, Fill)
        //    - controller mode (Standard Controls, Volume Only, Hidden)
        //    - background color (Any UIColor value)
        //
        NSString *pathStr = [[NSBundle mainBundle] bundlePath];
        NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
        NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];

        NSNumber *controlModeDefault;
        NSNumber *scalingModeDefault;
        NSNumber *backgroundColorDefault;
        NSDictionary *prefItem;
        for (prefItem in prefSpecifierArray)
        {
            NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			NSLog(keyValueStr);
            id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            if ([keyValueStr isEqualToString:kScalingModeKey])
            {
                scalingModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kControlModeKey])
            {
                controlModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kBackgroundColorKey])
            {
                backgroundColorDefault = defaultValue;
            }
			else if ([keyValueStr isEqualToString:kListSizeKey])
            {
                backgroundColorDefault = defaultValue;
            }
        }

        // since no default values have been set, create them here
        NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
		 scalingModeDefault, kScalingModeKey,
		 controlModeDefault, kControlModeKey,
		 backgroundColorDefault, kBackgroundColorKey,
		 nil];
		/*NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      0, kScalingModeKey,
                                      0, kControlModeKey,
                                      0, kBackgroundColorKey,
                                      nil];*/
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    scalingMode = [[NSUserDefaults standardUserDefaults] integerForKey:kScalingModeKey];
    controlMode = [[NSUserDefaults standardUserDefaults] integerForKey:kControlModeKey];
    backgroundColor = [[NSUserDefaults standardUserDefaults] integerForKey:kBackgroundColorKey];
	
}

-(void)addToPlayList:(MediaObject *)newMediaObject
{
	//if(![self doesVideoExistInPlayList:newMediaObject]){
		[self.playlist addObject:newMediaObject];
		self.foundAtLeastOneVideo = YES;
	//}
    
}
- (int*) getListSize
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *fileName = @"blinkxBeat.infoFile";
	NSString *pathToInfoFile = [folder stringByAppendingPathComponent: fileName];
	if ([fileManager fileExistsAtPath: pathToInfoFile] == NO)
	{
		[fileManager createDirectoryAtPath: folder attributes: nil];
		NSMutableDictionary * rootObject = [NSMutableDictionary dictionary];
		[rootObject setValue: [NSNumber numberWithInt:20] forKey:@"ListSize"];
		[NSKeyedArchiver archiveRootObject: rootObject toFile: pathToInfoFile];
	}
	NSDictionary * rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToInfoFile];
	return [[rootObject valueForKey:@"ListSize"] intValue];    
}
- (int*) setListSize :(int * )newSize
{
	//NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *fileName = @"blinkxBeat.infoFile";
	NSString *pathToInfoFile = [folder stringByAppendingPathComponent: fileName];
	NSMutableDictionary * rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue: [NSNumber numberWithInt:newSize] forKey:@"ListSize"];
	[NSKeyedArchiver archiveRootObject: rootObject toFile: pathToInfoFile];
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToInfoFile];
	return [[rootObject valueForKey:@"ListSize"] intValue];    
}
-(int)getCurrentListSize{
	return currentListSize;
}

- (void)getPlayList:(NSString *)playListPath
{
	NSLog([@"getPlayList" stringByAppendingString:playListPath]);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    XMLReader *streamingParser = [[XMLReader alloc] init];
    [streamingParser parseXMLFileAtURL:[NSURL URLWithString:playListPath] parseError:&parseError start:[self.playlist count] count:currentListSize];
    [streamingParser release];
    [pool release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}
- (void)getLocalPlayList:(NSObject*)dummy
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString * playListPath = [documentsDirPath stringByAppendingString:@"/start.xml"];
	
	// should check if start.xml exists, if not, downloads it, if it does, parses it, and refreshes start.xml in the background
	if(![mViewController doesFileExistLocally:@"localFile/start.xml"]){
		[self saveThisFile:[NSString stringWithFormat: feedURLString,--currentMaxResultInt] withFileName:@"start.xml"];
	}else{
		NSLog([@"getPlayList" stringByAppendingString:playListPath]);
		NSError *parseError = nil;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		XMLReader *streamingParser = [[XMLReader alloc] init];
		[streamingParser parseXMLwithData:[[NSData alloc] initWithContentsOfFile:playListPath] parseError:&parseError start:[self.playlist count] count:currentListSize];
		[streamingParser release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
	}
	[pool release];
	[self performSelectorInBackground:@selector(downloadNewPlaylist) withObject:nil];
}
-(void)downloadNewPlaylist{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self saveThisFile:[NSString stringWithFormat: feedURLString,--currentMaxResultInt] withFileName:@"start.xml"];
	[pool release];
}
-(BOOL)addToGrid:(MediaObject *)newMediaObject atPosition:(int)position{
	//NSLog(@"adding to grid %i",position);
	if([self getVideoIconByTag:position]!=nil)return;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *thisThumbFileName = [[[newMediaObject finalPath] lastPathComponent] stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];
	NSString *thumbnailLocalPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, thisThumbFileName];
	videoIcon *thisVideoIcon = [[videoIcon alloc] init];
	UIImage *thisThumbImage=[[[UIImage alloc] initWithContentsOfFile:thumbnailLocalPath] retain];
	[thisVideoIcon setBackground:thisThumbImage];
	[thisVideoIcon addTarget:self action:@selector(iconClicked:)];
	[thisVideoIcon setThisTag:position];
	[thisVideoIcon setTag:position];
	thisVideoIcon.frame = CGRectMake((position % 4) * 79+3,floor(position / 4) * 79+3, 76, 76);
	if([mViewController shouldRenderGrid]){
		[thumbGrid addSubview:thisVideoIcon];
	}else{
		thisVideoIcon.alpha=0.0;
		[thumbGrid addSubview:thisVideoIcon];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		if(!favsButton.enabled){
			//in show favs mode
			[thisVideoIcon favMode];
		}else{
			[thisVideoIcon unFavMode];
			// in regular mode
		}
		thisVideoIcon.alpha=1.0;
		[UIView commitAnimations];
	}
	return YES;
	[pool release];
	[thumbGrid setContentSize:CGSizeMake(320,460)];

}
BOOL showingStars = NO;
-(void)iconClicked:(id)sender{
	// if favorite mode, toggle favorite, else play the video
	
	if(showingStars){
		[self starClicked:sender];
	}else{
		[mViewController setClipAndPlay:sender];
	}
}

-(void)segmentedButtonBarClicked:(id)sender{
	[thumbGrid setContentOffset:CGPointMake(0,0) animated:YES];
	
	BOOL toFavOrToNormal =([sender selectedSegmentIndex]==0)?NO:YES;
	
	//if in favMode, favs grid view should hide stars, but remember to restore when toggled back
	if(toFavOrToNormal && showingStars){
		[self toggleStars:nil];
		shouldRestoreFavMode=YES;
	}else if(shouldRestoreFavMode){
		shouldRestoreFavMode=NO;
		[self toggleStars:nil];
	}
	
	// enable or disable buttons in favs grid
	if(toFavOrToNormal){
		refreshButton.enabled=NO;
		favsButton.enabled=NO;
	}else{
		refreshButton.enabled=YES;
		favsButton.enabled=YES;
	}
	
	// update the flag so everyone knows
	if(toFavOrToNormal){
		self.showingFavs=YES;
	}else{
		self.showingFavs=NO;
	}
	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];

	int foundFavorites = 0;
	for(int i = 0; i < [[self playlist] count]; i++){
		UIView *view = [self getVideoIconByTag:i];
		if([view isKindOfClass:[videoIcon class]]){
			int  thisTag = [view tag];
			MediaObject * thisMovie = [[self playlist] objectAtIndex:thisTag];
			if(toFavOrToNormal){
				// go to favorite mode!
				if(thisMovie.isFav==@"fav"){
					view.frame = CGRectMake((foundFavorites % 4) * 79+3,floor(foundFavorites / 4) * 79+3, 76, 76);
					view.alpha=1.0;
					foundFavorites++;
				}else{
					view.frame = CGRectMake((thisTag % 4) * 79+3,floor(thisTag / 4) * 79+3, 76, 76);
					view.alpha=0.0;
				}
			}else{
				// back to normal mode
				view.frame = CGRectMake((thisTag % 4) * 79+3,floor(thisTag / 4) * 79+3, 76, 76);
				view.alpha=1.0;
			}
		}
	}
	/*
	for (UIView *view in self.thumbGrid.subviews){
		if([view isKindOfClass:[videoIcon class]]){
			int  thisTag = [view tag];
			MediaObject * thisMovie = [[self playlist] objectAtIndex:thisTag];
			if(toFavOrToNormal){
				// go to favorite mode!
				if(thisMovie.isFav==@"fav"){
					view.frame = CGRectMake((foundFavorites % 4) * 79+3,floor(foundFavorites / 4) * 79+3, 76, 76);
					view.alpha=1.0;
					foundFavorites++;
				}else{
					view.frame = CGRectMake((thisTag % 4) * 79+3,floor(thisTag / 4) * 79+3, 76, 76);
					view.alpha=0.0;
				}
			}else{
				// back to normal mode
				view.frame = CGRectMake((thisTag % 4) * 79+3,floor(thisTag / 4) * 79+3, 76, 76);
				view.alpha=1.0;
			}
		}
	}*/
	[UIView commitAnimations];
	
	/*
	if([sender selectedSegmentIndex]==0){
		if(showingStars)[self toggleStars:nil];
		for (UIView *view in self.thumbGrid.subviews) {
			//NSLog(@"the tag for button: %i", view.tag);
			if (view.tag<500){
				int moviePosition = view.tag;
				if(showingStars){
					view.alpha=0.7;
				}else{
					view.alpha=1.0;
				}
				
				view.frame = CGRectMake((moviePosition % 4) * 79+3,floor(moviePosition / 4) * 79+3, 76, 76);
			}
			if(view.tag>1999 && view.tag < 4000){
				if(showingStars){
					int thisMovie = (view.tag<2999)?view.tag-2000:view.tag-3000;
					view.frame = CGRectMake((thisMovie % 4) * 79+50,floor(thisMovie / 4) * 79+5, 20, 20);
					//view.alpha=1.0;
					[thumbGrid bringSubviewToFront:view];
				}
			}
			if(view.tag==999 || view.tag==1001 || view.tag==1002)view.hidden=NO;
		}
		[thumbGrid setContentSize:CGSizeMake((300), floor([[self playlist] count]/4)*79+180)];
		
	}else if([sender selectedSegmentIndex]==1){
		if(showingStars)[self toggleStars:nil];
		int foundFavorites = 0;
		// there are multiple views with tag 0, like the scrollbar
		BOOL zeroTagFound = NO;
		for (UIView *view in self.thumbGrid.subviews) {
			NSLog(@"the tag for button: %i", view.tag);
			//NSLog(@"the tag star: %i, foundFavs : %i", view.tag,foundFavorites);
			if (view.tag<500){

				MediaObject * thisMovie = [[self playlist] objectAtIndex:view.tag];
				if([thisMovie.isFav isEqualToString:@"fav"]){
					view.alpha=1.0;
					view.frame = CGRectMake((foundFavorites % 4) * 79+3,floor(foundFavorites / 4) * 79+3, 76, 76);
					foundFavorites=foundFavorites+1;
				}else{
					view.alpha=0.0;
				}
			}
			// if this is a star
			
			if(view.tag>1999 && view.tag < 4000){
				int thisMovie = (view.tag<2999)?view.tag-2000:view.tag-3000;
				if(view.tag<2999){
					//star off
					//view.frame = CGRectMake((thisMovie % 4) * 79+50,floor(thisMovie / 4) * 79+5, 20, 20);
					view.alpha=0.0;
				}else if(view.tag>2999){
					if(showingStars){
						view.alpha=0.0;
						//NSLog(@"the tag star: %i, foundFavs : %i", view.tag,foundFavorites);
						//view.frame = CGRectMake(((foundFavorites-1) % 4) * 79+50,floor((foundFavorites-1) / 4) * 79+5, 20, 20);						
					}					
					//star on
				}
				//[thumbGrid bringSubviewToFront:view];
			}
			if(view.tag==999 || view.tag==1001 || view.tag==1002)view.hidden=YES;
		}
		[thumbGrid setContentSize:CGSizeMake((300), floor(foundFavorites/4)*79+180)];
	}
	[UIView commitAnimations];
	[foundFavorites release];
	*/
	
}
-(videoIcon*)getVideoIconByTag:(int*)tag{
	for( UIView * view in thumbGrid.subviews){
		if([view tag] == tag && [view isKindOfClass:[videoIcon class]])return view;
	}
	return nil;
}

-(void)starClicked:(id)sender{
	
	int thisTag = [sender tag];
	MediaObject * thisMovie = [[self playlist] objectAtIndex:thisTag];
	//videoIcon * thisVideoIcon = [thumbGrid viewWithTag:[sender tag]];
	videoIcon * thisVideoIcon = [self getVideoIconByTag:thisTag];
	NSLog(@"clicked tag: %i",thisTag);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	if(thisMovie.isFav==nil){
		thisMovie.isFav=@"fav";
		[thisVideoIcon makeFav];
	}else{
		thisMovie.isFav=nil;
		[thisVideoIcon unMakeFav];
	}
	[UIView commitAnimations];
}

-(IBAction)toggleStars:(id)sender{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	if(showingStars){
		playButton.enabled=YES;
		favText.alpha=0.0;
		for (UIView *view in self.thumbGrid.subviews) {
			if([view isKindOfClass:[videoIcon class]]){
				[view unFavMode];
			}
		}
	}else{
		playButton.enabled=NO;
		favText.alpha=1.0;
		for (videoIcon *view in self.thumbGrid.subviews) {
			if([view isKindOfClass:[videoIcon class]]){
				[view favMode];
			}
		}
	}
	showingStars=(showingStars)?NO:YES;
	[UIView commitAnimations];

}
-(BOOL)saveThisFile:(NSString *)remotePath withFileName:(NSString *)overrideFileName {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog([@"trying to download and save this file : " stringByAppendingString:remotePath]);
	NSFileManager *defaultManager;
	defaultManager = [NSFileManager defaultManager];
	remotePath = [remotePath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	NSString *url = remotePath;
	NSData *fileData = [NSData alloc];
	NSURL *fileURL = [[NSURL alloc] initWithString:url];
	NSString *filename = [NSString alloc];
	if(overrideFileName){
		filename = overrideFileName;
	}else{
		filename = [remotePath lastPathComponent];
	}
	
	NSString * documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if (!documentsDirPath) {NSLog(@"Documents directory not found!"); } 
	

	if (fileURL) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		fileData = [NSData dataWithContentsOfURL:fileURL];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
	}
	NSString *finalFilePath = [documentsDirPath stringByAppendingPathComponent:filename];
	
	
	// setting atomically to no means the file is written directly to the path, without an intermediate file
	// which means the video player can play from this location.
	
	// setting it to yes seems to be more stable... especially if you lose connection, you wont end up with a corrupt file.
	
	if([fileData writeToFile:finalFilePath atomically:YES]){
		NSLog([@"saved!" stringByAppendingString: finalFilePath]);
		[pool release];return YES;
		//[fileData release];
	}else{
		NSLog([@"something went wrong in saving file!" stringByAppendingString: finalFilePath]);
		[pool release];return NO;
	}
	
}
- (BOOL)isDataSourceAvailable
{
	NSLog(@"checking is data source is available");
    static BOOL checkNetwork = YES;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "cdn.blinkx.com";
		
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
		if (flags & kSCNetworkReachabilityFlagsIsWWAN)
			sCellNetwork = @"YES";
		else
			sCellNetwork = @"NO";
        CFRelease(reachability);
    }
	NSLog(@"checking if data source is available - done");
    return _isDataSourceAvailable;
}
-(IBAction)updateClicked:(id)sender{
	//NSLog(@"update clicked!");
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Loading new Videos" message:@"We'll keep your starred ones!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue",nil];
	[alert show];[alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex==0){
		//NSLog(@"alert view returned0!");
	}else if(buttonIndex==1){
		[self performSelectorInBackground:@selector(updatePlaylist) withObject:nil];
	}
}
-(void)updatePlaylist{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if(showingStars)[self toggleStars:nil];
	currentListSize=20;
	[self deleteAll];
	[self setListSize:currentListSize];
	
	// remove all video icons that are not starred
	// move them to a new position if they are starred
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	int foundFavorites=0;
	for (UIView *view in self.thumbGrid.subviews) {
		if([view isKindOfClass:[videoIcon class]]){
			MediaObject * thisMovie = [self.playlist objectAtIndex:view.tag];
			if(thisMovie.isFav==nil){
				[view removeFromSuperview];
			}else{
				[view setTag:foundFavorites];
				[view setThisTag:foundFavorites];
				view.frame = CGRectMake((foundFavorites % 4) * 79+3,floor(foundFavorites / 4) * 79+3, 76, 76);
				foundFavorites++;
			}
		}
	}
	[UIView commitAnimations];
	[pool release];
	[self performSelectorInBackground:@selector(getAndMergePlaylists:) withObject:nil];

}
-(void)getAndMergePlaylists:(NSObject*)dummy {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(![mViewController.av isAnimating])[mViewController.av performSelectorInBackground:@selector(startAnimating) withObject:nil];
	
	// copy the starred items to tempPlaylist

	self.tempPlaylist = [NSMutableArray array];
	for (int i=0; i< [self.playlist count]; i++){
		MediaObject * thisMovie = [self.playlist objectAtIndex:i];
		if(thisMovie.isFav!=nil){
			[self.tempPlaylist addObject:thisMovie];
		}
	}

	//[self.tempPlaylist addObjectsFromArray:self.playlist];
	// update self.playlist with new feed.

	self.playlist = [NSMutableArray array];

	[self getLocalPlayList:nil];

	// fills in tempPlaylist with new items
	
	for(int i=[self.tempPlaylist count]; i< [self.playlist count]; i++){
		MediaObject * thisMovie = [self.playlist objectAtIndex:i];
		[self.tempPlaylist addObject:thisMovie];
	}

	// then copy tempPlaylist back to playlist
	self.playlist = [NSMutableArray array];
	[self.playlist addObjectsFromArray:self.tempPlaylist];

	[thumbGrid setContentOffset:CGPointMake(0,0) animated:YES];

	[mViewController.av stopAnimating];
	shouldAutoPlay=NO;
	moreVideos.userInteractionEnabled=YES;

	[self performSelectorInBackground:@selector(renderGrid:) withObject:nil];
	[pool release];

}
-(void) deleteAll{
	NSLog(@"deleting all");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSFileManager *defaultManager= [NSFileManager defaultManager];
	NSArray *directoryContent = [defaultManager directoryContentsAtPath:documentsDirectory];
	int i;
	//BOOL *foundLocalFile = NO;

	for(i = 0; i < [directoryContent count]; i++){
		NSString *thisFile = [directoryContent objectAtIndex:i];
		if([[directoryContent objectAtIndex:i] hasSuffix:@"jpg"]){
			[defaultManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:thisFile] error:nil];
		}
	}
}

-(IBAction)moreVideosClicked:(id)sender{
	NSLog(@"moreVideosClicked");
	
	if([moreVideos.currentTitle isEqualToString:@"loading..."]){
		return;
	}
	if(currentListSize==100){
		[self alertWithMessage:@"100 videos is the current limit!"];
		return;
	}
	
	currentListSize+=20;
	[self setListSize:currentListSize];
	[mViewController.av2 performSelectorInBackground:@selector(startAnimating) withObject:nil];
	[moreVideos setTitle:@"loading..." forState:UIControlStateNormal];
	plusButton.hidden=YES;
	shouldAutoPlay=NO;

	[NSTimer scheduledTimerWithTimeInterval:(0.1) target:self selector:@selector(initializePlayLists) userInfo:nil repeats:NO];
}

-(void)alertWithMessage:(NSString *)message{
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"oops!" message:message delegate:self cancelButtonTitle:@"wait" otherButtonTitles:@"ok",nil];
	[alert show];[alert release];
}

-(void)initializePlayLists{
	//NSLog(@"debug1");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if([mViewController doesFileExistLocally:@"localFile/start.xml"]){
		NSString * localPlayListPath = [documentsDirPath stringByAppendingString:@"/start.xml"];
		[self getLocalPlayList:localPlayListPath];
		//NSLog(@"debug2");
	}else{
		if ([self isDataSourceAvailable] == NO){
			[self alertWithMessage:@"you need to be online the first time you run blinkx beat! quitting"];
			[super dealloc];
		}else{
			[self saveThisFile:[NSString stringWithFormat: feedURLString,--currentMaxResultInt] withFileName:@"start.xml"];
			NSString * localPlayListPath = [documentsDirPath stringByAppendingString:@"/start.xml"];
			[self getLocalPlayList:localPlayListPath];
		}
	}
	//NSLog(@"debug3");
	if(!self.foundAtLeastOneVideo){
		[self saveThisFile:[NSString stringWithFormat: feedURLString,--currentMaxResultInt] withFileName:@"start.xml"];
		NSString * localPlayListPath = [documentsDirPath stringByAppendingString:@"/start.xml"];
		[self getLocalPlayList:localPlayListPath];
		//[self alertWithMessage:@"something went wrong, quitting app.(this should not happen)"];
		[super dealloc];
		return;
	}
	//NSLog(@"debug4");
	if([self isDataSourceAvailable]){
		if([sCellNetwork isEqualToString:@"NO"]){
			//wifi mode
			NSLog(@"WI FI MODE!");
			//[self performSelectorInBackground:@selector(download_all_videos:) withObject:nil];
			if(!isRendering)[self performSelectorInBackground:@selector(renderGrid:) withObject:nil];
			
		}else{
			//celluar mode
			NSLog(@"3G MODE!");
			if(!isRendering)[self performSelectorInBackground:@selector(renderGrid:) withObject:nil];
		}
	}
	//[self performSelectorInBackground:@selector(download_all_thumbnails:) withObject:nil];

	//[self performSelectorInBackground:@selector(renderGrid:) withObject:nil];
	//[NSTimer scheduledTimerWithTimeInterval:(1) target:self selector:@selector(renderGrid:) userInfo:nil repeats:YES];
	
	if(shouldAutoPlay){
		//NSLog(@"debug5");
		[mViewController initMoviePlayer];
		if(!shouldPlayVideoOnLaunch){
			[mViewController stopPlaying:nil];
		}
		
		//[NSTimer scheduledTimerWithTimeInterval:(0.1) target:mViewController selector:@selector(initMoviePlayer) userInfo:nil repeats:NO];
		shouldAutoPlay=YES;
	}
	needsGridUpdate=YES;
	[pool release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
    // Override point for customization after app launch

	self.playlist = [NSMutableArray array];
	WiFiMode = YES;
	foundAtLeastOneVideo=NO;
	currentListSize = [self getListSize];
	//currentListSize = 20;
	
    // Add the view controller's view as a subview of the window
    [window addSubview: mViewController.view];
    [window makeKeyAndVisible];

    // get the movie player settings defaults
    [self setUserSettingsDefaults];
	//[NSTimer scheduledTimerWithTimeInterval:(5) target:self selector:@selector(download_all_videos:) userInfo:nil repeats:YES];
	//[NSTimer scheduledTimerWithTimeInterval:(4) target:self selector:@selector(download_all_thumbnails:) userInfo:nil repeats:YES];
	//[self performSelectorInBackground:@selector(initializePlayLists) withObject:nil];
	[NSTimer scheduledTimerWithTimeInterval:(0.3) target:self selector:@selector(initializePlayLists) userInfo:nil repeats:NO];
	
	[segmentedControl addTarget:self
						 action:@selector(segmentedButtonBarClicked:)
			   forControlEvents:UIControlEventValueChanged];
	
	
	
}

-(NSString*)getThumbPathForMovie:(MediaObject*)thisMovie{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *thisThumbFileName = [[[thisMovie finalPath] lastPathComponent] stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];
	NSString *thumbnailLocalPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, thisThumbFileName];
	return thumbnailLocalPath;
}

BOOL firstRender = YES;

-(void)renderGrid:(NSString *)dummyString{
	NSLog(@"renderGrid1");
	if(isRendering){return;}
	else{isRendering=YES;}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(![mViewController shouldRenderGrid] || true){
		missingThumbnailsFlag=NO;
		for(int i = 0; i < [[self playlist] count]; i++){
			MediaObject *thisMovie = [[self playlist] objectAtIndex:i];
			NSString * thumbnailLocalPath = [self getThumbPathForMovie:thisMovie];
			if(thisMovie.summary==nil){ // not rendered yet.
				if([mViewController doesFileExistLocally:[thumbnailLocalPath lastPathComponent]]){
					[self addToGrid:thisMovie atPosition:i];
					thisMovie.summary = @"rendered";
				}else{
					missingThumbnailsFlag=YES;
				}
			}	
		}
		if(missingThumbnailsFlag){
			if(!isDownloadingThumbnails)[self performSelectorInBackground:@selector(getThumbnailsInBackground:) withObject:nil];
		}else{
			[self performSelectorInBackground:@selector(download_all_videos:) withObject:nil];
		}
	}
	[pool release];
	isRendering=NO;
	if(needsGridUpdate)[self updateGridPosition];
}

-(void)getThumbnailsInBackground:(NSObject*)dummy{
	if(isDownloadingThumbnails)return;
	isDownloadingThumbnails=YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for(int i = 0; i < [[self playlist] count]; i++){
		MediaObject *thisMovie = [[self playlist] objectAtIndex:i];
		NSString * thumbnailLocalPath = [self getThumbPathForMovie:thisMovie];
		if(thisMovie.summary==nil){ // not rendered yet.
			[self saveThisFile:thisMovie.staticpreview withFileName:[thumbnailLocalPath lastPathComponent]];
			//[self addToGrid:thisMovie atPosition:i];
			[self performSelectorInBackground:@selector(renderGrid:) withObject:nil];
		}	
	}
	[pool release];
	isDownloadingThumbnails=NO;
	
}

-(void)updateGridPosition{
	int currentCount = [[self playlist] count];
	[thumbGrid setContentSize:CGSizeMake((300), floor(currentCount/4)*79+180)];
	moreVideos.frame = CGRectMake(50, ceil((currentCount+1)/4)*79+40,225,65);
	plusButton.hidden=NO;
	plusButton.frame = CGRectMake(230, ceil((currentCount+1)/4)*79+58,29,29);
	
	mViewController.av2.frame = CGRectMake(65, ceil((currentCount+1)/4)*79+53,37,37);
	[mViewController.av2 stopAnimating];
	//NSLog(@"renderGrid3.5");
	if(currentListSize==100){
		[moreVideos setTitle:@"maximum of 100 videos" forState:UIControlStateNormal];
		moreVideos.userInteractionEnabled=NO;
		plusButton.hidden=YES;
	}else{
		[moreVideos setTitle:@"Get 20 More" forState:UIControlStateNormal];
		moreVideos.userInteractionEnabled=YES;
	}
	//NSLog(@"renderGrid4");
	[thumbGrid setCanCancelContentTouches:YES];
	thumbGrid.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	thumbGrid.clipsToBounds = YES;
	if(scrollingEnabled){
		thumbGrid.scrollEnabled = YES;
	}else{
		thumbGrid.scrollEnabled = NO;
	}
	
}

-(void) download_all_videos : (NSString*)dummyString{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(isDownloadingVideos){
		//NSLog(@"skipping downloading videos");
		[pool release];return;
	}
	if(![sCellNetwork isEqualToString:@"NO"]){
		//NSLog(@"3G mode, dont download");
		[pool release];return;
	}
	if([mViewController shouldRenderGrid]){ 
		//NSLog(@"skipping downloading videos - grid hidden"); 
		[pool release];return;
	}
	if(isDownloadingThumbnails){
		[pool release];return;
	}
	
	
	NSLog(@"setting isDownloadingVideos=YES");
	isDownloadingVideos=YES;
	int i;
	for(i = 0; i < [[self playlist] count]; i++){
		MediaObject *thisMovie = [[self playlist] objectAtIndex:i];
		if([mViewController shouldRenderGrid]){ 
			//NSLog(@"stopping downloading videos - grid hidden"); 
			NSLog(@"setting isDownloadingVideos=NO");
			isDownloadingVideos=NO;
			//return;
		}else if(shouldStopDownloading){ 
			//NSLog(@"stopping downloading videos - grid hidden"); 
			NSLog(@"setting isDownloadingVideos=NO");
			shouldStopDownloading=NO;
			isDownloadingVideos=NO;
			//return;
		}else if(![mViewController doesFileExistLocally:thisMovie.finalPath]){
			if(![mViewController.av isAnimating])[mViewController.av performSelectorInBackground:@selector(startAnimating) withObject:nil];
			//refreshButton.hidden=YES;
			[self saveThisFile:thisMovie.finalPath withFileName:nil];
			[mViewController.av stopAnimating];
			//[refreshButton view].hidden=NO;
			//[self renderGrid:nil];
		}
		
	}
	NSLog(@"setting isDownloadingVideos=NO, downloading done!");
	isDownloadingVideos=NO;
	[pool release];
	
}
- (void)dealloc {
    [window release];
    [mViewController release];
    [super dealloc];
}

@end
