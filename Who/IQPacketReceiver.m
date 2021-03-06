//
//  IQPacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//
#import "UserDefaultManager.h"
#import "IQPacketReceiver.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "FriendsDBManager.h"
#import "AppDelegate.h"
#import "ChatDBManager.h"
#import "ConfessionsManager.h"
#import "ContactSearchManager.h"
#import "NSString+URLEncode.h"

@implementation IQPacketReceiver

+(bool)isPacketWithID:(NSString *)packetID packet:(XMPPIQ *)packet {
    return ([packet.elementID compare:packetID] == 0 && packet.elementID != nil);
}

+(void)handleIQPacket:(XMPPIQ *)iq {
    NSString *sanitizedXMLString = [self sanitizePacket:iq];
    if([self isPacketWithID:PACKET_ID_CREATE_VCARD packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_VCARD object:nil];
    } else if([self isPacketWithID:PACKET_ID_GET_JOINED_CHATS packet:iq]) {
        [self handleGetJoinedChatsPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_GET_PENDING_CHATS packet:iq]) {
        [self handleGetPendingChatsPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_GET_ROSTER packet:iq]) {
        [self handleGetRosterPacket: iq];
    //} else if([self isPacketWithID:PACKET_ID_JOIN_MUC packet:iq]) {
    } else if([self isPacketWithID:PACKET_ID_REGISTER_USER packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_REGISTER_USER object:nil];
        //} else if([self isPacketWithID:PACKET_ID_GET_LAST_TIME_ACTIVE packet:iq]) {
        //[self handleGetLastTimeActivePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SERVER_TIME packet:iq]) {
        [self handleGetServerTimePacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_GET_VCARD packet:iq]) {
        [self handleGetVCardPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT packet:iq]) {
        [self handleCreateOneToOneChatPacket];
    } else if([self isPacketWithID:PACKET_ID_POST_CONFESSION packet:iq]) {
        [self handlePostConfessionPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION packet:iq]) {
        [self handleCreateOneToOneChatFromConfessionPacket];
    } else if([self isPacketWithID:PACKET_ID_GET_CHAT_PARTICIPANTS packet:iq]) {
        [self handleGetChatParticipantsPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_SEARCH_FOR_USERS packet:iq]) {
        [self handleUserSearchPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_SEARCH_FOR_USER packet:iq]) {
        [self handleSearchForUserPacket:sanitizedXMLString];
    } else if([self isPacketWithID:PACKET_ID_GET_USER_INFO packet:iq]) {
        [self handleGetUserInfoPacket:sanitizedXMLString];
    }
}

+(void)handleGetUserInfoPacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\",\"(.*?)\",\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, xml.length)];
    if ([match numberOfRanges] > 0) {
        NSString *countryCode = [xml substringWithRange:[match rangeAtIndex:1]];
        NSString *phone = [xml substringWithRange:[match rangeAtIndex:2]];
        NSString *email = [xml substringWithRange:[match rangeAtIndex:3]];
        [UserDefaultManager saveCountryCode:countryCode];
        [UserDefaultManager savePhone:phone];
        [UserDefaultManager saveEmail:email];
    }
}

// This callback is only for packets searching for a single user, adds them as a friend if the user is found.
+(void)handleSearchForUserPacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\(?:\\[\\]|\"(.*?)\").*?(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, xml.length)];
    if ([match numberOfRanges] > 0) {
        NSString *username = [xml substringWithRange:[match rangeAtIndex:1]];
        NSString *searchedEmail;
        if ([match rangeAtIndex:4].length != 0) {
            searchedEmail = [xml substringWithRange:[match rangeAtIndex:3]];
        }
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        [conn sendElement:[IQPacketManager createSubscribePacket:username]];
        [FriendsDBManager updateEntry:username name:nil email:searchedEmail status:@(STATUS_REQUESTED)];
    }
}

