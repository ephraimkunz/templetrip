//
//  ScheduleViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Temple.h"
@import EventKit;

@interface ScheduleViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@property(strong, nonatomic) Temple *currentTemple;
@property (strong, nonatomic) NSDictionary * scheduleDict;
@property(nonatomic) NSString *dayTapped;
@property(nonatomic) NSArray *sessionTimesForToday;

- (BOOL)isClosedDate:(NSDate *)aDate;
-(BOOL)dateIsToday:(NSDate*) date;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end
