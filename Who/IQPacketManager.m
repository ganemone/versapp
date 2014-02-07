//
//  IQPacketManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "IQPacketManager.h"
#import "XMPPIQ.h"
#import "XMPPPresence.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "OneToOneChatManager.h"

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
    DDXMLElement *element = [self createWhoIQPacket:@"set" action:@"participant_join" packetID:PACKET_ID_ACCEPT_CHAT_INVITE chatID:chatId];
    NSLog(@"Accept Packet: %@",element.XMLString);
    return element;
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
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
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
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
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
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@",[ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    //[iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
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
    
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_FULL_NAME stringValue:[NSString stringWithFormat:@"%@ %@", firstName, lastName]]];
    
    DDXMLElement *nTag = [DDXMLElement elementWithName:@"N"];
    [nTag addChild:[DDXMLElement elementWithName:VCARD_TAG_FIRST_NAME stringValue:firstName]];
    [nTag addChild:[DDXMLElement elementWithName:VCARD_TAG_LAST_NAME stringValue:lastName]];
    
    [query addChild:nTag];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_USERNAME stringValue:phone]];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_EMAIL stringValue:email]];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_USERNAME stringValue:firstName]];
    
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_CREATE_VCARD]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
	[iq addChild:query];
    
    NSLog(@"VCard Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createUpdateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName phone:(NSString *)phone email:(NSString *)email {
    return [self createCreateVCardPacket:firstName lastname:lastName phone:phone email:email];
}

+(DDXMLElement *)createCreateMUCPacket:(NSString*)chatID roomName:(NSString*)roomName {
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:roomName, @"name", [ConnectionProvider getUser], @"owner_id", CHAT_TYPE_GROUP, @"type", nil];
    DDXMLElement *iq = [IQPacketManager createWhoIQPacket:@"set" action:@"create" packetID:PACKET_ID_CREATE_MUC chatID:chatID properties:properties];
    NSLog(@"PACKET: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createCreateOneToOneChatPacket:(NSString*)chatID roomName:(NSString*)roomName {
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:roomName, @"name", [ConnectionProvider getUser], @"owner_id", CHAT_TYPE_ONE_TO_ONE, @"type", nil];
    DDXMLElement *iq = [IQPacketManager createWhoIQPacket:@"set" action:@"create" packetID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT chatID:chatID properties:properties];
    NSLog(@"PACKET: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createMUCConfigurationFormRequestPacket:(NSString*)roomName {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@/%@", roomName, [ConnectionProvider getConferenceIPAddress], [ConnectionProvider getUser]]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_CONFIGURATION_FORM]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    
    DDXMLElement *element = [DDXMLElement elementWithName:@"query"];
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#owner"]];
    
    [iq addChild:element];
    
    NSLog(@"Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createJoinMUCPacket:(NSString *)chatID lastTimeActive:(NSString *)lastTimeActive {
    NSLog(@"Requesting History Since: %@", lastTimeActive);
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

+(DDXMLElement *)createSendMUCMessagePacket:(Message *)message {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_GROUP to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", message.chatID, [ConnectionProvider getConferenceIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];

    DDXMLElement *properties = [self createMessagePropertiesElement:message];
    
    DDXMLElement *groupChatProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *groupChatPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_GROUP_TYPE];
    DDXMLElement *groupChatPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:@"true"];
    [groupChatPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [groupChatProperty addChild:groupChatPropertyName];
    [groupChatProperty addChild:groupChatPropertyValue];

    DDXMLElement *receiverIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *receiverIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_RECEIVER_ID];
    DDXMLElement *receiverIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@", message.chatID, [ConnectionProvider getConferenceIPAddress]]];
    [receiverIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [receiverIDProperty addChild:receiverIDPropertyName];
    [receiverIDProperty addChild:receiverIDPropertyValue];
    
    [properties addChild:groupChatProperty];
    [properties addChild:receiverIDProperty];

    [messagePacket addBody:message.body];
    [messagePacket addThread:message.chatID];
    [messagePacket addChild:properties];

    
    NSLog(@"Message XML: %@", messagePacket.XMLString);
    return messagePacket;
}

