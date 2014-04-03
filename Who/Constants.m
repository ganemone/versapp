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
NSString *const PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION = @"packet_id_create_one_to_one_chat_from_confession";
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
NSString *const PACKET_ID_DESTROY_CONFESSION = @"packet_id_destroy_confession";
NSString *const PACKET_ID_FORCE_CREATE_ROSTER_ENTRY = @"packet_id_force_create_roster";
NSString *const PACKET_ID_SEARCH_FOR_USERS = @"packet_id_search_for_users";
NSString *const PACKET_ID_SEARCH_FOR_USER = @"packet_id_search_for_user";
NSString *const PACKET_ID_GET_USER_INFO = @"packet_id_get_user_info";
NSString *const PACKET_ID_SET_USER_INFO = @"packet_id_set_user_info";

NSString *const VCARD_TAG_FULL_NAME = @"FN";
NSString *const VCARD_TAG_FIRST_NAME = @"GIVEN";
NSString *const VCARD_TAG_LAST_NAME = @"FAMILY";
NSString *const VCARD_TAG_USERNAME = @"USERNAME";
NSString *const VCARD_TAG_NICKNAME = @"NICKNAME";
NSString *const VCARD_TAG_EMAIL = @"EMAIL";

NSString *const USER_DEFAULTS_PASSWORD = @"password";
NSString *const USER_DEFAULTS_VALID = @"validated";
NSString *const USER_DEFAULTS_COUNTRY = @"country";
NSString *const USER_DEFAULTS_USERNAME = @"nsdefault_key_username";
NSString *const USER_DEFAULTS_COUNTRY_CODE = @"nsdefault_key_country_code";
NSString *const USER_DEFAULTS_EMAIL = @"nsdefault_key_email";
NSString *const USER_DEFAULTS_PHONE = @"nsdefault_key_phone";
NSString *const USER_DEFAULTS_DEVICE_ID = @"nsdefault_key_device_id";

NSString *const CHAT_TYPE_GROUP = @"groupchat";
NSString *const CHAT_TYPE_ONE_TO_ONE = @"chat";
NSString *const CHAT_TYPE_ONE_TO_ONE_INVITER = @"one_to_one_inviter";
NSString *const CHAT_TYPE_ONE_TO_ONE_INVITED = @"one_to_one_invited";
NSString *const CHAT_TYPE_ONE_TO_ONE_CONFESSION = @"one_to_one_confession";
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
NSString *const MESSAGE_PROPERTY_GROUP_NAME = @"group_name";

NSString *const DICTIONARY_KEY_MESSAGE_OBJECT = @"message";
NSString *const DICTIONARY_KEY_ID = @"id";
NSString *const DICTIONARY_KEY_ERROR_CODE = @"dictionary_key_error_code";
NSString *const DICTIONARY_KEY_ERROR_MESSAGE = @"dictionary_key_error_message";

NSString *const NOTIFICATION_MUC_MESSAGE_RECEIVED = @"notification_muc_message_received";
NSString *const NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED = @"notification_one_to_one_message_received";
NSString *const NOTIFICATION_STREAM_DID_DISCONNECT = @"notification_stream_did_disconnect";
NSString *const NOTIFICATION_UPDATE_CHAT_LIST = @"notification_update_chat_list";
NSString *const NOTIFICATION_CREATED_MUC = @"notification_created_muc";
NSString *const NOTIFICATION_FINISHED_INVITING_MUC_USERS = @"notification_finished_inviting_muc_users";
NSString *const NOTIFICATION_FINISHED_INVITING_ONE_TO_ONE_USERS = @"notification_finished_inviting_one_to_one_users";
NSString *const NOTIFICATION_DISABLE_SWIPE = @"notification_disable_swipe";
NSString *const NOTIFICATION_ENABLE_SWIPE = @"notification_enable_swipe";
NSString *const NOTIFICATION_LOGOUT = @"notification_logout";
NSString *const NOTIFICATION_AUTHENTICATED = @"authenticated";
NSString *const NOTIFICATION_FAILED_TO_AUTHENTICATE = @"didNotAuthenticate";
NSString *const NOTIFICATION_CURRENT_GROUP_MEMBERS = @"notification_current_muc_members";
NSString *const NOTIFICATION_UPDATE_NOTIFICATIONS = @"notification_update_notifications";
NSString *const NOTIFICATION_UPDATE_FRIENDS = @"notification_update_friends";
NSString *const NOTIFICATION_ENABLE_DASHBOARD_EDITING = @"notification_enable_dashboard_editing";
NSString *const NOTIFICATION_DISABLE_DASHBOARD_EDITING = @"notification_disable_dashboard_editing";
NSString *const NOTIFICATION_FINISHED_REGISTERING_NAME = @"notification_finished_registering_name";
NSString *const NOTIFICATION_FINISHED_REGISTERING_PHONE = @"notification_finished_registering_phone";
NSString *const NOTIFICATION_FINISHED_REGISTERING_USERNAME = @"notification_finished_registering_username";
NSString *const NOTIFICATION_DID_REGISTER_USER = @"notification_did_register_user";
NSString *const NOTIFICATION_DID_FAIL_TO_REGISTER_USER = @"notification_did_fail_to_register_user";
NSString *const NOTIFICATION_PHONE_AVAILABLE = @"notification_phone_available";
NSString *const NOTIFICATION_PHONE_UNAVAILABLE = @"notification_phone_unavailable";
NSString *const NOTIFICATION_CONFESSION_DELETED = @"notification_confession_deleted";
NSString *const NOTIFICATION_SENT_VERIFICATION_TEXT = @"notification_sent_verification_text";
NSString *const NOTIFICATION_FAILED_TO_SEND_VERIFICATION_TEXT = @"notification_failed_to_send_verification_text";
NSString *const NOTIFICATION_DID_VERIFY_PHONE = @"notification_did_verify_phone";

