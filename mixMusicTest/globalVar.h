//
//  Header.h
//  mixMusicTest
//
//  Created by Eric Cao on 2/4/15.
//  Copyright (c) 2015 Eric Cao. All rights reserved.
//

#ifndef mixMusicTest_Header_h
#define mixMusicTest_Header_h

#define REVIEW_URL @"itms-apps://itunes.apple.com/us/app/mixing-guess-guess-magic-song/id967166808?ls=1&mt=8"

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

#define ADMOB @"ca-app-pub-3074684817942615/6100559886"
#define ADMOB_big @"ca-app-pub-3074684817942615/2588690285"

#define MAX_LEVEL 15
#define TOTAL_LEVEL 75

BOOL backFromGame;

@protocol closeBuyViewDelegate
-(void)closingBuy;

@end



#endif
