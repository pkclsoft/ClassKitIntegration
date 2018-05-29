//
//  LessonDatabase.h
//
//  Created by Peter Easdown on 29/05/2018
//

#import <Foundation/Foundation.h>

@class PlayerGame;

@interface LessonDatabase : NSObject

/*
 "skillLevel-0.skillMaximum-000.puzzleCount-1.skill-1"
 */

/**
 * This notification name is used to post a notification when the App Delegate receives a call to:
 *
 * - (BOOL) application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler;
 *
 * I observe this in the main view of my apps so because this call usually comes at some indeterminate time after the call to:
 *
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
 *
 * This way, your main app view can launch the activity only once it has enough information to define it.  I don't post this from within LessonDatabase
 * so that the app can handle it in it's own time.
 *
 */
#define SCHOOLWORK_ACTIVITY_LAUNCHED @"schoolWorkActivityLaunched"

@property (nonatomic, assign) NSUInteger skillLevel;
@property (nonatomic, assign) NSUInteger skillNumberMaximum;
@property (nonatomic, assign) NSUInteger puzzleCount;
@property (nonatomic, assign) NSUInteger skills;

/**
 * @return The shared instance of LessonDatabase.
 */
+ (LessonDatabase*) sharedInstance;

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
- (BOOL) appDidReceiveIdentifier:(NSArray<NSString*>*)identifier;

/**
 * @return YES if a SchoolWork initiated activity has been received by the application.
 */
- (BOOL) schoolWorkActivityPresent;

/**
 * When your application is triggering the start of an activity, call this, providing the number of questions,
 * puzzles, etc that make up the activity.  This is used to track and report progress to ClassKit.  For each
 * "question", LessonDatabase records a start and finish so that the progress reported is more indicative of
 * where the student is actually up to.  It also gives (I think) a finer grained representation of progress.
 *
 * @param numberOfQuestions an integer containing the number of questions in the activity.
 */
- (void) startActivityWith:(NSUInteger)numberOfQuestions;

/**
 * Saves the current state of the activity, effectively pushing the state to be reported to the SchoolWork app.  I found
 * this to be necessary, especially when the app is sent to background for any reason.  Otherwise progress might not be
 * reported properly.
 */
- (void) saveActivityState;

/**
 * Pauses the current activity.  Call this when your app is backgrounded, but probably only necessary if you are going to
 * support the ability to resume an incomplete activity when launched from the SchoolWork app.  Not all apps are going to cope
 * with this idea.
 */
- (void) pauseActivity;

/**
 * When you want to resume an activity without creatinng it anew, call this.  This would happen when your app
 * re-enters the active state after previously being backgrounded.
 */
- (void) resumeActivity;

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
- (void) endActivity:(PlayerGame*)forGame;

/**
 * Clears the current (if any) activity.
 */
- (void) clearActivity;

/**
 * Call this when the student is presented with a new question.
 */
- (void) startQuestion;

/**
 * Call this when a question has been answered.  This is technically identical to starting a question however it
 * has been implemented seperately to allow customisation on a per-app basis.
 */
- (void) questionAnswered;

@end
