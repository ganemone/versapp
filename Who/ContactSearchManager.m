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
#import "AppDelegate.h"
#import "UserDefaultManager.h"

@interface ContactSearchManager()

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSArray *allFriends;

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

-(FriendMO *)getFriendWithEmail:(NSString *)email {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"email = \"%@\"", email]];
    return [[_allFriends filteredArrayUsingPredicate:predicate] firstObject];
}

-(FriendMO *)getFriendWithUsername:(NSString *)username {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"username = \"%@\"", username]];
    return [[_allFriends filteredArrayUsingPredicate:predicate] firstObject];
}

-(void)accessContacts {
    _allFriends = [FriendsDBManager getAll];
    if (ABAddressBookRequestAccessWithCompletion) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!granted) {
                    //failure((__bridge NSError *)error);
                } else {
                    NSString *countryCode = [UserDefaultManager loadCountryCode];
                    NSString *phoneNumberWithoutCountry = [[[UserDefaultManager loadUsername] componentsSeparatedByString:@"-"] firstObject];
                    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:100];
                    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    for (id person in people) {
                        ABRecordRef personRecordReference = (__bridge ABRecordRef)person;
                        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonLastNameProperty);
                        
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
                        ABMultiValueRef phoneNumbers = ABRecordCopyValue(personRecordReference, kABPersonPhoneProperty);
                        ABMultiValueRef emailList = ABRecordCopyValue(personRecordReference, kABPersonEmailProperty);
                        BOOL shouldSearch = YES;
                        NSInteger emailCount = ABMultiValueGetCount(emailList);
                        NSString *tempEmail;
                        for (int i = 0; i < emailCount; i++) {
                            tempEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailList, i);
                            [emailBufferArray addObject:tempEmail];
                            FriendMO* friend;
                            if ((friend = [self getFriendWithEmail:tempEmail]) != nil) {
                                shouldSearch = ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_UNREGISTERED]]) ? YES : NO;
                            }
                            if (shouldSearch == NO) {
                                i = (int)emailCount;
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
                                if (phone.length == phoneNumberWithoutCountry.length) {
                                    phone = [NSString stringWithFormat:@"%@-%@", countryCode, phone];
                                }
                                [phoneBufferArray addObject:phone];
                                FriendMO* friend;
                                if ((friend = [self getFriendWithUsername:phone]) != nil) {
                                    shouldSearch = ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_UNREGISTERED]]) ? YES : NO;
                                }
                                if (shouldSearch == NO) {
                                    i = (int)phoneNumberCount;
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
                    });
                }
                CFRelease(addressBook);
            });
        });
    }
}

-(void)updateContactListAfterUserSearch {
    NSLog(@"Has user... %d", [FriendsDBManager hasUserWithEmail:@"ganemone@gmail.com"]);
    NSLog(@"User Status: %@", [FriendsDBManager getUserWithEmail:@"ganemone@gmail.com"]);
    NSMutableArray *contactsWithStatus = [[NSMutableArray alloc] initWithCapacity:[_contacts count]];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setParentContext:mainMoc];
    [moc performBlock:^{
        NSLog(@"Updating Contact List After Search!!!!");
        NSArray *phoneNumbers, *emailAddresses;
        NSString *tempPhone, *tempEmail;
        for (NSDictionary *contact in _contacts) {
            phoneNumbers = [contact objectForKey:VCARD_TAG_USERNAME];
            emailAddresses = [contact objectForKey:VCARD_TAG_EMAIL];
            tempEmail = nil, tempPhone = nil;
            FriendMO *friend = nil;
            int i = 0;
            while (friend == nil && i < MAX([phoneNumbers count], [emailAddresses count])) {
                if (i < [phoneNumbers count]) {
                    tempPhone = [phoneNumbers objectAtIndex:i];
                    NSLog(@"Temp Phone: %@", tempPhone);
                    friend = [FriendsDBManager getUserWithJID:tempPhone moc:moc];
                }
                if (i < [emailAddresses count]) {
                    tempEmail = [emailAddresses objectAtIndex:i];
                    NSLog(@"Temp Email: %@", tempEmail);
                    if (friend == nil) {
                        friend = [FriendsDBManager getUserWithEmail:tempEmail moc:moc];
                    }
                }
                i++;
            }
            
            NSNumber *status = (friend == nil) ? [NSNumber numberWithInt:STATUS_UNREGISTERED] : friend.status;
            NSString *name = [NSString stringWithFormat:@"%@ %@", [contact objectForKey:VCARD_TAG_FIRST_NAME], [contact objectForKey:VCARD_TAG_LAST_NAME]];
            NSLog(@"Found Friend %@? : %d", name, (friend != nil));
            if (tempPhone == nil) {
                tempPhone = @"";
            }
            if (tempEmail == nil) {
                tempEmail = @"";
            }
            if (name == nil) {
                name = @";";
            }
            NSDictionary *newContact = [NSDictionary dictionaryWithObjectsAndKeys:status, FRIENDS_TABLE_COLUMN_NAME_STATUS, name, FRIENDS_TABLE_COLUMN_NAME_NAME, tempPhone, FRIENDS_TABLE_COLUMN_NAME_USERNAME, tempEmail, FRIENDS_TABLE_COLUMN_NAME_EMAIL, nil];
            [contactsWithStatus addObject:newContact];
        }
        
        for (NSDictionary *contact in contactsWithStatus) {
            [FriendsDBManager updateFriendAfterSearch:[contact objectForKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME]
                                                 name:[contact objectForKey:FRIENDS_TABLE_COLUMN_NAME_NAME]
                                                email:[contact objectForKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL]
                                               status:[contact objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS]
                                  searchedPhoneNumber:nil
                                        searchedEmail:nil
                                                  moc:moc];
        }
        
        NSError *err = nil;
        if(![moc save:&err]) {
            NSLog(@"Failed to push data to parent...");
        }
        
        [mainMoc performBlock:^{
            NSError *error = nil;
            if (![mainMoc save:&error]) {
                NSLog(@"Failed to save data...");
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONTACTS_VIEW object:nil];
        });
    }];
}

@end
