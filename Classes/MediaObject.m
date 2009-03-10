#import "MediaObject.h"

@implementation MediaObject

@synthesize media_location        = _media_location;
@synthesize title                 = _title;              
@synthesize summary               = _summary;            
@synthesize channel               = _channel;            
@synthesize isFav                 = _isFav;           
@synthesize blinkxID              = _blinkxID; 
@synthesize external_player_url   = _external_player_url;
@synthesize num_dpmp4s            = _num_dpmp4s;         
@synthesize safe_flag             = _safe_flag;          
@synthesize staticpreview         = _staticpreview;   
@synthesize finalPath             = _finalPath;   

-(id) initWithCoder: (NSCoder *)coder
{
	self = [MediaObject alloc];

        self.media_location     = [coder decodeObjectForKey:@"media_location"];     
        self.title              = [coder decodeObjectForKey:@"title"];               
        self.summary            = [coder decodeObjectForKey:@"summary"];             
        self.channel            = [coder decodeObjectForKey:@"channel"];             
        self.isFav              = [coder decodeObjectForKey:@"isFav"];               
        self.blinkxID           = [coder decodeObjectForKey:@"blinkxID"];            
        self.external_player_url= [coder decodeObjectForKey:@"external_player_url"]; 
        self.num_dpmp4s         = [coder decodeObjectForKey:@"num_dpmp4s"];          
        self.safe_flag          = [coder decodeObjectForKey:@"safe_flag"];           
        self.staticpreview      = [coder decodeObjectForKey:@"staticpreview"];       
        self.finalPath          = [coder decodeObjectForKey:@"finalPath"];           

	return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
	//[super encodeWithCoder:coder];
    [coder encodeObject:self.media_location      forKey:@"media_location"];
    [coder encodeObject:self.title               forKey:@"title"];
    [coder encodeObject:self.summary             forKey:@"summary"];
    [coder encodeObject:self.channel             forKey:@"channel"];
    [coder encodeObject:self.isFav               forKey:@"isFav"];
    [coder encodeObject:self.blinkxID            forKey:@"blinkxID"];
    [coder encodeObject:self.external_player_url forKey:@"external_player_url"];
    [coder encodeObject:self.num_dpmp4s          forKey:@"num_dpmp4s"];
    [coder encodeObject:self.safe_flag           forKey:@"safe_flag"];
    [coder encodeObject:self.staticpreview       forKey:@"staticpreview"];
    [coder encodeObject:self.finalPath           forKey:@"finalPath"];
	
	
}

@end
