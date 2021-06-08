//
//  DetailsViewController.m
//  Flicks
//
//  Created by Vipata Kilembo on 6/6/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WebViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) NSDictionary *trailerArray;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSString *key;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    [self loadPoster];
    [self.posterView addGestureRecognizer:self.tapGesture];
    [self loadBackDrop];
    
    self.titleLabel.text = self.movie[@"title"];
    self.descriptionLabel.text = self.movie[@"overview"];
    
    [self.titleLabel sizeToFit];
    [self.descriptionLabel sizeToFit];
    [self getTrailer:self.movie[@"id"]];

    
    
}

-(void)loadPoster{
    
    NSString * baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString * posterURL = self.movie[@"poster_path"];
    NSString * fullPosterURL = [baseURL stringByAppendingString:posterURL];
    NSURL *url = [NSURL URLWithString:fullPosterURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.posterView setImageWithURLRequest:request placeholderImage:nil
                                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
                                        // imageResponse will be nil if the image is cached
                                        if (imageResponse) {
                                            NSLog(@"Image was NOT cached, fade in image");
                                            self.posterView.alpha = 0.0;
                                            self.posterView.image = image;
                                            
                                            //Animate UIImageView back to alpha 1 over 0.3sec
                                            [UIView animateWithDuration:0.3 animations:^{
                                                self.posterView.alpha = 1.0;
                                            }];
                                        }
                                        else {
                                            NSLog(@"Image was cached so just update the image");
                                            self.posterView.image = image;
                                        }
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
                                        NSLog(@"%@", error);
                                    }];
}


-(void)loadBackDrop{
    NSString * baseSmallURL = @"https://image.tmdb.org/t/p/w200";
    NSString * baseLargeURL = @"https://image.tmdb.org/t/p/w500";
    NSString * backdropURL = self.movie[@"backdrop_path"];

    
    NSString * urlSmallString = [baseSmallURL stringByAppendingString:backdropURL];
    NSString * urlLargeString = [baseLargeURL stringByAppendingString:backdropURL];
    
    NSURL *urlSmall = [NSURL URLWithString:urlSmallString];
    NSURL *urlLarge = [NSURL URLWithString:urlLargeString];
    
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];
    
    [self.backdropView setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                        self.backdropView.alpha = 0.0;
                                        self.backdropView.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            
                                                            self.backdropView.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [self.backdropView setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                            self.backdropView.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                   }];
}

-(void)getTrailer:(NSString*)movie{
    
    NSString *trailerURLString = [NSString stringWithFormat:@"%@/%@/%@",  @"https://api.themoviedb.org/3/movie", movie, @"videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US"];
    
//    NSString * trailerString = ;
    NSURL *url = [NSURL URLWithString:trailerURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.trailerArray = dataDictionary[@"results"][0];
               self.key = self.trailerArray[@"key"];
           }
       }];
    [task resume];

//    return @"";
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
        WebViewController *webViewController = [segue destinationViewController];
        NSLog(@"TRAILER KEY %@", self.trailerArray[@"key"]);
    webViewController.key = self.key;
}


@end
