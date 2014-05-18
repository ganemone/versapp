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
#import "MessagesDBManager.h"
#import "AppDelegate.h"
#import "ChatDBManager.h"
#import "Confession.h"
#import "ConfessionsManager.h"
#import "ContactSearchManager.h"

@implementation IQPacketReceiver

+(bool)isPacketWithID:(NSString *)packetID packet:(XMPPIQ *)packet {
    return ([packet.elementID compare:packetID] == 0 && packet.elementID != nil);
}

+(void)handleIQPacket:(XMPPIQ *)iq {
    if([self isPacketWithID:PACKET_ID_CREATE_VCARD packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_VCARD object:nil];
    } else if([self isPacketWithID:PACKET_ID_GET_JOINED_CHATS packet:iq]) {
        [self handleGetJoinedChatsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_PENDING_CHATS packet:iq]) {
        [self handleGetPendingChatsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_ROSTER packet:iq]) {
        [self handleGetRosterPacket: iq];
        
    } else if([self isPacketWithID:PACKET_ID_JOIN_MUC packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_REGISTER_USER packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_REGISTER_USER object:nil];
        //} else if([self isPacketWithID:PACKET_ID_GET_LAST_TIME_ACTIVE packet:iq]) {
        //[self handleGetLastTimeActivePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SERVER_TIME packet:iq]) {
        [self handleGetServerTimePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_VCARD packet:iq]) {
        [self handleGetVCardPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_INVITE_USER_TO_CHAT packet:iq]) {
        [self handleInviteUserToChatPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT packet:iq]) {
        [self handleCreateOneToOneChatPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SESSION_ID packet:iq]) {
        [self handleGetSessionIDPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_CONFESSIONS packet:iq]) {
        [self handleGetConfessionsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_MY_CONFESSIONS packet:iq]) {
        [self handleGetMyConfessionsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_FAVORITE_CONFESSION packet:iq]) {
        [self handleToggleFavoriteConfessionPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_POST_CONFESSION packet:iq]) {
        [self handlePostConfessionPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION packet:iq]) {
        [self handleCreateOneToOneChatFromConfessionPacket:(XMPPIQ*)iq];
    } else if([self isPacketWithID:PACKET_ID_CREATE_MUC packet:iq]) {
        [self handleCreatedMUCPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_CHAT_PARTICIPANTS packet:iq]) {
        [self handleGetChatParticipantsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_SEARCH_FOR_USERS packet:iq]) {
        [self handleUserSearchPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_SEARCH_FOR_USER packet:iq]) {
        [self handleSearchForUserPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_USER_INFO packet:iq]) {
        [self handleGetUserInfoPacket:iq];
    }
}

+(void)handleGetUserInfoPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\",\"(.*?)\",\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    if ([match numberOfRanges] > 0) {
        NSString *countryCode = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
        NSString *phone = [iq.XMLString substringWithRange:[match rangeAtIndex:2]];
        NSString *email = [iq.XMLString substringWithRange:[match rangeAtIndex:3]];
        [UserDefaultManager saveCountryCode:countryCode];
        [UserDefaultManager savePhone:phone];
        [UserDefaultManager saveEmail:email];
    }
}

// This callback is only for packets searching for a single user, adds them as a friend if the user is found.
+(void)handleSearchForUserPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\(?:\\[\\]|\"(.*?)\").*?(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    if ([match numberOfRanges] > 0) {
        NSString *username = [packetXML substringWithRange:[match rangeAtIndex:1]];
        NSString *searchedEmail;
        if ([match rangeAtIndex:4].length != 0) {
            searchedEmail = [packetXML substringWithRange:[match rangeAtIndex:3]];
        }
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        [conn sendElement:[IQPacketManager createSubscribePacket:username]];
        //[conn sendElement:[IQPacketManager createGetVCardPacket:username]];
        [FriendsDBManager updateEntry:username name:nil email:searchedEmail status:[NSNumber numberWithInt:STATUS_REQUESTED]];
    }
}

