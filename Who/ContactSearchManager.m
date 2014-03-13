//
//  ContactSearchManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactSearchManager.h"
#import "AddressBook/AddressBook.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "FriendsDBManager.h"
#import "FriendMO.h"

@interface ContactSearchManager()

@property (strong, nonatomic) NSMutableArray *contacts;

@end

static ContactSearchManager *selfInstance;

@implementation ContactSearchManager

+(instancetype)getInstance {
    @synchronized(self) {
        if (selfInstance == nil) {
            NSLog(@"Allocating self...");
            selfInstance = [[self alloc] init];
            selfInstance.contacts = [[NSMutableArray alloc] initWithCapacity:100];
        }
    }
    return selfInstance;
}

-(void)accessContacts {
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    //failure((__bridge NSError *)error);
                } else {
                    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:100];
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
                        NSString *tempEmail;
                        for (int i = 0; i < emailCount; i++) {
                            tempEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailList, i);
                            [emailBufferArray addObject:tempEmail];
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
                        
                        for (int i = 0; i < MAX(emailCount, phoneNumberCount); i++) {
                            if (i < emailCount) {
                                [allEmails addObject:[emailBufferArray objectAtIndex:i]];
                            } else {
                                [allEmails addObject:@""];
                            }
                            if (i < phoneNumberCount) {
                                [allPhoneNumbers addObject:[phoneBufferArray objectAtIndex:i]];
                            } else {
                                [allPhoneNumbers addObject:@""];
                            }
                        }
                        
                        [self.contacts addObject:[NSDictionary dictionaryWithObjectsAndKeys:firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, emailBufferArray, VCARD_TAG_EMAIL, phoneBufferArray, VCARD_TAG_USERNAME, nil]];
                    }
                    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createUserSearchPacketWithPhoneNumbers:allPhoneNumbers emails:allEmails]];
                }
                CFRelease(addressBook);
            });
        });
    }
}

-(void)updateContactListAfterUserSearch {
    NSArray *phoneNumbers, *emailAddresses;
    NSString *tempPhone, *tempEmail;
    for (NSDictionary *contact in _contacts) {
        phoneNumbers = [contact objectForKey:VCARD_TAG_USERNAME];
        emailAddresses = [contact objectForKey:VCARD_TAG_EMAIL];
        BOOL found = NO;
        int i = 0;
        while (found == NO && i < MAX([phoneNumbers count], [emailAddresses count])) {
            if (i < [phoneNumbers count]) {
                tempPhone = [phoneNumbers objectAtIndex:i];
                found = [FriendsDBManager hasUserWithJID:tempPhone];
            }
            if (i < [emailAddresses count] && !found) {
                tempEmail = [emailAddresses objectAtIndex:i];
                found = [FriendsDBManager hasUserWithEmail:tempEmail];
            }
            i++;
        }
        int status = (found == YES) ? STATUS_REGISTERED : STATUS_UNREGISTERED;
        NSString *name = [NSString stringWithFormat:@"%@ %@", [contact objectForKey:VCARD_TAG_FIRST_NAME], [contact objectForKey:VCARD_TAG_LAST_NAME]];

        [FriendsDBManager insert:tempPhone
                            name:name
                           email:tempEmail
                          status:[NSNumber numberWithInt:status]
             searchedPhoneNumber:nil
                    searchedEmail:nil];
    }
}

@end
