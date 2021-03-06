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
#import "ChatDBManager.h"
#import "UserDefaultManager.h"

@implementation IQPacketManager

- (XMPPIQ *)buildIQPacket:(NSString *)packetType packetID:(NSString *)packetID {
    return [[XMPPIQ alloc] initWithType:@"register" elementID:@"registering_user"];
}

+ (DDXMLElement *)createRemoveFriendPacket:(NSString *)username {
    DDXMLElement *packet = [DDXMLElement elementWithName:@"iq"];
    [packet addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [packet addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_REMOVE_FRIEND]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"]];

    DDXMLElement *item = [DDXMLElement elementWithName:@"item"];
    [item addAttribute:[DDXMLNode attributeWithName:@"jid" stringValue:[IQPacketManager getJIDFromUsername:username]]];
    [item addAttribute:[DDXMLNode attributeWithName:@"subscription" stringValue:@"remove"]];

    [query addChild:item];
    [packet addChild:query];

    return packet;
}

+ (NSString *)getJIDFromUsername:(NSString *)username {
    return [NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]];
}

+ (DDXMLElement *)createPresencePacketToUser:(NSString *)username withType:(NSString *)type {
    DDXMLElement *presence = [DDXMLElement elementWithName:@"presence"];
    [presence addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    return presence;
}

+ (DDXMLElement *)createUnsubscribedPacket:(NSString *)username {
    return [self createPresencePacketToUser:username withType:@"unsubscribed"];
}

+ (DDXMLElement *)createUnsubscribePacket:(NSString *)username {
    return [self createPresencePacketToUser:username withType:@"unsubscribe"];
}

+ (DDXMLElement *)createSubscribePacket:(NSString *)username {
    return [self createPresencePacketToUser:username withType:@"subscribe"];
}

+ (DDXMLElement *)createSubscribedPacket:(NSString *)username {
    return [self createPresencePacketToUser:username withType:@"subscribed"];
}

+ (DDXMLElement *)createGetJoinedChatsPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"status" stringValue:@"active"];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_JOINED_CHATS children:query];
    return iq;
}

+ (DDXMLElement *)createGetPendingChatsPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"status" stringValue:@"pending"];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_PENDING_CHATS children:query];
    return iq;
}

+ (DDXMLElement *)createGetChatInfoPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"get" action:@"get_chat" packetID:PACKET_ID_GET_CHAT_INFO chatID:chatId];
}

+ (DDXMLElement *)createGetChatParticipantsPacket:(NSString *)chatId {
    [ChatDBManager setChatIDUpdatingParticipants:chatId];
    DDXMLElement *query = [DDXMLElement elementWithName:@"participants"];
    [query addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:chatId]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"get" packetID:PACKET_ID_GET_CHAT_PARTICIPANTS children:query];
    return iq;
}

+ (DDXMLElement *)createDestroyChatPacket:(NSString *)chatId {
    return [self createWhoIQPacket:@"set" action:@"destroy" packetID:PACKET_ID_DESTROY_CHAT chatID:chatId];
}

+ (DDXMLElement *)createInviteToChatPacket:(NSString *)chatId invitedUsername:(NSString *)invitedUsername {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"user_id" stringValue:invitedUsername]];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"pending"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_INVITE_USER_TO_CHAT children:query];
    return iq;
}

+ (DDXMLElement *)createAcceptChatInvitePacket:(NSString *)chatId {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"active"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_ACCEPT_CHAT_INVITE children:query];
    return iq;
}

+ (DDXMLElement *)createDenyChatInvitePacket:(NSString *)chatId {
    DDXMLElement *query = [DDXMLElement elementWithName:@"participant"];
    [query addChild:[DDXMLNode elementWithName:@"chat_id" stringValue:chatId]];
    [query addChild:[DDXMLNode elementWithName:@"status" stringValue:@"inactive"]];
    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_DENY_CHAT_INVITE children:query];
    return iq;
}

+ (DDXMLElement *)createLeaveChatPacket:(NSString *)chatId {
    return [self createDenyChatInvitePacket:chatId];
}

