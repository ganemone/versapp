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

@property (strong, atomic) NSMutableDictionary *contacts;
@property (strong, nonatomic) NSArray *allFriends;
@property int numPacketsSent;
@end

static ContactSearchManager *selfInstance;

@implementation ContactSearchManager

+(instancetype)getInstance {
    @synchronized(self) {
        if (selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.contacts = [[NSMutableDictionary alloc] initWithCapacity:100];
        }
    }
    return selfInstance;
}

-(void)incrementNumPacketsSent {
    @synchronized(self) {
        _numPacketsSent++;
    }
}

-(void)decrementNumPacketsSent {
    @synchronized(self) {
        _numPacketsSent--;
    }
}

-(BOOL)isFinishedSearching {
    @synchronized(self) {
        return (_numPacketsSent == 0);
    }
}

-(void)resetNumPacketsSent {
    @synchronized(self) {
        _numPacketsSent = 0;
    }
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
                    [UserDefaultManager saveCountryCode:@"1"];
                    NSString *countryCode = [UserDefaultManager loadCountryCode];
                    NSString *phoneNumberWithoutCountry = [[[UserDefaultManager loadUsername] componentsSeparatedByString:@"-"] lastObject];
                    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allIDS = [[NSMutableArray alloc] initWithCapacity:100];
                    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    for (id person in people) {
                        ABRecordRef personRecordReference = (__bridge ABRecordRef)person;
                        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonLastNameProperty);
                        ABRecordID personID = ABRecordGetRecordID(personRecordReference);
                        NSString *personIDString = [NSString stringWithFormat:@"%d", personID];
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
                            if (phone.length == phoneNumberWithoutCountry.length) {
                                phone = [NSString stringWithFormat:@"%@%@", countryCode, phone];
                            }
                            [phoneBufferArray addObject:phone];
                        }
                        for (int i = 0; i < MAX([emailBufferArray count], [phoneBufferArray count]); i++) {
                            if (i < emailCount) {
                                [allEmails addObject:[emailBufferArray objectAtIndex:i]];
                            } else {
                                [allEmails addObject:@""];
                            }
                            if (i < [phoneBufferArray count]) {
                                [allPhoneNumbers addObject:[phoneBufferArray objectAtIndex:i]];
                            } else {
                                [allPhoneNumbers addObject:@""];
                            }
                            [allIDS addObject:personIDString];
                            [self.contacts setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:personIDString, DICTIONARY_KEY_ID, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, emailBufferArray, VCARD_TAG_EMAIL, phoneBufferArray, VCARD_TAG_USERNAME, [NSNumber numberWithInt:STATUS_UNREGISTERED], FRIENDS_TABLE_COLUMN_NAME_STATUS, [NSNumber numberWithInt:personID], FRIENDS_TABLE_COLUMN_NAME_UID, nil] forKey:personIDString];
                        }
                    }
                    int numToSplit = MIN(35, [allIDS count]);
                    int startingIndex = 0;
                    [self resetNumPacketsSent];
                    while ([allIDS count] >= startingIndex + numToSplit) {
                        NSMutableArray *tempPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:numToSplit];
                        NSMutableArray *tempEmails = [[NSMutableArray alloc] initWithCapacity:numToSplit];
                        NSMutableArray *tempIDS = [[NSMutableArray alloc] initWithCapacity:numToSplit];
                        for (int i = startingIndex; i < startingIndex + numToSplit; i++) {
                            [tempPhoneNumbers addObject:[allPhoneNumbers objectAtIndex:i]];
                            [tempEmails addObject:[allEmails objectAtIndex:i]];
                            [tempIDS addObject:[allIDS objectAtIndex:i]];
                        }
                        [self incrementNumPacketsSent];
                        startingIndex = startingIndex + numToSplit;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createUserSearchPacketWithPhoneNumbers:tempPhoneNumbers emails:tempEmails personIDS:tempIDS]];
                        });
                    }
                    startingIndex = startingIndex - numToSplit;
                    int capacity = ((int)[allIDS count]) - startingIndex;
                    NSMutableArray *tempPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:capacity];
                    NSMutableArray *tempEmails = [[NSMutableArray alloc] initWithCapacity:capacity];
                    NSMutableArray *tempIDS = [[NSMutableArray alloc] initWithCapacity:capacity];
                    for (int i = startingIndex - numToSplit; i < [allIDS count]; i++) {
                        [tempPhoneNumbers addObject:[allPhoneNumbers objectAtIndex:i]];
                        [tempEmails addObject:[allEmails objectAtIndex:i]];
                        [tempIDS addObject:[allIDS objectAtIndex:i]];
                    }
                    if ([tempIDS count] > 0) {
                        [self incrementNumPacketsSent];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createUserSearchPacketWithPhoneNumbers:tempPhoneNumbers emails:tempEmails personIDS:tempIDS]];
                        });
                    }
                }
                CFRelease(addressBook);
            });
        });
    }
}

-(void)updateContactListAfterUserSearch:(NSArray *)contactsFound {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setParentContext:mainMoc];
    [moc performBlock:^{
        for (NSDictionary *registeredContact in contactsFound) {
            NSString *dictionaryKey = [registeredContact objectForKey:DICTIONARY_KEY_ID];
            NSMutableDictionary *contact = [_contacts objectForKey:dictionaryKey];
            [contact setObject:[registeredContact objectForKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME] forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
            [contact setObject:[NSNumber numberWithInt:STATUS_REGISTERED] forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
            [contact setObject:[registeredContact objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER] forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
            [contact setObject:[registeredContact objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        }
        [self decrementNumPacketsSent];
        if ([self isFinishedSearching]) {
            NSEnumerator *contactEnumerator = [_contacts objectEnumerator];
            NSDictionary *contact;
            while ((contact = [contactEnumerator nextObject]) != nil) {
                [FriendsDBManager updateFriendAfterUserSearch:contact withContext:moc];
            }
        }
        
        NSError *err = nil;
        if(![moc save:&err]) {
        }
        
        [mainMoc performBlock:^{
            NSError *error = nil;
            if (![mainMoc save:&error]) {
            }
        }];
        
        if ([self isFinishedSearching]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONTACTS_VIEW object:nil];
            });
        }
    }];
}

@end
