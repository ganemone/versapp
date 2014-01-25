//
//  Constants.m
//  Who
//
//  Created by Giancarlo Anemone on 1/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//


// IMPORTANT - May need to be added to the applications target so it is linked to the final product. Source - Stackoverflow.
#import "Constants.h"

@implementation Constants

NSString *const PACKET_ID_GET_ROSTER = @"packet_id_get_roster";
NSString *const PACKET_ID_GET_JOINED_CHATS = @"packet_id_get_joined_chats";
NSString *const PACKET_ID_GET_PENDING_CHATS = @"packet_id_get_pending_chats";
NSString *const PACKET_ID_REGISTER_USER = @"packet_id_register_user";
NSString *const PACKET_ID_CREATE_VCARD = @"packet_id_create_vcard";
NSString *const PACKET_ID_CREATE_MUC = @"packet_id_create_muc";
NSString *const PACKET_ID_JOIN_MUC = @"packet_id_join_muc";
NSString *const PACKET_ID_GET_LAST_TIME_ACTIVE = @"packet_id_get_last_time_active";
NSString *const PACKET_ID_GET_SERVER_TIME = @"packet_id_get_server_time";
NSString *const PACKET_ID_GET_CHAT_PARTICIPANTS = @"packet_id_get_chat_participants";
NSString *const PACKET_ID_GET_CHAT_INFO = @"packet_id_get_chat_info";
NSString *const PACKET_ID_DESTROY_CHAT = @"packet_id_destroy_chat";
NSString *const PACKET_ID_INVITE_USER_TO_CHAT = @"packet_id_invite_user_to_chat";
NSString *const PACKET_ID_ACCEPT_CHAT_INVITE = @"packet_id_accept_chat_invite";
NSString *const PACKET_ID_DENY_CHAT_INVITE = @"packet_id_deny_chat_invite";

NSString *const VCARD_TAG_FN = @"FN";
NSString *const VCARD_TAG_LN = @"LN";
NSString *const VCARD_TAG_USERNAME = @"USERNAME";
NSString *const VCARD_TAG_EMAIL = @"EMAIL";

NSString *const CHAT_TYPE_GROUP = @"groupchat";
NSString *const CHAT_TYPE_ONE_TO_ONE = @"chat";

NSString *const MESSAGE_PROPERTY_SENDER_ID = @"sender_id";
NSString *const MESSAGE_PROPERTY_TIMESTAMP = @"time";

NSString *const NOTIFICATION_UPDATE_DASHBOARD_LISTVIEW = @"notification_update_dashboard_listview";

NSString *const APPLICATION_RESOURCE = @"who";

@end
