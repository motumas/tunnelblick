/*
 * Copyright 2011 Jonathan Bullard
 *
 *  This file is part of Tunnelblick.
 *
 *  Tunnelblick is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2
 *  as published by the Free Software Foundation.
 *
 *  Tunnelblick is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program (see the file COPYING included with this
 *  distribution); if not, write to the Free Software Foundation, Inc.,
 *  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *  or see http://www.gnu.org/licenses/.
 */


#import "InfoView.h"
#import "helper.h"


@implementation InfoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void) dealloc
{
    [logo release];
    [scrollTimer release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

-(void) awakeFromNib
{
    NSString * version = [NSString stringWithFormat: @"%@  -  %@", tunnelblickVersion([NSBundle mainBundle]), openVPNVersion()];
    [infoVersionTFC setTitle: version];
    
    NSString * logoPath = [[NSBundle mainBundle] pathForResource: @"tunnelblick" ofType: @"icns"];
    if (  logoPath  ) {
        [logo release];
        logo = [[NSImage alloc] initWithContentsOfFile: logoPath];
        [infoLogoIV setImage: logo];
    }
    
    NSString * descriptionPath = [[NSBundle mainBundle] pathForResource:@"description" ofType:@"rtf"];
    if (  descriptionPath  ) {
        [infoDescriptionTV setEditable: NO];
        [infoDescriptionSV setHasHorizontalScroller: NO];
        [infoDescriptionSV setHasVerticalScroller:   NO];

        NSAttributedString * descriptionString = [[[NSAttributedString alloc] initWithPath: descriptionPath documentAttributes: nil] autorelease];
        [infoDescriptionTV replaceCharactersInRange: NSMakeRange( 0, 0 ) 
                                            withRTF: [descriptionString RTFFromRange: NSMakeRange( 0, [descriptionString length] ) 
                                                                  documentAttributes:nil]];
    }
    
    NSString * creditsPath = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"rtf"];
    if (  creditsPath) {
        [infoCreditTV setEditable: NO];
        [infoCreditSV setHasHorizontalScroller: NO];
        [infoCreditSV setHasVerticalScroller:   NO];
        
        NSAttributedString * creditsString = [[[NSAttributedString alloc] initWithPath:creditsPath documentAttributes:nil] autorelease];
        [infoCreditTV replaceCharactersInRange:NSMakeRange( 0, 0 ) 
                                       withRTF:[creditsString RTFFromRange:
                                                NSMakeRange( 0, [creditsString length] ) 
                                                        documentAttributes:nil]];
    }
}

-(void) oldViewWillDisappear
{
    [scrollTimer invalidate];
}


-(void) newViewWillAppear
{
    requestedPosition = 0.0;
    restartAtTop = YES;
    startTime = [NSDate timeIntervalSinceReferenceDate] + 3.0;
    [infoCreditTV scrollPoint:NSMakePoint( 0.0, 0.0 )];
    
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 
                                                   target: self 
                                                 selector: @selector(scrollCredits:) 
                                                 userInfo: nil 
                                                  repeats: YES];
}


- (void)scrollCredits:(NSTimer *)timer
{
    if ([NSDate timeIntervalSinceReferenceDate] >= startTime) {
        if (  restartAtTop  ) {
            // Reset the startTime
            startTime = [NSDate timeIntervalSinceReferenceDate] + 3.0;
            restartAtTop = NO;
            
            // Fade back in
            if (   [infoCreditSV respondsToSelector: @selector(animator)]
                && [[infoCreditSV animator] respondsToSelector: @selector(setAlphaValue:)]  ) {
                [[infoCreditSV animator] setAlphaValue: 1.0];
            }
            // Set the position
            [infoCreditTV scrollPoint:NSMakePoint( 0.0, 0.0 )];
            
            return;
        }
        
        CGFloat actualPosition = [[infoCreditSV contentView] bounds].origin.y;
        if (  requestedPosition > actualPosition + 10.0  ) {
            // Reset the startTime
            startTime = [NSDate timeIntervalSinceReferenceDate] + 3.0;
            
            // Reset the position
            requestedPosition = 0.0;
            restartAtTop = YES;
            
            // Fade out quietly
            if (   [infoCreditSV respondsToSelector: @selector(animator)]
                && [[infoCreditSV animator] respondsToSelector: @selector(setAlphaValue:)]  ) {
                [[infoCreditSV animator] setAlphaValue: 0.0];
            }
        } else {
            // Scroll to the position
            [infoCreditTV scrollPoint:NSMakePoint( 0.0, requestedPosition )];
            
            // Increment the scroll position
            requestedPosition += 1.0;
        }
    }
}

@end
