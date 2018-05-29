//
//  LessonDatabase.m
//
//  Created by Peter Easdown on 29/05/2018
//

#import <Foundation/Foundation.h>
#import <ClassKit/ClassKit.h>
#import "LessonDatabase.h"
#import "PlayerGame.h"

@interface LessonDatabase () <CLSDataStoreDelegate>

@property (nonatomic, retain) NSArray<NSString*> *currentActivityIdentifier;
@property (nonatomic, assign) NSInteger numberOfQuestions;
@property (nonatomic, assign) NSInteger progressTarget;
@property (nonatomic, assign) NSInteger currentProgress;

@end

@implementation LessonDatabase

/*
 * An activity path will take the form:
 *
 * skillLevel-0.skillNumberMaximum-20.puzzleCount-1.skill-1
 *
 * where each element of the path has a prefix and a value.  The prefix is used to
 * define a property of the activity that needs to be set before the student can
 * start it.  The value provides a way to give the property a value.
 *
 * In this example, which has been lifted from my Tap Tangram app, there are four
 * properties:
 *
 *   skillLevel: which equates to easy (0), medium (1) or hard (2)
 *
 *   skillNumberMaximum: which provides the app with a limit on how big a number can
 *      be in question.  This allows the teacher to tune the activity per student, making
 *      it easier or harder.
 *
 *   puzzleCount: is the number of puzzles that need to be solved by the student in the
 *      actvity.  This has the added effect of makin the activity longer/shorter, requiring
 *      more questions to be answered.
 *
 *   skill: is the skill set to apply to the lesson where:
 *      1 = addition
 *      2 = subtraction
 *      3 = addition and subtraction
 *      4 = division
 *      5 = division and multiplication
 *      8 = multiplication
 *     15 = all skills
 *
 * Note that I have crafted the components this way so that the value for each property can
 * also be used to specify the displayOrder in the associated context.
 *
 * So if you are wanting to reuse this for your own app, you need to decide how you want to structure
 * your activity paths, and rebuild the following messages:
 *
 * - (id) init;
 * - (void) addSkillNumberMaximumsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context API_AVAILABLE(ios(11.3));
 * - (void) addPuzzleCountsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context  API_AVAILABLE(ios(11.3));
 * - (void) addSkillsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context  API_AVAILABLE(ios(11.3));
 * - (nullable __kindof CLSContext *)createContextForIdentifier:(nonnull NSString *)identifier parentContext:(nonnull __kindof CLSContext *)parentContext parentIdentifierPath:(nonnull NSArray<NSString *> *)parentIdentifierPath  API_AVAILABLE(ios(11.3));
 * - (BOOL) appDidReceiveIdentifier:(NSArray<NSString*>*)identifier;
 *
 */

// skill levels
#define SKILL_LEVEL_PREFIX @"skillLevel"
#define SKILL_LEVEL_EASY @"skillLevel-0"
#define SKILL_LEVEL_MEDIUM @"skillLevel-1"
#define SKILL_LEVEL_HARD @"skillLevel-2"

// skillNumberMaximum
#define SKILL_NUMBER_MAXIMUM_PREFIX @"skillNumberMaximum"

// question count
#define PUZZLE_COUNT_PREFIX @"puzzleCount"
#define PUZZLE_COUNT_1 @"puzzleCount-1"
#define PUZZLE_COUNT_3 @"puzzleCount-3"
#define PUZZLE_COUNT_5 @"puzzleCount-5"
#define PUZZLE_COUNT_10 @"puzzleCount-10"

// skills
#define SKILL_PREFIX @"skill-"
#define ADDITION_SKILL @"skill-1"
#define SUBTRACTION_SKILL @"skill-2"
#define ADDITION_AND_SUBTRACTION_SKILL @"skill-3"
#define DIVISION_SKILL @"skill-4"
#define MULTIPLICATION_SKILL @"skill-8"
#define ALL_MATH_SKILLS @"skill-15"

/**
 * This method adds, for each of the possible skill combinations, a new activity path to the input path, and submits it
 * to ClassKit.
 */
