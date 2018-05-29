//
//  Question.h
//
//  Created by Peter Easdown on 29/05/2018
//

#import <Foundation/Foundation.h>

/**
 *  This protocol represents a single question, to be asked of a single player.  A question will be
 *  for a specific skill (mapped 1 to 1 with QuestionType).  Implementors of this protocol will provide
 *  any extra functionality to represent specific question types.
 *
 *  Regardless of the type of question, the answer will always be an integer, it being either the 
 *  answer to a mathematical problem, or the number of a choice in a multiple choice question.
 */
@interface Question : NSObject

/**
 *  YES if the question has been answered.
 */
@property BOOL answered;

/**
 *  YES if the answer provided was correct.
 */
@property BOOL correct;

/**
 *  The amount of time taken to answer the question correctly.  If the question was not answered correctly,
 *  then this property will be 0.0;
 */
@property NSTimeInterval timeTaken;

/**
 *  Call this to mark the time at which a question is presented to the player.  This time
 *  will be used to track the time taken to answer the question correctly.
 */
- (void) questionStarted;

/**
 *  Call this to submit an answer to the question.
 */
- (void) submitAnswer:(BOOL)whichIsCorrect;

@end
