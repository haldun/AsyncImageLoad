//
//  UIImageView+MNDAsyncLoad.h
//  AsyncImageLoad
//
//  Created by Haldun Bayhantopcu on 01/12/13.
//  Copyright (c) 2013 monoid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MNDAsyncLoad)

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,
                                      NSError *error))failure;

- (void)cancelImageLoad;

@end
