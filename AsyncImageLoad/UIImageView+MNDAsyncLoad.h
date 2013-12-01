//
//  UIImageView+MNDAsyncLoad.h
//  AsyncImageLoad
//
//  Created by Haldun Bayhantopcu on 01/12/13.
//  Copyright (c) 2013 monoid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MNDAsyncLoad)

- (void)mnd_setImageWithURL:(NSURL *)url;
- (void)mnd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)mnd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response,
                                      NSError *error))failure;

- (void)mnd_cancelImageLoad;

@end
