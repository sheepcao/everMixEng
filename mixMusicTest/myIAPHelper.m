

#import "myIAPHelper.h"

@implementation myIAPHelper

+ (myIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static myIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.MagicSongGuess.coin1000",@"com.MagicSongGuess.coin2500",@"com.MagicSongGuess.coin4000",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
