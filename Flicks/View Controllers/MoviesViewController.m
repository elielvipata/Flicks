//
//  MoviesViewController.m
//  Flicks
//
//  Created by Vipata Kilembo on 6/6/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInidicator;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredData;
@property (nonatomic,strong) NSArray * movies;
@property (nonatomic, strong) UIRefreshControl * refreshControl;
@property (nonatomic,strong) NSArray * trailerDictionary;
@property (nonatomic,strong) NSString * errorMessage;


@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationItem.title = @"Now Playing";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.tintColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.8];
        
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        shadow.shadowOffset = CGSizeMake(2, 2);
        shadow.shadowBlurRadius = 4;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:22],
                                              NSForegroundColorAttributeName : [UIColor colorWithRed:0.5 green:0.15 blue:0.15 alpha:0.8],
                                              NSShadowAttributeName : shadow};
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    self.tableView.hidden = YES;
    [self.activityInidicator startAnimating];
    [self fetchMovies];
    [self.activityInidicator stopAnimating];
    self.tableView.hidden = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    

    
}

-(void)fetchMovies{

    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];

    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error"
                                                                                          message:[error localizedDescription]                                                                               preferredStyle:(UIAlertControllerStyleAlert)];
               

               // create an OK action
               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    [super viewDidAppear:YES];
                                                                }];
               
               [alert addAction:okAction];
               
               [self presentViewController:alert animated:YES completion:^{
                   // optional code for what happens after the alert controller has finished presenting
               }];
               
               NSLog(@"ERRRORRRR %@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                  self.movies = dataDictionary[@"results"];
                self.filteredData = self.movies;

               [self.tableView reloadData];
             
           }
        [self.refreshControl endRefreshing];

       }];
    
   

    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
     UITableViewCell * tappedCell = sender;
     NSIndexPath * indexPath = [self.tableView indexPathForCell:tappedCell];
     NSDictionary * movie = self.movies[indexPath.row];
     
     DetailsViewController * detailsViewController =  [segue destinationViewController];
     detailsViewController.movie = movie;
     
     NSLog(@"Tapped on a movie");
     
     
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MovieCell * cell =(MovieCell*) [tableView dequeueReusableCellWithIdentifier:@"MovieCell" forIndexPath:indexPath];
    NSDictionary * movie = self.movies[indexPath.row];
    cell.movieTitle.text = movie[@"original_title"];
    cell.movieDescription.text = movie[@"overview"];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = UIColor.blueColor;
    cell.selectedBackgroundView = backgroundView;
    
    NSString * baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString * posterURL = movie[@"poster_path"];
    NSString * fullPosterURL = [baseURL stringByAppendingString:posterURL];
    
    NSURL *url = [NSURL URLWithString:fullPosterURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [cell.moviePoster setImageWithURLRequest:request placeholderImage:nil
                                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                                        
                                        // imageResponse will be nil if the image is cached
                                        if (imageResponse) {
                                            NSLog(@"Image was NOT cached, fade in image");
                                            cell.moviePoster.alpha = 0.0;
                                            cell.moviePoster.image = image;
                                            
                                            //Animate UIImageView back to alpha 1 over 0.3sec
                                            [UIView animateWithDuration:0.3 animations:^{
                                                cell.moviePoster.alpha = 1.0;
                                            }];
                                        }
                                        else {
                                            NSLog(@"Image was cached so just update the image");
                                            cell.moviePoster.image = image;
                                        }
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                                        // do something for the failure condition
                                    }];
    
    
    
    NSURL *poster = [NSURL URLWithString:fullPosterURL];
    cell.moviePoster.image = nil;
    [cell.moviePoster setImageWithURL:poster];
    
//    cell.textLabel.text = movie[@"title"];
    return cell;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0) {
        self.movies = self.filteredData;

           NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
               return [evaluatedObject[@"original_title"] containsString:searchText];
           }];
        
           self.movies = [self.movies filteredArrayUsingPredicate:predicate];
           
           NSLog(@"%@", self.filteredData);
       }
       else {
           self.movies = self.filteredData;
       }
       [self.tableView reloadData];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    NSString * searchText =(NSString *) self.searchBar.text;
    
    
    if(searchText.length == 0){
        NSLog(@"EMPTYBAAAR");
        self.movies = self.filteredData;
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"view Will Appear");
    self.viewDidLoad;
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"view Did Appear");
    self.viewDidLoad;
}

@end
