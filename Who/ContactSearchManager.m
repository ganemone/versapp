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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!granted) {
                    //failure((__bridge NSError *)error);
                } else {
                    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:100];
                    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    for (id person in people) {
                        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonLastNameProperty);
                        
                        if (firstName == nil && lastName == nil) {
                            continue;
                        } else if(firstName == nil) {
                            firstName = [NSString stringWithFormat:@"%@", lastName];
                            lastName = @"";
                        } else if(lastName == nil) {
                            lastName = @"";
                        }
                        
                        NSMutableArray *phoneBufferArray = [[NSMutableArray alloc] init],
                        *emailBufferArray = [[NSMutableArray alloc] init];
                        
                        // Get all phone numbers of a contact
                        ABMultiValueRef phoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonPhoneProperty),
                        emailList = ABRecordCopyValue((__bridge ABRecordRef)(person), kABPersonEmailProperty);
                        BOOL shouldSearch = YES;
                        NSInteger emailCount = ABMultiValueGetCount(emailList);
                        NSString *tempEmail;
                        for (int i = 0; i < emailCount; i++) {
                            tempEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailList, i);
                            [emailBufferArray addObject:tempEmail];
                            FriendMO* friend;
                            if ((friend = [FriendsDBManager getUserWithEmail:tempEmail]) != nil) {
                                shouldSearch = ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_JOINED]] ||
                                                [friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_FRIENDS]]) ? NO : YES;
                            }
                            if (shouldSearch == NO) {
                                i = emailCount;
                            }
                        }
                        
                        NSInteger phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
                        NSError *regerr = NULL;
                        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&regerr];
                        NSString *phone;
                        if (shouldSearch == YES) {
                            for (int i = 0; i < phoneNumberCount; i++) {
                                phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                                phone = [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
                                [phoneBufferArray addObject:phone];
                                FriendMO* friend;
                                if ((friend = [FriendsDBManager getUserWithJID:phone]) != nil) {
                                    shouldSearch = ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_JOINED]] ||
                                                    [friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_FRIENDS]]) ? NO : YES;
                                }
                                if (shouldSearch == NO) {
                                    i = phoneNumberCount;
                                }
                            }
                        }
                        if (shouldSearch == YES) {
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
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createUserSearchPacketWithPhoneNumbers:allPhoneNumbers emails:allEmails]];
                        NSLog(@"Just Sent Search Packet...");
                    });
                }
                CFRelease(addressBook);
                NSLog(@"Released adress book...");
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
        int i = 0;
        FriendMO *friend;
        while (friend == nil && i < MAX([phoneNumbers count], [emailAddresses count])) {
            if (i < [phoneNumbers count]) {
                tempPhone = [phoneNumbers objectAtIndex:i];
                friend = [FriendsDBManager getUserWithJID:tempPhone];
            }
            if (i < [emailAddresses count] && friend == nil) {
                tempEmail = [emailAddresses objectAtIndex:i];
                friend = [FriendsDBManager getUserWithEmail:tempEmail];
            }
            i++;
        }
        NSNumber *status = (friend == nil) ? [NSNumber numberWithInt:STATUS_UNREGISTERED] : friend.status;
        NSString *name = [NSString stringWithFormat:@"%@ %@", [contact objectForKey:VCARD_TAG_FIRST_NAME], [contact objectForKey:VCARD_TAG_LAST_NAME]];
        [FriendsDBManager insert:tempPhone
                            name:name
                           email:tempEmail
                          status:status
             searchedPhoneNumber:nil
                   searchedEmail:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONTACTS_VIEW object:nil];
}

@end
