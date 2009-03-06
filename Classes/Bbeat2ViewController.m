
#import "Bbeat2ViewController.h"
#import "Bbeat2AppDelegate.h"

NSString * const OverlayViewTouchNotification = @"overlayViewTouch";

static NSUInteger currentClip = 0;
BOOL currentlyPlaying = NO;

BOOL * isGridView = YES;
BOOL shouldIncrementMovie = NO;
Bbeat2AppDelegate * appDelegate;

UIImageView *background;

@implementation Bbeat2ViewController

@synthesize av;
@synthesize av2;
@synthesize isGridView;


#pragma mark Movie Player Routines


//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	//NSLog(@"finished preloading something!");
	if([[notification userInfo] valueForKey:@"error"]){
		NSLog(@"movie failed to play");
		Bbeat2AppDelegate *appDelegate = (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
		MediaObject *thisMovie = [appDelegate.playlist objectAtIndex:currentClip];
		NSString *thisMovieURL = thisMovie.finalPath;
		NSLog(thisMovieURL);
		currentlyPlaying=NO;
		[mMoviePlayer stop];
		isGridView=NO;
		flipSideView.hidden=NO;

		[appDelegate performSelectorInBackground:@selector(renderGrid:) withObject:nil];
		
		//NSLog([self movieURL]);
	}
	//[background removeFromSuperview];
	//[[[mMoviePlayer videoViewController] view] remove addSubview:background];
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    //NSLog(@"moviePlaybackDidFinish!");
	//[self nextMovie];
	if (mMoviePlayer != nil) {
		// free the old movie player
		//NSLog(@"releasing!");
		[mMoviePlayer release];
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	
	if(shouldIncrementMovie){
	    //NSLog(@"incrementing movie");
		int currentListSize = [appDelegate getCurrentListSize];
	    currentClip=(currentClip==(currentListSize-1))?0:++currentClip;
	}
	
	if(currentlyPlaying){
		[self initMoviePlayer];
	}
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
	
}

-(void)drawSplash{

	
	background = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 480.0f, 320.0f)] autorelease];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	MediaObject *thisMovie = [appDelegate.playlist objectAtIndex:currentClip];
	NSString *thumbnailLocalPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [thisMovie.finalPath lastPathComponent]];
	NSString *thisThumbFileName = [thumbnailLocalPath stringByReplacingOccurrencesOfString:@"mp4" withString:@"jpg"];
	
	[background setImage:[[UIImage alloc] initWithContentsOfFile:thisThumbFileName]];
	NSLog(thisThumbFileName);
	NSArray *windows = [[UIApplication sharedApplication] windows];
	UIWindow *moviePlayerWindow = [windows objectAtIndex:0];
	//myButton.alpha=0.0;
	//[thumbGrid addSubview:myButton];
	CGAffineTransform transform = background.transform;
	
	// Rotate the view 90 degrees. 
	transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
	
    //UIScreen *screen = [UIScreen mainScreen];
    // Translate the view to the center of the screen
    transform = CGAffineTransformTranslate(transform,80,80);
	background.transform = transform;
	//[[[mMoviePlayer videoViewController] view] addSubview:background];
	[moviePlayerWindow addSubview:background];
	background.hidden=YES;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:background cache:YES];
	background.hidden=NO;
	
	//myButton.hidden=NO;
	//myButton.alpha=1.0;
	[UIView commitAnimations];
	
}

-(void)initMoviePlayer
{
	appDelegate= (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	currentlyPlaying=YES;
	shouldIncrementMovie=YES;
	isGridView=YES; 
	
	
    // Register to receive a notification when the movie is in memory and ready to play.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
	
	mMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[self movieURL]];
	
	//[mMoviePlayer _itemFailedToPlay:[NSError alloc]];
	

    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviePlayer];
	
    // Register to receive a notification when the movie scaling mode has changed. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieScalingModeDidChange:) name:MPMoviePlayerScalingModeDidChangeNotification object:mMoviePlayer];
	
	/*
	 Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
	 Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly,MPMovieControlModeHidden.
	 */
	mMoviePlayer.movieControlMode = MPMovieControlModeHidden;
	mMoviePlayer.scalingMode = MPMovieScalingModeAspectFill;
	
    /*
	 The color of the background area behind the movie can be any UIColor value.
	 */
    UIColor *colors[15] = {[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], 
        [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], 
        [UIColor yellowColor], [UIColor magentaColor],[UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
	[UIColor clearColor]};
    mMoviePlayer.backgroundColor = colors[ 0 ];
	
    /*
	 Register as an observer of the "overlayViewTouch" notification.
	 
	 Any user touches to the MyOverlayView (not in the button) will
	 result in the "overlayViewTouch" notification being posted, and
	 the overlayViewTouches: method in this class will be called
	 
	 */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayViewTouches:) name:OverlayViewTouchNotification object:nil];
	
	[[[mMoviePlayer videoViewController] view] addSubview:mOverlayView];
	/*
	self.av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.av.frame=CGRectMake(20, 10, 20, 20);
	*/
	NSArray *windows = [[UIApplication sharedApplication] windows];
	UIWindow *moviePlayerWindow = [windows objectAtIndex:0];
	//[moviePlayerWindow addSubview:self.av];
	
	[moviePlayerWindow addSubview:flipSideView];
	//flipSideView.hidden=YES;
	[mMoviePlayer play];
	flipSideView.hidden=YES;
	[mOverlayView setFadeTimer];
	
	//[self drawSplash];
	
	//[av startAnimating];
	
}
-(IBAction)previousMovie:(id)sender
{
	//NSLog(@"previousMovie clicked");
	int currentListSize = [appDelegate getCurrentListSize];
	currentClip=(currentClip==0)?(currentListSize-1):--currentClip;
	currentlyPlaying=YES;
    shouldIncrementMovie=NO;
	[mMoviePlayer stop];
}
-(IBAction)nextMovie:(id)sender
{
	int currentListSize = [appDelegate getCurrentListSize];
	
	currentClip=(currentClip==(currentListSize-1))?0:++currentClip;
	currentlyPlaying=YES;
	shouldIncrementMovie=NO;
	[mMoviePlayer stop];
}
-(IBAction)stopPlaying:(id)sender{
	NSLog(@"stop clicked!");
	currentlyPlaying=NO;
	[mMoviePlayer stop];
	isGridView=NO;
	flipSideView.hidden=NO;
	Bbeat2AppDelegate *appDelegate = (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate performSelectorInBackground:@selector(renderGrid:) withObject:nil];
	//[appDelegate renderGrid:nil];
	
}
-(void)setClipAndPlay:(id)sender{
	currentClip=[(UIControl *) sender tag];
	//NSLog(@"the user pressed: %i", [(UIControl *) sender tag]);
	[self initMoviePlayer];
}

