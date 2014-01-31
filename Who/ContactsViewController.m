//
//  ContactsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddressBook/AddressBook.h"

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
                    NSMutableArray *contacts = [[NSMutableArray alloc] init];
                    for (id person in people) {
                        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonLastNameProperty);
                        
                        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                        
                        // Get all phone numbers of a contact
                        ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty);
                        
                        // If the contact has multiple phone numbers, iterate on each of them
                        NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                        for (int i = 0; i < phoneNumberCount; i++) {
                            NSError *regerr = NULL;
                            NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&regerr];
                            phone = [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
                            [tempArray addObject:phone];
                        }
                        NSLog(@"First Name: %@", firstName);
                        NSLog(@"Last Name: %@", lastName);
                        for (int i = 0; i < tempArray.count; i++) {
                            NSLog(@"Phone Number: %@", tempArray[i]);
                        }
                    }
                }
                CFRelease(addressBook);
            });
        });
    }
}

@end