- (void) addSkillsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context  API_AVAILABLE(ios(11.3)) {
    // For each of the skills, create a new path and submit it to ClassKit.
    //
    [@[ADDITION_SKILL, SUBTRACTION_SKILL, ADDITION_AND_SUBTRACTION_SKILL, DIVISION_SKILL, MULTIPLICATION_SKILL, ALL_MATH_SKILLS] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSMutableArray<NSString*> *skillPath = [NSMutableArray arrayWithArray:path];
        [skillPath addObject:obj];

        // Log the path for info.
        //
        NSLog(@"path: %@", [self buildTitleForPath:skillPath]);

        // Submit it to ClassKit.
        //
        [context descendantMatchingIdentifierPath:skillPath completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {

        }];
    }];
}

/**
 * For each of the valid puzzle count values, add a new activity path to the input path and submit it to ClassKit.
 */
- (void) addPuzzleCountsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context  API_AVAILABLE(ios(11.3)) {
    [@[PUZZLE_COUNT_1, PUZZLE_COUNT_3, PUZZLE_COUNT_5, PUZZLE_COUNT_10] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<NSString*> *puzzleCountPath = [NSMutableArray arrayWithArray:path];
        [puzzleCountPath addObject:obj];

        NSLog(@"path: %@", [self buildTitleForPath:puzzleCountPath]);

        // Submit the "heading" of this puzzle count to ClassKit.
        //
        [context descendantMatchingIdentifierPath:puzzleCountPath completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {

        }];

        // Now submit each of the children of this heading.
        //
        [self addSkillsToPath:puzzleCountPath inContext:context];
    }];
}

/**
 * For each valid value of "skillNumberMaximum" (there could be 180 but that would be silly), create a heading activity
 * and then add any children.
 */
- (void) addSkillNumberMaximumsToPath:(nonnull NSArray<NSString*> *)path inContext:(CLSContext*)context API_AVAILABLE(ios(11.3)) {
    // Add the input path as a "heading" for this skill level (easy, medium or hard)
    //
    [context descendantMatchingIdentifierPath:path completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {

    }];

    // Now, for each possible value of "skillNumberMaximum", add a heading node and it's children.  Note that these number are
    // arbitrary, and hard-coded here as part of the example.
    //
    for (NSUInteger maxValue = 25; maxValue <= 200; maxValue += 25) {
        NSString *title = [NSString stringWithFormat:@"%@-%lu", SKILL_NUMBER_MAXIMUM_PREFIX, maxValue];

        NSMutableArray<NSString*> *skillNumberMaxPath = [NSMutableArray arrayWithArray:path];
        [skillNumberMaxPath addObject:title];

        // Submit the "heading" of this puzzle count to ClassKit.
        //
        [context descendantMatchingIdentifierPath:skillNumberMaxPath completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {

        }];

        // Now submit each of the children of this heading.
        //
        [self addPuzzleCountsToPath:skillNumberMaxPath inContext:context];
    }
}

/**
 * initialise the entire context tree.
 */
- (id) init {
    self = [super init];

    if (self != nil) {
        // Ensure that the currentActivityIdentifier starts as nil, so the app doesn't do anything for ClassKit unless it is
        // told to.
        //
        self.currentActivityIdentifier = nil;

        if (@available(iOS 11.3, *)) {
            // Set up the main context.
            //
            [CLSDataStore shared].delegate = self;
            CLSContext *mainContext = [CLSDataStore shared].mainAppContext;

            // this is primarily, a math app.  Gosh it would be nice for Apple to give us a better, richer set of subjects.
            //
            mainContext.topic = CLSContextTopicMath;

            // Now add all of the activities, for each of the skill levels.
            //
            [self addSkillNumberMaximumsToPath:@[SKILL_LEVEL_EASY] inContext:mainContext];
            [self addSkillNumberMaximumsToPath:@[SKILL_LEVEL_MEDIUM] inContext:mainContext];
            [self addSkillNumberMaximumsToPath:@[SKILL_LEVEL_HARD] inContext:mainContext];
        }
    }

    return self;
}

