//
//  TodayViewController.m
//  Example-iOS_ObjC_Extension
//
//  Created by Julien Bodet on 2018-03-09.
//  Copyright © 2018 William Denniss. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <AppAuthCore.h>

/*! @brief NSCoding key for the authState property.
 */
static NSString *const kAppAuthExampleAuthStateKey = @"authState";

@interface TodayViewController () <NCWidgetProviding, OIDAuthStateChangeDelegate>
    /*! @brief The authorization state. This is the AppAuth object that you should keep around and
     serialize to disk.
     */
    @property(nonatomic, readonly, nullable) OIDAuthState *authState;
    
    @property (weak, nonatomic) IBOutlet UITextView *logTextView;
    
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.extensionContext respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) { // iOS 10+
        [self.extensionContext setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
    } else {
        self.preferredContentSize = CGSizeMake(0, 600.0); // iOS 10-
    }
    
    [self loadState];
}
    
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
    
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode
                         withMaximumSize:(CGSize)maxSize {
    
    if (activeDisplayMode == NCWidgetDisplayModeExpanded) {
        self.preferredContentSize = CGSizeMake(maxSize.width, 600.0);
    } else if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = maxSize;
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}
    
/*! @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
*/
- (void)loadState {
    // loads OIDAuthState from NSUSerDefaults
    NSData *archivedAuthState =
    [[NSUserDefaults standardUserDefaults] objectForKey:kAppAuthExampleAuthStateKey];
    OIDAuthState *authState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAuthState];
    [self setAuthState:authState];
}
    
/*! @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
*/
- (void)saveState {
    // for production usage consider using the OS Keychain instead
    NSData *archivedAuthState = [ NSKeyedArchiver archivedDataWithRootObject:_authState];
    [[NSUserDefaults standardUserDefaults] setObject:archivedAuthState
                                              forKey:kAppAuthExampleAuthStateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
    
- (void)setAuthState:(nullable OIDAuthState *)authState {
    if (_authState == authState) {
        return;
    }
    _authState = authState;
    _authState.stateChangeDelegate = self;
    [self stateChanged];
}
    
- (void)stateChanged {
    [self saveState];
}
    
- (void)didChangeState:(OIDAuthState *)state {
    [self stateChanged];
}
    
- (IBAction)getUserInfo:(UIButton *)sender {
    NSURL *userinfoEndpoint =
    _authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
    if (!userinfoEndpoint) {
        [self logMessage:@"Userinfo endpoint not declared in discovery document"];
        return;
    }
    NSString *currentAccessToken = _authState.lastTokenResponse.accessToken;
    
    [self logMessage:@"Performing userinfo request"];
    
    [_authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
                                               NSString *_Nonnull idToken,
                                               NSError *_Nullable error) {
        if (error) {
            [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
            return;
        }
        
        // log whether a token refresh occurred
        if (![currentAccessToken isEqual:accessToken]) {
            [self logMessage:@"Access token was refreshed automatically (%@ to %@)",
             currentAccessToken,
             accessToken];
        } else {
            [self logMessage:@"Access token was fresh and not updated [%@]", accessToken];
        }
        
        // creates request to the userinfo endpoint, with access token in the Authorization header
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
        [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:nil
                                                         delegateQueue:nil];
        
        // performs HTTP request
        NSURLSessionDataTask *postDataTask =
        [session dataTaskWithRequest:request
                   completionHandler:^(NSData *_Nullable data,
                                       NSURLResponse *_Nullable response,
                                       NSError *_Nullable error) {
                       dispatch_async(dispatch_get_main_queue(), ^() {
                           if (error) {
                               [self logMessage:@"HTTP request failed %@", error];
                               return;
                           }
                           if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                               [self logMessage:@"Non-HTTP response"];
                               return;
                           }
                           
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           id jsonDictionaryOrArray =
                           [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                           
                           if (httpResponse.statusCode != 200) {
                               // server replied with an error
                               NSString *responseText = [[NSString alloc] initWithData:data
                                                                              encoding:NSUTF8StringEncoding];
                               if (httpResponse.statusCode == 401) {
                                   // "401 Unauthorized" generally indicates there is an issue with the authorization
                                   // grant. Puts OIDAuthState into an error state.
                                   NSError *oauthError =
                                   [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
                                                                                 errorResponse:jsonDictionaryOrArray
                                                                               underlyingError:error];
                                   [_authState updateWithAuthorizationError:oauthError];
                                   // log error
                                   [self logMessage:@"Authorization Error (%@). Response: %@", oauthError, responseText];
                               } else {
                                   [self logMessage:@"HTTP: %d. Response: %@",
                                    (int)httpResponse.statusCode,
                                    responseText];
                               }
                               return;
                           }
                           
                           // success response
                           [self logMessage:@"Success: %@", jsonDictionaryOrArray];
                       });
                   }];
        
        [postDataTask resume];
    }];
}
    
/*! @brief Logs a message to stdout and the textfield.
@param format The format string and arguments.
*/
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    // gets message as string
    va_list argp;
    va_start(argp, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);
    
    // outputs to stdout
    NSLog(@"%@", log);
    
    // appends to output log
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
                         _logTextView.text,
                         ([_logTextView.text length] > 0) ? @"\n" : @"",
                         dateString,
                         log];
}
- (IBAction)clearLogTextView:(UIButton *)sender {
    _logTextView.text = @"";
}
    
@end
