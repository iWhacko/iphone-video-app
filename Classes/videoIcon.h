//
//  videoIcon.h
//  bbeat2
//
//  Created by Mac on 2009/3/3.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface videoIcon : UIView {
	UIButton *thumbNail;
	UIImageView *starredStar;
	UIImageView *unStarredStar;
	UIImageView *starOverStar;
	BOOL isFav;
}
-(void)setBackground:(UIImage*)background;
-(void)addTarget:(id)theTarget action:(id)selector;
-(void)setThisTag:(id)tag;
-(void)makeFav;
-(void)unMakeFav;
-(void)favMode;
-(void)unFavMode;

@end
