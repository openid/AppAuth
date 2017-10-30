/*! @file OIDURLQueryComponent.h
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

@class OIDAuthorizationRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @brief If set to YES, will force the iOS 7-only code for @c OIDURLQueryComponent to be used,
        even on non-iOS 7 devices and simulators. Useful for testing the iOS 7 code paths on the
        simulator. Defaults to NO.
 */
extern BOOL gOIDURLQueryComponentForceIOS7Handling;

/*! @brief A utility class for creating and parsing URL query components.
 */
@interface OIDURLQueryComponent : NSObject {
  // private variables
  /*! @brief A dictionary of parameter names and values representing the contents of the query.
   */
  NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *_parameters;
}

/*! @brief The parameter names in the query.
 */
@property(nonatomic, readonly) NSArray<NSString *> *parameters;

/*! @brief The parameters represented as a dictionary.
    @remarks All values are @c NSString except for parameters which contain multiple values, in
        which case the value is an @c NSArray<NSString *> *.
 */
@property(nonatomic, readonly) NSDictionary<NSString *, NSObject<NSCopying> *> *dictionaryValue;

/*! @brief The value (or values) for a named parameter in the query.
    @param parameter The parameter name. Case sensitive.
    @return The value (or values) for a named parameter in the query.
 */
- (NSArray<NSString *> *)valuesForParameter:(NSString *)parameter;

/*! @brief Adds a parameter value to the query.
    @param parameter The name of the parameter. Case sensitive.
    @param value The value to add.
 */
- (void)addParameter:(NSString *)parameter value:(NSString *)value;

/*! @brief Adds multiple parameters with associated values to the query.
    @param parameters The parameter name value pairs to add to the query.
 */
- (void)addParameters:(NSDictionary<NSString *, NSString *> *)parameters;

/*! @param URL The URL to add the query component to.
    @return The original URL with the query component replaced by the parameters from this query.
 */
- (NSURL *)URLByReplacingQueryInURL:(NSURL *)URL;

/*! @brief Builds a query string that can be set to @c NSURLComponents.percentEncodedQuery
 @discussion This string is percent encoded, and shouldn't be used with
 @c NSURLComponents.query.
 @return An percentage encoded query string.
 */
- (NSString *)percentEncodedQueryString;


@end

NS_ASSUME_NONNULL_END
