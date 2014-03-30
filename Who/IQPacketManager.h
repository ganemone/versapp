//
//  IQPacketManager.h
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXMLElement.h"
#import "Confession.h"
#import "MessageMO.h"

@interface IQPacketManager : NSObject

+(DDXMLElement *)createUnsubscribedPacket:(NSString *)username;
+(DDXMLElement *)createSubscribePacket:(NSString*)username;
+(DDXMLElement *)createSubscribedPacket:(NSString*)username;
+(DDXMLElement *)createUnsubscribePacket:(NSString *)username;
+(DDXMLElement *)createGetRosterPacket;
+(DDXMLElement *)createGetJoinedChatsPacket;
+(DDXMLElement *)createGetPendingChatsPacket;
+(DDXMLElement *)createGetChatInfoPacket:(NSString*)chatId;
+(DDXMLElement *)createGetChatParticipantsPacket:(NSString*)chatId;
+(DDXMLElement *)createDestroyChatPacket:(NSString*)chatId;
+(DDXMLElement *)createInviteToChatPacket:(NSString*)chatId invitedUsername: (NSString*)invitedUsername;
+(DDXMLElement *)createAcceptChatInvitePacket:(NSString*)chatId;
+(DDXMLElement *)createDenyChatInvitePacket:(NSString*)chatId;
+(DDXMLElement *)createJoinMUCPacket:(NSString*)chatID lastTimeActive: (NSString*)lastTimeActive;
+(DDXMLElement *)createCreateMUCPacket:(NSString*)chatID roomName:(NSString*)roomName participants:(NSArray*)participants;
+(DDXMLElement *)createRegisterUserPacket:(NSString*)username password:(NSString*)password;
+(DDXMLElement *)createCreateVCardPacket:(NSString*)firstName lastname:(NSString*)lastName phone:(NSString*)phone email:(NSString*)email;
+(DDXMLElement *)createUpdateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName phone:(NSString *)phone email:(NSString *)email;
+(DDXMLElement *)createGetLastTimeActivePacket;
+(DDXMLElement *)createGetServerTimePacket;
+(DDXMLElement *)createSendMUCMessagePacket:(MessageMO *)message;
+(DDXMLElement *)createSendOneToOneMessagePacket:(MessageMO *)message;
+(DDXMLElement *)createAvailabilityPresencePacket;
+(DDXMLElement *)createGetVCardPacket:(NSString*)username;
+(DDXMLElement *)createGetConnectedUserVCardPacket;
+(DDXMLElement *)createRoomConfigurationForm:(NSString*)groupName;
+(DDXMLElement *)createInviteToMUCMessage:(NSString*)chatID username:(NSString*)username chatName:(NSString *)chatName;
+(DDXMLElement *)createCreateOneToOneChatPacket:(NSString*)chatID invitedUser:(NSString*)invitedUser roomName:(NSString*)roomName;
+(DDXMLElement *)createGetSessionIDPacket;
+(DDXMLElement *)createGetConfessionsPacket;
+(DDXMLElement *)createPostConfessionPacket:(Confession *)confession;
+(DDXMLElement *)createToggleFavoriteConfessionPacket:(NSString*)confessionID;
+(DDXMLElement *)createGetMyConfessionsPacket;
+(DDXMLElement *)createCreateOneToOneChatFromConfessionPacket:(Confession*)confession chatID:(NSString *)chatID;
+(DDXMLElement *)createForceCreateRosterEntryPacket:(NSString *)jid;
+(DDXMLElement *)createLeaveChatPacket:(NSString *)chatId;
+(DDXMLElement *)createExitRoomPacket:(NSString *)chatId;
+(DDXMLElement *)createDestroyConfessionPacket:(NSString*)confessionID;
+(DDXMLElement *)createUserSearchPacketWithSearchParam:(NSString *)searchParam;
+(DDXMLElement *)createUserSearchPacketWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray*)emails personIDS:(NSArray *)personIDS;
+(DDXMLElement *)createBlockImplicitUserPacket:(NSString *)username;
+(DDXMLElement *)createBlockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID;
+(DDXMLElement *)createUnblockImplicitUser:(NSString *)username;
+(DDXMLElement *)createUnblockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID;

@end
