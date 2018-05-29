//
//  Question.m
//
//  Created by Peter Easdown on 29/05/2018
//

#import "Question.h"

@implementation Question {
    
    NSTimeInterval startTime;
    
}

#pragma mark - Initializers

/**
 *  Initialises the object from the provided dictionary.
 */
- (id) init {
    self = [super init];
    
    if (self != nil) {
        self.answered = NO;
        self.correct = NO;
        self.timeTaken = 0.0;
        
        startTime = [NSDate timeIntervalSinceReferenceDate];
    }
    
    return self;
}

/**
 *  Call this to mark the time at which a question is presented to the player.  This time
 *  will be used to track the time taken to answer the question correctly.
 */
- (void) questionStarted {
    startTime = [NSDate timeIntervalSinceReferenceDate];
}

/**
 *  Call this to submit an answer to the question.
 */
- (void) submitAnswer:(BOOL)whichIsCorrect {
    self.answered = YES;
    self.correct = whichIsCorrect;
    self.timeTaken = [NSDate timeIntervalSinceReferenceDate] - startTime;
}

@end
