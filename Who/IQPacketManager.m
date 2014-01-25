//
//  IQPacketManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "IQPacketManager.h"
#import "XMPPIQ.h"
#import "ConnectionProvider.h"
#import "Constants.h"

@implementation IQPacketManager

-(XMPPIQ*)buildIQPacket:(NSString *)packetType packetID:(NSString *)packetID {
    return [[XMPPIQ alloc] initWithType:@"register" elementID:@"registering_user"];
}

-(void)setPacketProperty:(XMPPIQ*)packet packetProperty:(NSString*)packetProperty packetPropertyValue:(NSString*)packetPropertyValue {
    [packet setValue:packetProperty forKey:packetPropertyValue];
}

-(void)logPacket:(XMPPIQ*)packet {
    NSLog(@"Packet: %@", [packet XMLString]);
}

+(DDXMLElement *)createGetJoinedChatsPacket {
    return [self createWhoIQPacket:@"get" action:@"joined" packetID:PACKET_ID_GET_JOINED_CHATS];
}

+(DDXMLElement *)createGetPendingChatsPacket {
    return [self createWhoIQPacket:@"get" action:@"pending" packetID:PACKET_ID_GET_PENDING_CHATS];
}

+(DDXMLElement *)createGetChatInfoPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"get" action:@"get_chat" packetID:PACKET_ID_GET_CHAT_INFO chatID:chatId];
}

+(DDXMLElement *)createGetChatParticipantsPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"get" action:@"get_participants" packetID:PACKET_ID_GET_CHAT_PARTICIPANTS chatID:chatId];
}

+(DDXMLElement *)createDestroyChatPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"set" action:@"destroy" packetID:PACKET_ID_DESTROY_CHAT chatID:chatId];
}

+(DDXMLElement *)createInviteToChatPacket:(NSString *)chatId invitedUsername:(NSString *)invitedUsername {
    NSDictionary *properties = [NSDictionary dictionaryWithObject:invitedUsername forKey:@"invited_username"];
    return [self createWhoIQPacket:@"set" action:@"participant_insert" packetID:PACKET_ID_INVITE_USER_TO_CHAT chatID:chatId properties:properties];
}

+(DDXMLElement *)createAcceptChatInvitePacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"set" action:@"participant_join" packetID:PACKET_ID_ACCEPT_CHAT_INVITE chatID:chatId];
}

+(DDXMLElement *)createDenyChatInvitePacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"set" action:@"participant_leave" packetID:PACKET_ID_DENY_CHAT_INVITE chatID:chatId];
}

+(DDXMLElement*)createWhoIQPacket:(NSString*)type action:(NSString*)action packetID: (NSString*)packetID {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:chat"]];
    
    DDXMLElement *actionElement = [DDXMLElement elementWithName:@"chat"];
	[actionElement addAttribute:[DDXMLNode attributeWithName:@"action" stringValue:action]];
    
    [query addChild:actionElement];
	
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement*)createWhoIQPacket:(NSString*)type action:(NSString *)action packetID:(NSString *)packetID chatID:(NSString*)chatID {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:chat"]];
    
    DDXMLElement *actionElement = [DDXMLElement elementWithName:@"chat"];
    [actionElement addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:chatID]];
	[actionElement addAttribute:[DDXMLNode attributeWithName:@"action" stringValue:action]];
    
    
    [query addChild:actionElement];
	
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement*)createWhoIQPacket:(NSString*)type action:(NSString *)action packetID:(NSString *)packetID chatID:(NSString*)chatID properties:(NSDictionary*)properties {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:chat"]];
    
    DDXMLElement *actionElement = [DDXMLElement elementWithName:@"chat"];
    [actionElement addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:chatID]];
	[actionElement addAttribute:[DDXMLNode attributeWithName:@"action" stringValue:action]];
    for(NSString *key in [properties allKeys]) {
        [actionElement addAttribute:[DDXMLNode attributeWithName:key stringValue:[properties objectForKey:key]]];
    }
    
    [query addChild:actionElement];
	
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createGetRosterPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"]];
	
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_ROSTER]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createRegisterUserPacket:(NSString *)username password:(NSString *)password {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:register"]];
    
    [query addChild:[DDXMLElement elementWithName:@"username" stringValue:username]];
    [query addChild:[DDXMLElement elementWithName:@"password" stringValue:password]];
    
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_REGISTER_USER]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createCreateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName phone:(NSString *)phone email:(NSString *)email {
    DDXMLElement *query = [DDXMLElement elementWithName:@"vCard"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"vcard-temp"]];
    
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_FN stringValue:firstName]];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_LN stringValue:lastName]];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_USERNAME stringValue:phone]];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_EMAIL stringValue:email]];
    
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_CREATE_VCARD]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
	[iq addChild:query];
    
    return iq;
    
}

+(DDXMLElement *)createCreateMUCPacket:(NSString*)roomName {
    
    DDXMLElement *presence = [DDXMLElement elementWithName:@"presence"];
	//[iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[ConnectionProvider getServerIPAddress]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", roomName, [ConnectionProvider getConferenceIPAddress]]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_CREATE_MUC]];
    DDXMLElement *element = [DDXMLElement elementWithName:@"x"];
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc"]];
    
    [presence addChild:element];
    
    NSLog(@"Packet: %@", presence.XMLString);
    return presence;
}

+(DDXMLElement *)createJoinMUCPacket:(NSString *)chatID lastTimeActive:(NSString *)lastTimeActive {
    DDXMLElement *presence = [DDXMLElement elementWithName:@"presence"];
    [presence addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_JOIN_MUC]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@/%@", chatID, [ConnectionProvider getConferenceIPAddress], [ConnectionProvider getUser]]]];
    
    DDXMLElement *x = [DDXMLElement elementWithName:@"x"];
    [x addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc"]];
    
    DDXMLElement *history = [DDXMLElement elementWithName:@"history"];
    [history addAttribute:[DDXMLNode attributeWithName:@"since" stringValue:lastTimeActive]];
    
    [x addChild:history];
    [presence addChild:x];
    
    NSLog(@"Join MUC Packet: %@", presence.XMLString);
    
    return presence;
}

+(DDXMLElement *)createGetLastTimeActivePacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_LAST_TIME_ACTIVE]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:last"]];
    
    [iq addChild:query];
    NSLog(@"Get last time active: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createGetServerTimePacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_SERVER_TIME]];
    
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:time"]];
    
    [iq addChild:query];
    
    return iq;
}
@end