// NOTE: this should only be run AFTER the query for the roster
+(void)handleUserSearchPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\(?:\\[\\]|\"(.*?)\").*?(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    NSMutableArray *registeredContacts = [[NSMutableArray alloc] initWithCapacity:[matches count]];
    NSString *username, *searchedPhoneNumber, *searchedEmail, *uid;
    for (NSTextCheckingResult *match in matches) {
        uid = [packetXML substringWithRange:[match rangeAtIndex:1]];
        username = [packetXML substringWithRange:[match rangeAtIndex:2]];
        if ([match rangeAtIndex:3].length != 0) {
            searchedPhoneNumber = [packetXML substringWithRange:[match rangeAtIndex:3]];
        } else {
            searchedPhoneNumber = @"";
        }
        if ([match rangeAtIndex:4].length != 0) {
            searchedEmail = [packetXML substringWithRange:[match rangeAtIndex:4]];
        } else {
            searchedEmail = @"";
        }
        
        [registeredContacts addObject:[[NSDictionary alloc] initWithObjectsAndKeys:username, FRIENDS_TABLE_COLUMN_NAME_USERNAME, searchedPhoneNumber, FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER, searchedEmail, FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL, uid, DICTIONARY_KEY_ID, nil]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_SEARCH_FOR_USERS object:nil];
    [[ContactSearchManager getInstance] updateContactListAfterUserSearch: registeredContacts];
}

+(void)handleGetChatParticipantsPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    NSMutableArray *participants = [[NSMutableArray alloc] initWithCapacity:[matches count]];
    
    for (NSTextCheckingResult *match in matches) {
        if ([[packetXML substringWithRange:[match rangeAtIndex:3]] isEqualToString:@"active"]) {
            [participants addObject:[packetXML substringWithRange:[match rangeAtIndex:1]]];
        }
    }
    
    [ChatDBManager updateChatParticipants:participants];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_CHAT_PARTICIPANTS object:nil];
}