/**
 * The singleton instance of LessonDatabase.
 */
static LessonDatabase *shared_LessonDatabase = nil;

/**
 * @return The shared instance of LessonDatabase.
 */
+ (LessonDatabase*) sharedInstance {
    if (shared_LessonDatabase == nil) {
        shared_LessonDatabase = [[LessonDatabase alloc] init];
    }

    return shared_LessonDatabase;
}

/**
 * @return NSString containing a localized title for the given path.
 * @param path An array of NSString objects which is used to form a path delimeted by '.' characters.  This path string becomes the
 * parameter for a call to the NSLocalizedString() macro.
 */
- (NSString*) buildTitleForPath:(nonnull NSArray<NSString*> *)path {
    NSMutableString *pathString = [NSMutableString string];

    for (NSString *str in path) {
        [pathString appendString:str];

        if (str != path.lastObject) {
            [pathString appendString:@"."];
        }
    }

    return NSLocalizedString(pathString, @"");
}

- (nullable __kindof CLSContext *)createContextForIdentifier:(nonnull NSString *)identifier parentContext:(nonnull __kindof CLSContext *)parentContext parentIdentifierPath:(nonnull NSArray<NSString *> *)parentIdentifierPath  API_AVAILABLE(ios(11.3)){

    // Tokenize the identifer so that we can separate the prefix and the value.
    //
    NSArray<NSString*> *tokens = [identifier componentsSeparatedByString:@"-"];

    // This will contain the title for the context.
    //
    NSString *title = nil;

    /** Default the context type to "Exercise" because it needs to be _something_. */
    CLSContextType type = CLSContextTypeExercise;

    // If this is the first property, skillLevel, treat it as a "task".
    //
    if ([identifier hasPrefix:SKILL_LEVEL_PREFIX] == YES) {
        type = CLSContextTypeTask;
        title = NSLocalizedString(identifier, @"");

        // if this is the skillNumberMaximum, build the title so that it includes the value.
        //
    } else if ([identifier hasPrefix:SKILL_NUMBER_MAXIMUM_PREFIX] == YES) {
        type = CLSContextTypeChallenge;

        NSString *placeholder = NSLocalizedString(@"skillNumberMaximumTitle", @"");
        title = [NSString stringWithFormat:placeholder, tokens[1].integerValue];

        // The puzzle count is an "exercise" because I don't know what else to call it.  These Context types
        // don't make a lot of sense when you're building a hierarchy like this.
        //
    } else if ([identifier hasPrefix:PUZZLE_COUNT_PREFIX] == YES) {
        type = CLSContextTypeExercise;
        title = NSLocalizedString(identifier, @"");

        // Finally, because this is the lowest level, this is a "quiz"
        //
    } else if ([identifier hasPrefix:SKILL_PREFIX] == YES) {
        type = CLSContextTypeQuiz;
        title = NSLocalizedString(identifier, @"");
    }

    // Create the context object itself.
    //
    CLSContext *result = [[CLSContext alloc] initWithType:type identifier:identifier title:title];

    // Specify the display order using the value for this identifer; all identifiers are given numbers
    // that allow use to determine the order they appear in.
    //
    result.displayOrder = tokens[1].integerValue;

    // This is a math app.
    //
    result.topic = CLSContextTopicMath;

    // A little trace so we can see what is happeningg.
    //
    NSLog(@"createContextForIdentifier:%@ produces: %@", identifier, result);

    return result;
}

/**
 * This should be called when the app receives a call to:
 *
 * - (BOOL) application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler;
 *
 * on the AppDelegate class.  This method should pull apart the received identifier, validate it, and extract the properties it
 * conveys so that the activity can start with the appropriate parameters set.
 *
 * @param identifier A ClassKit context path, as received by the application.
 * @return YES if the identifier is deemed valid, and NO if not (which should in theory, never happen).
 */
