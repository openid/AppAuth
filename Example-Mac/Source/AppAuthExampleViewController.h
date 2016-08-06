/*! @file AppAuthExampleViewController.h
    @brief AppAuth macOS SDK Example
    @copyright
        Copyright 2016 Google Inc. All Rights Reserved.
    @copydetails
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */
#import <Cocoa/Cocoa.h>

@class AppDelegate;
@class OIDAuthState;
@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @class AppAuthExampleViewController
    @brief The example application's view controller.
 */
@interface AppAuthExampleViewController : NSViewController

@property(nullable) IBOutlet NSButton *authAutoButton;
@property(nullable) IBOutlet NSButton *authManual;
@property(nullable) IBOutlet NSButton *authAutoHTTPButton;
@property(nullable) IBOutlet NSButton *codeExchangeButton;
@property(nullable) IBOutlet NSButton *userinfoButton;
@property(nullable) IBOutlet NSButton *clearAuthStateButton;
@property(nullable) IBOutlet NSTextView *logTextView;

/*! @property appDelegate
    @brief The application delegate. This is used to store the current authorization flow.
 */
@property (nonatomic, weak, nullable) AppDelegate *appDelegate;

/*! @property authState
    @brief The authorization state. This is the AppAuth object that you should keep around and
        serialize to disk.
 */
@property(nonatomic, readonly, nullable) OIDAuthState *authState;

/*! @fn authWithAutoCodeExchange:
    @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
    @param sender IBAction sender.
 */
- (IBAction)authWithAutoCodeExchange:(nullable id)sender;

/*! @fn authNoCodeExchange:
    @brief Authorization code flow without a the code exchange (need to call @c codeExchange:
        manually)
    @param sender IBAction sender.
 */
- (IBAction)authNoCodeExchange:(nullable id)sender;

/*! @fn authWithAutoCodeExchange:
    @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
    @param sender IBAction sender.
 */
- (IBAction)authWithAutoCodeExchangeHTTP:(nullable id)sender;

/*! @fn codeExchange:
    @brief Performs the authorization code exchange at the token endpoint.
    @param sender IBAction sender.
 */
- (IBAction)codeExchange:(nullable id)sender;

/*! @fn userinfo:
    @brief Performs a Userinfo API call using @c OIDAuthState.withFreshTokensPerformAction.
    @param sender IBAction sender.
 */
- (IBAction)userinfo:(nullable id)sender;

/*! @fn clearAuthState:
    @brief Nils the @c OIDAuthState object.
    @param sender IBAction sender.
 */
- (IBAction)clearAuthState:(nullable id)sender;

/*! @fn clearLog:
    @brief Clears the UI log.
    @param sender IBAction sender.
 */
- (IBAction)clearLog:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