+ (DDXMLElement *)createExitRoomPacket:(NSString *)chatId {
    DDXMLElement *presence = [DDXMLElement elementWithName:@"presence"];
    [presence addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", chatId, [ConnectionProvider getConferenceIPAddress]]]];
    [presence addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"unavailable"]];
    return presence;
}

+ (DDXMLElement *)createWhoIQPacket:(NSString *)type action:(NSString *)action packetID:(NSString *)packetID {
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

+ (DDXMLElement *)createWhoIQPacket:(NSString *)type action:(NSString *)action packetID:(NSString *)packetID chatID:(NSString *)chatID {
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

+ (DDXMLElement *)createGetRosterPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:roster"]];

    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_ROSTER]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    //[iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@",[ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    //[iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createRegisterUserPacket:(NSString *)username password:(NSString *)password {
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

+ (DDXMLElement *)createCreateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName {
    DDXMLElement *query = [DDXMLElement elementWithName:@"vCard"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"vcard-temp"]];

    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_FULL_NAME stringValue:[NSString stringWithFormat:@"%@ %@", firstName, lastName]]];

    DDXMLElement *nTag = [DDXMLElement elementWithName:@"N"];
    [nTag addChild:[DDXMLElement elementWithName:VCARD_TAG_FIRST_NAME stringValue:firstName]];
    [nTag addChild:[DDXMLElement elementWithName:VCARD_TAG_LAST_NAME stringValue:lastName]];

    [query addChild:nTag];
    [query addChild:[DDXMLElement elementWithName:VCARD_TAG_NICKNAME stringValue:[NSString stringWithFormat:@"%@ %@", firstName, lastName]]];

    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_CREATE_VCARD]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createUpdateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName {
    return [self createCreateVCardPacket:firstName lastname:lastName];
}

+ (DDXMLElement *)createCreateMUCPacket:(NSString *)chatID roomName:(NSString *)roomName participants:(NSArray *)participants {

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
    return iq;
}


+ (DDXMLElement *)createCreateOneToOneChatPacket:(NSString *)chatID invitedUser:(NSString *)invitedUser roomName:(NSString *)roomName {
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
    return iq;
}

+ (DDXMLElement *)createCreateOneToOneChatFromConfessionPacket:(Confession *)confession chatID:(NSString *)chatID {
    [confession encodeBody];
    DDXMLElement *create = [DDXMLElement elementWithName:@"create"],
            *chatIDElement = [DDXMLElement elementWithName:@"id" stringValue:chatID],
            *name = [DDXMLElement elementWithName:@"name" stringValue:confession.body],
            *owner = [DDXMLElement elementWithName:@"owner_id" stringValue:@"server"],
            *type = [DDXMLElement elementWithName:@"type" stringValue:CHAT_TYPE_ONE_TO_ONE],
            *participantsElement = [DDXMLElement elementWithName:@"participants"],
            *degree = [DDXMLElement elementWithName:@"degree" stringValue:confession.degree];

    NSString *invitedID = [[confession.posterJID componentsSeparatedByString:@"@"] firstObject];

    [participantsElement addChild:[DDXMLNode elementWithName:@"participant" stringValue:invitedID]];
    [create addChild:chatIDElement];
    [create addChild:name];
    [create addChild:owner];
    [create addChild:type];
    [create addChild:degree];
    [create addChild:participantsElement];

    DDXMLElement *iq = [self getWhoChatIQElementWithType:@"set" packetID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION children:create];
    [confession decodeBody];
    return iq;
}

+ (DDXMLElement *)createMUCConfigurationFormRequestPacket:(NSString *)roomName {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@/%@", roomName, [ConnectionProvider getConferenceIPAddress], [ConnectionProvider getUser]]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_CONFIGURATION_FORM]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];

    DDXMLElement *element = [DDXMLElement elementWithName:@"query"];
    [element addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#owner"]];

    [iq addChild:element];

    return iq;
}

+ (DDXMLElement *)createJoinMUCPacket:(NSString *)chatID lastTimeActive:(NSString *)lastTimeActive {
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


    return presence;
}

+ (DDXMLElement *)createGetLastTimeActivePacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_LAST_TIME_ACTIVE]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:last"]];

    [iq addChild:query];
    return iq;
}

+ (DDXMLElement *)createGetServerTimePacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_SERVER_TIME]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"jabber:iq:time"]];

    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createSendMUCMessagePacket:(MessageMO *)message {
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


    return messagePacket;
}

