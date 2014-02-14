//
//  IQPacketManager.h
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXMLElement.h"
#import "Message.h"

@interface IQPacketManager : NSObject

+(DDXMLElement*)createGetRosterPacket;

+(DDXMLElement*)createGetJoinedChatsPacket;

+(DDXMLElement*)createGetPendingChatsPacket;

+(DDXMLElement*)createGetChatInfoPacket:(NSString*)chatId;

+(DDXMLElement*)createGetChatParticipantsPacket:(NSString*)chatId;

+(DDXMLElement*)createDestroyChatPacket:(NSString*)chatId;

+(DDXMLElement*)createInviteToChatPacket:(NSString*)chatId invitedUsername: (NSString*)invitedUsername;

+(DDXMLElement*)createAcceptChatInvitePacket:(NSString*)chatId;

+(DDXMLElement*)createDenyChatInvitePacket:(NSString*)chatId;

+(DDXMLElement*)createJoinMUCPacket:(NSString*)chatID lastTimeActive: (NSString*)lastTimeActive;

+(DDXMLElement*)createCreateMUCPacket:(NSString*)chatID roomName:(NSString*)roomName;

+(DDXMLElement*)createRegisterUserPacket:(NSString*)username password:(NSString*)password;

+(DDXMLElement*)createCreateVCardPacket:(NSString*)firstName lastname:(NSString*)lastName phone:(NSString*)phone email:(NSString*)email;

+(DDXMLElement *)createUpdateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName phone:(NSString *)phone email:(NSString *)email;

+(DDXMLElement*)createGetLastTimeActivePacket;

+(DDXMLElement*)createGetServerTimePacket;

+(DDXMLElement*)createSendMUCMessagePacket:(Message*)message;

+(DDXMLElement*)createSendOneToOneMessagePacket:(Message*)message;

+(DDXMLElement*)createAvailabilityPresencePacket;

+(DDXMLElement*)createGetVCardPacket:(NSString*)username;

+(DDXMLElement *)createGetConnectedUserVCardPacket;

+(DDXMLElement *)createRoomConfigurationForm:(NSString*)groupName;

+(DDXMLElement *)createInviteToMUCMessage:(NSString*)chatID username:(NSString*)username;

+(DDXMLElement *)createCreateOneToOneChatPacket:(NSString*)chatID roomName:(NSString*)roomName;

+(DDXMLElement *)createGetSessionIDPacket;

@end