- (BOOL) appDidReceiveIdentifier:(NSArray<NSString*>*)identifier {
    
    // Save the identifier so that we can use it later, but remember that the first
    // element is the app bundle ID, so ignore it.
    //
    self.currentActivityIdentifier = [NSArray arrayWithArray:[identifier subarrayWithRange:NSMakeRange(1, identifier.count-1)]];

    // Let us know what SchoolWork sent us.
    //
    NSLog(@"Received activity: %@", [self buildTitleForPath:self.currentActivityIdentifier]);

    // Now break the identifier down into it's parts to work out what activity has been requested.
    //
    @try {
        NSArray<NSString*> *tokens = [self.currentActivityIdentifier[0] componentsSeparatedByString:@"-"];
        self.skillLevel = tokens[1].integerValue;

        tokens = [self.currentActivityIdentifier[1] componentsSeparatedByString:@"-"];
        self.skillNumberMaximum = tokens[1].integerValue;

        tokens = [self.currentActivityIdentifier[2] componentsSeparatedByString:@"-"];
        self.puzzleCount = tokens[1].integerValue;

        tokens = [self.currentActivityIdentifier[3] componentsSeparatedByString:@"-"];

        self.skills = tokens[1].integerValue;

        // Trace what we got from the identifier.
        //
        NSLog(@"skillLevel: %lu, maximum:%lu, puzzles:%lu, skillMask: %02lx", self.skillLevel, self.skillNumberMaximum, (unsigned long)self.puzzleCount,
              (unsigned long)self.skills);

    } @catch (NSException *ex) {
        NSLog(@"Exception thrown parsing identifier: %@", ex);

        [self clearActivity];
    }

    return self.schoolWorkActivityPresent;
}

/**
 * @return YES if a SchoolWork initiated activity has been received by the application.
 */
- (BOOL) schoolWorkActivityPresent {
    return self.currentActivityIdentifier != nil;
}

/**
 * When your application is triggering the start of an activity, call this, providing the number of questions,
 * puzzles, etc that make up the activity.  This is used to track and report progress to ClassKit.  For each
 * "question", LessonDatabase records a start and finish so that the progress reported is more indicative of
 * where the student is actually up to.  It also gives (I think) a finer grained representation of progress.
 *
 * @param numberOfQuestions an integer containing the number of questions in the activity.
 */
- (void) startActivityWith:(NSUInteger)numberOfQuestions {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    // Make the context active.
                    //
                    [context becomeActive];

                    // Now record privately, the number of questions, and initialise the progress indicator.
                    //
                    self.numberOfQuestions = numberOfQuestions;
                    self.progressTarget = numberOfQuestions * 2; // * 2 to give question start, question end resolution to progress.
                    self.currentProgress = 0;

                    NSLog(@"startActivityWith:%ld questions, progressTarget: %ld", (long)self.numberOfQuestions, (long)self.progressTarget);

                    // Create the activity based on the context.
                    //
                    CLSActivity *newActivity = [context createNewActivity];

                    // Start it.
                    //
                    [newActivity start];

                    // And save it.  I do this via dispatch so that UI is not blocked.
                    //
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       [[CLSDataStore shared] saveWithCompletion:^(NSError * _Nullable error) {
                                           if (error != nil) {
                                               // You may want to do more than this.
                                               //
                                               NSLog(@"startActivityWith: Unable to save: %@", error);
                                           }
                                       }];
                                   });
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"startActivityWith: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * Pauses the current activity.  Call this when your app is backgrounded, but probably only necessary if you are going to
 * support the ability to resume an incomplete activity when launched from the SchoolWork app.  Not all apps are going to cope
 * with this idea.
 */
- (void) pauseActivity {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // If the activity exists, then stop it.
                    //
                    if (activity != nil) {
                        [activity stop];

                        // And save it.
                        //
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           [[CLSDataStore shared] saveWithCompletion:^(NSError * _Nullable error) {
                                               if (error != nil) {
                                                   // You may want to do more than this.
                                                   //
                                                   NSLog(@"pauseActivity: Unable to save: %@", error);
                                               }
                                           }];
                                       });
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"pauseActivity: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * Saves the current state of the activity, effectively pushing the state to be reported to the SchoolWork app.  I found
 * this to be necessary, especially when the app is sent to background for any reason.  Otherwise progress might not be
 * reported properly.
 */
