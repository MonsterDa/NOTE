//
//  NSURLSessionViewController.m
//  NOTE
//
//  Created by 卢腾达 on 2018/11/5.
//  Copyright © 2018 卢腾达. All rights reserved.
//

#import "NSURLSessionViewController.h"

@interface NSURLSessionViewController ()

@end

@implementation NSURLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = @"http://114.215.16.38:8090/zhaoniuw_web/home/getHomeBannerInfos";
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
        }
    }];
    [sessionTask resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
