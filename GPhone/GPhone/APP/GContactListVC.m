//
//  GContactListVC.m
//  GPhone
//
//  Created by Dylan on 2017/11/23.
//  Copyright © 2017年 郁兵生. All rights reserved.
//  通讯录

#import "GContactListViewController.h"
#import <Contacts/Contacts.h>
#import "GContactsManager.h"
#import "GContact.h"

@interface GContactListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating>
{
    NSMutableDictionary* friendMuDic;
    NSMutableArray* keysMuArr;
    NSMutableArray* searNameArr;
    NSString* searHearStr;
    
    BOOL isSear;
}

@property (nonatomic, strong) UISearchController *contactSearchController;
@property (nonatomic, strong) UITableView* contactTableView;

@property (nonatomic, strong) NSArray* contactList;

@end

@implementation GContactListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    searNameArr = [NSMutableArray array];
    
    [self requestData];
    [self contactTableView];
}


-(void)requestData{
    
    
    [self myFriendArrrrrrr];
    
    NSArray *keysArray = [friendMuDic allKeys];
    NSArray *resultArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    keysMuArr = [NSMutableArray arrayWithArray:resultArray];
    
    [keysMuArr removeObjectIdenticalTo:@"#"];
    [keysMuArr insertObject:@"#" atIndex:keysMuArr.count];
    
}

// 对通讯录进行 排序
- (void)myFriendArrrrrrr
{
    NSArray* zhimeArr = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    friendMuDic = [NSMutableDictionary dictionary];
    keysMuArr = [NSMutableArray array];
    
    for(int i=0;i<[self.contactList count];i++){
        GContact *chineseString=[self.contactList objectAtIndex:i];
        
        NSString* oneStr = [chineseString.contactNamePY substringToIndex:1];
        
        for (NSString* str in zhimeArr) {
            
            if ([oneStr isEqualToString:str]) {
                
                if ([friendMuDic objectForKey:str]==nil) {
                    NSMutableArray* array = [NSMutableArray array];
                    
                    [array addObject:chineseString];
                    [friendMuDic setObject:array forKey:str];
                    
                }else{
                    NSMutableArray* array = [friendMuDic objectForKey:str];
                    
                    [array addObject:chineseString];
                    [friendMuDic setObject:array forKey:str];
                    
                }
            }
        }
        
        if (![self isarray:oneStr]) {
            if (![oneStr isEqualToString:@"#"]) {
                if ([friendMuDic objectForKey:@"#"]==nil) {
                    NSMutableArray* array = [NSMutableArray array];
                    
                    [array addObject:chineseString];
                    [friendMuDic setObject:array forKey:@"#"];
                    
                }else{
                    NSMutableArray* array = [friendMuDic objectForKey:@"#"];
                    
                    [array addObject:chineseString];
                    [friendMuDic setObject:array forKey:@"#"];
                    
                }
            }
        }
    }
}

- (BOOL)isarray:(NSString*)string
{
    
    NSArray* zhimeArr1 = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    BOOL isBool = [zhimeArr1 containsObject: string];
    
    return isBool;
}


#pragma mark- tabledatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (isSear) {
        return 1;
    }else{
        return [friendMuDic allKeys].count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSear) {
        return searNameArr.count;
    }else{
        return [[friendMuDic objectForKey:[keysMuArr objectAtIndex:section]] count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    GContact* chinese;
    if (isSear) {
        chinese = [searNameArr objectAtIndex:indexPath.row];
    }else{
        NSArray* cellArr = [friendMuDic objectForKey:[keysMuArr objectAtIndex:indexPath.section]];
        chinese = [cellArr objectAtIndex:indexPath.row];
    }
    
    
    cell.textLabel.text =chinese.contactName;
    
    return cell;
}

#pragma mark- tableview delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 25)];
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 25)];
    [view addSubview:label];
    
    if (isSear) {
        label.text = searHearStr;
    }else{
        label.text = [keysMuArr objectAtIndex:section];
    }
    
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    tableView.sectionIndexColor = [UIColor grayColor];
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexTrackingBackgroundColor = [UIColor lightGrayColor];
    
    
    return keysMuArr;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GContact* chinese;
    
    if (isSear) {
        
        chinese = [searNameArr objectAtIndex:indexPath.row];
    }else{
        NSArray* cellArr = [friendMuDic objectForKey:[keysMuArr objectAtIndex:indexPath.section]];
        chinese = [cellArr objectAtIndex:indexPath.row];
    }
    NSLog(@"nameStr == %@",chinese.contactName);
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text ;
    
    if ([inputStr isEqualToString:@""]){
        isSear = NO;
    }else{
        isSear = YES;
        NSArray* array = [self tableViewSear:inputStr];
        searNameArr = [NSMutableArray arrayWithArray:array];
        
            [self zhimeFromSearString:inputStr];
    }

    [self.contactTableView reloadData];

}

#pragma mark - UIsearchBardelegate

- (NSArray*)tableViewSear:(NSString*)searStr
{
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (GContact* chinese in self.contactList) {
        if (searStr.length<=chinese.contactName.length) {
            NSString * toStr = [chinese.contactName substringToIndex:searStr.length];
            if ([toStr isEqualToString:searStr]) {
                [array addObject:chinese];
            }
        }
    }
    
    return array;
}


- (void)zhimeFromSearString:(NSString*)string{
    
    NSMutableString * pinYin = [[NSMutableString alloc]initWithString:string];
    //1.先转换为带声调的拼音
    if(CFStringTransform((__bridge CFMutableStringRef)pinYin, NULL, kCFStringTransformMandarinLatin, NO)) {
        NSLog(@"带声调的pinyin: %@", pinYin);
    }
    
    //2.再转换为不带声调的拼音
    if (CFStringTransform((__bridge CFMutableStringRef)pinYin, NULL, kCFStringTransformStripDiacritics, NO)) {
        NSLog(@"不带声调的pinyin: %@", pinYin);
        
        NSString *upper = [pinYin uppercaseString];
        searHearStr = [upper substringToIndex:1];
    }
}

- (UISearchController*)contactSearchController {
    if (!_contactSearchController) {
        _contactSearchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        _contactSearchController.searchResultsUpdater = self;
        _contactSearchController.dimsBackgroundDuringPresentation = YES;
        _contactSearchController.searchBar.placeholder = @"搜索";
    }
    return _contactSearchController;
}


- (UITableView*)contactTableView {
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _contactTableView.backgroundColor = [UIColor clearColor];
        _contactTableView.tableHeaderView = self.contactSearchController.searchBar;
        _contactTableView.dataSource = self;
        _contactTableView.delegate = self;
        [self.view addSubview:_contactTableView];
    }
    return _contactTableView;
}


- (NSArray*)contactList{
    if (!_contactList) {
        GContactsManager* contactsManager = [GContactsManager contactsManager];
        _contactList = [NSMutableArray arrayWithArray:contactsManager.contacts];
    }
    return _contactList;
}


@end
