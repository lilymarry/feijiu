//
//  SupplierflowViewController.m
//  FeijiuOA
//
//  Created by imac-1 on 2017/12/18.
//  Copyright © 2017年 魏艳丽. All rights reserved.
//

#import "SupplierflowViewController.h"
#import "BaoBiaoWebApi.h"
#import "SupplierflowModel.h"
#import "SupplierflowView.h"
#import "SupplierflowCelll.h"
#import "AlertHelper.h"
#import "SelectItemViewController.h"
#import "UserPermission.h"
#import "AppDelegate.h"
#import "URL.h"
#import "ImageHelpViewController.h"
#define tittleWidth 2005
@interface SupplierflowViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    NSMutableArray *dataArr;
    UIScrollView *rightScrollView;
    UITableView *rightTableView;
    SupplierflowView *view2;
    NSString *hwmcc;
    NSString *gyss;
   int indexy;
    
}
@property (strong, nonatomic)  UIButton *btn_time;

@property (weak, nonatomic) IBOutlet UILabel *lab_rkjs;
@property (weak, nonatomic) IBOutlet UILabel *lab_jsjz;
@property (weak, nonatomic) IBOutlet UILabel *lab_zje;
@property (weak, nonatomic) IBOutlet UILabel *lab_zcc;
@property (weak, nonatomic) IBOutlet UILabel *lab_pjdj;

@property (weak, nonatomic) IBOutlet UILabel *lab_tittle
;
@property (strong, nonatomic)  UILabel *titleLab;
@property (strong, nonatomic)  UIButton *stBtn;
@property (strong, nonatomic)  UIButton *etBtn;

@end

@implementation SupplierflowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
 //    self. automaticallyAdjustsScrollViewInsets=NO;
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.allowRotation = YES;//(以上2行代码,可以理解为打开横屏开关)
    
    [self setNewOrientation:YES];//调用转屏代码
    
   [self setNavigationView];
    
//    if(kDevice_Is_iPhoneX)
//    {
//        indexy=46;
//    }
//    else
//    {
//        indexy=0;
 // }
 //   NSLog(@"WWW%d",indexy);
 
    if ([self.flag isEqualToString:@"0"]) {
        NSDate *date=[NSDate date];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
        [_btn_time setTitle:[dateFormatter1 stringFromDate:date] forState:UIControlStateNormal];
  
        
        
    }
    else
    {
        
        NSDate *date=[NSDate date];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM"];
        [_btn_time setTitle:[dateFormatter1 stringFromDate:date] forState:UIControlStateNormal];

        
    }
    
    hwmcc=@"";
    gyss=@"";
    if ([[UserPermission standartUserInfo].isgys isEqualToString:@"1"]) {
        gyss=[UserPermission standartUserInfo].gysjc;
    }
    dataArr =[NSMutableArray array];

    rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,scrollViewWidth, self.view.frame.size.height,self.view.frame.size.width-scrollViewWidth)];
    rightScrollView.bounces = NO;
    rightScrollView.delegate = self;
   [self.view addSubview:rightScrollView];
    rightScrollView.contentSize = CGSizeMake(tittleWidth,self.view.frame.size.width-scrollViewWidth);


    rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, tittleWidth, CGRectGetHeight(rightScrollView.frame))];
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    rightTableView.rowHeight = 50;
    [rightScrollView addSubview:rightTableView];

    if ([self.flag isEqualToString:@"0"]) {
   
          _titleLab.text=@"每日流水统计";
        
    }
    else
    {

          _titleLab.text=@"每月流水统计";
    }


    [self getDataWithTime:_btn_time.titleLabel.text];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    

    // [self setNavigationView];
    
}

