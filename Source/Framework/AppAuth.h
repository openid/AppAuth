/*! @file AppAuth.h
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2015 Google Inc. All Rights Reserved.
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

#import <Foundation/Foundation.h>

//! Project version number for AppAuthFramework-iOS.
FOUNDATION_EXPORT double AppAuthVersionNumber;

//! Project version string for AppAuthFramework-iOS.
FOUNDATION_EXPORT const unsigned char AppAuthVersionString[];

#import <AppAuth/OIDAuthState.h>
#import <AppAuth/OIDAuthStateChangeDelegate.h>
#import <AppAuth/OIDAuthStateErrorDelegate.h>
#import <AppAuth/OIDAuthorizationRequest.h>
#import <AppAuth/OIDAuthorizationResponse.h>
#import <AppAuth/OIDAuthorizationService.h>
#import <AppAuth/OIDAuthorizationUICoordinator.h>
#import <AppAuth/OIDError.h>
#import <AppAuth/OIDErrorUtilities.h>
#import <AppAuth/OIDGrantTypes.h>
#import <AppAuth/OIDRegistrationRequest.h>
#import <AppAuth/OIDRegistrationResponse.h>
#import <AppAuth/OIDResponseTypes.h>
#import <AppAuth/OIDScopes.h>
#import <AppAuth/OIDScopeUtilities.h>
#import <AppAuth/OIDServiceConfiguration.h>
#import <AppAuth/OIDServiceDiscovery.h>
#import <AppAuth/OIDTokenRequest.h>
#import <AppAuth/OIDTokenResponse.h>
#import <AppAuth/OIDTokenUtilities.h>

#if TARGET_OS_TV
#elif TARGET_OS_WATCH
#elif TARGET_OS_IOS
#import <AppAuth/OIDAuthState+IOS.h>
#import <AppAuth/OIDAuthorizationService+IOS.h>
#import <AppAuth/OIDAuthorizationUICoordinatorIOS.h>
#elif TARGET_OS_MAC
#import <AppAuth/OIDAuthState+Mac.h>
#import <AppAuth/OIDAuthorizationService+Mac.h>
#import <AppAuth/OIDAuthorizationUICoordinatorMac.h>
#import <AppAuth/OIDRedirectHTTPHandler.h>
#else
#error "Platform Undefined"
#endif

/*! @mainpage AppAuth for iOS and macOS

 @section introduction Introduction

 AppAuth for iOS and macOS is a client SDK for communicating with [OAuth 2.0]
 (https://tools.ietf.org/html/rfc6749) and [OpenID Connect]
 (http://openid.net/specs/openid-connect-core-1_0.html) providers. It strives to
 directly map the requests and responses of those specifications, while following
 the idiomatic style of the implementation language. In addition to mapping the
 raw protocol flows, convenience methods are available to assist with common
 tasks like performing an action with fresh tokens.

 It follows the best practices set out in [OAuth 2.0 for Native Apps]
 (https://tools.ietf.org/html/draft-ietf-oauth-native-apps)
 including using `SFSafariViewController` for the auth request. For this reason,
 `UIWebView` is explicitly *not* supported due to usability and security reasons.

 It also supports the [PKCE](https://tools.ietf.org/html/rfc7636) extension to
 OAuth which was created to secure authorization codes in public clients when
 custom URI scheme redirects are used. The library is friendly to other
 extensions (standard or otherwise) with the ability to handle additional params
 in all protocol requests and responses.

 <b>Homepage</b>: http://openid.github.io/AppAuth-iOS/ <br>
 <b>API Documentation</b>: http://openid.github.io/AppAuth-iOS/docs/latest <br>
 <b>Git Repository</b>: https://github.com/openid/AppAuth-iOS <br>

 */
