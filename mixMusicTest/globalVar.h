//
//  Header.h
//  mixMusicTest
//
//  Created by Eric Cao on 2/4/15.
//  Copyright (c) 2015 Eric Cao. All rights reserved.
//

#ifndef mixMusicTest_Header_h
#define mixMusicTest_Header_h

#define REVIEW_URL @"itms-apps://itunes.apple.com/cn/app/mo-yin-da-shi-feng-kuang-cai-ge/id954971485?ls=1&mt=8"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

BOOL backFromGame;

@protocol closeBuyViewDelegate
-(void)closingBuy;

@end



#endif