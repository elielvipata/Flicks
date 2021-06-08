//
//  WebViewController.h
//  Flicks
//
//  Created by Vipata Kilembo on 6/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, weak) NSString *key;
@property (nonatomic, weak) NSString *urlString;


@end

NS_ASSUME_NONNULL_END
