//
//  ViewController.m
//  ClassKitIntegration
//
//  Created by Peter Easdown on 27/5/18.
//  Copyright © 2018 PKCLsoft. All rights reserved.
//

#import "ViewController.h"
#import "LessonDatabase.h"
#import "PlayerGame.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentQuestionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startActivityButton;
@property (weak, nonatomic) IBOutlet UIButton *answerQuestionButton;
@property (weak, nonatomic) IBOutlet UIButton *answerIncorrectlyButton;
@property (weak, nonatomic) IBOutlet UIButton *quitActivityButton;
@property (weak, nonatomic) IBOutlet UILabel *percentCorrectLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageTimeLabel;

@property (retain, nonatomic) PlayerGame *game;

@end

@implementation ViewController

#define NUMBER_OF_QUESTIONS (10)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.game = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSchoolWorkActivity:) name:SCHOOLWORK_ACTIVITY_LAUNCHED object:nil];

    [self updateUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI {
    if (self.game != nil) {
        self.currentQuestionLabel.text = [NSString stringWithFormat:@"%lu", self.game.currentQuestion + 1];
        self.questionCountLabel.text = [NSString stringWithFormat:@"%lu", self.game.questions.count];
        self.percentCorrectLabel.text = [NSString stringWithFormat:@"%3.2f", self.game.percentCorrect];
        self.averageTimeLabel.text = [NSString stringWithFormat:@"%3.2f", self.game.averageTimeToAnswer];

        self.answerQuestionButton.enabled = !self.game.gameOver;
        self.answerIncorrectlyButton.enabled = !self.game.gameOver;
        self.startActivityButton.enabled = self.game.gameOver;
        self.quitActivityButton.enabled = !self.game.gameOver;
    } else {
        self.currentQuestionLabel.text = @"Waiting to start";
        self.questionCountLabel.text = @"Unknown";
        self.percentCorrectLabel.text = @"0.0";
        self.averageTimeLabel.text = @"0.0";

        self.answerQuestionButton.enabled = NO;
        self.answerIncorrectlyButton.enabled = NO;
        self.startActivityButton.enabled = YES;
        self.quitActivityButton.enabled = NO;
    }
}

- (void) startSchoolWorkActivity:(NSNotification*)notification {
    [self startActivityPressed:nil];
}

- (IBAction)startActivityPressed:(id)sender {
    // In this simple demo, when the activity is started, we create the new "game".  If the app has been launched
    // by the SchoolWork, then set the game up using the properties of the game communicated by SchoolWork.
    //
    if ([LessonDatabase sharedInstance].schoolWorkActivityPresent == YES) {
        self.game = [PlayerGame playerGameWith:[LessonDatabase sharedInstance].puzzleCount];
        self.game.skills = [LessonDatabase sharedInstance].skills;
    } else {
        // If this is just a test without a launch from SchoolWork, then create a dummy game with 10 questions.
        //
        self.game = [PlayerGame playerGameWith:NUMBER_OF_QUESTIONS];
    }

    // Start the activity.
    //
    [[LessonDatabase sharedInstance] startActivityWith:self.game.questions.count];

    [self updateUI];
}

- (IBAction)answerQuestionPressed:(id)sender {
    [self.game answerQuestion:YES];

    if (self.game.gameOver == YES) {
        [[LessonDatabase sharedInstance] endActivity:self.game];
    } else {
        [self.game startNextQuestion];
    }

    [self updateUI];
}

- (IBAction)answerIncorrectlyPressed:(id)sender {
    [self.game answerQuestion:NO];

    if (self.game.gameOver == YES) {
        [[LessonDatabase sharedInstance] endActivity:self.game];
    } else {
        [self.game startNextQuestion];
    }

    [self updateUI];
}

- (IBAction)quitActivityPressed:(id)sender {
    [[LessonDatabase sharedInstance] endActivity:self.game];
    self.game = nil;

    [self updateUI];
}

@end
