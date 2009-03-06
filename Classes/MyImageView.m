
#import "MyImageView.h"


@implementation MyImageView

// Finger touches to the Image View will start the movie playing
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    if (touch.phase == UITouchPhaseBegan)
    {
        [mViewController playMovie:self];   // play the movie!
    }    
}


@end
