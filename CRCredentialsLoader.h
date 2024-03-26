#import <Foundation/Foundation.h>

typedef void (^CRCredentialsLoaderUpdateBlock)(NSString* currentStepDescription, bool isFinished);

@interface CRCredentialsLoader: NSObject
    + (void) runWithUpdateBlock:(CRCredentialsLoaderUpdateBlock)updateBlock;
@end