// NOTE: this should only be run AFTER the query for the roster
+(void)handleUserSearchPacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\(?:\\[\\]|\"(.*?)\").*?(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:xml options:0 range:NSMakeRange(0, xml.length)];
    NSMutableArray *registeredContacts = [[NSMutableArray alloc] initWithCapacity:[matches count]];
    NSString *username, *searchedPhoneNumber, *searchedEmail, *uid;
    for (NSTextCheckingResult *match in matches) {
        uid = [xml substringWithRange:[match rangeAtIndex:1]];
        username = [xml substringWithRange:[match rangeAtIndex:2]];
        if ([match rangeAtIndex:3].length != 0) {
            searchedPhoneNumber = [xml substringWithRange:[match rangeAtIndex:3]];
        } else {
            searchedPhoneNumber = @"";
        }
        if ([match rangeAtIndex:4].length != 0) {
            searchedEmail = [xml substringWithRange:[match rangeAtIndex:4]];
        } else {
            searchedEmail = @"";
        }

        [registeredContacts addObject:@{FRIENDS_TABLE_COLUMN_NAME_USERNAME : username, FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER : searchedPhoneNumber, FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL : searchedEmail, DICTIONARY_KEY_ID : uid}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_SEARCH_FOR_USERS object:nil];
    [[ContactSearchManager getInstance] updateContactListAfterUserSearch: registeredContacts];
}

+(void)handleGetChatParticipantsPacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:xml options:0 range:NSMakeRange(0, xml.length)];
    NSMutableArray *participants = [[NSMutableArray alloc] initWithCapacity:[matches count]];
    
    for (NSTextCheckingResult *match in matches) {
        NSString *status = [xml substringWithRange:[match rangeAtIndex:3]];
        if ([status isEqualToString:@"active"] || [status isEqualToString:@"pending"]) {
            NSDictionary *participantDict = @{PARTICIPANT_STATUS: [xml substringWithRange:[match rangeAtIndex:3]],
                                              PARTICIPANT_USERNAME : [xml substringWithRange:[match rangeAtIndex:1]],
                                              PARTICIPANT_INVITED_BY : [xml substringWithRange:[match rangeAtIndex:2]]};
            [participants addObject:participantDict];
        }
    }
    
    [ChatDBManager updateChatParticipants:participants];
    NSDictionary *userInfo = @{PACKET_ID_GET_CHAT_PARTICIPANTS: participants};
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_CHAT_PARTICIPANTS object:nil userInfo:userInfo];
}

+(void)handleGetJoinedChatsPacket:(NSString *)xml {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate getManagedObjectContextForBackgroundThread];
    __block dispatch_queue_t mainQueue = dispatch_get_main_queue();
    [moc performBlock:^{
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\",(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:xml options:0 range:NSMakeRange(0, xml.length)],
        *participants;
        NSString *participantString, *chatId, *type, *owner, *name, *degree;
        NSMutableArray *chatIDS = [[NSMutableArray alloc] initWithCapacity:20];
        for (NSTextCheckingResult *match in matches) {
            participantString = [xml substringWithRange:[match rangeAtIndex:1]];
            chatId = [xml substringWithRange:[match rangeAtIndex:2]];
            type = [xml substringWithRange:[match rangeAtIndex:3]];
            owner = [xml substringWithRange:[match rangeAtIndex:4]];
            name = [[xml substringWithRange:[match rangeAtIndex:5]] urlDecode];
            //*createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
            
            if ([match rangeAtIndex:7].length != 0) {
                degree = [xml substringWithRange:[match rangeAtIndex:7]];
            } else {
                degree = @"1";
            }
            
            participants = [participantString componentsSeparatedByString:@","];
            if ([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
                ChatMO *chat = [ChatDBManager getChatWithID:chatId withMOC:moc];
                if (chat != nil) {
                    name = [chat getChatName];
                    type = chat.chat_type;
                } else {
                    if ([owner isEqualToString:[ConnectionProvider getUser]]) {
                        NSString *participant = ([[participants firstObject] isEqualToString:[ConnectionProvider getUser]]) ? [participants lastObject] : [participants firstObject];
                        type = CHAT_TYPE_ONE_TO_ONE_INVITER;
                        name = [FriendsDBManager getUserWithUsername:participant].name;
                        if (name == nil) {
                            name = @"Loading...";
                        }
                    } else if([owner isEqualToString:@"server"]) {
                        type = CHAT_TYPE_ONE_TO_ONE_CONFESSION;
                    } else {
                        type = CHAT_TYPE_ONE_TO_ONE_INVITED;
                        name = ANONYMOUS_FRIEND;
                    }
                }
            }
            [chatIDS addObject:chatId];
            [ChatDBManager insertChatWithID:chatId chatName:name chatType:type participantString:participantString status:STATUS_JOINED degree:degree withContext:moc];
        }
        
        [delegate saveContextForBackgroundThread];
        
        dispatch_sync(mainQueue, ^{
            [ChatDBManager deleteChatsNotInArray:chatIDS withStatus:STATUS_JOINED];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
        });
    }];
}