NSString *const APPLICATION_RESOURCE = @"who";

NSString *const SEGUE_ID_AUTHENTICATED = @"SegueIDAuthenticated";
NSString *const SEGUE_ID_CONFIRMED = @"SegueIDConfirmed";
NSString *const SEGUE_ID_GROUP_CONVERSATION = @"SegueGroupConversation";
NSString *const SEGUE_ID_ONE_TO_ONE_CONVERSATION = @"SegueOneToOneConversation";
NSString *const SEGUE_ID_CREATED_MUC = @"SegueIdentifierCreatedMUC";
NSString *const SEGUE_ID_CREATED_CHAT = @"SegueIdentifierCreatedChat";
NSString *const SEGUE_ID_GROUP_VIEW_IMAGE = @"SegueIDGroupViewImage";
NSString *const SEGUE_ID_ONE_TO_ONE_VIEW_IMAGE = @"SegueIDOneToOneViewImage";
NSString *const SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION = @"SegueIDCreatedOneToOneChatFromConfession";
NSString *const SEGUE_ID_COMPOSE_CONFESSION = @"SegueIDComposeConfession";
NSString *const SEGUE_ID_SETTINGS = @"SegueIDSettings";
NSString *const SEGUE_ID_GO_TO_LOGIN_PAGE = @"SegueIDGoToLoginPage";
NSString *const SEGUE_ID_GO_TO_REGISTER_PAGE = @"SegueIDGoToRegisterPage";
NSString *const SEGUE_ID_FROM_REGISTER_TO_LOGIN = @"SegueIDFromRegisterToLogin";
NSString *const SEGUE_ID_LOGOUT = @"SegueIDLogout";
NSString *const SEGUE_ID_AUTHENTICATED_FROM_APP_INIT = @"SegueIDAuthenticatedFromAppInit";
NSString *const SEGUE_ID_ADD_TO_GROUP = @"SegueIDAddToGroup";
NSString *const SEGUE_ID_TUTORIAL = @"SegueIDTutorial";

NSString *const CELL_ID_CONVERSATION_PROTOTYPE = @"ConversationCellPrototype";
NSString *const CELL_ID_FRIENDS_PROTOTYPE = @"FriendsCellPrototype";

NSString *const USER_STATUS_PENDING = @"user_status_pending";
NSString *const USER_STATUS_FRIENDS = @"user_status_friends";
NSString *const USER_STATUS_REGISTERED = @"user_status_registered";
NSString *const USER_STATUS_REJECTED = @"user_status_rejected";
NSString *const USER_STATUS_UNREGISTERED = @"user_status_unregistered";

NSString *const CORE_DATA_TABLE_MESSAGES = @"MessageMO";
NSString *const CORE_DATA_TABLE_FRIENDS = @"FriendMO";
NSString *const CORE_DATA_TABLE_CHATS = @"ChatMO";

NSString *const FRIENDS_TABLE_COLUMN_NAME_USERNAME = @"username";
NSString *const FRIENDS_TABLE_COLUMN_NAME_NAME = @"name";
NSString *const FRIENDS_TABLE_COLUMN_NAME_STATUS = @"status";
NSString *const FRIENDS_TABLE_COLUMN_NAME_EMAIL = @"email";
NSString *const FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER = @"searchedPhoneNumber";
NSString *const FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL = @"searchedEmail";
NSString *const FRIENDS_TABLE_COLUMN_NAME_PHONE = @"phone";
NSString *const FRIENDS_TABLE_COLUMN_NAME_UID = @"uid"; 

NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_ID = @"chat_id";
NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_NAME = @"chat_name";
NSString *const CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME = @"user_defined_chat_name";
NSString *const CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE = @"has_new_message";
NSString *const CHATS_TABLE_COLUMN_NAME_STATUS = @"status";
NSString *const CHATS_TABLE_COLUMN_NAME_CHAT_TYPE = @"chat_type";
NSString *const CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING = @"participant_string";
NSString *const CHATS_TABLE_COLUMN_NAME_OWNER_ID = @"owner_id";