+(DDXMLElement *)createSendOneToOneMessagePacket:(Message *)message {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_ONE_TO_ONE to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", message.messageTo, [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];
    DDXMLElement *properties = [self createMessagePropertiesElement:message];
    
    DDXMLElement *receiverIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *receiverIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_RECEIVER_ID];
    DDXMLElement *receiverIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:message.messageTo];
    [receiverIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [receiverIDProperty addChild:receiverIDPropertyName];
    [receiverIDProperty addChild:receiverIDPropertyValue];
    
    DDXMLElement *oneToOneChatProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *oneToOneChatPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_ONE_TO_ONE_TYPE];
    DDXMLElement *oneToOneChatPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:@"true"];
    [oneToOneChatPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [oneToOneChatProperty addChild:oneToOneChatPropertyName];
    [oneToOneChatProperty addChild:oneToOneChatPropertyValue];
    
    [properties addChild:receiverIDProperty];
    [properties addChild:oneToOneChatProperty];
    
    [messagePacket addBody: message.body];
    [messagePacket addThread:message.chatID];
    [messagePacket addChild:properties];
    
    NSLog(@"Message: %@", messagePacket.XMLString);
    return messagePacket;
}

+(DDXMLElement *)createInviteToMUCMessage:(NSString*)chatID username:(NSString*)username {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_ONE_TO_ONE to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addBody:@"empty"];
    [messagePacket addThread:@"must_be_here"];
    
    DDXMLElement *properties = [DDXMLElement elementWithName:@"properties"];
    [properties addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"]];
    
    DDXMLElement *chatIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *chatIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_INVITATION_MESSAGE];
    DDXMLElement *chatIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:chatID];
    [chatIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [chatIDProperty addChild:chatIDPropertyName];
    [chatIDProperty addChild:chatIDPropertyValue];
    
    [properties addChild:chatIDProperty];
    [messagePacket addChild:properties];
    
    return messagePacket;
}

+(DDXMLElement *)createMessagePropertiesElement:(Message *)message {
    DDXMLElement *properties = [DDXMLElement elementWithName:@"properties"];
    [properties addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"]];
    
    DDXMLElement *senderProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *senderName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_SENDER_ID];
    DDXMLElement *senderValue = [DDXMLElement elementWithName:@"value" stringValue:message.sender];
    [senderValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [senderProperty addChild:senderName];
    [senderProperty addChild:senderValue];
    
    DDXMLElement *groupIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *groupIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_GROUP_ID];
    DDXMLElement *groupIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:message.chatID];
    [groupIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [groupIDProperty addChild:groupIDPropertyName];
    [groupIDProperty addChild:groupIDPropertyValue];
    
    [properties addChild:senderProperty];
    [properties addChild:groupIDProperty];
    
    return properties;
}

+(DDXMLElement *)createAvailabilityPresencePacket {
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    return presence;
}

+(DDXMLElement *)createGetVCardPacket:(NSString*)username {
    DDXMLElement *vcard = [self createGetConnectedUserVCardPacket];
    [vcard addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]]]];
    return vcard;
}

+(DDXMLElement *)createGetConnectedUserVCardPacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_VCARD]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    
    DDXMLElement *query = [DDXMLElement elementWithName:@"vCard"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"vcard-temp"]];
    
    [iq addChild:query];
    return iq;
}

+(DDXMLElement *)createRoomConfigurationForm:(NSString*)groupName {
    DDXMLElement *configurationElement = [DDXMLElement elementWithName:@"x"];
    [configurationElement addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:x:data"]];
    
    DDXMLElement *roomNameField = [DDXMLElement elementWithName:@"field"];
    DDXMLElement *roomDescField = [DDXMLElement elementWithName:@"field"];
    DDXMLElement *persistentRoom = [DDXMLElement elementWithName:@"field"];
    DDXMLElement *allowInvites = [DDXMLElement elementWithName:@"field"];
    
    [roomNameField addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"text-single"]];
    [roomDescField addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"text-single"]];
    [persistentRoom addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"boolean"]];
    [allowInvites addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"boolean"]];
    
    [roomNameField addAttribute:[DDXMLNode attributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"]];
    [roomDescField addAttribute:[DDXMLNode attributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"]];
    [persistentRoom addAttribute:[DDXMLNode attributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"]];
    [allowInvites addAttribute:[DDXMLNode attributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"]];
    
    [roomNameField addChild:[DDXMLNode elementWithName:@"value" stringValue:groupName]];
    [roomDescField addChild:[DDXMLNode elementWithName:@"value" stringValue:groupName]];
    [persistentRoom addChild:[DDXMLNode elementWithName:@"value" stringValue:@"1"]];
    [allowInvites addChild:[DDXMLNode elementWithName:@"value" stringValue:@"1"]];
    
    [configurationElement addChild:roomNameField];
    [configurationElement addChild:roomDescField];
    [configurationElement addChild:persistentRoom];
    [configurationElement addChild:allowInvites];
    
    return configurationElement;
    
}

@end
