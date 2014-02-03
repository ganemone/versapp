//
//  Constants.h
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const PACKET_ID_GET_ROSTER;
extern NSString *const PACKET_ID_GET_JOINED_CHATS;
extern NSString *const PACKET_ID_GET_PENDING_CHATS;
extern NSString *const PACKET_ID_REGISTER_USER;
extern NSString *const PACKET_ID_CREATE_VCARD;
extern NSString *const PACKET_ID_CREATE_MUC;
extern NSString *const PACKET_ID_JOIN_MUC;
extern NSString *const PACKET_ID_GET_LAST_TIME_ACTIVE;
extern NSString *const PACKET_ID_GET_SERVER_TIME;
extern NSString *const PACKET_ID_GET_CHAT_PARTICIPANTS;
extern NSString *const PACKET_ID_GET_CHAT_INFO;
extern NSString *const PACKET_ID_DESTROY_CHAT;
extern NSString *const PACKET_ID_INVITE_USER_TO_CHAT;
extern NSString *const PACKET_ID_ACCEPT_CHAT_INVITE;
extern NSString *const PACKET_ID_DENY_CHAT_INVITE;

extern NSString *const VCARD_TAG_FN;
extern NSString *const VCARD_TAG_LN;
extern NSString *const VCARD_TAG_USERNAME;
extern NSString *const VCARD_TAG_EMAIL;

extern NSString *const CHAT_TYPE_GROUP;
extern NSString *const CHAT_TYPE_ONE_TO_ONE;

extern NSString *const MESSAGE_PROPERTY_SENDER_ID;
extern NSString *const MESSAGE_PROPERTY_TIMESTAMP;
extern NSString *const MESSAGE_PROPERTY_GROUP_ID;
extern NSString *const MESSAGE_PROPERTY_THREAD;
extern NSString *const MESSAGE_PROPERTY_GROUP_TYPE;
extern NSString *const MESSAGE_PROPERTY_RECEIVER_ID;
extern NSString *const MESSAGE_PROPERTY_ONE_TO_ONE_TYPE;

extern NSString *const NOTIFICATION_UPDATE_DASHBOARD_LISTVIEW;

extern NSString *const APPLICATION_RESOURCE;

extern NSString *const SEGUE_ID_GROUP_CONVERSATION;
extern NSString *const SEGUE_ID_ONE_TO_ONE_CONVERSATION;

extern NSString *const CELL_ID_CONVERSATION_PROTOTYPE;
extern NSString *const CELL_ID_FRIENDS_PROTOTYPE;

extern NSString *const USER_STATUS_PENDING;
extern NSString *const USER_STATUS_FRIENDS;
extern NSString *const USER_STATUS_REGISTERED;
extern NSString *const USER_STATUS_REJECTED;
extern NSString *const USER_STATUS_UNREGISTERED;
extern NSString *const PACKET_ID_ROSTER;


@end
