@interface Format : NSObject

+(Format *)sharedInstance;

+(NSString*)LightGetServer:(NSString *)MyVideo;

+(NSString*)cleanReference:(NSString *)sMedia;
+(NSString*)getPathImage:(NSString *)sMedia type:(NSString *)sType extension:(NSString *)sExtension;
+(NSString*)get_ID:(NSString *)sMedia;
+(NSString*)getClipNumber:(NSString *)sMedia;

+(NSString*) getPath:(NSString *)sMedia bPreview:(BOOL)bPreview;
+(NSString*) getFinalFLV:(NSString *)sMedia bRtmp:(BOOL)bRtmp bPreview:(BOOL)bPreview;

+(NSString*)getPathImage:(NSString *)sMedia type:(NSString *)sType extension:(NSString *)sExtension;
+(NSString*)getImage:(NSString *)sMedia;
+(NSString*)getSrt:(NSString *)sMedia;
+(NSString*)getThumbnail:(NSString *)sMedia;
+(NSString*)getFirstFrame:(NSString *)sMedia;

@end