+(void)handleGetServerTimePacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<utc>(.*?)<\\/utc>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, xml.length)];
    NSString *utcTime = [xml substringWithRange:[match rangeAtIndex:1]];
    
    NSDictionary *userInfo = @{PACKET_ID_GET_SERVER_TIME : utcTime};
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_SERVER_TIME object:nil userInfo:userInfo];
}

+(void)handleGetVCardPacket:(XMPPIQ *)packet {
    NSString *firstName, *lastName, *itemName;//, *nickname;
    NSString *username = [[[packet fromStr] componentsSeparatedByString:@"@"] firstObject];
    NSArray *children = [packet children];
    for (NSUInteger i = 0; i < children.count; i++) {
        NSArray *grand = [children[i] children];
        for (NSUInteger j = 0; j < grand.count; j++) {
            itemName = [grand[j] name];
            if([itemName compare:@"N"] == 0) {
                NSArray *nameItems = [grand[j] children];
                for(NSUInteger k = 0; k < nameItems.count; k++) {
                    itemName = [nameItems[k] name];
                    if ([itemName compare:VCARD_TAG_FIRST_NAME] == 0) {
                        firstName = [nameItems[k] stringValue];
                    } else if([itemName compare:VCARD_TAG_LAST_NAME] == 0) {
                        lastName = [nameItems[k] stringValue];
                    }
                }
            }
        }
    }
    if ([username compare:[ConnectionProvider getUser]] != 0) {
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        if ([FriendsDBManager hasUserWithJID:username]) {
            [FriendsDBManager insert:username name:name email:nil status:nil searchedPhoneNumber:nil searchedEmail:nil uid:nil];
            [ChatDBManager updateOneToOneChatNames:name username:username];
        } else {
            [[ConnectionProvider getInstance] addName:name forUsername:username];
        }
    } else {
        //[UserDefaultManager saveEmail:email];
        [UserDefaultManager saveName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_VCARD object:nil];
}

+(void)handleGetPendingChatsPacket:(NSString *)xml {
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:xml options:0 range:NSMakeRange(0, xml.length)];

    NSString *participantString, *chatId, *type, *name;
    
    for(NSTextCheckingResult *match in matches) {
        participantString = [xml substringWithRange:[match rangeAtIndex:1]];
        chatId = [xml substringWithRange:[match rangeAtIndex:2]];
        type = [xml substringWithRange:[match rangeAtIndex:3]];
        //owner = [packetXML substringWithRange:[match rangeAtIndex:4]];
        name = [[xml substringWithRange:[match rangeAtIndex:5]] urlDecode];
        //createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
        //participants = [participantString componentsSeparatedByString:@", "];
        
        [ChatDBManager insertChatWithID:chatId chatName:name chatType:type participantString:participantString status:STATUS_PENDING degree:@"1"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_PENDING_CHATS object:nil];
}

+(NSString *)sanitizePacket:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@" " withString:@""];
    return packetXML;
}

