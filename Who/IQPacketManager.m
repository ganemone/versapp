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
#import "MessageMO.h"
#import "ChatDBManager.h"
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
    DDXMLElement *query = [DDXMLElement elementWithName:@"status" stringValue:@"active"];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_JOINED_CHATS children:query];
    NSLog(@"Create Get Joined Chats Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createGetPendingChatsPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"status" stringValue:@"pending"];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_PENDING_CHATS children:query];
    NSLog(@"Create Get Pending Chats Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createGetChatInfoPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"get" action:@"get_chat" packetID:PACKET_ID_GET_CHAT_INFO chatID:chatId];
}

+(DDXMLElement *)createGetChatParticipantsPacket:(NSString *)chatId {
    [ChatDBManager setChatIDUpdatingParticipants:chatId];
    DDXMLElement *query = [DDXMLElement elementWithName:@"participants"];
    [query addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:chatId]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_CHAT_PARTICIPANTS children:query];
    NSLog(@"Create Get Pending Chats Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createDestroyChatPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"set" action:@"destroy" packetID:PACKET_ID_DESTROY_CHAT chatID:chatId];
}

+(DDXMLElement *)createInviteToChatPacket:(NSString *)chatId invitedUsername:(NSString *)invitedUsername {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"user_id" stringValue:invitedUsername]];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"pending"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_INVITE_USER_TO_CHAT children:query];
    NSLog(@"Create Invite to Chat Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createAcceptChatInvitePacket:(NSString *)chatId {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"active"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_ACCEPT_CHAT_INVITE children:query];
    NSLog(@"Create Accept Chat Invite Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createDenyChatInvitePacket:(NSString *)chatId {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"inactive"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_DENY_CHAT_INVITE children:query];
    NSLog(@"Create Invite to Chat Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createLeaveChatPacket:(NSString *)chatId {
    return [self createDenyChatInvitePacket:chatId];
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
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_NICKNAME stringValue:[NSString stringWithFormat:@"%@ %@", firstName, lastName]]];
    
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

+(DDXMLElement *)createCreateMUCPacket:(NSString*)chatID roomName:(NSString*)roomName participants:(NSArray*)participants {
    
    DDXMLElement *create = [DDXMLElement elementWithName:@"create"],
    *chatIDElement = [DDXMLElement elementWithName:@"id" stringValue:chatID],
    *name = [DDXMLElement elementWithName:@"name" stringValue:roomName],
    *owner = [DDXMLElement elementWithName:@"owner_id" stringValue:[ConnectionProvider getUser]],
    *type = [DDXMLElement elementWithName:@"type" stringValue:CHAT_TYPE_GROUP],
    *participantsElement = [DDXMLElement elementWithName:@"participants"];
    
    for (NSString *participant in participants) {
        [participantsElement addChild:[DDXMLNode elementWithName:@"participant" stringValue:participant]];
    }
    
    [create addChild:chatIDElement];
    [create addChild:name];
    [create addChild:owner];
    [create addChild:type];
    [create addChild:participantsElement];
    
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_CREATE_MUC children:create];
    NSLog(@"Create Muc Packet \n\n %@", iq.XMLString);
    return iq;
}



+(DDXMLElement *)createCreateOneToOneChatPacket:(NSString*)chatID invitedUser:(NSString*)invitedUser roomName:(NSString*)roomName {
    DDXMLElement *create = [DDXMLElement elementWithName:@"create"],
    *chatIDElement = [DDXMLElement elementWithName:@"id" stringValue:chatID],
    *name = [DDXMLElement elementWithName:@"name" stringValue:roomName],
    *owner = [DDXMLElement elementWithName:@"owner_id" stringValue:[ConnectionProvider getUser]],
    *type = [DDXMLElement elementWithName:@"type" stringValue:CHAT_TYPE_ONE_TO_ONE],
    *participantsElement = [DDXMLElement elementWithName:@"participants"];
    
    [participantsElement addChild:[DDXMLNode elementWithName:@"participant" stringValue:invitedUser]];
    
    [create addChild:chatIDElement];
    [create addChild:name];
    [create addChild:owner];
    [create addChild:type];
    [create addChild:participantsElement];
    
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT children:create];
    NSLog(@"Create One To One Chat Packet \n\n %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createCreateOneToOneChatFromConfessionPacket:(Confession*)confession chatID:(NSString*)chatID {
    DDXMLElement *create = [DDXMLElement elementWithName:@"create"],
    *chatIDElement = [DDXMLElement elementWithName:@"id" stringValue:chatID],
    *name = [DDXMLElement elementWithName:@"name" stringValue:confession.body],
    *owner = [DDXMLElement elementWithName:@"owner_id" stringValue:@"server"],
    *type = [DDXMLElement elementWithName:@"type" stringValue:CHAT_TYPE_ONE_TO_ONE],
    *participantsElement = [DDXMLElement elementWithName:@"participants"];
    NSString *invitedID = [[confession.posterJID componentsSeparatedByString:@"@"] firstObject];

    [participantsElement addChild:[DDXMLNode elementWithName:@"participant" stringValue:invitedID]];
    
    [create addChild:chatIDElement];
    [create addChild:name];
    [create addChild:owner];
    [create addChild:type];
    [create addChild:participantsElement];
    
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION children:create];
    NSLog(@"Create Chat From Confession Packet \n\n %@", iq.XMLString);
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

