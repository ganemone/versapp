//
//  XMPPManager.m
//  Versapp
//
//  Created by Giancarlo Anemone on 8/10/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "XMPPManager.h"
#import "XMPPIDTracker.h"
#import "DDXMLElement.h"
#import "IQPacketManager.h"
#import "IQPacketReceiver.h"
#import "MessagePacketReceiver.h"
#import "ConnectionProvider.h"
#import "PresencePacketReceiver.h"

@interface XMPPManager ()

@property(strong, nonatomic) XMPPIDTracker *tracker;
@property(strong, nonatomic) XMPPStream *conn;

@end

static XMPPManager *selfInstance;

@implementation XMPPManager

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            ConnectionProvider *cp = [ConnectionProvider getInstance];
            selfInstance.tracker = [cp tracker];
            selfInstance.conn = [cp getConnection];
        }
    }
    return selfInstance;
}

- (void)sendUnsubscribedPacket:(NSString *)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendSubscribePacket:(NSString*)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendSubscribedPacket:(NSString*)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUnsubscribePacket:(NSString *)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendGetRosterPacket:(void (^)(XMPPElement *element))block {}
- (void)sendGetJoinedChatsPacket:(void (^)(XMPPElement *element))block {}
- (void)sendGetPendingChatsPacket:(void (^)(XMPPElement *element))block {}
- (void)sendGetChatInfoPacket:(NSString*)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendGetChatParticipantsPacket:(NSString*)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendDestroyChatPacket:(NSString*)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendInviteToChatPacket:(NSString*)chatId invitedUsername: (NSString*)invitedUsername responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendAcceptChatInvitePacket:(NSString*)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendDenyChatInvitePacket:(NSString*)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendJoinMUCPacket:(NSString*)chatID lastTimeActive: (NSString*)lastTimeActive responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendCreateMUCPacket:(NSString*)chatID roomName:(NSString*)roomName participants:(NSArray*)participants responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendRegisterUserPacket:(NSString*)username password:(NSString*)password responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendCreateVCardPacket:(NSString*)firstName lastname:(NSString*)lastName responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUpdateVCardPacket:(NSString *)firstName lastname:(NSString *)lastName responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendGetLastTimeActivePacket:(void (^)(XMPPElement *element))block {}
- (void)sendGetServerTimePacket:(void (^)(XMPPElement *element))block {}
- (void)sendSendMUCMessagePacket:(MessageMO *)message responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendSendOneToOneMessagePacket:(MessageMO *)message responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendAvailabilityPresencePacket:(void (^)(XMPPElement *element))block {}
- (void)sendGetVCardPacket:(NSString*)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendGetConnectedUserVCardPacket:(void (^)(XMPPElement *element))block {}
- (void)sendRoomConfigurationForm:(NSString*)groupName responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendInviteToMUCMessage:(NSString*)chatID username:(NSString*)username chatName:(NSString *)chatName responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendCreateOneToOneChatPacket:(NSString*)chatID invitedUser:(NSString*)invitedUser roomName:(NSString*)roomName responseBlock:(void (^)(XMPPElement *element))block {}

- (void)sendGetSessionIDPacket:(void (^)(XMPPElement *element))block {
    DDXMLElement *el = [IQPacketManager createGetSessionIDPacket];
    NSString *elementId = [[el attributeForName:@"id"] stringValue];
    NSLog(@"Element ID: %@", elementId);
    [_tracker addID:elementId block:^(id obj, id<XMPPTrackingInfo> info) {
        XMPPIQ *iq = obj;
        NSString *sanitizedResult = [IQPacketReceiver sanitizePacket:iq];
        [IQPacketReceiver handleGetSessionIDPacket:sanitizedResult];
        block(iq);
    } timeout:5000];
    [_conn sendElement:el];
}

- (void)sendPostConfessionPacket:(Confession *)confession responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendToggleFavoriteConfessionPacket:(NSString*)confessionID responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendCreateOneToOneChatFromConfessionPacket:(Confession*)confession chatID:(NSString *)chatID responseBlock:(void (^)(XMPPElement *element))block {
    DDXMLElement *el = [IQPacketManager createCreateOneToOneChatFromConfessionPacket:confession chatID:chatID];
    NSString *elementID = [[el attributeForName:@"id"] stringValue];
    [_tracker addID:elementID block:^(id obj, id<XMPPTrackingInfo> info) {
        XMPPIQ *iq = obj;
        block(iq);
    } timeout:5000];
    [_conn sendElement:el];
}
- (void)sendForceCreateRosterEntryPacket:(NSString *)jid responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendLeaveChatPacket:(NSString *)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendExitRoomPacket:(NSString *)chatId responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendDestroyConfessionPacket:(NSString*)confessionID responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUserSearchPacketWithSearchParam:(NSString *)searchParam responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUserSearchPacketWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray*)emails personIDS:(NSArray *)personIDS responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendReportOneToOneChatPacket:(NSString *)chat_id type:(NSString *)type responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendReportGroupChatPacket:(NSString *)chat_id type:(NSString *)type responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendReportMessageInGroupPacket:(NSString *)chat_id type:(NSString *)type message:(MessageMO *)message responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendReportThoughtPacket:(Confession *)thought type:(NSString *)type responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendBlockImplicitUserPacket:(NSString *)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendBlockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUnblockImplicitUser:(NSString *)username responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendUnblockUserInGroupPacket:(NSString *)username chatID:(NSString *)chatID responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendSetDeviceTokenPacket:(NSString *)deviceToken responseBlock:(void (^)(XMPPElement *element))block {}
- (void)sendGetUserInfoPacket:(void (^)(XMPPElement *element))block {}
- (void)sendSetUserInfoPacketFromDefaults:(void (^)(XMPPElement *element))block {}

@end