-(void)getDataWithTime:(NSString *)time
{
    NSString *method=@"supplierdailyflow";
    if ([self.flag isEqualToString:@"0"]) {
        
        method=@"supplierdailyflow";
    }
    else
    {
      method=@"suppliermonthlyflow";
        
    }
    [dataArr removeAllObjects];

    _lab_tittle.text=@"入库件数:0 平均单价:0 总车次:0 总金额:0 结算净重:0 净重:0";
    [AlertHelper MBHUDShow:@"加载中..." ForView:self.view AndDelayHid:30];
    [BaoBiaoWebApi supplierflowWithDate:time hwmc:hwmcc gys:gyss method:method Success:^(NSArray *arr) {
          [AlertHelper hideAllHUDsForView:self.view];
        
        @try {
            
            for (NSDictionary *dict in arr[0][@"lls"]) {
                SupplierflowModel *model=[[SupplierflowModel alloc]init];
                [model setValuesForKeysWithDictionary:dict];
                
                [dataArr addObject:model];
            }
            
            NSArray *data=arr[0][@"tj"];
            if (data.count>0) {
              NSDictionary *dic=arr[0][@"tj"][0];
                NSMutableString *str=[NSMutableString string];
                [str appendFormat:@"入库件数:%@ 平均单价:%@ 总车次:%@ 总金额:%@ 结算净重:%@ 净重:%@ ",dic[@"rkjs"],dic[@"pjdj"],dic[@"zcc"],dic[@"zje"],dic[@"rkjs"],dic[@"jz"]];
                _lab_tittle.text=str;
            }
           
            
            [rightTableView reloadData];
            
        }
        @catch (NSException *exception) {
            [AlertHelper singleMBHUDShow:@"无数据！" ForView:self.view AndDelayHid:2];
        }
        @finally {
            
        }
        
    } fail:^{
        [AlertHelper hideAllHUDsForView:self.view];
        
        [AlertHelper singleMBHUDShow:@"网络请求数据失败" ForView:self.view AndDelayHid:1];

    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectItemPress:(id)sender {

      SelectItemViewController *changyongController=  [ [SelectItemViewController alloc] initWithBlock:^(NSString *hwmc,NSString *gys,NSString *st ,NSString *et)
     {
         hwmcc=hwmc;
         gyss=gys;
         [self getDataWithTime:_btn_time.titleLabel.text];
     }];
    changyongController.state=@"0";
    changyongController.st=@"";
    changyongController.et=@"";
    changyongController.hwmc=hwmcc;
    changyongController.gys=gyss;
    [self.navigationController pushViewController:changyongController animated:YES];
}


- (void)back

{
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
    
    [self setNewOrientation:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)setNavigationView
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    UIView  *view=[[UIView alloc]initWithFrame:CGRectMake(100, 0,self.view.frame.size.height-200, 30)];
    self.navigationItem.titleView=view;
    
    _titleLab=[[UILabel alloc ] initWithFrame:CGRectMake(0, 0,100, 30)];
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.font=[UIFont systemFontOfSize:14];
    [view addSubview:_titleLab];
    
    
    _stBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _stBtn. frame=CGRectMake(CGRectGetMaxX (_titleLab.frame)+9, 0,43, 30);
    [_stBtn setImage:[UIImage imageNamed:@"zuo.png"] forState:UIControlStateNormal];
    [_stBtn addTarget:self action:@selector(timePress:) forControlEvents:UIControlEventTouchUpInside];
    _stBtn.tag=1000;
    _stBtn.titleLabel .font =[UIFont systemFontOfSize:12];
    [view addSubview:_stBtn];
    
    _btn_time=[UIButton buttonWithType:UIButtonTypeCustom];
    _btn_time. frame=CGRectMake(CGRectGetMaxX (_stBtn.frame)+9,0,80, 30);
    // [_btn_time addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    //  _btn_time.tag=1000;
    [_btn_time setTitle:@"2014-01-01" forState:UIControlStateNormal];
    _btn_time.titleLabel .font =[UIFont systemFontOfSize:12];
    [view addSubview:_btn_time];
    
    _etBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _etBtn. frame=CGRectMake(CGRectGetMaxX (_btn_time.frame)+9,0,43, 30);
    [_etBtn setImage:[UIImage imageNamed:@"you.png"] forState:UIControlStateNormal];
    [_etBtn addTarget:self action:@selector(timePress:) forControlEvents:UIControlEventTouchUpInside];
    _etBtn.tag=1001;
    _etBtn.titleLabel .font =[UIFont systemFontOfSize:12];
    [view addSubview:_etBtn];
    
}
- (void)timePress:(id)sender {
    UIButton *but= (UIButton *) sender;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([self.flag isEqualToString:@"0"]) {
           [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:_btn_time.titleLabel.text];
            NSDate *lastDay;
            if (but.tag==1000) {//时区问题 +8
                lastDay = [NSDate dateWithTimeInterval:-24*60*60+8 sinceDate:date];
        
            }
            else
            {
                lastDay = [NSDate dateWithTimeInterval:+24*60*60+8 sinceDate:date];
            }
       
            [_btn_time setTitle:[dateFormatter stringFromDate:lastDay] forState:UIControlStateNormal];
        [self getDataWithTime:[dateFormatter stringFromDate:lastDay]];
    }
    else
    {
        

        [dateFormatter setDateFormat:@"yyyy-MM"];
        NSDate *currentDate = [dateFormatter dateFromString:_btn_time.titleLabel.text];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
        //1表示1年后的时间 year = -1为1年前的日期，month day 类推
        if (but.tag==1000) {
              [lastMonthComps setMonth:-1];
        }
        else{
            
             [lastMonthComps setMonth:1];
        }
      
        NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
         [_btn_time setTitle:[dateFormatter stringFromDate:newdate] forState:UIControlStateNormal];
         [self getDataWithTime:[dateFormatter stringFromDate:newdate]];
     
    }
   
  

}

#pragma tableViewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     view2 = [[SupplierflowView alloc]instanceChooseView];
    [view2 setFrame:CGRectMake(0, 0, tittleWidth,50)];
    UIView *view = [[UIView alloc] initWithFrame:view2.frame];
    [view addSubview:view2];
    return view;
   
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
            return 50;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identfier=@"cell";
    SupplierflowCell *cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SupplierflowCell" owner:self options:nil] lastObject];
        
    }
    SupplierflowModel *model=[dataArr objectAtIndex:indexPath.row];
    cell.hwmc.text=model.hwmc;
    cell.jycs.text=model.jycs;
    cell.rkdh.text=model.rkdh;
    cell.dj.text=model.dj;
    cell.cph.text=model.cph;
    cell.kw.text=model.kw;
    cell.mz.text=model.mz;
    cell.mzsj.text=model.mzsj;
    cell.pz.text=model.pz;
    cell.pzsj.text=model.pzsj;
    cell.kl.text=model.kl;
    cell.kz.text=model.kz;
    cell.jz.text=model.jz;
    cell.jsjz.text=model.jsjz;
    cell.rkjs.text=model.rkjs;
    cell.jyjs.text=model.jyjs;
    cell.dje.text=model.dje;
    cell.je.text=model.je;
    cell.djrq.text=model.djrq;
    cell.rkrq.text=model.rkrq;
    cell.zdmc.text=model.zdmc;
    cell.xhf.text=model.xhf;
    cell.xhfdj.text=model.xhfdj;
    cell.gys.text=model.gys;
    cell.shr.text=model.shr;
    
    return cell;
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SupplierflowModel *model=[dataArr objectAtIndex:indexPath.row];
    
    NSLog(@"SSSS_ %@",model.piclist);
    ImageHelpViewController *tab=[[ImageHelpViewController alloc] init ];
    tab.model=model;
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
    
    [self setNewOrientation:NO];
    
    [self.navigationController pushViewController:tab animated:YES];
    
}
- (void)setNewOrientation:(BOOL)fullscreen

{
    if (fullscreen) {
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }else{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}

@end