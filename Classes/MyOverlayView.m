
#import "MyOverlayView.h"
#import "Bbeat2ViewController.h"

@implementation MyOverlayView

BOOL * showingOverlay = YES;
NSTimer *theTimer;

- (void)awakeFromNib
{
	CGAffineTransform transform = self.transform;

	// Rotate the view 90 degrees. 
	transform = CGAffineTransformRotate(transform, (M_PI / 2.0));

    UIScreen *screen = [UIScreen mainScreen];
    // Translate the view to the center of the screen
    transform = CGAffineTransformTranslate(transform, 
        ((screen.bounds.size.height) - (self.bounds.size.height))/2, 
        121);
	self.transform = transform;
	
}

- (void)dealloc {
	[super dealloc];
}
-(void)fadeIn{
	showingOverlay=YES;
	for (UIView *view in self.subviews) view.hidden=NO;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[self setAlpha:1];
	//CGRect myNewFrame = self.frame;
	//myNewFrame.origin.x=300;
	//[self setFrame:myNewFrame];
	[UIView commitAnimations];
	
	[self resetTimer];
}
-(void)fadeOut{
	showingOverlay=NO;
	self.userInteractionEnabled = NO;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[self setAlpha:0.05];
	
	[UIView commitAnimations];
	/*CGRect myNewFrame = self.frame;
	myNewFrame.origin.x=250;
	[self setFrame:myNewFrame];*/
	[NSTimer scheduledTimerWithTimeInterval:(0.5) target:self selector:@selector(hideButtons) userInfo:nil repeats:NO];
	theTimer = nil;
	[theTimer invalidate];
	[theTimer release]; 
	self.userInteractionEnabled = YES;
	//self.hidden=NO;
	//[self becomeFirstResponder];
}
-(void)hideButtons{
	for (UIView *view in self.subviews)view.hidden=YES;
}
-(void)setFadeTimer{
	for (UIView *view in self.subviews) view.hidden=NO;
	[self resetTimer];
	
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
	
    if([touch tapCount] == 2) {
		if(showingOverlay){
			//[self fadeOut];
			//Bbeat2AppDelegate *appDelegate = (Bbeat2AppDelegate *)[[UIApplication sharedApplication] delegate];
			//[appDelegate.mViewController stopPlaying];
		}
		//NSLog(@"double tap!");
    }
	else if([touch tapCount] == 1) {
		NSLog(@"single tap!");
		if(showingOverlay){
			[self fadeOut];
			[theTimer invalidate];
		}else{
			[self resetTimer];
			[self fadeIn];
		}
		//
    }
}
-(void)resetTimer{
	if([theTimer isValid]){
		[theTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:8]];
	}else{
		theTimer=[NSTimer scheduledTimerWithTimeInterval:(9) target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
	}
}

// Handle any touches to the overlay view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
	//NSLog(@"touched!");
	/*if(showingOverlay){
		[self fadeOut];
	}else{
		[self fadeIn];
	}*/
	
	
	
	
    if (touch.phase == UITouchPhaseBegan)
    {
        // IMPORTANT:
        // Touches to the overlay view are being handled using
        // two different techniques as described here:
        //
        // 1. Touches to the overlay view (not in the button)
        //
        // On touches to the view we will post a notification
        // "overlayViewTouch". MyViewController is registered 
        // as an observer for this notification, and the 
        // overlayViewTouches: method in MyViewController
        // will be called. 
        //
        // 2. Touches to the button 
        //
        // Touches to the button in this same view will 
        // trigger the MyViewController overlayViewButtonPress:
        // action method instead.

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:OverlayViewTouchNotification object:nil];

    }    
}


@end
