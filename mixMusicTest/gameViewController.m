//
//  ViewController.m
//  mixMusicTest
//
//  Created by Eric Cao on 12/9/14.
//  Copyright (c) 2014 Eric Cao. All rights reserved.
//

#import "gameViewController.h"
#import "globalVar.h"
#import "fallAnimation.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TOLAdViewController.h"
#import "LARSAdController.h"

#define kAdViewPortraitRect CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-48-44,[[UIScreen mainScreen] bounds].size.width,48)
#define cdFrame  CGRectMake(5, 5,40, 40)




@interface gameViewController ()<UIAlertViewDelegate>

@property (nonatomic ,strong) NSMutableArray *ignoreArray;
@property (nonatomic, strong) UIImageView *musicNote1;
@property (nonatomic, strong) UIImageView *musicNote2;
@property (nonatomic, strong) UIImageView *musicNote3;
@property (nonatomic, strong) UIImageView *musicNote4;
@property (nonatomic, strong) UIImageView *musicNote5;
@property (nonatomic, strong) UIImageView *musicNote6;
@property (nonatomic, strong) UIImageView *musicNote7;
@property (nonatomic, strong) UIImageView *musicNote8;
@property (nonatomic, strong) NSArray *musicNotes;

@property (nonatomic, strong) NSMutableArray *diskArray;
@property (nonatomic, strong) NSMutableArray *musicsArrayForShare;
@end

bool isplayed;
BOOL animating;
int totalRotateTimes;
int answerPickedCount;
int answerBtnTag;
@implementation gameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    
    self.musicNote1 = [[UIImageView alloc] init];
    self.musicNote2 = [[UIImageView alloc] init];
    self.musicNote3 = [[UIImageView alloc] init];
    self.musicNote4 = [[UIImageView alloc] init];
    self.musicNote5 = [[UIImageView alloc] init];
    self.musicNote6 = [[UIImageView alloc] init];
    self.musicNote7 = [[UIImageView alloc] init];
    self.musicNote8 = [[UIImageView alloc] init];
    
    
    
    self.musicNotes = [NSArray arrayWithObjects:self.musicNote1,self.musicNote2,self.musicNote3,self.musicNote4,self.musicNote5,self.musicNote6,self.musicNote7,self.musicNote8, nil];
    
    self.diskArray = [NSMutableArray arrayWithObjects:@"cd1",@"cd2",@"cd3",@"cd4",@"cd5",@"cd6",@"cd7",@"cd8",@"cd9",@"cd10",@"cd11",@"cd12",@"cd13", nil];

    //reset tags
    answerBtnTag = 0;
    
    [self dropDown];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"topbar"] forBarMetrics: UIBarMetricsDefault];

    [self.navigationController setNavigationBarHidden:NO];
    
    
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 75, 34)];
    
    
    self.coinShow = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.coinShow setFrame:CGRectMake(21, 0, 60, 34)];
    [self.coinShow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.coinShow.titleLabel.font =[UIFont fontWithName:@"Helvetica Neue" size:15];
    self.coinShow.titleLabel.textAlignment = NSTextAlignmentRight ;
    

    NSString *currentCoins = [NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]];
    [self.coinShow setTitle:currentCoins forState:UIControlStateNormal];
//    [self.coinShow setTitle:@"50000" forState:UIControlStateNormal];

    

    UIImageView *coinImage = [[UIImageView alloc] initWithFrame:CGRectMake(13,8, 17, 22)];
    [coinImage setImage:[UIImage imageNamed:@"coin"]];
//    [self.coinShow addSubview:coinImage];
    
    [self.coinShow addTarget:self action:@selector(buyCoinsAction) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonView addSubview:coinImage];
    [buttonView addSubview:self.coinShow];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    
    self.ignoreArray = [[NSMutableArray alloc] init];
    
    self.diskButtonFrameArray = [[NSMutableArray alloc] init];
    
    self.musicsArrayForShare = [NSMutableArray arrayWithArray:self.musicsArray];
    
    self.musicsPlayArray = [NSMutableArray arrayWithArray:self.musicsArray];
    self.myAudioArray = [NSMutableArray new];
    self.singleMusicsViewArray = [NSMutableArray new];

    isplayed =false;
    
    [self setupButtonsView];

    [self diskHideToTop];
//    [self diskPopUp];
    self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
    
    NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
    
    //统计用户游戏难度
    switch ([currentDifficulty intValue]) {
        case 0:
            [MobClick event:@"playDifficulty1"];
            break;
        case 1:
            [MobClick event:@"playDifficulty2"];

            break;
        case 2:
            [MobClick event:@"playDifficulty3"];

            break;
        case 3:
            [MobClick event:@"playDifficulty4"];

            break;
        case 4:
            [MobClick event:@"playDifficulty5"];

            break;
            
        default:
            break;
    }

//AD...
    
 
    //使用嵌入广告的方法实例。



    
    [self.view bringSubviewToFront:self.playConsoleView];
    
    //control big AD when main page appears.
    backFromGame = YES;
    


}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"gamePage"];

    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];


}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 设置广告视图的位置
    
    NSLog(@"view3:%@",self.view);


}
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        [CommonUtility tapSound:@"Window_Disappear" withType:@"mp3"];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop10secondMusics) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop13secondMusics) object:nil];
    [self stopMusics];
    isplayed =false;

}


