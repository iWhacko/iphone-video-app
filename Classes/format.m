#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#import "Format.h";

//format instance
static Format *sharedInstanced = nil;

//server selection
static int m_iMaxServers = nil;
static bool m_bUseLight = true;
static NSString *m_sAppRoot = @"b";
static NSString *m_sApplicationServer = @""; //for overriding video domain paths
static NSString *m_sVideoImgPath = nil; //for overriding image/swf/thumbnail/etc domain paths

//quality
static bool m_bForcePreview = false;
static NSString *m_sBandwidth = @"lo";
static NSString *m_sVideoType = @"mp4";

//stream
static NSString *m_sRtmpProtocol = @"rtmp";
static NSString *m_sStreamingServer = @"stream7.blinkx.com";
static NSString *m_sPreviewServer = @"redirectors/preview2.php?&f=";
static NSString *m_sApplication = @"clips";

//proxy
//static bool m_bProxyConnection = false;
//static NSString *m_bProxyPort;

@implementation Format

+(Format *)sharedInstance
{
	if(!sharedInstanced)
		sharedInstanced = [ [ Format alloc ] init ];
	
	return sharedInstanced;
}


+(NSString*)LightGetServer:(NSString *)MyVideo
{
	if(!m_iMaxServers)
		m_iMaxServers = 99;
	
	NSString *out = @"00";
	NSString *lowerCase = [MyVideo lowercaseString];
	
	int myValue = 0;
	int i;
	for(i = 0; i < [lowerCase length]; i++)
	{
		int val = [lowerCase characterAtIndex:i];
		
		if (val > 47 && val < 58)
			val -= 48;
		else if (val > 96 && val < 123)
			val -= 97-10;
		else
			val = 0;
		
		myValue += pow(val,4);
	}
	
	myValue = myValue%m_iMaxServers;
	
	if(myValue < 10)
		out = [NSString stringWithFormat:@"0%d", myValue];
	else 
		out = [NSString stringWithFormat:@"%d", myValue];
	
	return out;
}

+(NSString*)get_ID:(NSString *)sMedia
{
	NSString *sID = [sMedia lastPathComponent];
	return sID;
}

+(NSString*)getClipNumber:(NSString *)sMedia
{
	//get last part of url path to check for #n=
	NSString *endPath = [sMedia lastPathComponent];
	NSArray *my_array = [endPath componentsSeparatedByString:@"#"];
	
	if([my_array count] <= 1)
		return @"0";
	
	int c;
	for(c = 1; c < [my_array count]; c++)
	{
		NSArray *my_param = [[my_array objectAtIndex:c] componentsSeparatedByString:@"="];
		if([ [my_param objectAtIndex:0] isEqualToString:@"n"] && [my_param count] > 1)
			return [my_param objectAtIndex:1];
	}
	return @"0";
}

+(NSString*)cleanReference:(NSString *)sMedia
{
	NSRange out = [sMedia rangeOfString:@"#"];
	
	if(out.location == NSNotFound)
		return sMedia;
	
	return [sMedia substringToIndex:out.location];
}

// bw="hd"; bw="hi"; bw="lo";
+(NSString*) getPath:(NSString *)sMedia bPreview:(BOOL)bPreview
{
	// http://cdn-00.blinkx.com/stream/applications/clips/streams/b/05/PyroTV/20071003/37388751/37388751_preflv_0.flv
	
	NSString *sID = [Format get_ID:sMedia];
	NSString *clipNumber = [Format getClipNumber:sMedia];
	
	NSString *prefix = @"dp";
	
	NSString *bw = m_sBandwidth;
	
	if(bPreview)
	{
		prefix = @"pre";
		if([bw isEqualToString:@"lo"])
			bw = @"";
	}
	
	NSString *final = [Format cleanReference:[NSString stringWithFormat:@"%@%@_%@%@%@_%@", sMedia, sID, prefix, m_sVideoType, bw, clipNumber] ];
	return final;
}


