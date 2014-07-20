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
#import "BlacklistManager.h"

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
                    if ([UserDefaultManager loadCountryCode] == nil) {
                        [UserDefaultManager saveCountryCode:@"1"];
                    }
                    NSString *countryCode = [UserDefaultManager loadCountryCode];
                    NSString *phoneNumberWithoutCountry = [UserDefaultManager loadPhone]; 
                    NSMutableArray *allPhoneNumbers = [[NSMutableArray alloc] initWithCapacity:100];
                    NSMutableArray *allEmails = [[NSMutableArray alloc] initWithCapacity:100];
                    NSArray *people = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    for (id person in people) {
                        ABRecordRef personRecordReference = (__bridge ABRecordRef)person;
                        /*NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonFirstNameProperty);
                        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(personRecordReference, kABPersonLastNameProperty);
                        //ABRecordID personID = ABRecordGetRecordID(personRecordReference);
                        if (firstName == nil && lastName == nil) {
                            continue;
                        } else if(firstName == nil) {
                            firstName = [NSString stringWithFormat:@"%@", lastName];
                            lastName = @"";
                        } else if(lastName == nil) {
                            lastName = @"";
                        }*/
                        
                        // Get all phone numbers of a contact
                        ABMultiValueRef phoneNumbers = ABRecordCopyValue(personRecordReference, kABPersonPhoneProperty);
                        ABMultiValueRef emailList = ABRecordCopyValue(personRecordReference, kABPersonEmailProperty);
                        NSInteger emailCount = ABMultiValueGetCount(emailList);
                        NSString *tempEmail;
                        for (int i = 0; i < emailCount; i++) {
                            tempEmail = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emailList, i);
                            [allEmails addObject:tempEmail];
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
                            [allPhoneNumbers addObject:phone];
                        }
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BlacklistManager sendPostRequestWithPhoneNumbers:allPhoneNumbers emails:allEmails];
                    });
                }
                CFRelease(addressBook);
            });
        });
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You need to allow Versapp to access your contacts. You can do this in your settings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONTACTS_VIEW object:nil];
    }
}

-(void)updateContactListAfterUserSearch:(NSArray *)contactsFound {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate getManagedObjectContextForBackgroundThread];
    __block dispatch_queue_t mainQ = dispatch_get_main_queue();
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
        
        [delegate saveContextForBackgroundThread];
        
        if ([self isFinishedSearching]) {
            dispatch_sync(mainQ, ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_CONTACTS_VIEW object:nil];
            });
        }
    }];
}

@end