+(void)handleGetJoinedChatsPacket:(XMPPIQ *)iq {
    NSLog(@"Handling Get Joined Chats Packet...");
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate getManagedObjectContextForBackgroundThread];
    __block dispatch_queue_t mainQueue = dispatch_get_main_queue();
    [moc performBlock:^{
        
        NSError *error = NULL;
        NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\",(?:\\[\\]|\"(.*?)\")\\]" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)],
        *participants;
        NSString *participantString, *chatId, *type, *owner, *name, *degree;
        NSMutableArray *participantsWithoutVCards = [NSMutableArray array];
        for (NSTextCheckingResult *match in matches) {
            participantString = [packetXML substringWithRange:[match rangeAtIndex:1]];
            chatId = [packetXML substringWithRange:[match rangeAtIndex:2]];
            type = [packetXML substringWithRange:[match rangeAtIndex:3]];
            owner = [packetXML substringWithRange:[match rangeAtIndex:4]];
            name = [self urlDecode:[packetXML substringWithRange:[match rangeAtIndex:5]]];
            //*createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
            
            if ([match rangeAtIndex:7].length != 0) {
                degree = [packetXML substringWithRange:[match rangeAtIndex:7]];
            } else {
                degree = @"1";
            }
        
            participants = [participantString componentsSeparatedByString:@", "];
            for (NSString *participant in participants) {
                if ([FriendsDBManager getUserWithJID:participant moc:moc] == nil) {
                    [participantsWithoutVCards addObject:participant];
                }
            }
            if ([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
                ChatMO *chat = [ChatDBManager getChatWithID:chatId withMOC:moc];
                if (chat != nil) {
                    name = [chat getChatName];
                    type = chat.chat_type;
                } else {
                    if ([owner isEqualToString:[ConnectionProvider getUser]]) {
                        NSString *participant = ([[participants firstObject] isEqualToString:[ConnectionProvider getUser]]) ? [participants lastObject] : [participants firstObject];
                        type = CHAT_TYPE_ONE_TO_ONE_INVITER;
                        name = [FriendsDBManager getUserWithJID:participant moc:moc].name;
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
            NSLog(@"Degree: %@", degree);
            [ChatDBManager insertChatWithID:chatId chatName:name chatType:type participantString:participantString status:STATUS_JOINED degree:degree withContext:moc];
        }
        
        [delegate saveContextForBackgroundThread];
        
        dispatch_sync(mainQueue, ^{
            [ChatDBManager joinAllChats];
            XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
            for (NSString *username in participantsWithoutVCards) {
                [conn sendElement:[IQPacketManager createGetVCardPacket:username]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
        });
    }];
}

+ (NSString *)urlDecode:(NSString *)string {
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)urlencode:(NSString*)stringToEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[stringToEncode UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+(void)handleGetServerTimePacket:(XMPPIQ *)packet {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<utc>(.*?)<\\/utc>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:packet.XMLString options:0 range:NSMakeRange(0, packet.XMLString.length)];
    NSString *utcTime = [packet.XMLString substringWithRange:[match rangeAtIndex:1]];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:utcTime forKey:PACKET_ID_GET_SERVER_TIME];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_SERVER_TIME object:nil userInfo:userInfo];
}

+(void)handleGetVCardPacket:(XMPPIQ *)packet {
    NSString *firstName, *lastName, *itemName, *nickname;
    NSString *username = [[[packet fromStr] componentsSeparatedByString:@"@"] firstObject];
    NSArray *children = [packet children];
    for (int i = 0; i < children.count; i++) {
        NSArray *grand = [[children objectAtIndex:i] children];
        for (int j = 0; j < grand.count; j++) {
            itemName = [[grand objectAtIndex:j] name];
            if([itemName compare:VCARD_TAG_NICKNAME] == 0) {
                nickname = [[grand objectAtIndex:j] stringValue];
            } else if([itemName compare:@"N"] == 0) {
                NSArray *nameItems = [[grand objectAtIndex:j] children];
                for(int k = 0; k < nameItems.count; k++) {
                    itemName = [[nameItems objectAtIndex:k] name];
                    if ([itemName compare:VCARD_TAG_FIRST_NAME] == 0) {
                        firstName = [[nameItems objectAtIndex:k] stringValue];
                    } else if([itemName compare:VCARD_TAG_LAST_NAME] == 0) {
                        lastName = [[nameItems objectAtIndex:k] stringValue];
                    }
                }
            }
        }
    }
    if ([username compare:[ConnectionProvider getUser]] != 0) {
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        NSLog(@"Got VCard for User: %@", name);
        if ([FriendsDBManager hasUserWithJID:username]) {
            NSLog(@"Inserting Friend: %@", name);
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

+(void)handleGetPendingChatsPacket:(XMPPIQ *)packet {
    
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:packet];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)],
    *participants;
    NSString *participantString, *chatId, *type, *owner, *name, *createdTime;
    
    for(NSTextCheckingResult *match in matches) {
        participantString = [packetXML substringWithRange:[match rangeAtIndex:1]];
        chatId = [packetXML substringWithRange:[match rangeAtIndex:2]];
        type = [packetXML substringWithRange:[match rangeAtIndex:3]];
        owner = [packetXML substringWithRange:[match rangeAtIndex:4]];
        name = [self urlDecode:[packetXML substringWithRange:[match rangeAtIndex:5]]];
        createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
        participants = [participantString componentsSeparatedByString:@", "];
        
        [ChatDBManager insertChatWithID:chatId chatName:name chatType:type participantString:participantString status:STATUS_PENDING degree:@"1"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_PENDING_CHATS object:nil];
}

+(NSString*)getPacketXMLWithoutNewLines:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return packetXML;
}

+(NSString*)getPacketXMLWithoutWhiteSpace:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@" " withString:@""];
    return packetXML;
}

