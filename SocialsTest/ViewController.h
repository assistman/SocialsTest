//
//  ViewController.h
//  SocialsTest
//
//  Created by Stas on 9/28/12.
//  Copyright (c) 2012 Videal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    SLComposeViewController *slVC;
    
}

@property (strong, nonatomic) NSArray * array;
@property (unsafe_unretained, nonatomic) BOOL isBasicPermissionsGranted;
@property (strong, nonatomic) NSDictionary * dataDict;
@property (strong, nonatomic) ACAccount * facebookAccount;
@property (strong, nonatomic) ACAccountStore * accountStore;
@property (strong, nonatomic) IBOutlet UITextField *txtField;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)controlChanged:(id)sender;
- (IBAction)directPostClick:(id)sender;

@end
