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
NSString *const PACKET_ID_CREATE_ONE_TO_ONE_CHAT = @"packet_id_create_one_to_one_chat";
NSString *const PACKET_ID_GET_CONFIGURATION_FORM = @"packet_id_get_configuration_form";
NSString *const PACKET_ID_JOIN_MUC = @"packet_id_join_muc";
NSString *const PACKET_ID_GET_LAST_TIME_ACTIVE = @"packet_id_get_last_time_active";
NSString *const PACKET_ID_GET_SERVER_TIME = @"packet_id_get_server_time";
NSString *const PACKET_ID_GET_CHAT_PARTICIPANTS = @"packet_id_get_chat_participants";
NSString *const PACKET_ID_GET_CHAT_INFO = @"packet_id_get_chat_info";
NSString *const PACKET_ID_DESTROY_CHAT = @"packet_id_destroy_chat";
NSString *const PACKET_ID_INVITE_USER_TO_CHAT = @"packet_id_invite_user_to_chat";
NSString *const PACKET_ID_ACCEPT_CHAT_INVITE = @"packet_id_accept_chat_invite";
NSString *const PACKET_ID_DENY_CHAT_INVITE = @"packet_id_deny_chat_invite";
NSString *const PACKET_ID_GET_VCARD = @"packet_id_get_vcard";
NSString *const PACKET_ID_GET_SESSION_ID = @"packet_id_get_session_id";
NSString *const PACKET_ID_GET_CONFESSIONS = @"packet_id_get_confessions";
NSString *const PACKET_ID_POST_CONFESSION = @"packet_id_post_confession";
NSString *const PACKET_ID_FAVORITE_CONFESSION = @"packet_id_favorite_confession";
NSString *const PACKET_ID_GET_MY_CONFESSIONS = @"packet_id_get_my_confessions";

NSString *const VCARD_TAG_FULL_NAME = @"FN";
NSString *const VCARD_TAG_FIRST_NAME = @"GIVEN";
NSString *const VCARD_TAG_LAST_NAME = @"FAMILY";
NSString *const VCARD_TAG_USERNAME = @"USERNAME";
NSString *const VCARD_TAG_NICKNAME = @"NICKNAME";
NSString *const VCARD_TAG_EMAIL = @"EMAIL";

NSString *const CHAT_TYPE_GROUP = @"groupchat";
NSString *const CHAT_TYPE_ONE_TO_ONE = @"chat";
NSString *const MESSAGE_TYPE_HEADLINE = @"headline";

NSString *const MESSAGE_PROPERTY_BODY = @"message_body";
NSString *const MESSAGE_PROPERTY_SENDER_ID = @"sender_id";
NSString *const MESSAGE_PROPERTY_TIMESTAMP = @"time";
NSString *const MESSAGE_PROPERTY_GROUP_ID = @"group_id";
NSString *const MESSAGE_PROPERTY_THREAD_ID = @"thread";
NSString *const MESSAGE_PROPERTY_GROUP_TYPE = @"group_chat_message_property";
NSString *const MESSAGE_PROPERTY_ONE_TO_ONE_TYPE = @"one_to_one_message";
NSString *const MESSAGE_PROPERTY_RECEIVER_ID = @"receiver_id";
NSString *const MESSAGE_PROPERTY_IMAGE_LINK = @"image_link";
NSString *const MESSAGE_PROPERTY_INVITATION_MESSAGE = @"CHAT_ID";

NSString *const NOTIFICATION_MUC_MESSAGE_RECEIVED = @"notification_muc_message_received";
NSString *const NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED = @"notification_one_to_one_message_received";
NSString *const NOTIFICATION_ADMIN_AUTHENTICATED = @"notification_admin_authenticated";
NSString *const NOTIFICATION_STREAM_DID_DISCONNECT = @"notification_stream_did_disconnect";
NSString *const NOTIFICATION_UPDATE_CHAT_LIST = @"notification_update_chat_list";
NSString *const NOTIFICATION_CREATED_MUC = @"notification_created_muc";
NSString *const NOTIFICATION_FINISHED_INVITING_MUC_USERS = @"notification_finished_inviting_muc_users";
NSString *const NOTIFICATION_FINISHED_INVITING_ONE_TO_ONE_USERS = @"notification_finished_inviting_one_to_one_users";

