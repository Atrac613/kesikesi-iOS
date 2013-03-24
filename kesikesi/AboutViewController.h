//
//  AboutViewController.h
//  kesikesi
//
//  Created by Osamu Noguchi on 3/24/13.
//  Copyright (c) 2013 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AboutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SKStoreProductViewControllerDelegate> {
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