+(NSString*)getDecodedPacketXML:(XMPPIQ *)iq {
    NSString *ret = [self getPacketXMLWithoutWhiteSpace:iq];
    return [[ret stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(void)handleGetRosterPacket: (XMPPIQ *)iq {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate getManagedObjectContextForBackgroundThread];
    __block dispatch_queue_t mainQ = dispatch_get_main_queue();
    [moc performBlock:^{
        
        NSError *error = NULL;
        DDXMLElement *query = [[iq children] firstObject];
        NSArray *items = [query children];
        DDXMLElement *item;
        NSMutableArray *itemsWithoutVCard = [NSMutableArray array];
        NSMutableArray *itemsToSendSubscribedPacket = [NSMutableArray array];
        NSMutableArray *allItems = [NSMutableArray array];
        int numContactsAddedThroughBlacklist = 0;
        for (int i = 0; i < items.count; i++)
        {
            item = items[i];
            NSString *subscription = [[item attributeForName:@"subscription"] XMLString];
            //Parse jid
            NSString *jid = [[item attributeForName:@"jid"] XMLString] ;
            NSRegularExpression *regexJid = [NSRegularExpression regularExpressionWithPattern:@"jid=\"(.*)@" options: 0 error:&error];
            NSTextCheckingResult *matchJid = [regexJid firstMatchInString:jid options:0 range:NSMakeRange(0,jid.length)];
            NSString *resultJid = [jid substringWithRange:[matchJid rangeAtIndex:1]];
            [allItems addObject:resultJid];
            if ([subscription rangeOfString:@"none"].location != NSNotFound){
                if ([FriendsDBManager insertWithMOC:moc
                                           username:resultJid
                                               name:nil
                                              email:nil
                                             status:[NSNumber numberWithInt:STATUS_REQUESTED]
                                searchedPhoneNumber:nil
                                      searchedEmail:nil
                                                uid:nil])
                {
                    [itemsWithoutVCard addObject:resultJid];
                }
            }
            else
            {
                if([subscription rangeOfString:@"to"].location != NSNotFound)
                {
                    [itemsToSendSubscribedPacket addObject:resultJid];
                }
                if ([FriendsDBManager insertWithMOC:moc
                                           username:resultJid
                                               name:nil
                                              email:nil
                                             status:[NSNumber numberWithInt:STATUS_FRIENDS]
                                searchedPhoneNumber:nil
                                      searchedEmail:nil
                                                uid:nil])
                {
                    numContactsAddedThroughBlacklist++;
                    [itemsWithoutVCard addObject:resultJid];
                }
                
            }
        }
        [delegate saveContextForBackgroundThread];
        dispatch_sync(mainQ, ^{
            ConnectionProvider *cp = [ConnectionProvider getInstance];
            XMPPStream *conn = [cp getConnection];
            /*if (cp.shouldAlertUserWithAddedFriends)
            {
                [cp setShouldAlertUserWithAddedFriends:NO];
                if ([allItems count] > 0)
                {
                    NSString *message = ([allItems count] > 1) ? @"Friends": @"Friend";
                    NSString *message2 = ([allItems count] > 1) ? @"have": @"has";
                    
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:[NSString stringWithFormat:@"%d %@ %@ been added to your friends list.", [allItems count], message, message2]
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                }
            }*/
            for (NSString *username in itemsWithoutVCard)
            {
                [conn sendElement:[IQPacketManager createGetVCardPacket:username]];
            }
            for (NSString *username in itemsToSendSubscribedPacket)
            {
                [conn sendElement:[IQPacketManager createSubscribedPacket:username]];
            }
        });
    }];
}

+(void)handleInviteUserToChatPacket:(XMPPIQ*)iq {
}

+(void)handleCreateOneToOneChatPacket:(XMPPIQ*)iq {
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
}

+(void)handleGetSessionIDPacket:(XMPPIQ*)iq {
    NSLog(@"Handling get session id packet");
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<value>(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate setSessionID:[iq.XMLString substringWithRange:[match rangeAtIndex:1]]];
    NSString *degree = [UserDefaultManager getThoughtDegree];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createGetConfessionsPacketWithDegree:degree]];
    if ([UserDefaultManager hasSentBlacklist] == NO) {
        [[[ContactSearchManager alloc] init] accessContacts];
        [UserDefaultManager setSentBlacklistTrue];
    }
}

