//
//  WebViewController.m
//  Flicks
//
//  Created by Vipata Kilembo on 6/7/21.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Convert the url String to a NSURL object.
    NSLog(@"WEBVIEW %@", self.key);
    
    self.urlString =  [NSString stringWithFormat:@"%@%@",@"https://www.youtube.com/watch?v=", self.key];
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    

    // Place the URL in a URL Request.
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];
    // Load Request into WebView.
    [self.webView loadRequest:request];
    
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