-(void)buyCoinsAction
{
    [CommonUtility tapSound:@"comprar_coins" withType:@"mp3"];
    
    [MobClick event:@"bugCoinClick"];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    
    if (!self.buyCoinsView) {
        
        self.buyCoinsView = [[[NSBundle mainBundle] loadNibNamed:@"buyCoinsViewController" owner:self options:nil] objectAtIndex:0];
        [self.view addSubview:self.buyCoinsView];

        
        [self.loadingView setFrame:CGRectMake(0, 0, self.buyCoinsView.frame.size.width, self.buyCoinsView.frame.size.height)];
        [self.loadingView setHidden:YES];
        [self.buyCoinsView addSubview:self.loadingView];
    }
    
    
    UILabel *coinsLabel = (UILabel *)[self.buyCoinsView viewWithTag:2];
    [coinsLabel setText:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]]];
    self.itemsToBuy = (UITableView *)[self.buyCoinsView viewWithTag:10];

    self.myBuyController = [[buyCoinsViewController alloc] initWithCoinLabel:coinsLabel andParentController:self andParentCoinButton:self.coinShow andLoadingView:self.loadingView andTableView:self.itemsToBuy];
    
    [self.buyCoinsView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    self.myBuyController.closeDelegate =self;

    UIButton *closeBuyView = (UIButton *)[self.buyCoinsView viewWithTag:1];
    [closeBuyView addTarget:self action:@selector(closingBuy) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.itemsToBuy.delegate = self.myBuyController;
    self.itemsToBuy.dataSource = self.myBuyController;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.itemsToBuy addSubview:self.refreshControl];
    
    [self.refreshControl addTarget:self.myBuyController action:@selector(reloadwithRefreshControl:) forControlEvents:UIControlEventValueChanged];
    [self.myBuyController reloadwithRefreshControl:self.refreshControl];
    [self.refreshControl beginRefreshing];
    
    [UIView animateWithDuration:0.65 delay:0.05 usingSpringWithDamping:0.8 initialSpringVelocity:0.4 options:0 animations:^{
        [self.buyCoinsView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    } completion:^(BOOL finished){

            [self.navigationItem setHidesBackButton:YES];

    
    }];
    
    [self.itemsToBuy reloadData];
    

}

-(void)closingBuy
{
    [CommonUtility tapSound:@"Window_Disappear" withType:@"mp3"];

    [UIView animateWithDuration:0.65 delay:0.05 usingSpringWithDamping:0.8 initialSpringVelocity:0.4 options:0 animations:^{
        [self.buyCoinsView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
    } completion:nil];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem setHidesBackButton:NO];

}

-(void)setupButtonsView
{
    self.guessNameBtnArray = [[NSMutableArray alloc] initWithCapacity:5];

 
    CGFloat first_Y = self.downPartView.frame.size.height/2-15 - ((int)self.musicsArray.count/2)*63;
    if (IS_IPHONE_4_OR_LESS) {
    
        first_Y = self.downPartView.frame.size.height/2+5 - ((int)self.musicsArray.count/2)*52;
    }
    for (int i = 0; i<self.musicsArray.count ; i++) {
        UIButton *cdBtn = [[UIButton alloc] initWithFrame:CGRectMake(-520,first_Y + i*63, 270, 50)];
        if (IS_IPHONE_4_OR_LESS) {
            [cdBtn setFrame:CGRectMake(-520,first_Y + i*52, 270, 46)];
        }
        
        cdBtn.tag = i;
        
//        [cdBtn setImage:[UIImage imageNamed:[self randomDiskWithRange:13-i]] forState:UIControlStateNormal];
        UIImageView *cdImage = [[UIImageView alloc] initWithFrame:cdFrame];
        [cdImage setImage:[UIImage imageNamed:[self randomDiskWithRange:13-i]]];
        [cdBtn addSubview:cdImage];
        cdImage.tag = 10;
        
        [cdBtn addTarget:self action:@selector(diskTap:) forControlEvents:UIControlEventTouchUpInside];
        cdBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        
        [cdBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 28, 0, 0)];
//        [cdBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//        [cdBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//        [cdBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
        [cdBtn setBackgroundImage:[UIImage imageNamed:@"nextBtn"] forState:UIControlStateNormal];
        

        [cdBtn setHidden:YES];
        [self.downPartView addSubview:cdBtn];
        [self.guessNameBtnArray addObject:cdBtn];

    }
    

}

-(NSString *)randomDiskWithRange:(int)range
{
    unsigned int randomNumber = arc4random()%range;
    NSString *cdName = self.diskArray[randomNumber];
    
    [self.diskArray removeObjectAtIndex:randomNumber];
    
    return cdName;
    
}
-(unsigned int)randomDiskNumberWithRange:(int)range
{
    unsigned int randomNumber = arc4random()%13+1;

    
    return randomNumber;
    
}

- (void)diskTap:(UIButton *)sender {

    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    
    NSDictionary *allAnswers = [self.gameDataForSingleLevel objectForKey:@"choices"];

    int diskNumber = -1;
    
    for(int i = 0 ; i < self.guessNameBtnArray.count ; i++ )
    {
        if (sender == self.guessNameBtnArray[i]) {
            diskNumber = i;
        }
    }
    NSString *songName = self.musicsArray[diskNumber];
    NSArray *songNameWord = [songName componentsSeparatedByString:@" "];

    NSString *songAnswer = [allAnswers objectForKey:songName];
    NSArray *songAnswerSingleLetter = [songAnswer componentsSeparatedByString:@","];
//    NSLog(@"answer count:%ld",(unsigned long)songAnswerSingleLetter.count);
//    NSLog(@"songName:%@",songName);

    
    if(!self.choicesBoardView)
    {
        self.choicesBoardView = [[[NSBundle mainBundle] loadNibNamed:@"choicesBoardView" owner:self options:nil] objectAtIndex:0];
        [self.choicesBoardView setFrame:CGRectMake(self.downPartView.frame.origin.x,[UIScreen mainScreen].bounds.size.height , self.downPartView.frame.size.width,self.downPartView.frame.size.height +3)];
        self.choicesBoardView.songName = @"";
        [self.choicesBoardView setupBoard];
        [self.view addSubview:self.choicesBoardView];
        
        
        //下滑回收
        UISwipeGestureRecognizer *recognizer;
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        
        [self.choicesBoardView addGestureRecognizer:recognizer];

    }
    //only support less than 8 letters.
    NSLog(@"center:%f",self.choicesBoardView.center.x);
//    UIButton *answerButton = (UIButton *)[self.choicesBoardView viewWithTag:1];
    CGFloat firstAnswer_Y = 0;
    if (songNameWord.count>1) {
        firstAnswer_Y = /*answerButton.frame.origin.y*/185 - 40 * songNameWord.count;
    }else
    {
        firstAnswer_Y = /*answerButton.frame.origin.y*/185 - 60;
    }
        

    UIImage *buttonBackImage = [UIImage imageNamed:@"answerBack"];

    for (int j = 0; j<songNameWord.count; j++) {
        
        CGFloat firstAnswerSquare_X = (self.choicesBoardView.center.x - (26+4) *((NSString *)songNameWord[j]).length/2 - self.choicesBoardView.frame.origin.x);//

        for (int i = 0; i<((NSString *)songNameWord[j]).length; i++) {
            
            AnswerButton *myAnswerBtn = [[AnswerButton alloc] initWithFrame:CGRectMake(firstAnswerSquare_X+1 + i*(4+26), firstAnswer_Y+j*38, 25, 25)];
            
            [myAnswerBtn addTarget:self action:@selector(answerTapped:) forControlEvents:UIControlEventTouchUpInside];
            myAnswerBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            [myAnswerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            myAnswerBtn.tag = 100 + answerBtnTag;
            answerBtnTag ++;
            myAnswerBtn.isFromTag = -1;
            [myAnswerBtn setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
            [self.choicesBoardView addSubview:myAnswerBtn];
        }

        
    }
    
    
//    CGFloat firstAnswerSquare_X = (self.choicesBoardView.center.x - (33+4) *songName.length/2 - self.choicesBoardView.frame.origin.x);//considering the distance between two squares . distance = 2.
//    UIImage *buttonBackImage = [UIImage imageNamed:@"answerBack"];
//    for (int i = 0; i<songName.length; i++) {
//
//        
//        AnswerButton *myAnswerBtn = [[AnswerButton alloc] initWithFrame:CGRectMake(firstAnswerSquare_X+1 + i*(4+33), answerButton.frame.origin.y - 75, 33, 33)];
//        
//        [myAnswerBtn addTarget:self action:@selector(answerTapped:) forControlEvents:UIControlEventTouchUpInside];
//        myAnswerBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];        [myAnswerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        myAnswerBtn.tag = i+100;
//        myAnswerBtn.isFromTag = -1;
//        [myAnswerBtn setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
//        [self.choicesBoardView addSubview:myAnswerBtn];
//    }
    
//    NSLog(@"sub:%@",[self.choicesBoardView subviews]);

    for (int i = 1; i < 22; i++) {
        UIButton *answerButton = (UIButton *)[self.choicesBoardView viewWithTag:i];
        [answerButton setHidden:NO];
        [answerButton setTitle:songAnswerSingleLetter[i-1] forState:UIControlStateNormal];
    }
    
    [self.deleteButton setEnabled:YES];
    [self.playSingleButton setEnabled:YES];
    [self.showAnswerButton setEnabled:YES];

    
    [UIView animateWithDuration:0.9 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0.89 options:0 animations:^{
        [self.choicesBoardView setFrame:CGRectMake(self.downPartView.frame.origin.x,self.downPartView.frame.origin.y, self.downPartView.frame.size.width,self.downPartView.frame.size.height+3)];
    } completion:^(BOOL finished){
        
        [self.navigationItem setHidesBackButton:YES];
        
        
    }];
    
    [CommonUtility tapSound:@"Window_Appear" withType:@"mp3"];
    
    //init this song's answer pick count.
    self.choicesBoardView.songName = songName;
    self.choicesBoardView.songNumber = diskNumber;

    answerPickedCount = 0;
    


    
}


-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    //如果往下滑
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        
        //先加载数据，再加载动画特效
        
        [self returnChoicesBoard:nil];
        
    }
    
}

