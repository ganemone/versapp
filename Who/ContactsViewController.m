//
//  ContactsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddressBook/AddressBook.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface ContactsViewController()
@property (strong, nonatomic) ConnectionProvider* cp;
@end

@implementation ContactsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self accessContacts];
}

-(void) accessContacts {
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    //failure((__bridge NSError *)error);
                } else {
                    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    for (id person in people) {
                        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonLastNameProperty);
                        
                        NSMutableArray *phoneBufferArray = [[NSMutableArray alloc] init],
                        *emailBufferArray = [[NSMutableArray alloc] init];
                        
                        // Get all phone numbers of a contact
                        ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty),
                        emailList = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonEmailProperty);
                        
                        NSInteger emailCount = ABMultiValueGetCount(emailList);
                        for (int i = 0; i < emailCount; i++) {
                            [emailBufferArray addObject:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailList, i)];
                        }
                        
                        NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                        NSError *regerr = NULL;
                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&regerr];
                        NSString *phone;
                        for (int i = 0; i < phoneNumberCount; i++) {
                            phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                            phone = [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
                            [phoneBufferArray addObject:phone];
                        }
                        NSLog(@"First Name: %@", firstName);
                        NSLog(@"Last Name: %@", lastName);
                        for (int i = 0; i < phoneBufferArray.count; i++) {
                            NSLog(@"Phone Number: %@", phoneBufferArray[i]);
                        }
                        for (int i = 0; i < emailBufferArray.count; i++) {
                            NSLog(@"Email: %@", emailBufferArray[i]);
                        }
                    }
                }
                CFRelease(addressBook);
            });
        });
    }
}

@end
