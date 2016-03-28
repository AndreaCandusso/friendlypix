//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "SignInViewController.h"
@import FirebaseAuth;
@import FirebaseApp;
@import Firebase.Core;
@import Firebase.AdMob;

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation SignInViewController
- (IBAction)didTapSignUp:(id)sender {
  [[FIRAuth auth] createUserWithEmail:_emailField.text password:_passwordField.text callback:^(FIRUser * _Nullable user, NSError * _Nullable error) {
    if (error) {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    [self signedIn:user];
  }];
}

- (IBAction)didTapSignIn:(UIButton *)sender {
  //  FIRAuth *firebaseAuth = [FIRAuth auth];
  //  FIRAuthUI *firebaseAuthUI = [FIRAuthUI authUIForApp:firebaseAuth.app];
  //  [firebaseAuthUI presentSignInWithViewController:self callback:^(FIRUser *_Nullable user,
  //                                                                  NSError *_Nullable error) {
  [[FIRAuth auth] signInWithEmail:_emailField.text
                         password:_passwordField.text
                         callback:^(FIRUser *user, NSError *error) {
                           if (error) {
                             NSLog(@"%@", error.localizedDescription);
                             return;
                           }

                           [self signedIn:user];
                         }];
}

- (void)signedIn:(FIRUser *)user {
  FIRDatabaseReference *ref;
  ref = [FIRDatabase database].reference;
  FIRDatabaseReference *peopleRef = [ref childByAppendingPath: [NSString stringWithFormat:@"people/%@", user.uid]];
  [peopleRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *peopleSnapshot) {
    if (peopleSnapshot.exists) {
      [FPAppState sharedInstance].currentUser = [[FPUser alloc] initWithSnapshot:peopleSnapshot];
    } else {
      NSDictionary *person = @{
                               @"displayName" : user.displayName ? user.displayName : @"",
                               @"photoUrl" : user.photoURL ? [user.photoURL absoluteString] : @""
                               };
      
      [peopleRef setValue:person];
    }
  }];
  [self performSegueWithIdentifier:@"SignInToFP" sender:nil];
}


@end