- (void) saveActivityState {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // If the activity exists then save it.
                    //
                    if (activity != nil) {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           [[CLSDataStore shared] saveWithCompletion:^(NSError * _Nullable error) {
                                               if (error != nil) {
                                                   // You may want to do more than this.
                                                   //
                                                   NSLog(@"saveActivityState: Unable to save: %@", error);
                                               }
                                           }];
                                       });
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"saveActivityState: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * When you want to resume an activity without creatinng it anew, call this.  This would happen when your app
 * re-enters the active state after previously being backgrounded.
 */
- (void) resumeActivity {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // if the activity exists, start it, and save it.
                    //
                    if (activity != nil) {
                        [activity start];

                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           [[CLSDataStore shared] saveWithCompletion:^(NSError * _Nullable error) {
                                               if (error != nil) {
                                                   // You may want to do more than this.
                                                   //
                                                   NSLog(@"resumeActivity: Unable to save: %@", error);
                                               }
                                           }];
                                       });
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"resumeActivity: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * When you want to add, as part of the activity report, a quantity of some sort (a score, statistics from the activity,
 * etc), you can call this convenience message.
 *
 * @param titleStr The non-localised title of the item to be reported.  This is localised before being given to the CLSQuantityItem
 * @param quantity A value for the item.  Even though it's a double, ClassKit never seems to display it as such.
 * @param activity The CLSActivity object to which the item will be added.
 */
- (void) addQuantityItem:(NSString*)titleStr quantity:(double)quantity toActivity:(CLSActivity*)activity  API_AVAILABLE(ios(11.3)){
    if (@available(iOS 11.3, *)) {
        // Get the localised title.
        //
        NSString *title = NSLocalizedString(titleStr, @"");

        // Create the item.
        //
        CLSQuantityItem *item = [[CLSQuantityItem alloc] initWithIdentifier:titleStr title:title];

        // And set the actual value (why isn't there a constructor with this?)
        //
        item.quantity = quantity;

        // Add the item to the activity.
        //
        [activity addAdditionalActivityItem:item];

        // because I like to.
        //
        NSLog(@"addItem: %@", item);
    }
}

/**
 * This should be called when the student finishes the activty, regardless of whether they actually completed the work
 * or they just quit.  The progress will be reported appropriately, along with any statistics about the activity that
 * come from the app itself.  This is where LessonDatabase get's to know a bit more about the app it has been integrated
 * with.
 *
 * Rather than try to abstract away the enclosing app, I decided it was far simpler, to customise this method for each
 * app in the same way I customised the code that builds the activity tree.  ClassKit already provides a layer of abstraction
 * for the activity and I didn't see the point of adding another layer.
 *
 * @param forGame is the app-specific game, activity, lesson, etc object that is the internal representation of the activity.
 * This is used to obtain information about how the student performed, so that this information can be shared with the teacher
 * via ClassKit.
 */