+(DDXMLElement *)createSendMUCMessagePacket:(MessageMO *)message {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_GROUP to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", message.group_id, [ConnectionProvider getConferenceIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];
    
    DDXMLElement *properties = [self createMessagePropertiesElement:message chatID:message.group_id];
    
    DDXMLElement *groupChatProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *groupChatPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_GROUP_TYPE];
    DDXMLElement *groupChatPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:@"true"];
    [groupChatPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [groupChatProperty addChild:groupChatPropertyName];
    [groupChatProperty addChild:groupChatPropertyValue];
    
    DDXMLElement *receiverIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *receiverIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_RECEIVER_ID];
    DDXMLElement *receiverIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@", message.group_id, [ConnectionProvider getConferenceIPAddress]]];
    [receiverIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [receiverIDProperty addChild:receiverIDPropertyName];
    [receiverIDProperty addChild:receiverIDPropertyValue];
    
    [properties addChild:groupChatProperty];
    [properties addChild:receiverIDProperty];
    
    [messagePacket addBody:message.message_body];
    [messagePacket addThread:message.group_id];
    [messagePacket addChild:properties];
    
    
    NSLog(@"Message XML: %@", messagePacket.XMLString);
    return messagePacket;
}

+(DDXMLElement *)createSendOneToOneMessagePacket:(MessageMO *)message {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_ONE_TO_ONE to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", message.receiver_id, [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];
    DDXMLElement *properties = [self createMessagePropertiesElement:message chatID:message.group_id];
    
    DDXMLElement *receiverIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *receiverIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_RECEIVER_ID];
    DDXMLElement *receiverIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:message.receiver_id];
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
    
    [messagePacket addBody: message.message_body];
    [messagePacket addThread:message.group_id];
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

+(DDXMLElement *)createMessagePropertiesElement:(MessageMO *)message chatID:(NSString*)chatID {
    DDXMLElement *properties = [DDXMLElement elementWithName:@"properties"];
    [properties addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"]];
    
    DDXMLElement *senderProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *senderName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_SENDER_ID];
    DDXMLElement *senderValue = [DDXMLElement elementWithName:@"value" stringValue:message.sender_id];
    [senderValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [senderProperty addChild:senderName];
    [senderProperty addChild:senderValue];
    
    DDXMLElement *groupIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *groupIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_GROUP_ID];
    DDXMLElement *groupIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:chatID];
    [groupIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [groupIDProperty addChild:groupIDPropertyName];
    [groupIDProperty addChild:groupIDPropertyValue];
    
    if (message.image_link != nil) {
        DDXMLElement *imageLinkProperty = [DDXMLElement elementWithName:@"property"];
        DDXMLElement *imageLinkPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_IMAGE_LINK];
        DDXMLElement *imageLinkPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:message.image_link];
        [imageLinkPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
        [imageLinkProperty addChild:imageLinkPropertyName];
        [imageLinkProperty addChild:imageLinkPropertyValue];
        [properties addChild:imageLinkProperty];
    }
    
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