-(void)answerTapped:(AnswerButton *)sender
{
//    NSLog(@"tag:%ld",sender.tag);
    

    [CommonUtility tapSound:@"Letter_Remove" withType:@"mp3"];
    if  (sender.titleLabel.text && ![sender.titleLabel.text isEqualToString:@" "])
    {
        [sender setTitle:@" " forState:UIControlStateNormal];
        UIButton *isFromButton = (UIButton *)[self.choicesBoardView viewWithTag:sender.isFromTag];
        [isFromButton setHidden:NO];
        answerPickedCount --;
    }
    
    if([sender.titleLabel.textColor isEqual:[UIColor redColor]])
    {
            for (UIButton *subview in [self.choicesBoardView subviews]) {
                if ([subview isKindOfClass:[AnswerButton class]]) {
                    
                    [subview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        
    }
  

    
}



- (IBAction)choicesTaped:(UIButton *)sender {
    
    
    NSMutableArray *decisions = [[NSMutableArray alloc] init];
    
    for (UIButton *subview in [self.choicesBoardView subviews]) {
        if ([subview isKindOfClass:[AnswerButton class]]) {

            [decisions insertObject:subview atIndex:(subview.tag-100)];
        }
    }

    
    for (int i = 0;i<decisions.count;i++) {
        AnswerButton *answer = decisions[i];
        if (!answer.titleLabel.text || [answer.titleLabel.text isEqualToString:@" "] ||[answer.titleLabel.text isEqualToString:@""]) {
            
            [CommonUtility tapSound:@"Letter_Add" withType:@"mp3"];

            [answer setTitle:sender.titleLabel.text forState:UIControlStateNormal];
            
            answer.isFromTag =(int)sender.tag;
            answerPickedCount ++;
            
            [sender setHidden:YES];
            break;
        }
        
    }
    if (answerPickedCount == decisions.count) {
        NSString *songNameGuessed = @"";
        
        NSString *songNameWithoutBlank = [self.choicesBoardView.songName stringByReplacingOccurrencesOfString:@" " withString:@""];
        for (int i = 0;i<decisions.count;i++) {
            AnswerButton *answer = decisions[i];
            songNameGuessed = [songNameGuessed stringByAppendingString:answer.titleLabel.text];
        }
        if ([songNameGuessed isEqualToString:songNameWithoutBlank]) {

            NSLog(@"you got it");
            [MobClick event:@"rightAnswer"];

            [self.guessNameBtnArray[self.choicesBoardView.songNumber] setHidden:NO];
            CGRect diskFrame = [(UIButton *)self.guessNameBtnArray[self.choicesBoardView.songNumber] frame];
            
            UILabel *songResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, diskFrame.size.width, diskFrame.size.height)];

            songResult.text = self.choicesBoardView.songName;
            songResult.font = [UIFont fontWithName:@"Oriya Sangam MN" size:18];
            
            songResult.numberOfLines = 2;
            songResult.textAlignment = NSTextAlignmentCenter;
            [songResult setTextColor:[UIColor whiteColor]];
            [songResult setBackgroundColor:[UIColor clearColor]];
            

            UIImageView *CDimage =(UIImageView *)[self.guessNameBtnArray[self.choicesBoardView.songNumber] viewWithTag:10];
            if (CDimage) {
                [CDimage removeFromSuperview];
            }
            
            UIButton *buttonGuess =self.guessNameBtnArray[self.choicesBoardView.songNumber];
            [buttonGuess setTitle:@" " forState:UIControlStateNormal];

            
            
            UIImageView *checkMark = [[UIImageView alloc] initWithFrame:cdFrame];
            [checkMark setImage:[UIImage imageNamed:@"checkMark"]];
            [songResult addSubview:checkMark];
            
            [self.guessNameBtnArray[self.choicesBoardView.songNumber] addSubview:songResult];
            [self.musicsPlayArray removeObject:self.choicesBoardView.songName];
            
            [self.guessNameBtnArray[self.choicesBoardView.songNumber] setEnabled:NO];
            [self returnChoicesBoard:nil];

            if (self.musicsPlayArray.count == 0) {
                
//                [self goOnNext];
            
            }else
            {
                [CommonUtility tapSound:@"Correct" withType:@"mp3"];

            }
            
        }else
        {
            NSLog(@"you failed it.");
            [CommonUtility tapSound:@"Incorrect" withType:@"mp3"];
            [MobClick event:@"wrongAnswer"];

            for (UIButton *subview in [self.choicesBoardView subviews]) {
                if ([subview isKindOfClass:[AnswerButton class]]) {
                    
                    //1
                    [UIView transitionWithView:subview duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [subview setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                    } completion:^(BOOL finished) {
                        
                        //2
                        [UIView transitionWithView:subview duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            [subview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        } completion:^(BOOL finished) {
                            
                            //3
                            [UIView transitionWithView:subview duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                [subview setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                            } completion:^(BOOL finished) {
                                
                                //4
                                [UIView transitionWithView:subview duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                    [subview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                                } completion:^(BOOL finished) {
                                    
                                    //5
                                    [UIView transitionWithView:subview duration:0.18 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                        [subview setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                    } completion:^(BOOL finished) {
                                        
                                    }];
                                    
                                    
                                }];
                                
                                
                            }];
                            
                            
                        }];
                        
                        
                    }];
                }
            }
//            UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"再试一次" message:@"答错啦，大侠重头来过吧" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"重新来过", nil];
//            failAlert.tag = 1;
//            [failAlert show];
        }
    }
    
    
}


-(void)goOnNext
{
    //load levelPassView
    
    if(!self.levelPassView)
    {
        self.levelPassView = [[[NSBundle mainBundle] loadNibNamed:@"levelPassView" owner:self options:nil] objectAtIndex:0];
        [self.levelPassView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        CGRect aframe = self.levelPassView.frame;
        aframe.origin.y = -[UIScreen mainScreen].bounds.size.height;
        [self.levelPassView setFrame:aframe];
        
        [self.view addSubview:self.levelPassView];
        
        NSLog(@"passView%@",self.levelPassView);
        
    }
    
    
    [self modifyPlist:@"gameData" withValue:self.musicsPlayArray forKey:@"musicPlaying"];
    
    int levelNow = [[self.gameDataForSingleLevel objectForKey:@"currentLevel"] intValue];
    
//change
    self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
    NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
    int coinReward = LEVEL_PASS_COIN*([currentDifficulty intValue]+1);
    [CommonUtility coinsChange:coinReward];
    [self.coinShow setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
    
    if (levelNow == TOTAL_LEVEL) {
        
        UIAlertView *finishLevelAlert = [[UIAlertView alloc] initWithTitle:@"Unbelievable" message:@"You are awesome！We will update song library very soon！You may restart the game to recombine songs." delegate:self cancelButtonTitle:@"Wait patiently" otherButtonTitles:nil, nil];
        [finishLevelAlert show];
        
    }else if (levelNow % MAX_LEVEL == 0) {

        
        self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
        NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
        

        
        int levelNow = [[self.gameDataForSingleLevel objectForKey:@"currentLevel"] intValue];
        [self.delegate resetPlist];

        [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",levelNow+1] forKey:@"currentLevel"];
        [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",[currentDifficulty intValue]+1] forKey:@"difficulty"];
        
        [self.levelPassMessage setHidden:YES];
        [self.difficultyPass setHidden:NO];
        UILabel *coinAmount = (UILabel *)[self.difficultyPass viewWithTag:1];
        [coinAmount setText:[NSString stringWithFormat:@"%d",coinReward]];
        
        [UIView animateWithDuration:0.55 delay:0.15 usingSpringWithDamping:0.99 initialSpringVelocity:0.99 options:0 animations:^{
            CGRect aframe = self.levelPassView.frame;
            aframe.origin.y = 0;
            [self.levelPassView setFrame:aframe];
            
            
        } completion:nil];
        
        
    }else
    {
        self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
        
        
        int levelNow = [[self.gameDataForSingleLevel objectForKey:@"currentLevel"] intValue];
        [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",levelNow+1] forKey:@"currentLevel"];
        
        [self.difficultyPass setHidden:YES];
        [self.levelPassMessage setHidden:NO];
        
        UILabel *coinAmount = (UILabel *)[self.levelPassMessage viewWithTag:1];
        [coinAmount setText:[NSString stringWithFormat:@"%d",coinReward]];
        
        [UIView animateWithDuration:0.55 delay:0.15 usingSpringWithDamping:0.99 initialSpringVelocity:0.99 options:0 animations:^{
            CGRect aframe = self.levelPassView.frame;
            aframe.origin.y = 0;
            [self.levelPassView setFrame:aframe];
            
            
        } completion:nil];
        

    }



    
}

-(BOOL)checkCoins:(int)price
{
    if ([CommonUtility fetchCoinAmount] < price) {
       
        UIAlertView *coinsShort = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Not enough coins. Get coins now?" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Continue", nil];
        coinsShort.tag = 3;
        [coinsShort show];
        
        return NO;
    }else
    {
        return YES;
    }
}

- (IBAction)deleteSomeWords {
    
    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    if ([self checkCoins:DELETE_PRICE])
    {
        
        UIAlertView *deleteWordsAlert = [[UIAlertView alloc] initWithTitle:@"Attention" message:[NSString stringWithFormat:@"Remove 5 wrong choices by spending %d coins?",DELETE_PRICE] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [deleteWordsAlert show];
        deleteWordsAlert.tag = 10;
        
        
    }
}

-(void)stopSingleMusic
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop10secondMusics) object:nil];

    
    for (AVAudioPlayer *audio in self.myAudioArray) {
        if ([audio isPlaying]) {
            [audio stop];
            
            
        }
    }
    if (animating) {
        [self stopSpin];
        [self.deleteOneBtn setEnabled:YES];
        [self.shareBtn setEnabled:YES];
        [self.playBtn setImage:[UIImage imageNamed:@"开始"] forState:UIControlStateNormal];
        
        isplayed =false;

       
//        [self enableButtons];
    }

}

-(void)stop10secondMusics
{
    [self.playSingleButton setEnabled:YES];
    [self stopSingleMusic];

}

- (IBAction)playSingleSong {
    
    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    if ([self checkCoins:SINGLE_SONG_PRICE]){
        
        UIAlertView *playSingleAlert = [[UIAlertView alloc] initWithTitle:@"Attention" message:[NSString stringWithFormat:@"Play this single song by spending %d coins?",SINGLE_SONG_PRICE] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [playSingleAlert show];
        playSingleAlert.tag = 11;
       
    }

}

- (IBAction)showFullAnswer {
    
    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    if ([self checkCoins:SHOW_ANSWER_PRICE]){
        
        UIAlertView *playSingleAlert = [[UIAlertView alloc] initWithTitle:@"Attention" message:[NSString stringWithFormat:@"Get this song name by spending %d coins?",SHOW_ANSWER_PRICE] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [playSingleAlert show];
        playSingleAlert.tag = 12;
        
    }
}

-(NSString *)jointURL
{
    NSInteger songsCount = self.musicsArrayForShare.count;
    NSString *musicsURL = @"http://baidu.com";
    switch (songsCount) {
        case 1:
            musicsURL = [NSString stringWithFormat:@"http://cgx.nwpu.info/index.php?name[]=%@.m4a&lang=en",self.musicsArrayForShare[0]];
            break;
        case 2:
            musicsURL = [NSString stringWithFormat:@"http://cgx.nwpu.info/index.php?name[]=%@.m4a&name[]=%@.m4a&lang=en",self.musicsArrayForShare[0],self.musicsArrayForShare[1]];
            break;
        case 3:
            musicsURL = [NSString stringWithFormat:@"http://cgx.nwpu.info/index.php?name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&lang=en",self.musicsArrayForShare[0],self.musicsArrayForShare[1],self.musicsArrayForShare[2]];
            break;
        case 4:
            musicsURL = [NSString stringWithFormat:@"http://cgx.nwpu.info/index.php?name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&lang=en",self.musicsArrayForShare[0],self.musicsArrayForShare[1],self.musicsArrayForShare[2],self.musicsArrayForShare[3]];
            break;
        case 5:
            musicsURL = [NSString stringWithFormat:@"http://cgx.nwpu.info/index.php?name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&name[]=%@.m4a&lang=en",self.musicsArrayForShare[0],self.musicsArrayForShare[1],self.musicsArrayForShare[2],self.musicsArrayForShare[3],self.musicsArrayForShare[4]];
            break;
            
        default:
            break;
    }
    
    return musicsURL;
}

- (IBAction)shareButton:(UIButton *)sender {
    
    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    [MobClick event:@"shareFromGame"];
    NSString *musicsURL = [self jointURL];
    NSLog(@"string1:%@",musicsURL);
    NSMutableString * theURL = [[NSMutableString alloc]initWithString:musicsURL];
    
    NSString * escaped = [theURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"string2:%@",escaped);

    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:escaped];
    
    params.picture =[NSURL URLWithString:[NSString stringWithFormat:@"http://cgx.nwpu.info/image/cd%u.png",[self randomDiskNumberWithRange:13]]];
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                         name:@"Mixing"
                                      caption:nil
                                  description:@"What are these songs? Come and help!\nHow many songs can you find ?"
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
                                                  
                                              }
                                          }
                                      }];
        
        
    } else {
        // Present the feed dialog
        UIAlertView * fbAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Can't find facebook app on your device.Share failed." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil, nil];
        [fbAlert show];
        
    }

    
}