+ (DDXMLElement *)createSendOneToOneMessagePacket:(MessageMO *)message {
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

    [messagePacket addBody:message.message_body];
    [messagePacket addThread:message.group_id];
    [messagePacket addChild:properties];

    return messagePacket;
}

+ (DDXMLElement *)createInviteToMUCMessage:(NSString *)chatID username:(NSString *)username chatName:(NSString *)chatName {
    XMPPMessage *messagePacket = [XMPPMessage messageWithType:CHAT_TYPE_ONE_TO_ONE to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:@"null"]];
    [messagePacket addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    [messagePacket addBody:@""];
    [messagePacket addThread:@"must_be_here"];

    DDXMLElement *properties = [DDXMLElement elementWithName:@"properties"];
    [properties addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.jivesoftware.com/xmlns/xmpp/properties"]];

    DDXMLElement *chatIDProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *chatIDPropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_INVITATION_MESSAGE];
    DDXMLElement *chatIDPropertyValue = [DDXMLElement elementWithName:@"value" stringValue:chatID];

    DDXMLElement *chatNameProperty = [DDXMLElement elementWithName:@"property"];
    DDXMLElement *chatNamePropertyName = [DDXMLElement elementWithName:@"name" stringValue:MESSAGE_PROPERTY_GROUP_NAME];
    DDXMLElement *chatNamePropertyValue = [DDXMLElement elementWithName:@"value" stringValue:chatName];

    [chatIDPropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [chatIDProperty addChild:chatIDPropertyName];
    [chatIDProperty addChild:chatIDPropertyValue];

    [chatNamePropertyValue addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"string"]];
    [chatNameProperty addChild:chatNamePropertyName];
    [chatNameProperty addChild:chatNamePropertyValue];

    [properties addChild:chatNameProperty];
    [properties addChild:chatIDProperty];
    [messagePacket addChild:properties];

    return messagePacket;
}

+ (DDXMLElement *)createMessagePropertiesElement:(MessageMO *)message chatID:(NSString *)chatID {
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

+ (DDXMLElement *)createAvailabilityPresencePacket {
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    return presence;
}

+ (DDXMLElement *)createGetVCardPacket:(NSString *)username {
    DDXMLElement *vcard = [self createGetConnectedUserVCardPacket];
    [vcard addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", username, [ConnectionProvider getServerIPAddress]]]];
    return vcard;
}

+ (DDXMLElement *)createGetConnectedUserVCardPacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    //[iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@/%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress], APPLICATION_RESOURCE]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_VCARD]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"vCard"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"vcard-temp"]];

    [iq addChild:query];
    return iq;
}

+ (DDXMLElement *)createRoomConfigurationForm:(NSString *)groupName {
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

+ (DDXMLElement *)createGetSessionIDPacket {
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:session"]];

    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_SESSION_ID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];
    [iq addChild:query];
    return iq;
}

/*+(DDXMLElement *)createGetConfessionsPacketWithDegree:(NSString *)degree {

    DDXMLElement *since = [DDXMLElement elementWithName:@"since" stringValue:@"0"];
    DDXMLElement *degreeElement = [DDXMLElement elementWithName:@"degree" stringValue:degree];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"get" packetID:PACKET_ID_GET_CONFESSIONS children:since moreChilden:degreeElement];
    return iq;
}

+(DDXMLElement *)createGetConfessionsPacketWithDegree:(NSString *)degree since:(NSString *)sinceString {
    
    DDXMLElement *since = [DDXMLElement elementWithName:@"since" stringValue:sinceString];
    DDXMLElement *degreeElement = [DDXMLElement elementWithName:@"degree" stringValue:degree];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"get" packetID:PACKET_ID_GET_CONFESSIONS children:since moreChilden:degreeElement];
    return iq;
}*/

+ (DDXMLElement *)createPostConfessionPacket:(Confession *)confession {
    [confession encodeBody];

    DDXMLElement *create = [DDXMLElement elementWithName:@"create"];
    [create addChild:[DDXMLNode elementWithName:@"body" stringValue:confession.body]];
    [create addChild:[DDXMLNode elementWithName:@"image_url" stringValue:confession.imageURL]];

    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_POST_CONFESSION children:create];
    return iq;
}