- (void) endActivity:(PlayerGame*)forGame {
    // Only do something if there is an activity present, and we actually have a game object to report on.
    //
    if ((self.currentActivityIdentifier != nil) && (forGame != nil)) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // If there is an activity, create the report.
                    //
                    if (activity != nil) {
                        if (forGame != nil) {
                            // The game considers itself to be over, then ensure that the progress is set to 100%
                            //
                            if (forGame.gameOver == YES) {
                                [activity addProgressRangeFromStart:0.0 toEnd:1.0];
                            }

                            // Count the number of questions that the student got correct.
                            //
                            NSUInteger questionsCorrect = [forGame numberCorrect];

                            // Report the score.  This is something I really don't like in ClassKit, the assumption that every activity has
                            // a maximum score which is ridiculous.  If the app is simply a math game with an indeterminate number of questions
                            // (maybe it's time limited), then the max-score will not be fixed, and there's no way to report it as a score without
                            // having the word "Count" present.
                            //
                            NSString *scoreTitle = NSLocalizedString(@"classKitScoreTitle", @"");
                            CLSScoreItem *score = [[CLSScoreItem alloc] initWithIdentifier:@"score" title:scoreTitle score:questionsCorrect maxScore:forGame.questions.count];

                            activity.primaryActivityItem = score;

                            NSLog(@"endActivity: %@, score: %@", activity, score);

                            // Add some quantity items to show some more statistics to the teacher.
                            //
                            [self addQuantityItem:@"classKitQuestionsCorrectCountTitle" quantity:questionsCorrect toActivity:activity];

                            [self addQuantityItem:@"classKitQuestionsCountTitle" quantity:forGame.questions.count toActivity:activity];

                            // This is a double that the SchoolWork app rounds to the nearest integer.  Bug filed.
                            //
                            [self addQuantityItem:@"classKitAverageTimeToAnswerTitle" quantity:forGame.averageTimeToAnswer toActivity:activity];

                            [self addQuantityItem:@"classKitQuestionCountTitle" quantity:forGame.questions.count toActivity:activity];
                        }

                        // Now that we've added our report, stop the activity.
                        //
                        [activity stop];

                        // And resign from being active.
                        //
                        [context resignActive];

                        // Clear the local indicator that we have an activity to present to the student (so that
                        // the student isn't asked to do it again).
                        //
                        [self clearActivity];

                        // Save the activity state, updating the SchoolWork app with the final results.
                        //
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           [[CLSDataStore shared] saveWithCompletion:^(NSError * _Nullable error) {
                                               if (error != nil) {
                                                   // You may want to do more than this.
                                                   //
                                                   NSLog(@"endActivity: Unable to save: %@", error);
                                               }
                                           }];
                                       });
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"endActivity: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * Clears the current (if any) activity.
 */
- (void) clearActivity {
    self.currentActivityIdentifier = nil;
}

/**
 * Call this when the student is presented with a new question.
 */
- (void) startQuestion {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // If the activity is there, then increment the progress indicator, and update the activity.  We don't save the
                    // context here; it doesn't seem to be necessary, so long as you remember to save when the app is backgrounded.
                    //
                    if (activity != nil) {
                        self.currentProgress++;
                        double progress = (double)self.currentProgress / (double)self.progressTarget;
                        [activity addProgressRangeFromStart:0.0 toEnd:progress];

                        NSLog(@"startQuestion: %@, currentProgress: %ld, progressTarget: %ld", activity, (long)self.currentProgress, (long)self.progressTarget);
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"startQuestion: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

/**
 * Call this when a question has been answered.  This is technically identical to starting a question however it
 * has been implemented seperately to allow customisation on a per-app basis.
 */
- (void) questionAnswered {
    // Only do something if there is an activity present.
    //
    if (self.currentActivityIdentifier != nil) {
        if (@available(iOS 11.3, *)) {
            // Find the appropriate context.
            //
            [[CLSDataStore shared].mainAppContext descendantMatchingIdentifierPath:self.currentActivityIdentifier completion:^(CLSContext * _Nullable context, NSError * _Nullable error) {
                if ((error == nil) && (context != nil)) {
                    CLSActivity *activity = context.currentActivity;

                    // If the activity is there, then increment the progress indicator, and update the activity.  We don't save the
                    // context here; it doesn't seem to be necessary, so long as you remember to save when the app is backgrounded.
                    //
                    if (activity != nil) {
                        self.currentProgress++;
                        double progress = (double)self.currentProgress / (double)self.progressTarget;
                        [activity addProgressRangeFromStart:0.0 toEnd:progress];

                        NSLog(@"questionAnswered: %@, currentProgress: %ld, progressTarget: %ld", activity, (long)self.currentProgress, (long)self.progressTarget);
                    }
                } else {
                    // No context found which shouldn't happen.  Clear the activity.
                    //
                    NSLog(@"questionAnswered: unable to find context: %@", error);

                    [self clearActivity];
                }
            }];
        } else {
            // This shouldn't be possible, but lets be safe.
            //
            [self clearActivity];
        }
    }
}

@end