- (IBAction)refreshMusics:(UIButton *)sender {//delete one song
    [MobClick event:@"bombOne"];

    [CommonUtility tapSound:@"click" withType:@"mp3"];
    
    if(self.musicsPlayArray.count <= 1)
    {
        UIAlertView *noDeleteAlert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"No more delete!One song left ONLY!" delegate:nil cancelButtonTitle:@"Keep trying" otherButtonTitles:nil, nil];
        [noDeleteAlert show];
        return;
    }
    
    if ([self checkCoins:BOMB_SONG_PRICE]){
        
        UIAlertView *playSingleAlert = [[UIAlertView alloc] initWithTitle:@"Attention" message:[NSString stringWithFormat:@"Remove a song by spending %d conis?",BOMB_SONG_PRICE] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [playSingleAlert show];
        playSingleAlert.tag = 13;
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        if (alertView.tag == 1) {
            
            for (UIView *subview in [self.choicesBoardView subviews]) {
                if ([subview isKindOfClass:[AnswerButton class]]) {
                    [((AnswerButton *)subview) setTitle:@" " forState:UIControlStateNormal];
                    answerPickedCount = 0;
                }
                [subview setHidden:NO];
            }
        }
        
        if (alertView.tag == 2) {
            
            self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
            NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
            
            [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",[currentDifficulty intValue]+1] forKey:@"difficulty"];
            
            [self nextLevel];
        }
        if (alertView.tag == 3) {
            [self buyCoinsAction];
        }
        
        if (alertView.tag == 10)//删除错误选项
        {
            [MobClick event:@"deleteChoice"];
            [CommonUtility tapSound:@"s_remove" withType:@"mp3"];

            NSString *songName = self.choicesBoardView.songName;
            int i = 0;
            while (i<5) {
                
                unsigned int randomNumber = 1+ arc4random()%21;  //1~21
                UIButton *answerButton = (UIButton *)[self.choicesBoardView viewWithTag:randomNumber];
                if ([CommonUtility myContainsStringFrom:songName for:answerButton.titleLabel.text] || answerButton.isHidden) {
                    continue;
                }else
                {
                    [answerButton setHidden:YES];
                    i++;
                }
                
            }
            
            [self.deleteButton setEnabled:NO];
            [CommonUtility coinsChange:-DELETE_PRICE];
            [self.coinShow setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];

        }
        
        if (alertView.tag == 11)//单曲播放

        {
            [MobClick event:@"playSingleSone"];

            
            NSString *songName = self.choicesBoardView.songName;
            
            [self.myAudioArray removeAllObjects];
            [self tapSound:songName withType:@"m4a"];
            [self.playSingleButton setEnabled:NO];
            [self performSelector:@selector(stop10secondMusics) withObject:nil afterDelay:10.0f];
            
            [CommonUtility coinsChange:-SINGLE_SONG_PRICE];
            [self.coinShow setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
        }
        
        if (alertView.tag == 12)//公布答案
        {
            [MobClick event:@"showAnswer"];
            [CommonUtility tapSound:@"go" withType:@"mp3"];

            NSString *songName = self.choicesBoardView.songName;
            NSString *songNameWithoutBlank = [songName stringByReplacingOccurrencesOfString:@" " withString:@""];

            for (int i = 0; i < [songNameWithoutBlank length]; i++) {
               AnswerButton *myAnswerbtn =(AnswerButton *)[self.choicesBoardView viewWithTag:(100+i)];
                [myAnswerbtn setTitle:[songNameWithoutBlank substringWithRange:NSMakeRange(i, 1)] forState:UIControlStateNormal];
                
            }
            
            
            [self.guessNameBtnArray[self.choicesBoardView.songNumber] setHidden:NO];
            CGRect diskFrame = [(UIButton *)self.guessNameBtnArray[self.choicesBoardView.songNumber] frame];


            UILabel *songResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, diskFrame.size.width, diskFrame.size.height)];
//            songResult.center = [(UIButton *)self.diskButtons[self.choicesBoardView.songNumber] center];
          
            songResult.text = songName;
            songResult.font = [UIFont fontWithName:@"Oriya Sangam MN" size:18];
            songResult.numberOfLines = 2;
            songResult.textAlignment = NSTextAlignmentCenter;
            [songResult setTextColor:[UIColor whiteColor]];
            
            UIImageView *CDimage =(UIImageView *)[self.guessNameBtnArray[self.choicesBoardView.songNumber] viewWithTag:10];
            if (CDimage) {
                [CDimage removeFromSuperview];
            }
            
            UIButton *buttonGuess =self.guessNameBtnArray[self.choicesBoardView.songNumber];
            [buttonGuess setTitle:@" " forState:UIControlStateNormal];
            
            
            UIImageView *checkMark = [[UIImageView alloc] initWithFrame:cdFrame ];
            [checkMark setImage:[UIImage imageNamed:@"checkMark"]];
            
            [songResult addSubview:checkMark];
            
            [buttonGuess addSubview:songResult];
            [buttonGuess setEnabled:NO];
            [self.musicsPlayArray removeObject:songName];
            
            
            [self.showAnswerButton setEnabled:NO];
            
            [CommonUtility coinsChange:-SHOW_ANSWER_PRICE];
            [self.coinShow setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
        }
        
        if (alertView.tag == 13)//去除一首混播歌曲
        {
            
            [CommonUtility tapSound:@"s_remove" withType:@"mp3"];
            int diskNumber = -1;
            
            for(int i = (int)(self.guessNameBtnArray.count -1) ; i >= 0 ; i-- )
            {
                if (![((UIButton *)self.guessNameBtnArray[i]).titleLabel.text isEqualToString:@" "]) {
                   
                    diskNumber = i;
                    CGRect diskFrame = [self.guessNameBtnArray[i] frame];

                    
                    UILabel *ignoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, diskFrame.size.width, diskFrame.size.height)];
                    [ignoreLabel setText:@"Ignore this song"];
                    ignoreLabel.font = [UIFont fontWithName:@"Oriya Sangam MN" size:18];
                    [ignoreLabel setTextColor:[UIColor whiteColor]];
                    ignoreLabel.textAlignment = NSTextAlignmentCenter;

                    UIImageView *CDimage =(UIImageView *)[self.guessNameBtnArray[i] viewWithTag:10];
                    if (CDimage) {
                        [CDimage removeFromSuperview];
                    }
                    
                    UIButton *buttonGuess =self.guessNameBtnArray[i];
                    [buttonGuess setTitle:@" " forState:UIControlStateNormal];
                    [buttonGuess addSubview:ignoreLabel];
                    [buttonGuess setEnabled:NO];

                    
                    //            UIImageView *rightBackImg = [[UIImageView alloc] initWithFrame:songResult.frame];
                    //            [rightBackImg setImage:[UIImage imageNamed:@"rightBack"]];
                    //           if (songName.length >3) {
                    //                CGRect aframe = songResult.frame;
                    //                aframe.origin.y -= 6;
                    //                [rightBackImg setFrame:aframe];
                    //            }
                    //            [self.downPartView addSubview:rightBackImg];
                    
//                    UIImageView *checkMark = [[UIImageView alloc] initWithFrame:cdFrame ];
//                    [checkMark setImage:[UIImage imageNamed:@"closeBuyBtn"]];
//                    
//                    [ignoreLabel addSubview:checkMark];
                    
                    
                    break;
                }
            }
            NSString *songName = self.musicsArray[diskNumber];
            
            [self.musicsArray removeObject:songName];
            [self.musicsPlayArray removeObject:songName];
            
            
            
            self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
            
            NSMutableArray *currentMusics = [self.gameDataForSingleLevel objectForKey:@"musicPlaying"];
            [currentMusics removeObject:songName];
            [self modifyPlist:@"gameData" withValue:currentMusics forKey:@"musicPlaying"];
            
            [CommonUtility coinsChange:-BOMB_SONG_PRICE];
            [self.coinShow setTitle:[NSString stringWithFormat:@"%d",[CommonUtility fetchCoinAmount]] forState:UIControlStateNormal];
        }
    }
}


