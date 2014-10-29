//
//  TMEProductCommentsVC.m
//  ThreeMin
//
//  Created by Khoa Pham on 9/22/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

#import "TMEProductCommentsVC.h"
#import "TMEProductCommentViewModel.h"
#import "TMEProductCommentViewModel.h"
#import "TMESingleSectionDataSource.h"
#import "TMEProductCommentCell.h"
#import "TMEProductComment.h"

@interface TMEProductCommentsVC () <UITableViewDelegate>

@property (nonatomic, strong) FBKVOController *viewModelKVOController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TMEProductCommentCell *prototypeCell;
@property (nonatomic, strong) TMESingleSectionDataSource *dataSource;

@end

@implementation TMEProductCommentsVC

- (void)awakeFromNib
{
    self.title = @"Comments";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTableView];
    [self configureViewModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // FIXME: Temporarily fix
    if (self.tableView.height == 0) {
        self.tableView.height = 1;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewModel
- (void)configureViewModel
{
    self.viewModelKVOController = [FBKVOController controllerWithObserver:self];
    [self.viewModelKVOController observe:self.viewModel
                                 keyPath:@"productComments"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                   block:^(id observer, id object, NSDictionary *change)
    {
        typeof(self) innerSelf = observer;
        NSArray *items = [innerSelf determinedItems:innerSelf.viewModel.productComments];
        [innerSelf determineHeightWithItems:items];

        innerSelf.dataSource.items = items;
        [innerSelf.tableView reloadData];
    }];

    [self.viewModelKVOController observe:self.viewModel
                                 keyPath:@"productCommentsCount"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                   block:^(id observer, id object, NSDictionary *change)
     {
         typeof(self) innerSelf = observer;
         innerSelf.title = NSStringf(@"%d comments", innerSelf.viewModel.productCommentsCount);
     }];
}

#pragma mark - TableView
- (void)setupTableView
{
    self.tableView.tableFooterView = [[UIView alloc] init];

    self.tableView.delegate = self;

    // DataSource
    self.dataSource = [[TMESingleSectionDataSource alloc] init];
    self.dataSource.cellIdentifier = [TMEProductCommentCell kind];
    self.dataSource.cellConfigureBlock = ^(TMEProductCommentCell *cell, TMEProductComment *comment) {
        [cell configureForModel:comment];
    };

    self.tableView.dataSource = self.dataSource;

    if (self.displayedInBrief) {
        self.tableView.scrollEnabled = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}

- (TMEProductCommentCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:[TMEProductCommentCell kind]];
    }

    return _prototypeCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TMEProductComment *comment = self.dataSource.items[indexPath.row];

    return [self cellHeighFromComment:comment] + 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UINavigationController *navC = self.navigationController ?: self.parentViewController.navigationController;
    (void)(navC);
}

#pragma mark - Delegate
- (void)didChangeHeight:(CGFloat)height
{
    if ([self.delegate respondsToSelector:@selector(productCommentsVC:didChangeHeight:)]) {
        [self.delegate productCommentsVC:self didChangeHeight:height];
    }
}

#pragma mark - Helper
- (NSArray *)determinedItems:(NSArray *)productsComments
{
    if (!self.displayedInBrief) {
        return productsComments;
    }

    NSMutableArray *items = [NSMutableArray array];
    for (int i=0; i<productsComments.count && i < self.maxCommentCountInBrief; ++i) {
        [items addObject:productsComments[i]];
    }

    return items;
}

- (CGFloat)cellHeighFromComment:(TMEProductComment *)comment
{
    [self.prototypeCell configureForModel:comment];

    [self.prototypeCell updatePreferredMaxLayoutWidth];

    [self.prototypeCell layoutIfNeeded];
    [self.prototypeCell updateConstraintsIfNeeded];

    return [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (void)determineHeightWithItems:(NSArray *)items
{
    CGFloat height = 0;
    for (TMEProductComment *comment in items) {
        height += [self cellHeighFromComment:comment];
    }

    // For some padding
    if (height > 0) {
        height += 17;
    }

    [self didChangeHeight:height];
}

@end