+(void)handleGetRosterPacket: (XMPPIQ *)iq {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *username = [ConnectionProvider getUser];
    NSManagedObjectContext *moc = [delegate getManagedObjectContextForBackgroundThread];
    __block dispatch_queue_t mainQ = dispatch_get_main_queue();
    [moc performBlock:^{
        
        NSError *error = NULL;
        DDXMLElement *query = [[iq children] firstObject];
        NSArray *items = [query children];
        DDXMLElement *item;
        NSMutableArray *itemsWithoutVCard = [NSMutableArray array];
        NSMutableArray *itemsToSendSubscribedPacket = [NSMutableArray array];
        NSMutableArray *itemsToDelete = [NSMutableArray array];
        NSMutableArray *allItems = [NSMutableArray array];
        int numContactsAddedThroughBlacklist = 0;
        for (NSUInteger i = 0; i < items.count; i++)
        {
            item = items[i];
            NSString *subscription = [[item attributeForName:@"subscription"] XMLString];
            //Parse jid
            NSString *jid = [[item attributeForName:@"jid"] XMLString];
            NSRegularExpression *regexJid = [NSRegularExpression regularExpressionWithPattern:@"jid=\"(.*)@" options: 0 error:&error];
            NSTextCheckingResult *matchJid = [regexJid firstMatchInString:jid options:0 range:NSMakeRange(0,jid.length)];
            NSString *itemUsername = [jid substringWithRange:[matchJid rangeAtIndex:1]];
            if ([[itemUsername lowercaseString] isEqualToString:[username lowercaseString]]) {
                continue;
            }
            // I sent a friend request, but the user hasn't accepted it yet.
            if([[item attributeForName:@"ask"] stringValue] != nil)
            {
                NSLog(@"ASK = SUBSCRIBE: %@", [item XMLString]);
                continue;
            }

            [allItems addObject:itemUsername];
            if ([subscription rangeOfString:@"none"].location != NSNotFound){
                [itemsToDelete addObject:itemUsername];
                [FriendsDBManager deleteUserWithUsername:itemUsername];
            }
            else
            {
                if([subscription rangeOfString:@"to"].location != NSNotFound)
                {
                    [itemsToSendSubscribedPacket addObject:itemUsername];
                }
                if ([FriendsDBManager insertWithMOC:moc
                                           username:itemUsername
                                               name:nil
                                              email:nil
                                             status:@(STATUS_FRIENDS)
                                searchedPhoneNumber:nil
                                      searchedEmail:nil
                                                uid:nil])
                {
                    numContactsAddedThroughBlacklist++;
                    [itemsWithoutVCard addObject:itemUsername];
                }
                
            }
        }
        [delegate saveContextForBackgroundThread];
        dispatch_sync(mainQ, ^{
            ConnectionProvider *cp = [ConnectionProvider getInstance];
            XMPPStream *conn = [cp getConnection];
            NSLog(@"ROSTER PACKET");
            NSLog(@"Items without vcard :%@", itemsWithoutVCard);
            NSString *uname;
            for (uname in itemsWithoutVCard)
            {
                [conn sendElement:[IQPacketManager createGetVCardPacket:uname]];
            }
            for (uname in itemsToSendSubscribedPacket)
            {
                [conn sendElement:[IQPacketManager createSubscribedPacket:uname]];
            }
            for (uname in itemsToDelete) {
                [conn sendElement:[IQPacketManager createRemoveFriendPacket:uname]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_ROSTER object:nil];
        });
    }];
}

+ (void)handleCreateOneToOneChatPacket {
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
}

+(void)handleGetSessionIDPacket:(NSString*)xml {
    NSLog(@"Handling Session ID");
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<value>(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, xml.length)];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setSessionID:[xml substringWithRange:[match rangeAtIndex:1]]];
    NSLog(@"SET SESSION ID: %@", delegate.sessionID);

    if (![UserDefaultManager hasSentBlacklist]) {
        [[[ContactSearchManager alloc] init] accessContacts];
        [UserDefaultManager setSentBlacklistTrue];
    }
    
    ConfessionsManager *cm = [ConfessionsManager getInstance];
    if ([FriendsDBManager hasEnoughFriends]) {
        [cm setMethod:THOUGHTS_METHOD_FRIENDS];
    } else {
        [cm setMethod:THOUGHTS_METHOD_GLOBAL];
    }
    [cm loadConfessions];
}

+(void)handlePostConfessionPacket:(NSString *)xml {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<value>(.*?),(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, xml.length)];
    NSString *confessionID = [xml substringWithRange:[match rangeAtIndex:1]];
    NSString *createdTimestamp = [xml substringWithRange:[match rangeAtIndex:2]];
    [[ConfessionsManager getInstance] updatePendingConfession:confessionID timestamp:createdTimestamp];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_POST_CONFESSION object:nil];
}

+ (void)handleCreateOneToOneChatFromConfessionPacket {
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
}

@end