+(DDXMLElement *)createGetSessionIDPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:session"]];
    
	DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_SESSION_ID]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",[ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
	[iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createGetConfessionsPacket {

    DDXMLElement *since = [DDXMLElement elementWithName:@"since" stringValue:@"0"];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"get" packetID:PACKET_ID_GET_CONFESSIONS children:since];
    NSLog(@"Get Confessions Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createPostConfessionPacket:(Confession *)confession {
    [confession encodeBody];
    
    DDXMLElement *create = [DDXMLElement elementWithName:@"create"];
    [create addChild:[DDXMLNode elementWithName:@"body" stringValue:confession.body]];
    [create addChild:[DDXMLNode elementWithName:@"image_url" stringValue:confession.imageURL]];
    
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_POST_CONFESSION children:create];
    NSLog(@"Posting Confession Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createToggleFavoriteConfessionPacket:(NSString *)confessionID {
    DDXMLElement *toggleFavorite = [DDXMLElement elementWithName:@"toggle_favorite"];
    [toggleFavorite addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:confessionID]];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_POST_CONFESSION children:toggleFavorite];
    NSLog(@"Toggle Favorite Confession Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createGetMyConfessionsPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:confession"]];
    
    DDXMLElement *confession = [DDXMLElement elementWithName:@"confession"];
    [confession addAttribute:[DDXMLNode attributeWithName:@"action" stringValue:@"mine"]];
    [query addChild:confession];
    
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_MY_CONFESSIONS]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];
    [iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createDestroyConfessionPacket:(NSString*)confessionID {
    DDXMLElement *destroy = [DDXMLElement elementWithName:@"destroy"];
    [destroy addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:confessionID]];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_POST_CONFESSION children:destroy];
    NSLog(@"Destroy Confession Packet: %@", iq.XMLString);
    return iq;
}

+(DDXMLElement *)createForceCreateRosterEntryPacket:(NSString *)jid {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
	[query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"]];
    
    DDXMLElement *item = [DDXMLElement elementWithName:@"item"];
    [item addAttribute:[DDXMLNode attributeWithName:@"jid" stringValue:jid]];
    [item addAttribute:[DDXMLNode attributeWithName:@"name" stringValue:@"nickname"]];
    [item addAttribute:[DDXMLNode attributeWithName:@"subscription" stringValue:@"both"]];
    
    DDXMLElement *contactItem = [DDXMLElement elementWithName:@"groups" stringValue:@"Contacts"];
    
    [item addChild:contactItem];
    [query addChild:item];
    
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_FORCE_CREATE_ROSTER_ENTRY]];
	[iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    //[iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];
    [iq addChild:query];
    
    return iq;
}

+(DDXMLElement *)createUserSearchPacketWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray*)emails {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_SEARCH_FOR_USERS]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue: [self getPacketFromString]]];
    
    DDXMLElement *search = [DDXMLElement elementWithName:@"search"];
    [search addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:search"]];
    
    DDXMLElement *contacts = [DDXMLElement elementWithName:@"contacts"];
    for (int i = 0; i < [phoneNumbers count]; i++) {
        DDXMLElement *contact = [DDXMLElement elementWithName:@"contact"],
        *phone = [DDXMLElement elementWithName:@"phone" stringValue:[phoneNumbers objectAtIndex:i]],
        *email = [DDXMLElement elementWithName:@"email" stringValue:[emails objectAtIndex:i]];
        [contact addChild:phone];
        [contact addChild:email];
        [contacts addChild:contact];
    }
    
    [search addChild:contacts];
    [iq addChild:search];
    
    NSLog(@"User search packet: %@", iq.XMLString);
    return iq;
}

// ---------------------
// Helper Packet Methods
// ---------------------
+(DDXMLElement*)getWhoChatIQElementWithType:(NSString*)type packetID: (NSString*)packetID children:(DDXMLElement*)element {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"],
    *chat = [DDXMLElement elementWithName:@"chat"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from"
                                      stringValue:[NSString stringWithFormat:@"%@@%@",[ConnectionProvider getUser],[ConnectionProvider getServerIPAddress]]]];
    
    [chat addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:chat"]];
    [chat addChild:element];
    
    [iq addChild:chat];
    return iq;
}

+(DDXMLElement*)getWhoConfessionIQElementWithType:(NSString*)type packetID: (NSString*)packetID children:(DDXMLElement*)element {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"],
    *chat = [DDXMLElement elementWithName:@"confession"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue: [self getPacketFromString]]];
    
    [chat addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:confession"]];
    [chat addChild:element];
    
    [iq addChild:chat];
    return iq;
}

+(NSString *)getPacketFromString {
    return [NSString stringWithFormat:@"%@@%@",[ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
}

@end
