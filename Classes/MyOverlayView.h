
#import <UIKit/UIKit.h>
//#import "Bbeat2AppDelegate.h"


@interface MyOverlayView : UIView {
	NSTimer *theTimer;
	//IBOutlet Bbeat2ViewController *mViewController;
}

- (void)awakeFromNib;
- (void)dealloc;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)fadeIn;
-(void)fadeOut;
-(void)setFadeTimer;

@end
