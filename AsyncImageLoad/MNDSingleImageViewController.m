
//
//  MNDSingleImageViewController.m
//  AsyncImageLoad
//
//  Created by Haldun Bayhantopcu on 03/12/13.
//  Copyright (c) 2013 monoid. All rights reserved.
//

#import "MNDSingleImageViewController.h"
#import "UIImageView+MNDAsyncLoad.h"

@interface MNDSingleImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation MNDSingleImageViewController

- (IBAction)loadImage:(id)sender
{
  NSString *imageURLString = @"http://images.apple.com/mac/home/images/feature_ilife_iwork_hero_2x.jpg";
  NSURL *imageURL = [NSURL URLWithString:imageURLString];
  [self.imageView setImageWithURL:imageURL];
}

- (void)loadImageManual
{
  NSString *imageURLString = @"http://images.apple.com/mac/home/images/feature_ilife_iwork_hero_2x.jpg";
  NSURL *imageURL = [NSURL URLWithString:imageURLString];
  NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"error: %@", error);
      return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if (httpResponse.statusCode != 200) {
      NSLog(@"expected 200 instead got: %ld", (long)httpResponse.statusCode);
      return;
    }
    
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageView.image = image;
    });
  }];
  [task resume];

}

@end
