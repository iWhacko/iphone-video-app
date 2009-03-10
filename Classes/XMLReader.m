#import "XMLReader.h"
#import "Format.h"

static NSUInteger parsedMediaObjectCounter;

@implementation XMLReader

BOOL shouldStop = YES;
int MAX_ITEMS = 20;
int startPos = 0;

@synthesize currentMediaObject = _currentMediaObject;
@synthesize contentOfCurrentMediaProperty = _contentOfCurrentMediaProperty;

//#define MAX_ITEMS 20

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parsedMediaObjectCounter = 0;
	shouldStop=NO;
}

- (void)parseXMLwithData:(NSData *)data parseError:(NSError **)error start:(int)start count:(int)howManyToParse
{	
	startPos = start;
	MAX_ITEMS=howManyToParse-1;
    //NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	NSLog(@"parse time start");
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	NSLog(@"parse time stop");
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error start:(int)start count:(int)howManyToParse
{	
	startPos = start;
	MAX_ITEMS=howManyToParse-1;
	NSLog(@"parse time start");
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	NSLog(@"parse time stop");
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
	
	/*
	 if (parsedMediaObjectCounter > MAX_ITEMS) {
	 [parser abortParsing];
	 }
	 */
    
    
    if ([elementName isEqualToString:@"media"]) {
        if(parsedMediaObjectCounter==MAX_ITEMS){
			shouldStop=YES;
		}
		parsedMediaObjectCounter++;
		self.currentMediaObject = [[MediaObject alloc] init];
		if(parsedMediaObjectCounter > startPos){
			
			// Add the new MediaObject object to the playlist.
			[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToPlayList:) withObject:self.currentMediaObject waitUntilDone:YES];
			
			
		}
		return;
        
    }
	/* kind of a silly way to do this - but works without importing a whole xml parser lib like libxml2 .*/
	if ([elementName isEqualToString:@"media_location"]) {
        self.contentOfCurrentMediaProperty = [NSMutableString string];
    } else if ([elementName isEqualToString:@"staticpreview"]) {
        self.contentOfCurrentMediaProperty = [NSMutableString string];        
    } 
	
	/*
	 if ([elementName isEqualToString:@"title"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"media_location"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"summary"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"channel"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"category"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"id"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"external_player_url"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"safe_flag"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 } else if ([elementName isEqualToString:@"staticpreview"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];        
	 } else if ([elementName isEqualToString:@"num_dpmp4s"]) {
	 self.contentOfCurrentMediaProperty = [NSMutableString string];
	 }
	 */
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
	/*
	 @interface MediaObject : NSObject
	 {
	 @public NSString *media_location;
	 @public NSString *title;
	 @public NSString *summary;
	 @public NSString *channel;
	 @public NSString *category;
	 @public NSString *blinkxID;
	 @public NSString *external_player_url;
	 @public int num_dpmp4s;
	 @public NSString *safe_flag;
	 @public NSString *staticpreview;
	 }
	 */
    /* kind of a silly way to do this - but works.*/
    /*if ([elementName isEqualToString:@"title"]) {
	 self.currentMediaObject.title = self.contentOfCurrentMediaProperty;
	 
	 } else */
	
	if ([elementName isEqualToString:@"media_location"]) {
		if ([self.contentOfCurrentMediaProperty rangeOfString: @"http"].location != NSNotFound){
			self.currentMediaObject.finalPath = self.contentOfCurrentMediaProperty;
			
		}else{
			//for blinkx api
			//self.currentMediaObject.media_location = self.contentOfCurrentMediaProperty;
			self.currentMediaObject.finalPath = [Format getFinalFLV:self.contentOfCurrentMediaProperty bRtmp:0 bPreview:0];
		}
		
		
		
		
		
		//NSLog (self.currentMediaObject.finalPath) ;
		if(shouldStop){
			[parser abortParsing];
		}
	} else if ([elementName isEqualToString:@"staticpreview"]) {
        self.currentMediaObject.staticpreview = [self.contentOfCurrentMediaProperty stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
    }
    /*    
	 } else if ([elementName isEqualToString:@"summary"]) {
	 self.currentMediaObject.summary = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"channel"]) {
	 self.currentMediaObject.channel = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"category"]) {
	 self.currentMediaObject.category = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"id"]) {
	 self.currentMediaObject.blinkxID = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"external_player_url"]) {
	 self.currentMediaObject.external_player_url = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"safe_flag"]) {
	 self.currentMediaObject.safe_flag = self.contentOfCurrentMediaProperty;
	 
	 } else if ([elementName isEqualToString:@"staticpreview"]) {
	 //storyLink = [storyLink stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	 self.currentMediaObject.staticpreview = [self.contentOfCurrentMediaProperty stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	 
	 } else if ([elementName isEqualToString:@"num_dpmp4s"]) {
	 self.currentMediaObject.num_dpmp4s = self.contentOfCurrentMediaProperty;
	 }*/
	//NSLog (self.contentOfCurrentMediaProperty) ;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.contentOfCurrentMediaProperty) {
        [self.contentOfCurrentMediaProperty appendString:string];
    }
}

@end