+ (DDXMLElement *)createToggleFavoriteConfessionPacket:(NSString *)confessionID {
    DDXMLElement *toggleFavorite = [DDXMLElement elementWithName:@"toggle_favorite"];
    [toggleFavorite addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:confessionID]];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_FAVORITE_CONFESSION children:toggleFavorite];
    return iq;
}

+ (DDXMLElement *)createGetMyConfessionsPacket {
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

+ (DDXMLElement *)createDestroyConfessionPacket:(NSString *)confessionID {
    DDXMLElement *destroy = [DDXMLElement elementWithName:@"destroy"];
    [destroy addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:confessionID]];
    DDXMLElement *iq = [self getWhoConfessionIQElementWithType:@"set" packetID:PACKET_ID_DESTROY_CONFESSION children:destroy];
    return iq;
}

+ (DDXMLElement *)createForceCreateRosterEntryPacket:(NSString *)jid {
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

+ (DDXMLElement *)createUserSearchPacketWithSearchParam:(NSString *)searchParam {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_SEARCH_FOR_USER]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];

    DDXMLElement *search = [DDXMLElement elementWithName:@"search"];
    [search addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:search"]];

    DDXMLElement *contact = [DDXMLElement elementWithName:@"contact"];
    DDXMLElement *contacts = [DDXMLElement elementWithName:@"contacts"];
    NSString *phoneString, *emailString;
    if ([searchParam componentsSeparatedByString:@"@"].count > 1) {
        phoneString = @"";
        emailString = searchParam;
    } else {
        phoneString = searchParam;
        emailString = @"";
    }

    DDXMLElement *uid = [DDXMLElement elementWithName:@"id" stringValue:@"id"];
    DDXMLElement *phone = [DDXMLElement elementWithName:@"phone" stringValue:phoneString];
    DDXMLElement *email = [DDXMLElement elementWithName:@"email" stringValue:emailString];

    [contact addChild:phone];
    [contact addChild:email];
    [contact addChild:uid];
    [contacts addChild:contact];

    [search addChild:contacts];
    [iq addChild:search];

    return iq;
}

+ (DDXMLElement *)createUserSearchPacketWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails personIDS:(NSArray *)personIDS {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_SEARCH_FOR_USERS]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];

    DDXMLElement *search = [DDXMLElement elementWithName:@"search"];
    [search addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:search"]];

    DDXMLElement *contacts = [DDXMLElement elementWithName:@"contacts"];
    for (int i = 0; i < [phoneNumbers count]; i++) {
        DDXMLElement *contact = [DDXMLElement elementWithName:@"contact"],
                *uid = [DDXMLElement elementWithName:@"id" stringValue:[personIDS objectAtIndex:i]],
                *phone = [DDXMLElement elementWithName:@"phone" stringValue:[phoneNumbers objectAtIndex:i]],
                *email = [DDXMLElement elementWithName:@"email" stringValue:[emails objectAtIndex:i]];
        [contact addChild:phone];
        [contact addChild:email];
        [contact addChild:uid];
        [contacts addChild:contact];
    }

    [search addChild:contacts];
    [iq addChild:search];

    return iq;
}

+ (DDXMLElement *)createSetUserInfoPacketFromDefaults {
    NSString *countryCode = [UserDefaultManager loadCountryCode];
    NSString *phone = [UserDefaultManager loadPhone];
    NSString *email = [UserDefaultManager loadEmail];

    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_SET_USER_INFO]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:info"]];
    DDXMLElement *ccode = [DDXMLElement elementWithName:@"ccode" stringValue:countryCode];
    DDXMLElement *phoneElement = [DDXMLElement elementWithName:@"phone" stringValue:phone];
    DDXMLElement *emailElement = [DDXMLElement elementWithName:@"email" stringValue:email];
    [query addChild:ccode];
    [query addChild:phoneElement];
    [query addChild:emailElement];
    [iq addChild:query];
    return iq;
}

+ (DDXMLElement *)createGetUserInfoPacket {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_GET_USER_INFO]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"get"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:info"]];
    [iq addChild:query];
    return iq;
}