- (IBAction)returnChoicesBoard:(UIButton *)sender {
    [CommonUtility tapSound:@"Window_Disappear" withType:@"mp3"];

    
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:0 animations:^{
        [self.choicesBoardView setFrame:CGRectMake(self.downPartView.frame.origin.x,[UIScreen mainScreen].bounds.size.height , self.downPartView.frame.size.width,self.downPartView.frame.size.height +3)];
    } completion:^(BOOL finished){
        [self.navigationItem setHidesBackButton:NO];

        
        
        
    }];
    [self stopSingleMusic];
    for (UIView *subview in [self.choicesBoardView subviews]) {
        if ([subview isKindOfClass:[AnswerButton class]]) {
            [subview removeFromSuperview];
        }
    }
    answerBtnTag = 0;
    if (self.musicsPlayArray.count == 0) {
        
        [self performSelector:@selector(goOnNext) withObject:nil afterDelay:0.35];
        [CommonUtility tapSound:@"s_levelup" withType:@"mp3"];

    }else
    {

    }

    
}


#pragma mark disk animation

- (void)spinWithOptions: (UIViewAnimationOptions) options :(UIView *)destRotateView {
    [UIView animateWithDuration: 0.01f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         destRotateView.transform = CGAffineTransformRotate(destRotateView.transform, M_PI/68 );
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             

                             if (animating) {
                                 // if flag still set, keep spinning with constant speed

                                [self spinWithOptions:UIViewAnimationOptionTransitionNone :destRotateView];
                                 
                                 
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        for (UIButton * button in self.guessNameBtnArray) {
            
            button.imageView.backgroundColor = [UIColor blueColor];
                [self spinWithOptions: UIViewAnimationOptionTransitionNone:[button viewWithTag:10]];

        }
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

-(void)diskHideToTop
{
    NSInteger musicCount = self.musicsArray.count;
    
    for (int i = 0;i<musicCount;i++) {
        
        
        NSString *songName = self.musicsArray[i];
        NSArray *songNameWord = [songName componentsSeparatedByString:@" "];
        
        NSLog(@"songName:%@,songNameWord:%lu",songName,(unsigned long)songNameWord.count);
        
        UIButton *guessBtn = (UIButton *)self.guessNameBtnArray[i];
        if (songNameWord.count == 1) {
            
            [guessBtn setTitle:[NSString stringWithFormat:@"Song Name: 1 word,%lu letters",(unsigned long)(songName.length-songNameWord.count + 1)] forState:UIControlStateNormal];
        }else
        {
            [guessBtn setTitle:[NSString stringWithFormat:@"Song Name: %lu words,%lu letters",(unsigned long)songNameWord.count,(unsigned long)(songName.length-songNameWord.count + 1)] forState:UIControlStateNormal];
        }
        
        
        

        
        [UIView animateWithDuration:0.65+i*0.17 delay:(3+4*i)/20
             usingSpringWithDamping:0.55 initialSpringVelocity:0.4 options:0 animations:^{

                 CGRect aframe = guessBtn.frame;
                 aframe.origin.x = (SCREEN_WIDTH-aframe.size.width)/2;
                 [guessBtn setFrame:aframe];
                 [guessBtn setHidden:NO];
            
            
             } completion:^(BOOL finished){
             
                 if (finished) {
                     NSLog(@"finished:%@",guessBtn);
                     
                 }else
                     NSLog(@"nonono:%@",guessBtn);
                 
             }];
    
    }
//    for (int i = 0; i < [self.currentDifficulty intValue]; i++) {
//        UILabel *ignoreLabel = [[UILabel alloc] initWithFrame:[self.guessNameBtnArray[i] frame]];
//        [ignoreLabel setText:@"Ignore this song"];
//        ignoreLabel.textAlignment = NSTextAlignmentCenter;
//        [ignoreLabel setTextColor:[UIColor whiteColor]];
//        [self.ignoreArray insertObject:ignoreLabel atIndex:i];
//        [self. downPartView addSubview:ignoreLabel];
//        [ignoreLabel setHidden:YES];
//        
//        if (i >= musicCount && i <= [self.currentDifficulty intValue]) {
//            
//            [ignoreLabel setHidden:NO];
//            
//        }
//    }
    
    
}
//-(void)diskPopUp
//{
//    for (int i = 0;i<self.diskButtons.count;i++) {
//        
//        [self.diskButtons[i] setEnabled:NO];
//        
//        [UIView animateWithDuration:0.65+i*0.12 delay:0.2 usingSpringWithDamping:0.55 initialSpringVelocity:0.4 options:0 animations:^{
//            [self.diskButtons[i] setFrame:[[self.diskButtonFrameArray objectAtIndex:i] CGRectValue]];
//
//            
//        } completion:nil];
//        
//
//        if (self.ignoreArray.count > 0 && self.ignoreArray[i]!=nil) {
//
//        [UIView animateWithDuration:0.65+i*0.12 delay:0.35 usingSpringWithDamping:0.5 initialSpringVelocity:0.4 options:0 animations:^{
//            [self.ignoreArray[i] setFrame:[[self.diskButtonFrameArray objectAtIndex:i] CGRectValue]];
//            
//            
//        } completion:nil];
//    }
//
//    }
//    
//}

//
//-(void)tapButton
//{
//    CGRect aframe = self.downPartView.frame;
//    aframe.origin.y -= 100;
//    [self.downPartView setFrame:aframe];
//}


-(void)tapSound:(NSString *)name withType:(NSString *)type
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[ NSString stringWithFormat:@"%@.%@",name,type]];
    
    NSLog(@"folderPath:%@",folderPath);

    if (soundFilePath)
    {
        NSError *error;
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:folderPath] == NO)
        {
            
           BOOL success = [[NSFileManager defaultManager] copyItemAtPath:soundFilePath
                                                    toPath:folderPath
                                                     error:&error];
//            NSLog(@"Error description-%@ \n", [error localizedDescription]);
//            NSLog(@"Error reason-%@", [error localizedFailureReason]);
            NSLog(@"succsee:%d",success);
        }
        
    }
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:folderPath ];
    
    NSError *error;
    AVAudioPlayer *myAudioPlayer= [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    NSLog(@"error:%@",[error localizedDescription]);
    myAudioPlayer.volume = 1.0f;

    NSLog(@"Audio:%@",myAudioPlayer);
    if (myAudioPlayer) {
        [self.myAudioArray addObject:myAudioPlayer];
        [myAudioPlayer play];
    }
  
    
}
-(void)stopMusics
{
    for (AVAudioPlayer *audio in self.myAudioArray) {
        if ([audio isPlaying]) {
            [audio stop];
            
        }
    }
    [self stopSpin];
    [self.deleteOneBtn setEnabled:YES];
    [self.shareBtn setEnabled:YES];
    [self.playBtn setImage:[UIImage imageNamed:@"开始"] forState:UIControlStateNormal];

    
//    [self enableButtons];
}
//
//-(void)enableButtons
//{
//    for (int i=0;i<self.diskButtons.count;i++) {
//        
//        UIButton *button = self.diskButtons[i];
//        
//        [UIView animateWithDuration: 0.03f
//                              delay: 0.0f
//                            options: 0
//                         animations: ^{
//                             button.transform = CGAffineTransformRotate(button.transform, -((totalRotateTimes)%256 ) *( M_PI/128));
//                         }
//                         completion:nil];
//        
//        if (![button isHidden]) {
//            [button setEnabled:YES];
//            [button setTitle:[NSString stringWithFormat:@"%lu字歌",(unsigned long)[self.musicsArray[i] length]] forState:UIControlStateNormal];
//
//        }
//    }
//    totalRotateTimes = 0;
//}

