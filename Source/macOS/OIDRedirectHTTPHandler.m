/*! @file OIDRedirectHTTPHandler.m
    @brief AppAuth iOS SDK
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

#import "OIDRedirectHTTPHandler.h"

#import "OIDAuthorizationService.h"
#import "OIDErrorUtilities.h"
#import "OIDLoopbackHTTPServer.h"

@implementation OIDRedirectHTTPHandler {
  HTTPServer *_httpServ;
  NSURL *_successURL;
}

- (instancetype)init {
  return [self initWithSuccessURL:nil];
}

- (instancetype)initWithSuccessURL:(nullable NSURL *)successURL {
  self = [super init];
  if (self) {
    _successURL = [successURL copy];
  }
  return self;
}

- (NSURL *)startHTTPListener:(NSError **)returnError {
  // Cancels any pending requests.
  [self cancelHTTPListener];

  // Starts a HTTP server on the loopback interface.
  // By not specifying a port, a random available one will be assigned.
  _httpServ = [[HTTPServer alloc] init];
  [_httpServ setDelegate:self];
  NSError *error = nil;
  if (![_httpServ start:&error]) {
    if (returnError) {
      *returnError = error;
    }
    return nil;
  } else {
    NSString *serverURL = [NSString stringWithFormat:@"http://127.0.0.1:%d/", [_httpServ port]];
    return [NSURL URLWithString:serverURL];
  }
}

- (void)cancelHTTPListener {
  [self stopHTTPListener];

  // Cancels the pending authorization flow (if any) with error.
  NSError *cancelledError =
      [OIDErrorUtilities errorWithCode:OIDErrorCodeProgramCanceledAuthorizationFlow
                       underlyingError:nil
                           description:@"The HTTP listener was cancelled programmatically."];
  [_currentAuthorizationFlow failAuthorizationFlowWithError:cancelledError];
  _currentAuthorizationFlow = nil;
}

- (void)stopHTTPListener {
  _httpServ.delegate = nil;
  [_httpServ stop];
  _httpServ = nil;
}

- (void)HTTPConnection:(HTTPConnection *)conn didReceiveRequest:(HTTPServerRequest *)mess {
  // Sends URL to AppAuth.
  CFURLRef url = CFHTTPMessageCopyRequestURL(mess.request);
  BOOL handled = [_currentAuthorizationFlow resumeAuthorizationFlowWithURL:(__bridge NSURL *)url];

  // Stops listening to further requests after the first valid authorization response.
  if (handled) {
    _currentAuthorizationFlow = nil;
    [self stopHTTPListener];
  }

  // Responds to browser request.
  NSString *bodyText;
  NSInteger httpResponseCode;
  if (handled) {
    bodyText = @"<html><body>Authorization complete.<br> Return to the app.</body></html>";
    httpResponseCode = (_successURL) ? 302 : 200;
  } else {
    bodyText = @"<html><body>Error.</body></html>";
    httpResponseCode = 400;
  }
  NSData *data = [bodyText dataUsingEncoding:NSUTF8StringEncoding];

  CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
                                                          httpResponseCode,
                                                          NULL,
                                                          kCFHTTPVersion1_1);
  if (handled && _successURL) {
    CFHTTPMessageSetHeaderFieldValue(response,
                                     (__bridge CFStringRef)@"Location",
                                     (__bridge CFStringRef)_successURL.absoluteString);
  }
  CFHTTPMessageSetHeaderFieldValue(response,
                                   (__bridge CFStringRef)@"Content-Length",
                                   (__bridge CFStringRef)[NSString stringWithFormat:@"%lu",
                                       (unsigned long)data.length]);
  CFHTTPMessageSetBody(response, (__bridge CFDataRef)data);

  [mess setResponse:response];
  CFRelease(response);
}

- (void)dealloc {
  [self stopHTTPListener];
}

@end