// ---------------------
// Reporting
// ---------------------
+ (DDXMLElement *)createReportOneToOneChatPacket:(NSString *)chat_id type:(NSString *)type {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:PACKET_ID_REPORT_ONE_TO_ONE];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"who:iq:report"];

    ChatMO *chat = [ChatDBManager getChatWithID:chat_id];

    NSString *username;
    for (NSString *jid in [chat getParticipantJIDS]) {
        if (![jid isEqualToString:[ConnectionProvider getUser]]) {
            username = jid;
        }
    }

    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"reported_username" stringValue:username];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"report_type" stringValue:type];
    DDXMLElement *objectElement = [DDXMLElement elementWithName:@"report_object" stringValue:@"chat"];

    NSString *metadata = [NSString stringWithFormat:@"ChatID: %@, Last Message: %@", chat_id, [chat getLastMessage]];
    DDXMLElement *metadataElement = [DDXMLElement elementWithName:@"report_metadata" stringValue:metadata];

    [query addChild:usernameElement];
    [query addChild:typeElement];
    [query addChild:objectElement];
    [query addChild:metadataElement];
    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createReportGroupChatPacket:(NSString *)chat_id type:(NSString *)type {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:PACKET_ID_REPORT_GROUP];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"who:iq:report"];

    ChatMO *chat = [ChatDBManager getChatWithID:chat_id];

    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"reported_username" stringValue:@""];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"report_type" stringValue:type];
    DDXMLElement *objectElement = [DDXMLElement elementWithName:@"report_object" stringValue:@"groupchat"];

    NSString *metadata = [NSString stringWithFormat:@"ChatID: %@, Last Message: %@", chat_id, [chat getLastMessage]];
    DDXMLElement *metadataElement = [DDXMLElement elementWithName:@"report_metadata" stringValue:metadata];

    [query addChild:usernameElement];
    [query addChild:typeElement];
    [query addChild:objectElement];
    [query addChild:metadataElement];
    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createReportMessageInGroupPacket:(NSString *)chat_id type:(NSString *)type message:(MessageMO *)message {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:PACKET_ID_REPORT_MESSAGE_IN_GROUP];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"who:iq:report"];

    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"reported_username" stringValue:message.sender_id];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"report_type" stringValue:type];
    DDXMLElement *objectElement = [DDXMLElement elementWithName:@"report_object" stringValue:@"groupchat_msg"];

    NSString *metadata = [NSString stringWithFormat:@"ChatID: %@, Reported Message: %@", chat_id, message.message_body];
    DDXMLElement *metadataElement = [DDXMLElement elementWithName:@"report_metadata" stringValue:metadata];

    [query addChild:usernameElement];
    [query addChild:typeElement];
    [query addChild:objectElement];
    [query addChild:metadataElement];
    [iq addChild:query];

    return iq;
}

+ (DDXMLElement *)createReportThoughtPacket:(Confession *)thought type:(NSString *)type {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:PACKET_ID_REPORT_THOUGHT];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]];

    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"who:iq:report"];

    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"reported_username" stringValue:thought.posterJID];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"report_type" stringValue:type];
    DDXMLElement *objectElement = [DDXMLElement elementWithName:@"report_object" stringValue:@"thought"];

    NSString *metadata = [NSString stringWithFormat:@"ThoughtID: %@, Thought: %@, Image: %@", thought.confessionID, thought.body, thought.imageURL];
    DDXMLElement *metadataElement = [DDXMLElement elementWithName:@"report_metadata" stringValue:metadata];

    [query addChild:usernameElement];
    [query addChild:typeElement];
    [query addChild:objectElement];
    [query addChild:metadataElement];
    [iq addChild:query];

    return iq;
}

// ---------------------
// Blocking
// ---------------------
+ (DDXMLElement *)createBlockImplicitUserPacket:(NSString *)username {
    return [self getBlockingPacketForUser:username blockingType:@"block" withType:BLOCKING_TYPE_IMPLICIT withID:PACKET_ID_BLOCK_IMPLICIT_USER];
}

