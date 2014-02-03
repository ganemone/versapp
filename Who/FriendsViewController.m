//
//  FriendsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendsViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface FriendsViewController()
@property (strong, nonatomic) ConnectionProvider* cp;
@end

@implementation FriendsViewController

-(void)viewDidLoad{

    self.cp = [ConnectionProvider getInstance];
    DDXMLElement *iq = [IQPacketManager createGetRosterPacket];
    NSLog(@"RosterIQ Packet: %@", iq.XMLString);
    [[self.cp getConnection] sendElement:iq];
    

}


@end