+(NSString*) getFinalFLV:(NSString *)sMedia bRtmp:(BOOL)bRtmp bPreview:(BOOL)bPreview
{
	if(m_bForcePreview && [m_sBandwidth isEqualToString:@"hd"])
		m_sBandwidth = @"hi";
	
	/// check if sMedia is already a full path to video file
	NSString *checkPath = [sMedia substringToIndex:5];
	if([checkPath isEqualToString:@"rtmp:"] || [checkPath isEqualToString:@"http:"] || [checkPath isEqualToString:@"file:"])
		return sMedia;
	
	///////////
	/// create path to video file
	
	NSString *ApplicationServer = m_sApplicationServer;
	
    // if(m_bUseLight || [ApplicationServer length] == 0)
	// ApplicationServer = [NSString stringWithFormat:@"cdn-%@.blinkx.com/stream", [Format LightGetServer:sMedia] ];
    ApplicationServer = @"cdn.blinkx.com/stream";
	
	//if(m_bProxyConnection)
	//ApplicationServer = [NSString stringWithFormat:@"127.0.0.1:%@/%@", m_bProxyPort, ApplicationServer];
	
	NSString *sPath;
	
	if(bRtmp)
	{
		sPath = [NSString stringWithFormat:@"%@://%@/%@/%@", m_sRtmpProtocol, m_sStreamingServer, m_sApplication, m_sAppRoot]; 
	}
	else
	{
		if(m_bForcePreview && !bPreview)
		{
			NSString *previewServer = @"";
            // if(m_bUseLight)
			// previewServer = [NSString stringWithFormat:@"cdn-%@.blinkx.com/store/", [Format LightGetServer:sMedia] ];
			
			// Revisit this thing... If the preview2.php doesnt 
			//previewServer+=Settings.GetGlobal("g_sPreviewServer", m_sPreviewServer);
			
			previewServer = [previewServer stringByAppendingString:m_sPreviewServer];
			
			sPath = [NSString stringWithFormat:@"http://%@/%@", previewServer, m_sAppRoot];
		}
		else
		{
            // sPath = [NSString stringWithFormat:@"http://%@/applications/%@/streams/%@", ApplicationServer, m_sApplication, m_sAppRoot];
			sPath = [NSString stringWithFormat:@"http://%@/%@", ApplicationServer, m_sAppRoot];
		}
	}
	
	NSString *final_ = [NSString stringWithFormat:@"%@%@", sPath, [Format getPath:sMedia bPreview:bPreview] ];
	
	if(bRtmp)
		return final_;
	
	return [NSString stringWithFormat:@"%@.%@", final_, m_sVideoType];
}

/////////////////////////////////
/// thumnails/first frame/srt

+(NSString*)getPathImage:(NSString *)sMedia type:(NSString *)sType extension:(NSString *)sExtension
{
	NSString *VideoImgPath;
	NSString *ApplicationServer;
	
	if(m_bUseLight)
		ApplicationServer = [NSString stringWithFormat:@"cdn-%@.blinkx.com/stream/applications/clips/streams/", [Format LightGetServer:sMedia] ];
	else
		ApplicationServer = @"us-store.blinkx.com/images/video/";
	
	//if(m_bProxyConnection)
	//ApplicationServer = [NSString stringWithFormat:@"127.0.0.1:%@/%@", m_bProxyPort, ApplicationServer];
	
	if(m_sVideoImgPath && [m_sVideoImgPath length] > 0)
		VideoImgPath = m_sVideoImgPath;
	else
		VideoImgPath = [NSString stringWithFormat:@"http://%@%@", ApplicationServer, m_sAppRoot];  
	
	NSString *sID = [Format get_ID:sMedia];
	NSString *clipnumber = [Format getClipNumber:sMedia];
	
	return [NSString stringWithFormat:@"%@%@%@_%@_%@.%@", VideoImgPath, [Format cleanReference:sMedia], sID, sType, clipnumber, sExtension];
}

+(NSString*)getImage:(NSString *)sMedia
{
	return [Format getPathImage:sMedia type:@"swf" extension:@"swf"];
}

+(NSString*)getSrt:(NSString *)sMedia
{
	return [Format getPathImage:sMedia type:@"srt" extension:@"xml"];
}

+(NSString*)getThumbnail:(NSString *)sMedia
{
	return [Format getPathImage:sMedia type:@"tn" extension:@"jpg"];
}

+(NSString*)getFirstFrame:(NSString *)sMedia
{
	return [Format getPathImage:sMedia type:@"img" extension:@"jpg"];
}

/// end thumnails/first frame/srt
/////////////////////////////////

@end