int const STATUS_FRIENDS = 0;
int const STATUS_REGISTERED = 1;
int const STATUS_PENDING = 2;
int const STATUS_REJECTED = 3;
int const STATUS_UNREGISTERED = 4;
int const STATUS_REQUESTED = 5;
int const STATUS_INVITED = 6;

int const STATUS_JOINED = 0;
int const STATUS_REQUEST_PENDING = 1;
int const STATUS_INACTIVE = 2;
int const STATUS_REQUEST_REJECTED = 3;

NSString *const NOTIFICATIONS = @"Notifications";
NSString *const NO_NOTIFICATIONS = @"You have no notifications";
NSString *const NOTIFICATIONS_GROUP = @"Group Invitations";
NSString *const NOTIFICATIONS_FRIEND = @"Friend Requests";
NSString *const ANONYMOUS_FRIEND = @"Anonymous Friend";

NSString *const BEGINNING_OF_TIME = @"1970-01-01T00:00:00Z";

NSString *const SETTING_CHANGE_EMAIL = @"change_email";
NSString *const SETTING_CHANGE_PASSWORD = @"change_password";
NSString *const SETTING_LEAVE_GROUPS = @"leave_groups";
NSString *const SETTING_LOGOUT = @"logout";
NSString *const SETTING_SUPPORT = @"info_support";
NSString *const SETTING_PRIVACY = @"info_privacy";
NSString *const SETTING_TERMS = @"info_terms";
NSString *const EMAIL_CHANGED = @"Email Address Changed";
NSString *const PASSWORD_CHANGED = @"Password Changed";
NSString *const LOGIN_AGAIN = @"Login Again";

NSString *const STORYBOARD_ID_PAGE_VIEW_CONTROLLER = @"MainPageViewController";
NSString *const STORYBOARD_ID_NOTIFICATIONS_VIEW_CONTROLLER = @"NotificationsViewController";
NSString *const STORYBOARD_ID_DASHBOARD_VIEW_CONTROLLER = @"DashboardViewController";
NSString *const STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER = @"FriendsViewController";
NSString *const STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER = @"ContactsViewController";
NSString *const STORYBOARD_ID_SWIPE_VIEW_CONTROLLER = @"MainSwipeViewController";
NSString *const STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER = @"ConfessionsViewController";
NSString *const STORYBOARD_ID_CONNECTION_LOST_VIEW_CONTROLLER = @"ConnectionLostViewController";
NSString *const STORYBOARD_ID_NEW_USER_REGISTER_NAME_VIEW_CONTROLLER = @"NewUserRegisterNameViewController";
NSString *const STORYBOARD_ID_NEW_USER_REGISTER_PHONE_VIEW_CONTROLLER = @"NewUserRegisterPhoneViewController";
NSString *const STORYBOARD_ID_NEW_USER_REGISTER_USERNAME_VIEW_CONTROLLER = @"NewUserRegisterUsernameViewController";
NSString *const STORYBOARD_ID_ENTER_CONFIRMATION_CODE_VIEW_CONTROLLER = @"EnterConfirmationCodeViewController";
NSString *const STORYBOARD_ID_NEW_USER_CONFIRMATION_CODE_VIEW_CONTROLLER = @"NewUserConfirmationCodeViewController";
NSString *const STORYBOARD_ID_TUTORIAL_SLIDE_VIEW_CONTROLLER = @"TutorialSlideViewController";

NSString *const PAGE_NAVIGATE_TO_MESSAGES = @"page_navigate_to_messages";
NSString *const PAGE_NAVIGATE_TO_CONFESSIONS = @"page_navigate_to_confessions";
NSString *const PAGE_NAVIGATE_TO_FRIENDS = @"page_navigate_to_friends";
NSString *const PAGE_NAVIGATE_TO_CONTACTS = @"page_navigate_to_contacts";

NSString *const UPDATE_CONTACTS_VIEW = @"update_contacts_view";

NSString *const REPORT_BLOCK = @"Block Sender";
NSString *const REPORT_ABUSE = @"Report Abuse";
NSString *const REPORT_CONFIRM_BLOCK = @"Block sender!";
NSString *const REPORT_CONFIRM_ABUSE = @"Report abuse!";

NSString *const INVALID_CODE = @"Incorrect Code...try again.";
NSString *const NOT_VALIDATED = @"Phone number not yet confirmed.";

NSString *const PACKET_ID_BLOCK_IMPLICIT_USER = @"packet_id_block_implicit_user";
NSString *const PACKET_ID_BLOCK_USER_IN_GROUP = @"packet_id_block_user_in_group";
NSString *const PACKET_ID_UNBLOCK_IMPLICIT_USER = @"packet_id_unblock_implicit_user";
NSString *const PACKET_ID_UNBLOCK_USER_IN_GROUP = @"packet_id_unblock_user_in_group";

NSString *const PACKET_ID_SET_DEVICE_TOKEN = @"packet_id_set_device_token";

NSString *const BLOCKING_TYPE_IMPLICIT = @"implicit_user";
NSString *const BLOCKING_TYPE_GROUP = @"user_in_group";


@end
