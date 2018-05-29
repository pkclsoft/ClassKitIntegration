//
//  PlayerGame.h
//
//  Created by Peter Easdown on 29/05/2018
//

#import <Foundation/Foundation.h>
#import "Question.h"

/**
 *  This class represents a single game for a player.  This 'game' will basically be a record of
 *  the questions asked, the answers given, how fast the answers were given, etc.
 *
 *  The object can be used as the game progresses to steer the nature of future questions so that
 *  the player is given an opportunity to answer some questions more than once (especially if they
 *  make a mistake the first time), and so that if the player has more than one skill enabled
 *  in their profile, that all skills are covered as evenly as possible.  
 *
 *  Also, within a given skill, the object will try to give a spread of complexity so that questions
 *  vary from easy to hard depending on the profile settings.
 */
@interface PlayerGame : NSObject

/** CUT-DOWN OF THE CLASS FOR CLASSKIT DEMO PURPOSES */

/**
 * Constructs a player game with the specified number of questions.
 */
+ (PlayerGame*) playerGameWith:(NSUInteger)questionCount;

/**
 * Starts the next question.
 */
- (void) startNextQuestion;

/**
 * Answers the current question.
 */
- (void) answerQuestion:(BOOL)correctly;

/**
 * Returns YES if there are no questions remaining.
 */
- (BOOL) gameOver;

/**
 * Returns the number of correct answers.
 */
- (NSUInteger) numberCorrect;

/**
 *  Returns the percentage of correct answers.
 */
- (float) percentCorrect;

/**
 *  Returns the average amount of time to answer a question.
 */
- (float) averageTimeToAnswer;

/**
 *  The player's skills used in this game.  This can be one or all of the skills, so it is a mask of the skills in the
 *  GameSkill enum.
 */
@property (nonatomic, assign) NSUInteger skills;

/**
 *  The current score for the player in this game.
 */
@property NSUInteger score;

/**
 *  The questions that have been asked and answered in this game.
 */
@property NSMutableArray<Question*> *questions;
@property (assign, nonatomic) NSInteger currentQuestion;

@end
