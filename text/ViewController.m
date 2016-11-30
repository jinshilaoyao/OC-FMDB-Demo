//
//  ViewController.m
//  text
//
//  Created by YangY on 2016/11/21.
//  Copyright © 2016年 羊羊. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    FMDatabase * dataBase;
    NSMutableArray * _usernameArr;
    NSMutableArray * _passwordArr;
    UIAlertController * _alert;
}
@property (weak, nonatomic) IBOutlet UITableView *table;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1 获取数据库对象
    NSString *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path=[path stringByAppendingPathComponent:@"userInfo.sqlite"];
    
    dataBase=[FMDatabase databaseWithPath:path];
    // 2 打开数据库，如果不存在则创建并且打开
    BOOL open=[dataBase open];
    if(open){
        NSLog(@"数据库打开成功");
    }
    //3 创建表
    NSString * create1=@"CREATE TABLE IF NOT EXISTS A_user (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,username TEXT,password TEXT)";
    BOOL c1= [dataBase executeUpdate:create1];
    if(c1){
        NSLog(@"创建表成功");
    }
    
    _alert = [UIAlertController alertControllerWithTitle:@"请输入账号密码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"账号";
    }];
    [_alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
    }];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [_alert addAction:action1];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!_alert.textFields[0].text||!_alert.textFields[1].text) {
            return ;
        }
//        4 插入数据
        NSString * insertSql= @" INSERT INTO A_user(username, password)VALUES(?,?)";
        //    插入语句
        bool inflag1=[dataBase executeUpdate:insertSql,_alert.textFields[0].text,_alert.textFields[1].text];
        if(inflag1){
            NSLog(@"插入数据成功");
            [self selectForm];
            [self.table reloadData];
        }
    }];
    [_alert addAction:action2];
    
    _usernameArr = [[NSMutableArray alloc] init];
    _passwordArr = [[NSMutableArray alloc] init];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.tableFooterView = [UIView new];

    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(click)];
    self.navigationItem.rightBarButtonItem = left;
    [self selectForm];
}
//数据库查询操作
- (void)selectForm{
    [_usernameArr removeAllObjects];
    [_passwordArr removeAllObjects];
    //    5查询数据FMDB的FMResultSet提供了多个方法来获取不同类型的数据
    NSString * sql=@" select * from A_user ";
    FMResultSet *result=[dataBase executeQuery:sql];
    
    while(result.next){
        NSString * username =[result stringForColumn:@"username"];
        [_usernameArr addObject:username];
        NSString * password =[result stringForColumn:@"password"];
        [_passwordArr addObject:password];
    }
}
- (void)click{
    [self presentViewController:_alert animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _usernameArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _usernameArr[indexPath.row];
    cell.detailTextLabel.text = _passwordArr[indexPath.row];
    return cell;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        UIAlertController * editAlert = [UIAlertController alertControllerWithTitle:@"修改账号密码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [editAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = _usernameArr[indexPath.row];
        }];
        [editAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = _passwordArr[indexPath.row];
        }];
        [self presentViewController:editAlert animated:YES completion:nil];

        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [editAlert addAction:action3];
        UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //    修改语句
            BOOL flag=  [dataBase executeUpdate:@" UPDATE A_user SET username = ?,password = ? WHERE id = ?;",editAlert.textFields[0].text,editAlert.textFields[1].text,@(indexPath.row+1)];
            if(flag){
                NSLog(@"修改成功");
                [self selectForm];
                [self.table reloadData];
            }
        }];
        [editAlert addAction:action4];
    }];
        
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //        删除语句
            BOOL dflag= [dataBase executeUpdate:@"delete from A_user WHERE username = ?",_usernameArr[indexPath.row]];
            if(dflag){
                NSLog(@"删除");
                [_usernameArr removeObjectAtIndex:indexPath.row];
                [_passwordArr removeObjectAtIndex:indexPath.row];
                [self.table reloadData];
            }

    }];
    
    return @[editAction,deleteAction];
}
@end
