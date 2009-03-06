//
//  videoIcon.m
//  bbeat2
//
//  Created by Mac on 2009/3/3.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "videoIcon.h"



@implementation videoIcon


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		thumbNail= [[UIButton alloc] init];
		thumbNail = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		thumbNail.frame = CGRectMake(0,0, 76, 76);
		[self addSubview:thumbNail];
		
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *starOnPath = [bundle pathForResource:@"star_on76" ofType:@"png"];
		
		starredStar   = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:starOnPath]];
		starredStar.frame   = CGRectMake(0,0, 76, 76);
		[self addSubview:starredStar];
		[self bringSubviewToFront:starredStar];
		starredStar.alpha=0.0;
		//starredStar.hidden=YES;
		
		NSString *starPath = [bundle pathForResource:@"star_off76" ofType:@"png"];
		unStarredStar = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:starPath]];
		unStarredStar.frame = CGRectMake(0,0, 76, 76);
		[self addSubview:unStarredStar];
		[self bringSubviewToFront:unStarredStar];
		unStarredStar.alpha=0.0;
		//unStarredStar.hidden=YES;
		
		NSString *starOverPath = [bundle pathForResource:@"star_over" ofType:@"png"];
		starOverStar = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:starOverPath]];
		starOverStar.frame = CGRectMake(0,0, 76, 76);
		[self addSubview:starOverStar];
		[self bringSubviewToFront:starOverStar];
		starOverStar.alpha=0.0;
		//starOverStar.hidden=YES;
		
		
		
		
		isFav = NO;
		
    }
    return self;
}

- (void)setBackground:(UIImage *)background{

	[thumbNail setBackgroundImage:background forState: UIControlStateNormal];
}

-(void)addTarget:(id)theTarget action:(id)selector{
	[thumbNail addTarget:theTarget action:selector forControlEvents:UIControlEventTouchUpInside];
}
-(void)setThisTag:(id)tag{
	[thumbNail setTag:tag];
}
-(void)makeFav{
	//NSLog(@"makFav");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	unStarredStar.alpha=0.0;
	starredStar.alpha=1.0;
	starOverStar.alpha=0.0;
	//thumbNail.alpha=1.0;
	isFav=YES;
	[UIView commitAnimations];
}
-(void)unMakeFav{
	//NSLog(@"unmakFav");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	unStarredStar.alpha=0.3;
	starredStar.alpha=0.0;
	starOverStar.alpha=0.0;
	//thumbNail.alpha=1.0;
	isFav=NO;
	[UIView commitAnimations];
}
-(void)favMode{
	//NSLog(@"favMode");
	if(isFav){
		unStarredStar.alpha=0.0;
		starredStar.alpha=1.0;
		starOverStar.alpha=0.0;
	}else{
		unStarredStar.alpha=0.3;
		starredStar.alpha=0.0;
		starOverStar.alpha=0.0;
	}
	//starOverStar.hidden=YES;
	//unStarredStar.hidden=NO;
	//starredStar.hidden=NO;
}
-(void)unFavMode{
	//NSLog(@"unfavMode");
	if(isFav){
		starOverStar.alpha=1.0;
		unStarredStar.alpha=0.0;
		starredStar.alpha=0.0;
	}else{
		starOverStar.alpha=0.0;
		unStarredStar.alpha=0.0;
		starredStar.alpha=0.0;
	}
	//starOverStar.hidden=NO;
	//unStarredStar.hidden=YES;
	//starredStar.hidden=YES;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	//[super drawRect:rect];
	[self bringSubviewToFront:unStarredStar];
	[self bringSubviewToFront:starredStar];
}


- (void)dealloc {
    [super dealloc];
}


@end
