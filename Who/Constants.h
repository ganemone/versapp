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
extern NSString *const PACKET_ID_CREATE_ONE_TO_ONE_CHAT;
extern NSString *const PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION;
extern NSString *const PACKET_ID_JOIN_MUC;
extern NSString *const PACKET_ID_GET_CONFIGURATION_FORM;
extern NSString *const PACKET_ID_GET_LAST_TIME_ACTIVE;
extern NSString *const PACKET_ID_GET_SERVER_TIME;
extern NSString *const PACKET_ID_GET_CHAT_PARTICIPANTS;
extern NSString *const PACKET_ID_GET_CHAT_INFO;
extern NSString *const PACKET_ID_DESTROY_CHAT;
extern NSString *const PACKET_ID_INVITE_USER_TO_CHAT;
extern NSString *const PACKET_ID_ACCEPT_CHAT_INVITE;
extern NSString *const PACKET_ID_DENY_CHAT_INVITE;
extern NSString *const PACKET_ID_GET_VCARD;
extern NSString *const PACKET_ID_GET_SESSION_ID;
extern NSString *const PACKET_ID_GET_CONFESSIONS;
extern NSString *const PACKET_ID_POST_CONFESSION;
extern NSString *const PACKET_ID_FAVORITE_CONFESSION;
extern NSString *const PACKET_ID_GET_MY_CONFESSIONS;
extern NSString *const PACKET_ID_DESTROY_CONFESSION;
extern NSString *const PACKET_ID_FORCE_CREATE_ROSTER_ENTRY;
extern NSString *const PACKET_ID_SEARCH_FOR_USERS;
extern NSString *const PACKET_ID_SEARCH_FOR_USER;

extern NSString *const VCARD_TAG_FULL_NAME;
extern NSString *const VCARD_TAG_FIRST_NAME;
extern NSString *const VCARD_TAG_LAST_NAME;
extern NSString *const VCARD_TAG_USERNAME;
extern NSString *const VCARD_TAG_NICKNAME;
extern NSString *const VCARD_TAG_EMAIL;
extern NSString *const USER_DEFAULTS_PASSWORD;

extern NSString *const CHAT_TYPE_GROUP;
extern NSString *const CHAT_TYPE_ONE_TO_ONE;
extern NSString *const MESSAGE_TYPE_HEADLINE;

extern NSString *const MESSAGE_PROPERTY_BODY;
extern NSString *const MESSAGE_PROPERTY_SENDER_ID;
extern NSString *const MESSAGE_PROPERTY_TIMESTAMP;
extern NSString *const MESSAGE_PROPERTY_GROUP_ID;
extern NSString *const MESSAGE_PROPERTY_THREAD;
extern NSString *const MESSAGE_PROPERTY_GROUP_TYPE;
extern NSString *const MESSAGE_PROPERTY_RECEIVER_ID;
extern NSString *const MESSAGE_PROPERTY_ONE_TO_ONE_TYPE;
extern NSString *const MESSAGE_PROPERTY_IMAGE_LINK;
extern NSString *const MESSAGE_PROPERTY_INVITATION_MESSAGE;
extern NSString *const DICTIONARY_KEY_MESSAGE_OBJECT;

extern NSString *const NOTIFICATION_MUC_MESSAGE_RECEIVED;
extern NSString *const NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED;
extern NSString *const NOTIFICATION_STREAM_DID_DISCONNECT;
extern NSString *const NOTIFICATION_UPDATE_CHAT_LIST;
extern NSString *const NOTIFICATION_CREATED_MUC;
extern NSString *const NOTIFICATION_FINISHED_INVITING_MUC_USERS;
extern NSString *const NOTIFICATION_FINISHED_INVITING_ONE_TO_ONE_USERS;

extern NSString *const APPLICATION_RESOURCE;

