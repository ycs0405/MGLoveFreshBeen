//
//  SuperMarketVC.m
//  MGLoveFreshBeen
//
//  Created by ming on 16/7/12.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "SuperMarketVC.h"
#import "SuperMarketModel.h"
#import "ProductsCell.h"
#import "CategoryCell.h"
#import "SupermarketHeadView.h"


@interface SuperMarketVC ()<UITableViewDataSource,UITableViewDelegate>

/** 商品TableView */
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;
/** 分类TableView */
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
/** <#注释#> */
@property (nonatomic,strong) SuperMarket *superMarketData;

@property (nonatomic,strong) NSMutableArray *goodsArr;

/** 记录左边TableView点击的位置 */
@property (nonatomic,strong) NSIndexPath *categortsSelectedIndexPath;



/** 记录右边边TableView是否滚动到某个头部 */
@property (nonatomic, assign) BOOL isScrollDown;
/** 记录右边边TableView是否滚动到的位置的Y坐标 */
@property (nonatomic, assign) BOOL lastOffsetY;
/** 记录右边边TableView是否滚动到某个头部 */
@property (nonatomic,assign) NSInteger productSection;

@end

@implementation SuperMarketVC
#pragma mark - lazy

#pragma mark - 声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    [self loadSupermarketData];
    
    // 通知
    [self addNotication];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadSupermarketData];
}

- (void)setupTableView{
    self.categoryTableView.showsVerticalScrollIndicator = YES;
    self.categoryTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.categoryTableView respondsToSelector:@selector(layoutMargins)]) {
        self.categoryTableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    
    self.productsTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.productsTableView respondsToSelector:@selector(layoutMargins)]) {
        self.productsTableView.layoutMargins = UIEdgeInsetsZero;
    }
    CGPoint orgin = self.productsTableView.orgin ;
    orgin.y = MGNavHeight;
    self.productsTableView.orgin = orgin;
    
    [self.productsTableView registerClass:[SupermarketHeadView class] forHeaderFooterViewReuseIdentifier:@"MGKSupermarketHeadView"];
}

#pragma mark - 加载数据
- (void)loadSupermarketData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"supermarket" ofType: nil];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.superMarketData = [SuperMarket objectWithKeyValues:dict];
    
    // 分类
    [self.categoryTableView reloadData];
    // 默认选中第一个
    [self.categoryTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    
    
    
    
    
    _goodsArr = [NSMutableArray array];
    // 商品
    ProductstModel *productsModel = self.superMarketData.data.products;
    for (CategoriesModel *cModel in self.superMarketData.data.categories) {
        NSArray *goodsArr = (NSArray *)[productsModel valueForKeyPath:[cModel valueForKey:@"id"]];
        [self.goodsArr addObject:goodsArr];
    }
    [self.productsTableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.productsTableView) { // 右边tableView 👉➡️
         return self.superMarketData.data.categories.count;
    }else{  // 左边tableView 👈⬅️
       return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.categoryTableView) { // 左边tableView 👈⬅️
        return self.superMarketData.data.categories.count;
    }else{  // 右边tableView 👉➡️
        if (self.goodsArr.count > 0) {
            NSArray *arr = self.goodsArr[section];
            return arr.count;
        }
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.categoryTableView) { // 左边tableView 👈⬅️
        CategoryCell *cell = [CategoryCell categoryCellWithTableView:tableView];
        cell.categoryModel = self.superMarketData.data.categories[indexPath.row];
        return cell;
    }else { // 右边tableView 👉➡️
        ProductsCell *cell = [ProductsCell productsCellWithTableView:tableView];
        Goods *goods = self.goodsArr[indexPath.section][indexPath.row];
        cell.goods = goods;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.productsTableView) { // 右边tableView 👉➡️
        return 25;
    }else{  // 左边tableView 👈⬅️
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.categoryTableView) { // 左边tableView 👈⬅️
        return 45;
    }else{  // 右边tableView 👉➡️
        return 100;
    }
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([tableView isEqual:self.productsTableView]) {
        SupermarketHeadView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MGKSupermarketHeadView"];
        headView.hidden = NO;
        CategoriesModel *categoryModel = self.superMarketData.data.categories[section];
        if (self.superMarketData.data.categories.count > 0 && [categoryModel valueForKey:@"name"] != nil ) {
            headView.titleLabel.text =  [categoryModel valueForKey:@"name"];
        }
        return headView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.categoryTableView) { // 左边tableView 👈⬅️
        self.categortsSelectedIndexPath = indexPath;
        [MGNotificationCenter postNotificationName:MGCategortsSelectedIndexPathNotificationCenter object:nil];
    }else{ // 右边tableView 👉➡️
       
    }
}

#pragma mark - =============== 以下方法用来滚动 滚动  滚动 =================
#pragma mark - 用来滚动滚动滚动
// 头部即将消失
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    _productSection = section;
    [MGNotificationCenter postNotificationName:MGWillDisplayHeaderViewNotificationCenter object:nil];
}

// 头部完全消失
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    _productSection = section;
    [MGNotificationCenter postNotificationName:MGDidEndDisplayingHeaderViewNotificationCenter object:nil];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.productsTableView) { // 右边tableView 👉➡️
        self.isScrollDown = (_lastOffsetY < scrollView.contentOffset.y);
        _lastOffsetY = scrollView.contentOffset.y;
    }else{  // 左边tableView 👈⬅️
        return;
    }
}


#pragma mark - 通知
- (void)addNotication{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 1.左边选中的通知
    [MGNotificationCenter addObserverForName:MGCategortsSelectedIndexPathNotificationCenter object:nil queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        [self.productsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_categortsSelectedIndexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
    
    // 2.HeaderView完全消失的通知
    [MGNotificationCenter addObserverForName:MGWillDisplayHeaderViewNotificationCenter object:nil queue:queue usingBlock:^(NSNotification * _Nonnull note) {
        [self.categoryTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_productSection inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }];
    
    // 3.HeaderView即将消失的通知
    [MGNotificationCenter addObserverForName:MGDidEndDisplayingHeaderViewNotificationCenter object:queue queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.categoryTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(_productSection+1) inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }];
}

- (void)dealloc{
    [MGNotificationCenter removeObserver:self];
}

@end


// 获取指定的目录
// NSUserDomainMask,默认手机开发的话，就填该参数
// YES是表示详细目录，如果填NO的话，那么前面的目录默认会用~表示，这个~在电脑可以识别，在手机里面是不能识别的，所以默认也用YES
//    NSString *path2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//
//    // 拼接路径名称
////    NSString *filePath = [path2 stringByAppendingString:@"array.plist"];
//    NSString *filePath = [path2 stringByAppendingPathComponent:@"array.plist"];
//    MGLog(@"%@",path2);
//    //把数组写入到文件
//    [dict writeToFile:filePath atomically:YES];