//-(void)enableButtons
//{
//    for (int i=0;i<self.diskButtons.count;i++) {
//        
//        UIButton *button = self.diskButtons[i];
//        
//        [button setHidden:YES];
//        
//        NSString *songName = self.musicsArray[i];
//        NSArray *songNameWord = [songName componentsSeparatedByString:@" "];
//        
//        NSLog(@"songName:%@,songNameWord:%lu",songName,(unsigned long)songNameWord.count);
//        
//        UIButton *guessBtn = (UIButton *)self.guessNameBtnArray[i];
//        [guessBtn setTitle:[NSString stringWithFormat:@"Composed of %lu words,%lu letters",(unsigned long)songNameWord.count,songName.length-songNameWord.count + 1] forState:UIControlStateNormal];
//        CGRect destFrame = guessBtn.frame;
//        CGRect originFrame = guessBtn.frame;
//
//        destFrame.origin.x = -destFrame.size.width - 50;
//        [guessBtn setFrame:destFrame];
//        
//        [UIView beginAnimations:nil context:nil];
//        [guessBtn setFrame:originFrame];
//        [guessBtn setHidden:NO];
//        [UIView commitAnimations];
//        
//    }
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)playBtn:(id)sender {
   
    
    [MobClick event:@"playTap"];
    [self.playBtn setTitle:self.levelTitle forState:UIControlStateNormal];
    if (isplayed) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop13secondMusics) object:nil];
        
        [self stopMusics];
        
        isplayed =false;
    }else
    {
        [self initMusics];
        isplayed = true;
        
        [self performSelector:@selector(stop13secondMusics) withObject:nil afterDelay:13.0f];
    }