extern NSString *const SEGUE_ID_AUTHENTICATED;
extern NSString *const SEGUE_ID_GROUP_CONVERSATION;
extern NSString *const SEGUE_ID_ONE_TO_ONE_CONVERSATION;
extern NSString *const SEGUE_ID_CREATED_MUC;
extern NSString *const SEGUE_ID_CREATED_CHAT;
extern NSString *const SEGUE_ID_GROUP_VIEW_IMAGE;
extern NSString *const SEGUE_ID_ONE_TO_ONE_VIEW_IMAGE;
extern NSString *const SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION;
extern NSString *const SEGUE_ID_COMPOSE_CONFESSION;
extern NSString *const SEGUE_ID_SETTINGS;
extern NSString *const SEGUE_ID_GO_TO_LOGIN_PAGE;
extern NSString *const SEGUE_ID_FROM_REGISTER_TO_LOGIN;

extern NSString *const CELL_ID_CONVERSATION_PROTOTYPE;
extern NSString *const CELL_ID_FRIENDS_PROTOTYPE;

extern NSString *const USER_STATUS_PENDING;
extern NSString *const USER_STATUS_FRIENDS;
extern NSString *const USER_STATUS_REGISTERED;
extern NSString *const USER_STATUS_REJECTED;
extern NSString *const USER_STATUS_UNREGISTERED;
extern NSString *const PACKET_ID_ROSTER;

extern NSString *const CORE_DATA_TABLE_MESSAGES;
extern NSString *const CORE_DATA_TABLE_FRIENDS;
extern NSString *const CORE_DATA_TABLE_CHATS;

extern NSString *const FRIENDS_TABLE_COLUMN_NAME_USERNAME;
extern NSString *const FRIENDS_TABLE_COLUMN_NAME_NAME;
extern NSString *const FRIENDS_TABLE_COLUMN_NAME_STATUS;
extern NSString *const FRIENDS_TABLE_COLUMN_NAME_EMAIL;
extern NSString *const FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER;
extern NSString *const FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL;

extern NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_ID;
extern NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_NAME;
extern NSString *const CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME;
extern NSString *const CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE;
extern NSString *const CHATS_TABLE_COLUMN_NAME_STATUS;
extern NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_TYPE;
extern NSString *const CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING;

extern int const STATUS_FRIENDS;
extern int const STATUS_REGISTERED;
extern int const STATUS_PENDING;
extern int const STATUS_REJECTED;
extern int const STATUS_UNREGISTERED;
extern int const STATUS_REQUESTED;
extern int const STATUS_INVITED;

extern int const STATUS_JOINED;
extern int const STATUS_REQUEST_PENDING;
extern int const STATUS_INACTIVE;
extern int const STATUS_REQUEST_REJECTED;

extern NSString *const INVITATION_ACCEPT;
extern NSString *const INVITATION_DECLINE;
extern NSString *const NOTIFICATIONS_GROUP;
extern NSString *const NOTIFICATIONS_FRIEND;

extern NSString *const SETTING_CHANGE_EMAIL;
extern NSString *const SETTING_CHANGE_PASSWORD;
extern NSString *const SETTING_LEAVE_GROUPS;
extern NSString *const SETTING_LOGOUT;
extern NSString *const SETTING_SUPPORT;
extern NSString *const SETTING_PRIVACY;
extern NSString *const SETTING_TERMS;

extern NSString *const STORYBOARD_ID_PAGE_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_NOTIFICATIONS_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_DASHBOARD_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_SWIPE_VIEW_CONTROLLER;
extern NSString *const STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER;

extern NSString *const PAGE_NAVIGATE_TO_MESSAGES;
extern NSString *const PAGE_NAVIGATE_TO_CONFESSIONS;
extern NSString *const PAGE_NAVIGATE_TO_FRIENDS;
extern NSString *const PAGE_NAVIGATE_TO_CONTACTS;

extern NSString *const UPDATE_CONTACTS_VIEW;

extern NSString *const REPORT_BLOCK;
extern NSString *const REPORT_ABUSE;
extern NSString *const REPORT_CONFIRM_BLOCK;
extern NSString *const REPORT_CONFIRM_ABUSE;

@end
