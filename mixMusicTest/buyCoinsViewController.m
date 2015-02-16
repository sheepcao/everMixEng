//
//  buyCoinsViewController.m
//  mixMusicTest
//
//  Created by Eric Cao on 1/23/15.
//  Copyright (c) 2015 Eric Cao. All rights reserved.
//

#import "buyCoinsViewController.h"
#import "myIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <FacebookSDK/FacebookSDK.h>




@interface buyCoinsViewController (){
    NSMutableArray *_products;
    NSNumberFormatter * _priceFormatter;
    UILabel *currentCoinsLabel;
    UIButton *_parentCoinsButton;
    UIView *_loadingView;
}
@end

@implementation buyCoinsViewController

- (id)initWithCoinLabel:(UILabel *)coinLabel andParentController:(UIViewController *)controller andParentCoinButton:(UIButton *)parentCoinsButton andLoadingView:(UIView *)loadingView andTableView:(UITableView *)tableview{
    
   	self = [super init];
    if (self != nil) {
        self.itemsTable = tableview;
        
        _loadingView = loadingView;
        _parentCoinsButton = parentCoinsButton;
        self.parentControler = controller;
        
        currentCoinsLabel = coinLabel;
        
        _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
    }
    return self;
    
    
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    NSMutableArray *IAPProducts = [NSMutableArray arrayWithCapacity:5];
    for (id product in _products) {
        if ([product isKindOfClass:[SKProduct class]]) {
            [IAPProducts addObject:product];
        }
    }
    [IAPProducts enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            if ([product.productIdentifier isEqualToString:@"com.MagicSongGuess.coin1000"]) {
                [MobClick event:@"ClickTier1"];
                
                
                [CommonUtility coinsChange:1000];
                
                [currentCoinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
                
                [_parentCoinsButton setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
                
            }else if([product.productIdentifier isEqualToString:@"com.MagicSongGuess.coin2500"])
            {
                [MobClick event:@"ClickTier2"];
                
                [CommonUtility coinsChange:2500];//2元买2500coins
                
                [currentCoinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
                
                [_parentCoinsButton setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
            }else if([product.productIdentifier isEqualToString:@"com.MagicSongGuess.coin4000"])
            {
                [MobClick event:@"ClickTier3"];
                
                [CommonUtility coinsChange:4000];//3元买4000coins
                
                [currentCoinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
                
                [_parentCoinsButton setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
            }
            
        }
    }];
    
    
    
}

-(void)reloadwithRefreshControl:(UIRefreshControl *)refreshControl{
    _products = nil;
    [[myIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            //            _products = products;
            _products = [NSMutableArray arrayWithArray:products];
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"FBShare"] isEqualToString:@"yes"]) {
                [_products addObject:@"Facebook:  300 Coins"];
            }
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"reviewed"] isEqualToString:@"yes"] &&[CommonUtility fetchCoinAmount] < 400) {
                [_products addObject:@"Review us:  300 Coins"];
            }
            
            
            [self.itemsTable reloadData];
        }
        [refreshControl endRefreshing];
    }];
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _products.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"2");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"buyCellView" owner:self options:nil] lastObject];//加载nib文件
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    
    if ([_products[indexPath.row] isKindOfClass:[SKProduct class]]) {
        SKProduct * product = (SKProduct *) _products[indexPath.row];
        
        cell.textLabel.text = product.localizedTitle;
    }else if([_products[indexPath.row] isKindOfClass:[NSString class]])
    {
        NSString *product = (NSString *) _products[indexPath.row];
        
        cell.textLabel.text = product;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonUtility tapSound:@"click" withType:@"mp3"];
    if ([_products[indexPath.row] isKindOfClass:[SKProduct class]]) {
        
        SKProduct *product = _products[indexPath.row];
        NSLog(@"Buying %@...", product.productIdentifier);
        [[myIAPHelper sharedInstance] buyProduct:product withLoadingView:_loadingView];
        
        [_loadingView setHidden:NO];
        
    }else if([_products[indexPath.row] isKindOfClass:[NSString class]])
    {
        NSString *product = (NSString *) _products[indexPath.row];
        if ([product isEqualToString:@"Facebook:  300 Coins"]) {
            [self shareToFB];
            
        }else if([product isEqualToString:@"Review us:  300 Coins"])
        {
            [self reviewUS];
        }
        
        [self.closeDelegate closingBuy];
        
        
    }
    
    
 }

-(void)shareToFB
{
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/mixing-guess-guess-magic-song/id967166808?ls=1&mt=8"];
    
    params.picture =[NSURL URLWithString:@"http://cgx.nwpu.info/image/iconEng.png"];
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:@"Mixing"
                                      caption:nil
                                  description:@"I am playing Mixing Guess,so interesting and chanllenging."
                                      picture:params.picture
                                  clientState:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                              if ((int)[[results objectForKey:@"didComplete"] intValue] == 1 && [[results objectForKey:@"completionGesture"] isEqualToString: @"post"]) {
                                                  NSLog(@"success!!");
                                                  
                                                  [CommonUtility coinsChange:300];
                                                  [currentCoinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
                                                  [_parentCoinsButton setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
                                                  [MobClick event:@"CoinFromFB"];
                                                  
                                                  [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"FBShare"];
                                                  
                                                  
                                                  [self.itemsTable reloadData];
                                                  
                                                  
                                              }
                                          }
                                      }];
        
        
    } else {
        // Present the feed dialog
        UIAlertView * fbAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't find facebook app on your device.Share failed." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
        [fbAlert show];
        
    }
    
}


-(void)reviewUS
{
    
    [CommonUtility coinsChange:300];
    [currentCoinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
    [_parentCoinsButton setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"reviewed"];
    
    [self.itemsTable reloadData];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
    
    
    
}


@end