-(IBAction)playMovie:(id)sender
{	
	[self initMoviePlayer];
    //[mMoviePlayer play];
}
BOOL paused=NO;
-(IBAction)pausePlay:(id)sender{
	if(!paused){
		paused=YES;
		[mMoviePlayer pause];
	}else{
		paused=NO;
		[mMoviePlayer resume];
	}
}

#pragma mark View Controller Routines


-(NSURL *)movieURL
{
	Bbeat2AppDelegate *appDelegate = (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
    MediaObject *thisMovie = [appDelegate.playlist objectAtIndex:currentClip];
	NSString *thisMovieURL = thisMovie.finalPath;
	
	// skip if favs mode and this not a fav.
	int currentListSize = [appDelegate getCurrentListSize];
	
	if(appDelegate.showingFavs){
		//NSLog(@"showing favs! skipping non favs!");
		//int skipCount = 0;
		for(int i=0; i< currentListSize; i++){
			if(thisMovie.isFav==nil){
				currentClip=(currentClip==(currentListSize-1))?0:++currentClip;
				thisMovie = [appDelegate.playlist objectAtIndex:currentClip];
			}else{
				break;
			}
		}
	}
	
	
	if([self doesFileExistLocally:thisMovieURL]){
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *localPathToMovie = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [thisMovie.finalPath lastPathComponent]];
		NSLog([@"local video ->! : " stringByAppendingString:localPathToMovie]);
		mMovieURL = [NSURL URLWithString:localPathToMovie];
	}else{
		NSLog([@"remote video -> " stringByAppendingString:thisMovie.finalPath]);
		mMovieURL = [NSURL URLWithString:thisMovieURL];
	}
    return mMovieURL;
}
-(BOOL)doesFileExistLocally:(NSString*)movieFile{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *directoryContent = [[NSFileManager defaultManager] directoryContentsAtPath:documentsDirectory];
	int i;
	//BOOL *foundLocalFile = NO;
	int thisCount = [directoryContent count];
	for(i = 0; i < thisCount; i++){
		if([[directoryContent objectAtIndex:i] isEqualToString:[movieFile lastPathComponent]]){
			return YES;
		}
	}
	return NO;
}


-(IBAction)toggleFlip:(id)sender{
	NSLog(@"info button clicked!");
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:(isGridView ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	//Bbeat2AppDelegate *appDelegate = (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if(isGridView){
		isGridView=NO;
		[self viewWillDisappear:YES];
		[self viewDidDisappear:YES];
		[self.view addSubview:flipSideView];
		flipSideView.hidden=NO;
		//[appDelegate performSelectorInBackground:@selector(renderGrid:) withObject:nil];
	}else{
		isGridView=YES;
		flipSideView.hidden=YES;
	}
	
    [UIView commitAnimations];
}
-(BOOL)shouldRenderGrid{
	return flipSideView.hidden;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return YES;
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Low on memory: Release anything that's not essential, such as cached data, or perhaps 
    // unload the movie, etc.
	[mMoviePlayer stop];
}

// Touches in the MyOverlayView (not in the overlay button)
// post the "overlayViewTouch" notification and will send
// the overlayViewTouches: message
- (void)overlayViewTouches:(NSNotification *)notification
{
	//NSLog(@"overlay got touched!");
    // Handle touches to the MyOverlayView here... 
}

// Action method for the MyOverlayView button
-(IBAction)overlayViewButtonPress:(id)sender
{
	[mOverlayView fadeIn];
    // Handle touches to the MyOverlayView 
    // button here... 
}

- (void)dealloc {
	
    [super dealloc];
    
    [mMovieURL release];
    
    // remove movie notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerContentPreloadDidFinishNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:mMoviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerScalingModeDidChangeNotification
                                                  object:mMoviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:OverlayViewTouchNotification
                                                  object:mMoviePlayer];
    // free our movie player
    [mMoviePlayer release];
}

@end
