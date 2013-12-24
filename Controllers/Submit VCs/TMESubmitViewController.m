//
//  TMESubmitViewController.m
//  PhotoButton
//
//  Created by Toan Slan on 12/23/13.
//
//

#import "TMESubmitViewController.h"
#import "TMESubmitTableCell.h"

static CGFloat const LABEL_CONTENT_DEFAULT_HEIGHT = 26;

@interface TMESubmitViewController()
<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate
>

@property (strong, nonatomic) NSMutableArray *arrayConversation;

@end

@interface TMESubmitViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProduct;
@property (weak, nonatomic) IBOutlet UILabel *lblProductName;
@property (weak, nonatomic) IBOutlet UILabel *lblProductPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceOffered;
@property (weak, nonatomic) IBOutlet UILabel *lblDealLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableViewConversation;
@property (weak, nonatomic) IBOutlet UITextField *txtInputMessage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation TMESubmitViewController

- (NSMutableArray *)arrayConversation{
    if (!_arrayConversation) {
        _arrayConversation = [@[] mutableCopy];
    }
    return _arrayConversation;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"You Offer";
    [self.tableViewConversation registerNib:[UINib nibWithNibName:NSStringFromClass([TMESubmitTableCell class]) bundle:Nil] forCellReuseIdentifier:NSStringFromClass([TMESubmitTableCell class])];
    
    self.txtInputMessage.delegate = self;
    
    [self loadTransaction];
    [self loadProductDetail];
}

- (void)loadProductDetail
{
    self.lblProductName.text = self.product.name;
    self.lblProductPrice.text = [NSString stringWithFormat:@"$%@",self.product.price];
    [self.imageViewProduct setImageWithURL:[NSURL URLWithString:[[self.product.images anyObject] thumb]]];
    
    self.lblPriceOffered.text = [NSString stringWithFormat:@"$%@",self.product.price];
}

- (void)reloadTableViewConversation{
    [self.tableViewConversation setHeight:(self.arrayConversation.count * [TMESubmitTableCell getHeight])];
    [self.scrollView setContentSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, CGRectGetMaxY(self.tableViewConversation.frame) + 280)];
    [self.txtInputMessage alignBelowView:self.tableViewConversation offsetY:10 sameWidth:YES];
    [self.tableViewConversation reloadData];
}

- (void)loadTransaction
{
    [[TMETransactionManager sharedInstance] getListMessageOfProduct:self.product
                                                             toUser:self.product.user
                                                     onSuccessBlock:^(NSArray *arrayTransaction)
    {
        self.arrayConversation = [arrayTransaction mutableCopy];
        [self reloadTableViewConversation];
    }
                                                    andFailureBlock:^(NSInteger statusCode,id obj)
    {
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TMESubmitTableCell getHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayConversation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TMESubmitTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMESubmitTableCell class]) forIndexPath:indexPath];
    [cell configCellWithConversation:self.arrayConversation[indexPath.row] andSeller:self.product.user];
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self postTransaction];
    self.txtInputMessage.text = @"";
    return YES;
}

- (void)postTransaction{
    [[TMETransactionManager sharedInstance] postMessageTo:self.product
                                              withMessage:self.txtInputMessage.text
                                           onSuccessBlock:^(TMETransaction *transaction)
    {
        [self.arrayConversation addObject:transaction];
        [self reloadTableViewConversation];
    }
                                          andFailureBlock:^(NSInteger statusCode, id obj)
    {
        DLog(@"Error: %d", statusCode);
    }];
}

@end
