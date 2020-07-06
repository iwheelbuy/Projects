#import "Classes+Safely.h"

@implementation Safely

+ (void) try: (__attribute__((noescape)) void(^ _Nullable)(void))try catch: (__attribute__((noescape)) void(^ _Nullable)(NSException *exception))catch finally: (__attribute__((noescape)) void(^ _Nullable)(void))finally {
    @try {
        if (try != NULL) try();
    }
    @catch (NSException *exception) {
        if (catch != NULL) catch(exception);
    }
    @finally {
        if (finally != NULL) finally();
    }
}

@end