+ (DDXMLElement *)createBlockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:block"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_UNBLOCK_USER_IN_GROUP]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];

    DDXMLElement *block = [DDXMLElement elementWithName:@"block"];
    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"username" stringValue:username];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"type" stringValue:BLOCKING_TYPE_GROUP];
    DDXMLElement *chatIDElement = [DDXMLElement elementWithName:@"chat_id" stringValue:chatID];

    [block addChild:chatIDElement];
    [block addChild:usernameElement];
    [block addChild:typeElement];
    [query addChild:block];
    [iq addChild:query];
    return iq;
}

+ (DDXMLElement *)createUnblockImplicitUser:(NSString *)username {
    return [self getBlockingPacketForUser:username blockingType:@"unblock" withType:BLOCKING_TYPE_IMPLICIT withID:PACKET_ID_UNBLOCK_IMPLICIT_USER];
}

+ (DDXMLElement *)createUnblockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:block"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_UNBLOCK_USER_IN_GROUP]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];

    DDXMLElement *block = [DDXMLElement elementWithName:@"unblock"];
    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"username" stringValue:username];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"type" stringValue:BLOCKING_TYPE_GROUP];
    DDXMLElement *chatIDElement = [DDXMLElement elementWithName:@"chat_id" stringValue:chatID];

    [block addChild:chatIDElement];
    [block addChild:usernameElement];
    [block addChild:typeElement];
    [query addChild:block];
    [iq addChild:query];
    return iq;
}

+ (DDXMLElement *)getBlockingPacketForUser:(NSString *)username blockingType:(NSString *)blockingType withType:(NSString *)type withID:(NSString *)packetID {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query"];
    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:block"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];

    DDXMLElement *block = [DDXMLElement elementWithName:blockingType];
    DDXMLElement *usernameElement = [DDXMLElement elementWithName:@"username" stringValue:username];
    DDXMLElement *typeElement = [DDXMLElement elementWithName:@"type" stringValue:type];
    [block addChild:usernameElement];
    [block addChild:typeElement];
    [query addChild:block];
    [iq addChild:query];
    return iq;
}

// ---------------------
// Helper Packet Methods
// ---------------------

+ (DDXMLElement *)getWhoChatIQElementWithType:(NSString *)type packetID:(NSString *)packetID children:(DDXMLElement *)element {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"],
            *chat = [DDXMLElement elementWithName:@"chat"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from"
                                      stringValue:[NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]]]];

    [chat addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:chat"]];
    [chat addChild:element];

    [iq addChild:chat];
    return iq;
}

+ (DDXMLElement *)getWhoConfessionIQElementWithType:(NSString *)type packetID:(NSString *)packetID children:(DDXMLElement *)element {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"],
            *chat = [DDXMLElement elementWithName:@"confession"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];

    [chat addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:confession"]];
    [chat addChild:element];

    [iq addChild:chat];
    return iq;
}

+ (DDXMLElement *)getWhoConfessionIQElementWithType:(NSString *)type packetID:(NSString *)packetID children:(DDXMLElement *)element moreChilden:(DDXMLElement *)moreChildren {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"],
            *chat = [DDXMLElement elementWithName:@"confession"];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:packetID]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:type]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];

    [chat addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:confession"]];
    [chat addChild:element];
    [chat addChild:moreChildren];

    [iq addChild:chat];
    return iq;
}

// ---------------------------------
// Device Token - Push Notifications
// ---------------------------------
+ (DDXMLElement *)createSetDeviceTokenPacket:(NSString *)deviceToken {
    DDXMLElement *iq = [DDXMLElement elementWithName:@"iq"];
    DDXMLElement *query = [DDXMLElement elementWithName:@"query" stringValue:deviceToken];
    [iq addAttribute:[DDXMLNode attributeWithName:@"id" stringValue:PACKET_ID_SET_DEVICE_TOKEN]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"set"]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:[ConnectionProvider getServerIPAddress]]];
    [iq addAttribute:[DDXMLNode attributeWithName:@"from" stringValue:[self getPacketFromString]]];

    [query addAttribute:[DDXMLNode attributeWithName:@"xmlns" stringValue:@"who:iq:token"]];
    [iq addChild:query];
    return iq;
}

+ (NSString *)getPacketFromString {
    return [NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
}

+ (NSString *)getPacketFromStringWithResource {
    return [NSString stringWithFormat:@"%@@%@/who", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
}


@end
