#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, copy)   NSString  *name;
@property (nonatomic, copy)   NSString  *email;
- (instancetype)initWithID:(NSInteger)userID name:(NSString *)name email:(NSString *)email;
@end

@implementation User
- (instancetype)initWithID:(NSInteger)userID name:(NSString *)name email:(NSString *)email {
    if (self = [super init]) {
        _userID = userID;
        _name   = [name copy];
        _email  = [email copy];
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<User id=%ld name=%@>", (long)_userID, _name];
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        User *user = [[User alloc] initWithID:1 name:@"Alice" email:@"alice@example.com"];
        NSLog(@"%@", user);
    }
    return 0;
}
