//
//  MoviesGridViewController.m
//  Flicks
//
//  Created by Vipata Kilembo on 6/6/21.
//

#import "MoviesGridViewController.h"
#import "GridCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"


@interface MoviesGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (nonatomic,strong) NSArray * movies;
@property (weak, nonatomic) IBOutlet UICollectionView *movieCollection;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredData;



@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationItem.title = @"Popular";
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        navigationBar.tintColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.25 alpha:0.8];
        
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        shadow.shadowOffset = CGSizeMake(2, 2);
        shadow.shadowBlurRadius = 4;
        navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:22],
                                              NSForegroundColorAttributeName : [UIColor colorWithRed:0.5 green:0.15 blue:0.15 alpha:0.8],
                                              NSShadowAttributeName : shadow};
    
    
    self.movieCollection.dataSource = self;
    self.movieCollection.delegate = self;
    self.searchBar.delegate = self;
    [self fetchMovies];
    
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout*)self.movieCollection.collectionViewLayout;
    CGFloat posterPerLine = 2;
    CGFloat width = self.movieCollection.frame.size.width/2;
    CGFloat height = width * 1.5;
    layout.itemSize = CGSizeMake(width-2, height);
    


    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UICollectionViewCell * tappedCell = sender;
    NSIndexPath * indexPath = [self.movieCollection indexPathForCell:tappedCell];
    NSDictionary * movie = self.movies[indexPath.item];
    
    DetailsViewController * detailsViewController =  [segue destinationViewController];
    detailsViewController.movie = movie;
    
    NSLog(@"Tapped on a movie");
}


- (void)fetchMovies{

    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=2"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
              self.movies = dataDictionary[@"results"];
               self.filteredData = self.movies;
               [self.movieCollection reloadData];
           }

       }];
    


    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.item];
    NSString * baseURL = @"https://image.tmdb.org/t/p/w500";
    NSString * posterURL = movie[@"poster_path"];
    NSString * fullPosterURL = [baseURL stringByAppendingString:posterURL];
    
    NSURL *poster = [NSURL URLWithString:fullPosterURL];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:poster];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
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
       [self.movieCollection reloadData];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    NSString * searchText =(NSString *) self.searchBar.text;
    
    
    if(searchText.length == 0){
        NSLog(@"EMPTYBAAAR");
        self.movies = self.filteredData;
        [self.movieCollection reloadData];
    }
}


@end