+(void)handleGetConfessionsPacket:(XMPPIQ *)iq {
    NSLog(@"Got Confessions Packet: %@", iq.XMLString);
    NSString *decodedPacketXML = [self getPacketXMLWithoutWhiteSpace:iq];
    //decodedPacketXML = [self getDecodedPacketXML:iq];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\"(.*?)\",\"(.*?)\",\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",\"(.*?)\"\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:decodedPacketXML options:0 range:NSMakeRange(0, decodedPacketXML.length)];
    NSString *confessionID, *jid, *body, *imageURL, *timestamp, *favoritedUsers, *degree;
    NSNumber *favoriteCount;
    NSMutableArray *favoritedUsersArray;
    Confession *confession;
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    [confessionsManager clearConfessions];
    
    for(NSTextCheckingResult *match in matches) {
        confessionID = [decodedPacketXML substringWithRange:[match rangeAtIndex:1]];
        jid = [decodedPacketXML substringWithRange:[match rangeAtIndex:2]];
        body = [decodedPacketXML substringWithRange:[match rangeAtIndex:3]];
        if ([match rangeAtIndex:4].length != 0) {
            imageURL = [decodedPacketXML substringWithRange:[match rangeAtIndex:4]];
        }
        timestamp = [decodedPacketXML substringWithRange:[match rangeAtIndex:5]];
        if ([match rangeAtIndex:6].length != 0) {
            favoritedUsers = [decodedPacketXML substringWithRange:[match rangeAtIndex:6]];
        }
        if ([match rangeAtIndex:7].length != 0) {
            favoriteCount = [NSNumber numberWithInteger:[[decodedPacketXML substringWithRange:[match rangeAtIndex:7]] integerValue]];
        }
        
        degree = [decodedPacketXML substringWithRange:[match rangeAtIndex:8]];
        
        if (favoriteCount != nil && [favoriteCount isEqualToNumber:[NSNumber numberWithInt:0]] == FALSE) {
            favoritedUsers = [favoritedUsers stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            favoritedUsersArray = [NSMutableArray arrayWithArray:[favoritedUsers componentsSeparatedByString:@","]];
        } else {
            favoritedUsersArray = [[NSMutableArray alloc] init];
        }
        if (!(imageURL.length > 0) || [imageURL isEqualToString:@"null"]) {
            imageURL = @"g1398792552";
        }
        body = [[body stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        confession = [Confession create:body posterJID:jid imageURL:imageURL confessionID:confessionID createdTimestamp:timestamp degreeOfConnection:degree favoritedUsers:favoritedUsersArray];
        [confessionsManager addConfession:confession];
    }
    
    [confessionsManager sortConfessions];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_CONFESSIONS object:nil];
}

+(void)handleGetMyConfessionsPacket:(XMPPIQ *)iq {
    
}

+(void)handleToggleFavoriteConfessionPacket:(XMPPIQ *)iq {
}

+(void)handlePostConfessionPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<value>(.*?),(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    NSString *confessionID = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
    NSString *createdTimestamp = [iq.XMLString substringWithRange:[match rangeAtIndex:2]];
    [[ConfessionsManager getInstance] updatePendingConfession:confessionID timestamp:createdTimestamp];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_POST_CONFESSION object:nil];
}

+(void)handleCreateOneToOneChatFromConfessionPacket:(XMPPIQ *)iq {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
}

+(void)handleCreatedMUCPacket:(XMPPIQ *)iq {
}

@end
