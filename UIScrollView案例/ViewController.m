//
//  ViewController.m
//  UIScrollView案例
//
//  Created by 童益鳴 on 2020/03/16.
//  Copyright © 2020 童益鳴. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate> /* 让控制器遵守代理协议*/
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *lastImgView;

@end

/*
需求：监听UIScrollView的滚动事件
分析：要监听UIScrollView的滚动事件，需要通过代理来实现，无法通过addTarget：的方式监听。
通过代理监听滚定事件的步骤：
1，为UIScrollView找一个代理对象，也就是设置UIScrollView的delegate属性
 self.scrollView.delegate = self;
 提醒：不需要单独创建一个代理对象，直接将控制器作为控件的代理对象即可。
 
 2，为保证代理对象中拥有对应的方法，所以必须让代理对象（控制器自己）遵守对应控件的代理协议（当前控制器要做为哪个控件的代理对象，那么控制器就要遵守这个控件的代理协议）
 一般控件的代理协议命名规则都是：控件名Delegate（eg：UIScrollViewDelegate）
 
 3，在控制器中实现需要的方法
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   //启用scrollview，必须先设置他的contentSize
    //控件的最大的Y值，maxY = y + 控件本身的高
    CGFloat maxH = CGRectGetMaxY(self.lastImgView.frame);
    self.scrollView.contentSize = CGSizeMake(0, maxH);
   //设置默认滚动开始的偏移量
    self.scrollView.contentOffset = CGPointMake(0, -(64 + 10));
    
    //为UIScrollView找代理 两种方式
    //方式① 让当前控制器作为UIScrollView的代理对象
    //方式② 选中控件，点选delegate拖线到控制器
    self.scrollView.delegate = self;
   //设置极端滑动时距离上面的始终有74的内边距，距离下面54的内边距
    self.scrollView.contentInset = UIEdgeInsetsMake(74, 0, 54, 0);
}

//①bonus设置启动页淡出效果
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self launchAnimation];
}

#pragma mark - Private Methods
//②bonus设置启动页淡出效果
- (void)launchAnimation
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"launch"];
    UIView *launchView = vc.view;
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    launchView.frame = [UIApplication sharedApplication].keyWindow.frame;
    [mainWindow addSubview:launchView];
    
    [UIView animateWithDuration:3.0f delay:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        launchView.alpha = 0.0f;
        launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.0f, 2.0f, 1.0f);
    } completion:^(BOOL finished) {
        [launchView removeFromSuperview];
    }];
}

//toast提示
- (void)makeToast:(NSString *)message
{
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIView *firstSubview = alert.view.subviews.firstObject;
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:141/255.0f green:0/255.0f blue:254/255.0f alpha:1.0f];
    }
    NSMutableAttributedString *AS = [[NSMutableAttributedString alloc] initWithString:message];
    [AS addAttribute: NSForegroundColorAttributeName value: [UIColor whiteColor] range: NSMakeRange(0,AS.length)];
    [alert setValue:AS forKey:@"attributedTitle"];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
    });
}

//delegate 即将开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"即将开始拖拽... %s",__func__);
}

//delegate 正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"正在滚动... %s",__func__);
    //当前滚动的位置(监听)
    NSString *pointStr = NSStringFromCGPoint(scrollView.contentOffset);
    int movedH = scrollView.contentOffset.y;
    int ENUM_TYPE = 0;
    if (movedH > 230) {
        ENUM_TYPE = 1;
    } else if (movedH < -200) {
        ENUM_TYPE = 2;
    }
    NSLog(@"-- %@",pointStr);
    switch (ENUM_TYPE) {
        case 0:
            break;
        case 1:
            [self makeToast:@"已经下移至底部！"];
            break;
        case 2:
            [self makeToast:@"已经上移至顶部！"];
            break;
        default:
            break;
    }
}

//delegate 滚动完毕
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"滚动完毕... %s",__func__);
}

////delegate 滚动完毕
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//   NSLog(@"滚动完毕... %s",__func__);
//}

@end
