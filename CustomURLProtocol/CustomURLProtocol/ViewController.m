#import "ViewController.h"
#import "AFNetworking.h"
#import "CustomURLProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIButton *btn = [UIButton new];
//    btn.backgroundColor = [UIColor orangeColor];
    
    [CustomURLProtocol startMonitor];
    

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40, 50)];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"网络请求" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

// 网络请求
- (void)clickBtn {
    
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
    
}
@end