//    [self performSelector:@selector(PlayStart) withObject:nil afterDelay:0.5f];


}


-(void)initMusics
{
    [self.myAudioArray removeAllObjects];
    
    for (int i = 0; i< self.musicsPlayArray.count; i++) {
        [self tapSound:self.musicsPlayArray[i] withType:@"m4a"];
    }
    [self startSpin];
    [self.playBtn setImage:[UIImage imageNamed:@"停止"] forState:UIControlStateNormal];
    [self.deleteOneBtn setEnabled:NO];
    [self.shareBtn setEnabled:NO];

}
-(void)stop13secondMusics
{
    if (isplayed) {
        [self stopMusics];
        isplayed =false;
    }
}



-(void)nextLevel
{
    
    [CommonUtility tapSound:@"go" withType:@"mp3"];
    
    self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
//
    NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
//
    int levelNow = [[self.gameDataForSingleLevel objectForKey:@"currentLevel"] intValue];
//    [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",levelNow+1] forKey:@"currentLevel"];
    
    gameViewController *myGameViewController = [[gameViewController alloc] initWithNibName:@"gameViewController" bundle:nil];

    
    NSMutableArray *currentMusics = [self.gameDataForSingleLevel objectForKey:@"musicPlaying"];

    if (currentMusics && currentMusics.count > 0) {
        
        myGameViewController.musicsArray = currentMusics;
        
    }else
    {
        NSMutableArray *passMusics = [self.delegate configSongs];
        myGameViewController.musicsArray = passMusics;
        [self modifyPlist:@"gameData" withValue:passMusics forKey:@"musicPlaying"];

        
    }
    

    
    
    myGameViewController.delegate = self.delegate;
    myGameViewController.navigationItem.title = [NSString stringWithFormat:@"%d",(levelNow  - [currentDifficulty intValue]*MAX_LEVEL)];
    myGameViewController.currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
    
    NSArray *arrayControllers = self.navigationController.viewControllers;
    NSMutableArray *arrayControllerNew = [NSMutableArray arrayWithArray:arrayControllers];
    [arrayControllerNew removeLastObject];
    [arrayControllerNew addObject:myGameViewController];
    [self.navigationController setViewControllers:arrayControllerNew animated:YES];
    
    [MobClick event:@"levelPass"];

}


