#import <Foundation/Foundation.h>

#import "MediaObject.h"
@interface XMLReader : NSObject {
	
@private        
    MediaObject *_currentMediaObject;
    NSMutableString *_contentOfCurrentMediaProperty;
}

@property (nonatomic, retain) MediaObject *currentMediaObject;
@property (nonatomic, retain) NSMutableString *contentOfCurrentMediaProperty;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error start:(int)start count:(int)howManyToParse;
- (void)parseXMLwithData:(NSData *)data parseError:(NSError **)error start:(int)start count:(int)howManyToParse;

@end
