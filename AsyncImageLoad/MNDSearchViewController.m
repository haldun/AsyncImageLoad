//
//  MNDSearchViewController.m
//  AsyncImageLoad
//
//  Created by Haldun Bayhantopcu on 01/12/13.
//  Copyright (c) 2013 monoid. All rights reserved.
//

#import "MNDSearchViewController.h"
#import "UIImageView+MNDAsyncLoad.h"

@interface MNDSearchViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *results;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation MNDSearchViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)searchForTerm:(NSString *)term
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@", term]];
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                                        self.results = results[@"results"];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.tableView reloadData];
                                        });
                                      }];
  [task resume];
}

- (NSURLSession *)session
{
  if (!_session) {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config];
  }
  return _session;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  NSDictionary *track = self.results[indexPath.row];
  cell.textLabel.text = track[@"trackName"];
  NSURL *imageURL = [NSURL URLWithString:track[@"artworkUrl100"]];
  
  __weak typeof(cell) weakCell = cell;
  
  [cell.imageView setImageWithURL:imageURL placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakCell.imageView.image = image;
      [weakCell setNeedsLayout];
    });
  }];
  return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [cell.imageView cancelImageLoad];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  NSString *term = searchBar.text;
  [self searchForTerm:term];
  [searchBar resignFirstResponder];
}

@end
