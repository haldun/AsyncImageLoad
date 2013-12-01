//
//  UIImageView+MNDAsyncLoad.m
//  AsyncImageLoad
//
//  Created by Haldun Bayhantopcu on 01/12/13.
//  Copyright (c) 2013 monoid. All rights reserved.
//

#import "UIImageView+MNDAsyncLoad.h"
#import <objc/runtime.h>

static NSString * const MNDAsyncLoadErrorDomain = @"MNDAsyncLoadErrorDomain";

static char kMNDImageLoadTaskKey;

@interface UIImageView (_MNDAsyncLoad)

@property (strong, nonatomic, setter = mnd_setImageLoadTask:) NSURLSessionDataTask *mnd_imageLoadTask;

@end

@implementation UIImageView (_MNDAsyncLoad)

- (NSURLSessionDataTask *)mnd_imageLoadTask
{
  return (NSURLSessionDataTask *) objc_getAssociatedObject(self, &kMNDImageLoadTaskKey);
}

- (void)mnd_setImageLoadTask:(NSURLSessionDataTask *)imageLoadTask
{
  objc_setAssociatedObject(self, &kMNDImageLoadTaskKey, imageLoadTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIImageView (MNDAsyncLoad)

+ (NSURLSession *)mnd_sharedSession
{
  static NSURLSession *session = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    session = [NSURLSession sessionWithConfiguration:config];
  });
  return session;
}

- (void)mnd_setImageWithURL:(NSURL *)url
{
  [self mnd_setImageWithURL:url placeholderImage:nil];
}

- (void)mnd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
  [self mnd_setImageWithURL:url placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)mnd_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholderImage
                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,
                                      NSError *error))failure
{
  [self mnd_cancelImageLoad];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  
  self.image = placeholderImage;
  self.mnd_imageLoadTask =
    [[UIImageView mnd_sharedSession] dataTaskWithRequest:request
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                         
                                         if (error) {
                                           if (failure) {
                                             failure(request, httpResponse, error);
                                           }
                                           return;
                                         }
                                         
                                         if (httpResponse.statusCode != 200) {
                                           if (failure) {
                                             NSError *httpError = [NSError errorWithDomain:MNDAsyncLoadErrorDomain
                                                                                      code:httpResponse.statusCode
                                                                                  userInfo:nil];
                                             failure(request, httpResponse, httpError);
                                           }
                                           return;
                                         }
                                        
                                         UIImage *image = [UIImage imageWithData:data];
                                           if (success) {
                                             success(request, httpResponse, image);
                                           } else {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                               self.image = image;
                                             });
                                           }
                                       }];
  [self.mnd_imageLoadTask resume];
}

- (void)mnd_cancelImageLoad
{
  [self.mnd_imageLoadTask cancel];
  self.mnd_imageLoadTask = nil;
}

@end
