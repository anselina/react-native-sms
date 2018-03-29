//
//  SendSMS.m
//  SendSMS
//
//  Created by Trevor Porter on 7/13/16.


#import "SendSMS.h"
#import <React/RCTUtils.h>

@implementation SendSMS

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(send:(NSDictionary *)options :(RCTResponseSenderBlock)callback)
{
    _callback = callback;
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {

        NSString *body = options[@"body"];
        NSArray *recipients = options[@"recipients"];

        if (body) {
          messageController.body = body;
        }

        if (recipients) {
          messageController.recipients = recipients;
        }

        // If device can send attachments and an attachment was provided (only images are supported)
        if ([MFMessageComposeViewController canSendAttachments]) {
          if (options[@"attachment"] && options[@"attachment"][@"path"] && options[@"attachment"][@"type"]) {
            NSString *attachmentPath = options[@"attachment"][@"path"];
            NSString *attachmentType = options[@"attachment"][@"type"];
            NSString *attachmentName = options[@"attachment"][@"name"];

            NSData *fileData = [NSData dataWithContentsOfFile:attachmentPath];
            NSString *mimeType;
            if ([attachmentType isEqualToString:@"jpg"]) {
              mimeType = @"image/jpeg";
            } else if ([attachmentType isEqualToString:@"jpeg"]) {
              mimeType = @"image/jpeg";
            } else if ([attachmentType isEqualToString:@"png"]) {
              mimeType = @"image/png";
            } else if ([attachmentType isEqualToString:@"gif"]) {
              mimeType = @"image/gif";
            }

            [messageController addAttachmentData:fileData typeIdentifier:mimeType filename:attachmentName];
          }
        }

        messageController.messageComposeDelegate = self;
        UIViewController *currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while(currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        }
        [currentViewController presentViewController:messageController animated:YES completion:nil];
    } else {
        bool completed = NO, cancelled = NO, error = YES;
        _callback(@[@(completed), @(cancelled), @(error)]);
    }
}

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    bool completed = NO, cancelled = NO, error = NO;
    switch (result) {
        case MessageComposeResultSent:
            completed = YES;
            break;
        case MessageComposeResultCancelled:
            cancelled = YES;
            break;
        default:
            error = YES;
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        _callback(@[@(completed), @(cancelled), @(error)]);
    }];
}

@end