-(NSMutableDictionary *)readDataFromPlist:(NSString *)plistname
{
    //read level data from plist
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[ NSString stringWithFormat:@"%@.plist",plistname ]];
    NSMutableDictionary *levelData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    //    NSLog(@"levelData%@",levelData);
    return levelData;
    
}
-(void)modifyPlist:(NSString *)plistname withValue:(id)value forKey:(NSString *)key
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[ NSString stringWithFormat:@"%@.plist",plistname ]];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:plistPath] == YES)
    {
        if ([manager isWritableFileAtPath:plistPath])
        {
            NSMutableDictionary* infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            [infoDict setObject:value forKey:key];
            [infoDict writeToFile:plistPath atomically:NO];
            [manager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
        }
    }
}

#pragma mark AD..

-(void)dropDown
{
    
    
    for (int i = 0; i<8; i++) {
        
        double size = [self randomSize];
        CGRect aframe = CGRectMake([self randomXfrom:40*i toEnd:40+40*i], -50, size, size);
        [self setupAnimationNote:self.musicNotes[i] imageName:[NSString stringWithFormat:@"note%d",i] ImageFrame:aframe];
        
    }
    
    [self.view sendSubviewToBack:self.imgBack];
    
}
-(double)randomXfrom:(int)startX toEnd:(int)endX
{
    unsigned int randomNumber = startX + arc4random()%(endX - startX);
    return (double)randomNumber;
    
}
-(double)randomY
{
    unsigned int randomNumber = 20 + arc4random()%120;
    return (double)randomNumber;
    
}
-(double)randomSize
{
    unsigned int randomNumber = 20 + arc4random()%30;
    return (double)randomNumber;
    
}
-(int)randomSpeed
{
    unsigned int randomNumber = 20 + arc4random()%100;
    return randomNumber;
}

-(void)setupAnimationNote:(UIImageView *)NoteImageView imageName:(NSString *)ImgName ImageFrame:(CGRect)imgFrame
{
    NoteImageView = [[UIImageView alloc] initWithFrame:imgFrame];
    [NoteImageView setImage:[UIImage imageNamed:ImgName]];
    NoteImageView.alpha = 0;
    [self.view addSubview:NoteImageView];
    [self.view sendSubviewToBack:NoteImageView];
    
    fallAnimation *myFall = [[fallAnimation alloc] initWithView:NoteImageView];
    
    [myFall startDisplayOnGame];
//    [myFall performSelector:@selector(startDisplayOnGame) withObject:nil afterDelay:0.05];
    
}
- (IBAction)levelPassTap {
    
    [self nextLevel];
}

- (IBAction)difficultyPassTap:(id)sender {
    
//    self.gameDataForSingleLevel = [self readDataFromPlist:@"gameData"] ;
//    NSString *currentDifficulty = [self.gameDataForSingleLevel objectForKey:@"difficulty"];
//    
//    [self modifyPlist:@"gameData" withValue:[NSString stringWithFormat:@"%d",[currentDifficulty intValue]+1] forKey:@"difficulty"];
    [self nextLevel];
}
- (IBAction)guessNameTap:(id)sender {
}
@end
