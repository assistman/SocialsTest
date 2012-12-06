//
//  ViewController.m
//  SocialsTest
//
//  Created by Stas on 9/28/12.
//  Copyright (c) 2012 Videal. All rights reserved.
//
/*
 // Options dictionary keys for Facebook access
 ACCOUNTS_EXTERN NSString * const ACFacebookAppIdKey;            // Your Facebook App ID, as it appears on the Facebook website.
 ACCOUNTS_EXTERN NSString * const ACFacebookPermissionsKey;      // An array of of the permissions you're requesting. Optional.
 ACCOUNTS_EXTERN NSString * const ACFacebookAudienceKey;         // Only required when posting permissions are requested.
 
 // Options dictionary values for Facebook access
 ACCOUNTS_EXTERN NSString * const ACFacebookAudienceEveryone;    // Posts from your app are visible to everyone.
 ACCOUNTS_EXTERN NSString * const ACFacebookAudienceFriends;     // Posts are visible only to friends.
 ACCOUNTS_EXTERN NSString * const ACFacebookAudienceOnlyMe;
 */

#import "ViewController.h"

const NSString * FB_APP_ID = @"287334188047018";

@interface ViewController ()

@end

@implementation ViewController
@synthesize dataDict;
@synthesize isBasicPermissionsGranted;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Social Sharing";
    self.txtField.delegate = self;
    self.segmentedControl.momentary = NO;
    self.segmentedControl.selectedSegmentIndex = -1;
    self.imgView.image = [UIImage imageNamed:@"sofi.jpg"];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    if (self.accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray * accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
    NSLog(@"acc is: %@", accounts);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self accessBasicPermissions];

}

- (IBAction)controlChanged:(id)sender {
    UISegmentedControl * control = (UISegmentedControl *)sender;
     NSLog(@"index is: %d", control.selectedSegmentIndex);
}

- (void)accessBasicPermissions {
    if (self.accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //Although the ACAccountStore class states that the permissions parameter is optional YOU MUST PASS IT!
    //As Facebook tutorial states:
    //"You are now required to request read and publish permission separately (and in that order). Most likely, you will request the read permissions for personalization when the app starts and the user first logs in. Later, if appropriate, your app can request publish permissions when it intends to post data to Facebook."
    //Although there are many basic permissions YOU MUST PASS either `email` or "user_location", or "user_birthday" (in other cases it does not work!!)
    NSArray * permissions = @[@"email"];
    NSDictionary * dict = @{ACFacebookAppIdKey : FB_APP_ID, ACFacebookPermissionsKey : permissions, ACFacebookAudienceKey : ACFacebookAudienceEveryone};
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
        __block NSString * statusText = nil;
        if (granted) {
            statusText = @"Logged in";
            NSArray * accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
            self.facebookAccount = [accounts lastObject];
            NSLog(@"account is: %@", self.facebookAccount);
            self.isBasicPermissionsGranted = YES;
            self.statusLabel.text = statusText;
        }
        else {
            self.statusLabel.text = @"Login failed";
            self.isBasicPermissionsGranted = NO;
            NSLog(@"error is: %@", error);
        }
    }];
}

- (IBAction)directPostClick:(id)sender {
    self.statusLabel.text = @"Waiting for authorization...";
    if (self.accountStore == nil) {
        self.accountStore = [[ACAccountStore alloc] init];
    }   
    ACAccountType * facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //Now we can obtain some extra permissions
    NSArray * permissions = @[@"publish_stream"];
    //NSArray * permissions = @[@"user_about_me"];
    NSDictionary * dict = @{ACFacebookAppIdKey : FB_APP_ID, ACFacebookPermissionsKey : permissions, ACFacebookAudienceKey : ACFacebookAudienceEveryone};
    [self.accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
        __block NSString * statusText = nil;
        if (granted) {
            statusText = @"Logged in";
            NSArray * accounts = [self.accountStore accountsWithAccountType:facebookAccountType];
            self.facebookAccount = [accounts lastObject];
            NSLog(@"account is: %@", self.facebookAccount);
            self.statusLabel.text = statusText;
            [self postToFeed];
        }
        else {
            self.statusLabel.text = @"Login failed";
            NSLog(@"error is: %@", error);
        }
    }];
}

- (void)postToFeed {
    //POSTING Hello World message on wall
    NSDictionary * parameters = @{@"message" : @"Hello world!"};
    NSURL * feedUrl = [NSURL URLWithString:@"https://graph.facebook.com/oauth/access_token?client_id=287334188047018&client_secret=850f1d33e2529eb3e98e205ab91f2afb&grant_type=client_credentials"];
    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedUrl parameters:parameters];
    request.account = self.facebookAccount;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Posted!";
            NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"response is: %@", dataString);
        });
    }];
    
    //GET USER
//    NSURL * feedUrl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
//    SLRequest * request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:feedUrl parameters:nil];
//    request.account = self.facebookAccount;
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.statusLabel.text = @"User obtained!";
//            //CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)responseData, kCFPropertyListImmutable, NULL);
//            //self.dataDict = (__bridge NSDictionary *)plist;
//            NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//            NSArray *keys = [NSArray arrayWithObject:@"key"];
//            NSArray *objects = [NSArray arrayWithObject:dataString];
//            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//            
//            for (id key in dictionary) {
//                NSLog(@"key: %@, value: %@", key, [dictionary objectForKey:key]);
//            }
//            self.dataDict = dictionary;
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"Login" ofType:@"plist"];
//            [dictionary writeToFile:path  atomically:YES];
//            NSLog(@"self.dataDict is: %@", self.dataDict);
//            NSLog(@"data is: %@", responseData);
//        });
//    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && alertView.tag == 555) {
        NSArray * activityItems = @[self.imgView.image, self.txtField.text];
        /*This controller allows to select the resource you want to share with (Also you can choose such options:
        - print via air port printer
        - assign (an image for example) to contact
        - save to camera roll
        - Copy
         )*/
        UIActivityViewController * activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else if (buttonIndex == 1 && alertView.tag == 555) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Select the resource" message:@"You should select the appropriate resource above" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        alert.delegate = self;
        alertView.tag = 333;
        [alert show];
    }
}




- (BOOL)textFieldShouldReturn:(UITextField *)txtField {
    [txtField resignFirstResponder];
    if (self.segmentedControl.selectedSegmentIndex == -1) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sharing options" message:@"Do you want to open Sharing Options Screen or share on exact resource?" delegate:self cancelButtonTitle:@"Sharing screen" otherButtonTitles:@"Exact resource", nil];
        alert.delegate = self;
        alert.tag = 555;
        [alert show];
        return NO;
    }
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            //This controller allows to post directly to facebook
            slVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        }
    }
    else {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            //This controller allows to post directly to Twitter
            slVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        }
    }
    BOOL textSet = [slVC setInitialText:self.txtField.text];
    BOOL imageSet = [slVC addImage:self.imgView.image];
    if (imageSet && textSet) {
        [self presentViewController:slVC animated:YES completion:nil];
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