NSString *const APPLICATION_RESOURCE = @"who";

NSString *const SEGUE_ID_AUTHENTICATED = @"SegueIDAuthenticated";
NSString *const SEGUE_ID_GROUP_CONVERSATION = @"SegueGroupConversation";
NSString *const SEGUE_ID_ONE_TO_ONE_CONVERSATION = @"SegueOneToOneConversation";
NSString *const SEGUE_ID_CREATED_MUC = @"SegueIdentifierCreatedMUC";
NSString *const SEGUE_ID_CREATED_CHAT = @"SegueIdentifierCreatedChat";
NSString *const SEGUE_ID_GROUP_VIEW_IMAGE = @"SegueIDGroupViewImage";
NSString *const SEGUE_ID_ONE_TO_ONE_VIEW_IMAGE = @"SegueIDOneToOneViewImage";

NSString *const CELL_ID_CONVERSATION_PROTOTYPE = @"ConversationCellPrototype";
NSString *const CELL_ID_FRIENDS_PROTOTYPE = @"FriendsCellPrototype";

NSString *const USER_STATUS_PENDING = @"user_status_pending";
NSString *const USER_STATUS_FRIENDS = @"user_status_friends";
NSString *const USER_STATUS_REGISTERED = @"user_status_registered";
NSString *const USER_STATUS_REJECTED = @"user_status_rejected";
NSString *const USER_STATUS_UNREGISTERED = @"user_status_unregistered";

NSString *const CORE_DATA_TABLE_MESSAGES = @"MessageMO";
NSString *const CORE_DATA_TABLE_FRIENDS = @"FriendMO";

NSString *const FRIENDS_TABLE_COLUMN_NAME_USERNAME = @"username";
NSString *const FRIENDS_TABLE_COLUMN_NAME_NAME = @"name";
NSString *const FRIENDS_TABLE_COLUMN_NAME_STATUS = @"status";
NSString *const FRIENDS_TABLE_COLUMN_NAME_EMAIL = @"email";

int const STATUS_FRIENDS = 0;
int const STATUS_REGISTERED = 1;
int const STATUS_PENDING = 2;
int const STATUS_REJECTED = 3;
int const STATUS_UNREGISTERED = 4;

NSString *const INVITATION_ACCEPT = @"a";
NSString *const INVITATION_DECLINE = @"d";

NSString *const SETTING_CHANGE_EMAIL = @"change_email";
NSString *const SETTING_CHANGE_PASSWORD = @"change_password";
NSString *const SETTING_LEAVE_GROUPS = @"leave_groups";
NSString *const SETTING_LOGOUT = @"logout";
NSString *const SETTING_SUPPORT = @"info_support";
NSString *const SETTING_PRIVACY = @"info_privacy";
NSString *const SETTING_TERMS = @"info_terms";

NSString *const STORYBOARD_ID_PAGE_VIEW_CONTROLLER = @"MainPageViewController";
NSString *const STORYBOARD_ID_NOTIFICATIONS_VIEW_CONTROLLER = @"NotificationsViewController";
NSString *const STORYBOARD_ID_DASHBOARD_VIEW_CONTROLLER = @"DashboardViewController";
NSString *const STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER = @"FriendsViewController";
NSString *const STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER = @"ContactsViewController";
NSString *const STORYBOARD_ID_SWIPE_VIEW_CONTROLLER = @"MainSwipeViewController";
NSString *const STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER = @"ConfessionsViewController";

@end
