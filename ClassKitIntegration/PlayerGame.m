//
//  PlayerGame.m
//
//  Created by Peter Easdown on 29/05/2018
//

#import "PlayerGame.h"

@interface PlayerGame ()

@end


@implementation PlayerGame

- (id) initWith:(NSUInteger)questionCount {
    self = [super init];
    
    if (self != nil) {
        _questions = [NSMutableArray arrayWithCapacity:questionCount];
        _skills = 15;
        _score = 0;
        _currentQuestion = -1;

        // for the demo
        //
        for (NSUInteger i = 0; i < questionCount; i++) {
            [_questions addObject:[[Question alloc] init]];
        }

        [self startNextQuestion];
    }
    
    return self;
}

/**
 * Constructs a player game with the specified number of questions.
 */
+ (PlayerGame*) playerGameWith:(NSUInteger)questionCount {
    return [[PlayerGame alloc] initWith:questionCount];
}

/**
 *  Returns the percentage of correct answers.
 */
- (float) percentCorrect {
    float totalCorrect = (float)[self numberCorrect];

    return totalCorrect / (float)self.questions.count;

}

/**
 * Returns the number of correct answers.
 */
- (NSUInteger) numberCorrect {
    NSUInteger result = 0;

    for (Question *q in self.questions) {
        if ((q.answered == YES) && (q.correct == YES)) {
            result += 1;
        }
    }

    return result;
}

/**
 *  Returns the average amount of time to answer a question.
 */
- (float) averageTimeToAnswer {
    float totalCorrect = 0.0;
    NSTimeInterval totalTime = 0.0;

    for (Question *q in self.questions) {
        if ((q.answered == YES) && (q.correct == YES)) {
            totalCorrect += 1.0;
            totalTime += q.timeTaken;
        }
    }
    
    return totalTime / totalCorrect;
}

/**
 * Starts the next question.
 */
- (void) startNextQuestion {
    self.currentQuestion++;

    [[self.questions objectAtIndex:self.currentQuestion] questionStarted];
}

/**
 * Answers the current question.
 */
- (void) answerQuestion:(BOOL)correctly {
    [[self.questions objectAtIndex:self.currentQuestion] submitAnswer:correctly];
}

/**
 * Returns YES if there are no questions remaining.
 */
- (BOOL) gameOver {
    return [self.questions lastObject].answered;
}

@end
