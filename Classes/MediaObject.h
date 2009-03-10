#import <Foundation/Foundation.h>

@interface MediaObject : NSCoder
{
@public NSString *_media_location;
@public NSString *_title;
@public NSString *_summary;
@public NSString *_channel;
@public NSString *_isFav;
@public NSString *_blinkxID;
@public NSString *_external_player_url;
@public NSString *_num_dpmp4s;
@public NSString *_safe_flag;
@public NSString *_staticpreview;
@public NSString *_finalPath;
}

@property (nonatomic, retain) NSString *media_location;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) NSString *isFav;
@property (nonatomic, retain) NSString *blinkxID;
@property (nonatomic, retain) NSString *external_player_url;
@property (nonatomic, retain) NSString  *num_dpmp4s;
@property (nonatomic, retain) NSString  *safe_flag;
@property (nonatomic, retain) NSString  *staticpreview;
@property (nonatomic, retain) NSString  *finalPath;

@end
