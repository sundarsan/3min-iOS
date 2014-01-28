//
//  TMEActivityViewController.m
//  PhotoButton
//
//  Created by admin on 1/2/14.
//
//

#import "TMEActivityViewController.h"
#import "TMEActivityTableViewCell.h"
#import "TMESubmitViewController.h"
#import "TMELoadMoreTableViewCell.h"

@interface TMEActivityViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView                    * tableViewActivity;
@property (strong, nonatomic) NSMutableArray                        * arrayConversation;
@property (assign, nonatomic) BOOL                                    havingPreviousActivities;
@property (assign, nonatomic) NSInteger                               currentPage;

@end

@implementation TMEActivityViewController

- (NSMutableArray *)arrayConversation{
  if (!_arrayConversation) {
    _arrayConversation = [[NSMutableArray alloc] init];
  }
  return _arrayConversation;
}

#pragma mark - VC cycle life

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationController.navigationBar.topItem.title = @"Activity";
  self.scrollableView = self.tableViewActivity;
  [self enablePullToRefresh];
  [self disableNavigationTranslucent];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(reloadActivity:)
                                               name:NOTIFICATION_RELOAD_CONVERSATION
                                             object:nil];
  
  [self.tableViewActivity registerNib:[UINib nibWithNibName:NSStringFromClass([TMEActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TMEActivityTableViewCell class])];
  [self getCachedActivity];
  
  if (!self.arrayConversation.count) {
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
  }
  
  [self loadListActivityWithPage:1];
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [self loadListActivityWithPage:1];
}

#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  if (self.havingPreviousActivities) {
    return self.arrayConversation.count + 1;
  }
  return self.arrayConversation.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  if (self.havingPreviousActivities && indexPath.row == self.arrayConversation.count) {
    return [TMELoadMoreTableViewCell getHeight];
  }
  return [TMEActivityTableViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  if (self.havingPreviousActivities && indexPath.row == self.arrayConversation.count) {
    TMELoadMoreTableViewCell *cellLoadMore = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMELoadMoreTableViewCell class])];
    if (cellLoadMore == nil) {
      // Load the top-level objects from the custom cell XIB.
      NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TMELoadMoreTableViewCell class]) owner:self options:nil];
      // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
      cellLoadMore = [topLevelObjects objectAtIndex:0];
    }
    self.currentPage++;
    [self loadListActivityWithPage:self.currentPage];
    
    return cellLoadMore;
  }
  
  TMEConversation *conversation = self.arrayConversation[indexPath.row];
  TMEActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMEActivityTableViewCell class]) forIndexPath:indexPath];
  [cell configCellWithConversation:conversation]; return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row < self.arrayConversation.count) {
    TMESubmitViewController *submitController = [[TMESubmitViewController alloc] init];
    
    TMEConversation *conversation = self.arrayConversation[indexPath.row];
    
    submitController.product = conversation.product;
    submitController.conversation = conversation;
    
    [self.navigationController pushViewController:submitController animated:YES];
  }
}

#pragma mark - Caching stuffs

- (void)getCachedActivity{
  NSArray *arrayActivityCached = [TMEConversation MR_findAllSortedBy:@"latest_update" ascending:NO];
  
  for (TMEConversation *conversation in arrayActivityCached) {
    [self.arrayConversation addObject:conversation];
  }
  self.currentPage = 0;
  if (self.arrayConversation.count) {
    self.currentPage = (self.arrayConversation.count / 10) + 1;
    [self reloadTableViewActivity];
  }
}

#pragma mark - Handle notification

- (void)loadListActivityWithPage:(NSInteger)page{
  [[TMEConversationManager sharedInstance] getListConversationWithPage:page
                                                        onSuccessBlock:^(NSArray *arrayConversation)
   {
     self.havingPreviousActivities = YES;
     self.tableViewActivity.hidden = NO;
     
     if (!arrayConversation.count) {
       self.havingPreviousActivities = NO;
     }
     
     if (!self.currentPage) {
       self.currentPage = page;
     }
     NSMutableSet *setConversation = [NSMutableSet setWithArray:self.arrayConversation];
     [setConversation addObjectsFromArray:arrayConversation];
     
     self.arrayConversation = [[setConversation allObjects] mutableCopy];
     self.arrayConversation = [[self.arrayConversation sortByAttribute:@"latest_update" ascending:NO] mutableCopy];
     
     [self reloadTableViewActivity];
     
     [self.pullToRefreshView endRefreshing];
     [SVProgressHUD dismiss];
   }
                                                       andFailureBlock:^(NSInteger statusCode, NSError *error)
   {
     return DLog(@"%d", statusCode);
     [self.pullToRefreshView endRefreshing];
   }];
  
}

- (void)reloadActivity:(NSNotification *)notification{
  [self loadListActivityWithPage:1];
}

- (void)reloadTableViewActivity{
  [self.tableViewActivity reloadData];
  self.tableViewActivity.hidden = NO;
}

- (void)pullToRefreshViewDidStartLoading:(UIRefreshControl *)view
{
  if (![TMEReachabilityManager isReachable]) {
    [SVProgressHUD showErrorWithStatus:@"No connection!"];
    [self reloadTableViewActivity];
    [self.pullToRefreshView endRefreshing];
    return;
  }
  self.pullToRefreshView.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing activities.."];
  NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
  [formattedDate setDateFormat:@"d MMM, h:mm a"];
  NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[formattedDate stringFromDate:[NSDate date]]];
  [self loadListActivityWithPage:1];
  self.pullToRefreshView.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];
}

@end
