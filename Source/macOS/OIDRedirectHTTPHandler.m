/*! @file OIDAuthorizationFlowSession.m
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
#import "OIDLoopbackHTTPServer.h"

@implementation OIDRedirectHTTPHandler {
  HTTPServer *httpServ;
  NSURL *successURL;
}

- (nullable instancetype)init {
  return [self initWithSuccessURL:nil];
}

- (nullable instancetype)initWithSuccessURL:(NSURL *)successURL_ {
  self = [super init];
  if (self) {
    successURL = successURL_;
  }
  return self;
}

- (NSURL*)startHTTPListener:(NSError **)returnError {
  // Starts a HTTP server on the loopback interface.
  // By not specifying a port, a random available one will be assigned.
  httpServ = [[HTTPServer alloc] init];
  [httpServ setDelegate:self];
  NSError *error = nil;
  if (![httpServ start:&error]) {
    if (returnError) {
      *returnError = error;
    }
    return nil;
  } else {
    NSString *serverURL = [NSString stringWithFormat:@"http://127.0.0.1:%d/", [httpServ port]];
    return [NSURL URLWithString:serverURL];
  }
}

- (void)stopHTTPListener {
  httpServ.delegate = nil;
  [httpServ stop];
  httpServ = nil;
}

- (void)HTTPConnection:(HTTPConnection *)conn didReceiveRequest:(HTTPServerRequest *)mess {
  // Sends URL to AppAuth.
  CFURLRef url = CFHTTPMessageCopyRequestURL(mess.request);
  BOOL success = [_currentAuthorizationFlow resumeAuthorizationFlowWithURL:(__bridge NSURL *)url];

  // Responds to browser request.
  NSString *bodyText;
  NSInteger httpResponseCode;
  if (success) {
    bodyText = @"<html><body>Return to the app.</body></html>";
    httpResponseCode = (successURL) ? 302 : 200;
  } else {
    bodyText = @"<html><body>Error.</body></html>";
    httpResponseCode = 400;
  }
  NSData *data = [bodyText dataUsingEncoding:NSUTF8StringEncoding];

  CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
                                                          httpResponseCode,
                                                          NULL,
                                                          kCFHTTPVersion1_1);
  if (success && successURL) {
    CFHTTPMessageSetHeaderFieldValue(response,
                                     (__bridge CFStringRef)@"Location",
                                     (__bridge CFStringRef)[successURL absoluteString]);
  }
  CFHTTPMessageSetHeaderFieldValue(response,
                                   (__bridge CFStringRef)@"Content-Length",
                                   (__bridge CFStringRef)[NSString stringWithFormat:@"%d",
                                   [data length]]);
  CFHTTPMessageSetBody(response, (__bridge CFDataRef)data);

  [mess setResponse:response];
  CFRelease(response);
}

- (void)dealloc {
  [self stopHTTPListener];
}

@end
