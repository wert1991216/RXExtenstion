//
//  RXSystemServer.m
//  RXExtenstion
//
//  Created by srx on 16/6/3.
//  Copyright © 2016年 https://github.com/srxboys. All rights reserved.
//

#import "RXSystemServer.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"


@interface RXSystemServer ()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@end

@implementation RXSystemServer
//+ (RXSystemServer *)shareRXSystemServer {
//    ... 实现 单例
//}
DEFINE_SINGLETON_FOR_CLASS(RXSystemServer)


- (void)openURL:(NSString*)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [self closeAllKeyboard];
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
#else
        [[UIApplication sharedApplication] openURL:url];
#endif
    }
}

- (void)callTelephone:(NSString*)number {
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType  isEqualToString:@"iPod touch"]||[deviceType  isEqualToString:@"iPad"]||[deviceType  isEqualToString:@"iPhone Simulator"])
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_9_0
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的设备不能打电话"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
#else
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"您的设备不能打电话" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * closeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击了确定按钮
        }];
        [alert addAction:closeAction];
        [SharedAppDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
#endif
        return;
    }
    if (number.length == 0) return;
    
    NSString *urlStr = [NSString stringWithFormat:@"tel://%@", number];
    [self openURL:urlStr];
}

#pragma mark - Send Email

- (void)sendEmailTo:(NSArray*)emailAddresses withSubject:(NSString*)subject andMessageBody:(NSString*)emailBody
{
    [self closeAllKeyboard];
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:subject];//邮件主题
        [picker setToRecipients:emailAddresses];//设置发送给谁，参数是NSarray
//        picker setCcRecipients:<#(nullable NSArray<NSString *> *)#> //可以添加抄送
        
        // Attach an image to the email
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"jpg"];
        //        NSData *myData = [NSData dataWithContentsOfFile:path];
        //        [picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"rainy"];
        
        [picker setMessageBody:emailBody isHTML:NO];//设置邮件正文内容
        if(!picker) return;
        [SharedAppDelegate.window.rootViewController presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
       
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_9_0
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的设备没有配置邮箱帐号"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
#else
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"您的设备没有配置邮箱帐号" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * closeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击了确定按钮
        }];
        [alert addAction:closeAction];
        [SharedAppDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
#endif
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
//            [SharedAppDelegate.window makeToast:@"邮件已取消"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"邮件已取消" isSuccessToast:NO];
            break;
        case MFMailComposeResultSaved:
//            [SharedAppDelegate.window makeToast:@"邮件已保存"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"邮件已保存" isSuccessToast:YES];
            break;
        case MFMailComposeResultSent:
//            [SharedAppDelegate.window makeToast:@"邮件发送成功"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"邮件发送成功" isSuccessToast:YES];
            break;
        case MFMailComposeResultFailed:
//            [SharedAppDelegate.window makeToast:@"邮件发送失败"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"邮件发送失败" isSuccessToast:NO];
            break;
        default:
            break;
    }
    
    [SharedAppDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Send Message

- (void)sendMessageTo:(NSArray*)phoneNumbers withMessageBody:(NSString*)messageBody
{
    [self closeAllKeyboard];
    /*
    if(![MFMessageComposeViewController canSendText]) {
     //检测是否可用，然后自己设置弹框
        return;
    }
    */
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.recipients = phoneNumbers;
    picker.body = messageBody;
    if(!picker) {
        return;
    }
    [SharedAppDelegate.window.rootViewController presentViewController:picker animated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self closeAllKeyboard];
    switch (result)
    {
        case MessageComposeResultCancelled:
//            [SharedAppDelegate.window makeToast:@"短消息已取消"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"短消息已取消" isSuccessToast:YES];
            break;
        case MessageComposeResultSent:
//            [SharedAppDelegate.window makeToast:@"短消息已发送"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"短消息已发送" isSuccessToast:YES];
            break;
        case MessageComposeResultFailed:
//            [SharedAppDelegate.window makeToast:@"短消息发送失败"];
            //            [SharedAppDelegate.window showToastWithDuration:1.0f message:@"短消息发送失败" isSuccessToast:NO];
            break;
        default:
            break;
    }
    
    [SharedAppDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)closeAllKeyboard {
    [SharedAppDelegate closeAllKeyboard];
}

@end
