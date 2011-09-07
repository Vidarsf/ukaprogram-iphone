//
//  EventDetailsViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventDetailsViewController : UIViewController {
    IBOutlet UILabel *headerLabel;
    IBOutlet UILabel *footerLabel;
    IBOutlet UILabel *leadLabel;
    IBOutlet UILabel *textLabel;
    IBOutlet UILabel *notInUseLabel;
    IBOutlet UIImageView *eventImgView;
    IBOutlet UIScrollView *sView;
    UIActivityIndicatorView *loadSpinner;
    Event * event;
    UIButton *favButton;
}
@property (retain) IBOutlet UILabel *headerLabel;
@property (retain) IBOutlet UILabel *footerLabel;
@property (retain) IBOutlet UILabel *leadLabel;
@property (retain) IBOutlet UILabel *textLabel;
@property (retain) IBOutlet UIScrollView *sView;
@property (retain) Event *event;
@property (retain) IBOutlet UIImageView *eventImgView;
@property (retain) IBOutlet UILabel *notInUseLabel;
@property (retain) UIActivityIndicatorView *loadSpinner;

@end

