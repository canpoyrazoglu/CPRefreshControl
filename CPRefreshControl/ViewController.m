//
//  ViewController.m
//  CPRefreshControl
//
//  Created by Can Poyrazoğlu on 24.08.2017.
//  Copyright © 2017 Can Poyrazoğlu. All rights reserved.
//

#import "ViewController.h"
#import "CPRefreshControl.h"

@interface ViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet CPRefreshControl *refreshControl;

@end

@implementation ViewController

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float offset = scrollView.contentOffset.y;
    NSLog(@"offset %f", offset);
    if(offset >= 0){
        self.refreshControl.value = 0;
    }else{
        self.refreshControl.value = -offset / 50;
    }
}

- (IBAction)didTapEndAnimatingButton:(id)sender {
    [self.refreshControl endAnimating];
}
@end
