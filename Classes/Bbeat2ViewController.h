
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MyOverlayView.h"
#import "FlipSideView.h"

// Notification string used for touches to the overlay view
extern NSString * const OverlayViewTouchNotification;

@interface Bbeat2ViewController : UIViewController {

    MPMoviePlayerController *mMoviePlayer;
    NSURL *mMovieURL;
	IBOutlet UIActivityIndicatorView *av;
	IBOutlet UIActivityIndicatorView *av2;
	BOOL *isGridView;
	IBOutlet FlipSideView *flipSideView;
    IBOutlet MyOverlayView *mOverlayView;
}

-(NSURL *)movieURL;
-(void)initMoviePlayer;
-(IBAction)previousMovie:(id)sender;
-(IBAction)nextMovie:(id)sender;
-(IBAction)playMovie:(id)sender;
-(IBAction)stopPlaying:(id)sender;
-(IBAction)pausePlay:(id)sender;
-(void)setClipAndPlay:(id)sender;
-(IBAction)toggleFlip:(id)sender;
-(BOOL)shouldRenderGrid;
-(BOOL)doesFileExistLocally:(NSString*)movieFile;
-(void)overlayViewTouches:(NSNotification *)notification;
-(IBAction)overlayViewButtonPress:(id)sender;

@property (nonatomic, retain) UIActivityIndicatorView *av;
@property (nonatomic, retain) UIActivityIndicatorView *av2;
@property BOOL *isGridView;

@end
