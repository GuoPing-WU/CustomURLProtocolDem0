#import "ViewController.h"
#import "AFNetworking.h"
#import "CustomURLProtocol.h"
#import "NSURLProtocol+WebKitSupport.h"
#import "ReplacingImageURLProtocol.h"
#import "ViewController111.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //测试DNS解析
//    [CustomURLProtocol startMonitor];
    //测试WKWebView支持NSURLProtocol
//    [NSURLProtocol registerClass:[ReplacingImageURLProtocol class]];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 50)];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"网络请求" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 100;
    [self.view addSubview:btn];
    
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 150, self.view.frame.size.width - 40, 50)];
    btn1.backgroundColor = [UIColor blueColor];
    [btn1 setTitle:@"URLProtocol handled" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag = 101;
    [self.view addSubview:btn1];
    
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width - 40, 50)];
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 setTitle:@"URLProtocol not handled" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn2.tag = 102;
    [self.view addSubview:btn2];
}

// 网络请求
- (void)clickBtn:(UIButton *)sender {
    
    if (sender.tag == 100) {
        //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //    configuration.protocolClasses = @[[CustomURLProtocol class]];

        //    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:configuration];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //    [manager GET:@"http://www.baidu.com" parameters:nil headers:nil progress:nil success:nil failure:nil];
            
            [manager POST:@"http://www.baidu.com" parameters:@{@"key": @"123"} headers:nil progress:nil success:nil failure:nil];
          
            
            //    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://xiaozhuanlan.com"]];
            //    NSURLSession *session = [NSURLSession sharedSession];//注意这里使用的是sharedSession
            
            
            //    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
            //    self.dataTask = [session dataTaskWithRequest:req];
            //    [self.dataTask  resume];
    } else {
        
        //iOS 11.0之前支持WKWebView的方法
//        for (NSString* scheme in @[@"http", @"https"]) {
//            if ([sender tag] == 101) {
//                [NSURLProtocol wk_registerScheme:scheme];
//            } else {
//                [NSURLProtocol wk_unregisterScheme:scheme];
//            }
//        }
        
        [self presentViewController:[ViewController111 new] animated:YES completion:nil];
    }
}
@end
