//
//  ViewController.m
//  test1
//
//  Created by ylicloud on 16/4/7.
//  Copyright © 2016年 ylicloud. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ViewController
@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,40, self.view.frame.size.width, self.view.frame.size.height)];
 
    webView.keyboardDisplayRequiresUserAction = NO;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    webView.scrollView.bounces = NO;
    [webView setDelegate:self];
    [self.view addSubview:webView];
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"测试" ofType:@"txt"];
    NSLog(@"%@",filePath);
    [self test:filePath];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)test:(NSString*) path
{
 
    NSURL *url = [NSURL fileURLWithPath:path];
    NSLog(@"111%@  2222%@  3333%@", url.relativePath, url.absoluteString,url.relativeString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    return;
    
    NSStringEncoding enc = 0x80000631;
    NSString *htmlString = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
     NSLog(@"%@",htmlString);
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:path]];
    
    return;
    
   
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       // NSString *fileExtension = [path pathExtension];
        NSString *encodeType = nil;
        //if([fileExtension caseInsensitiveCompare:@"txt"] == NSOrderedSame){
           encodeType = [self decodeData2String:path];
//        }
//        else if([fileExtension caseInsensitiveCompare:@"html"] == NSOrderedSame ||
//                [fileExtension caseInsensitiveCompare:@"htm"] == NSOrderedSame)
//        {
//            encodeType = [self getFileCharset:path];
//        }
        if(encodeType){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *data = [NSData dataWithContentsOfFile:path];
                NSString *str = [path lastPathComponent];
                NSRange range = [path rangeOfString:str];
                NSMutableString *mutablestr = [[NSMutableString alloc] initWithString:path];
                [mutablestr deleteCharactersInRange:range];
                NSURL *baseUrl = [NSURL fileURLWithPath:mutablestr];
                NSLog(@"%@",baseUrl);
                [self.webView loadData:data MIMEType:@"text/html" textEncodingName:encodeType baseURL:baseUrl];
            });
        }
       
    });
}

- (NSString *)getFileCharset:(NSString *)localfilePath
{
    // GBK解码
    NSStringEncoding enc = 0x80000632;
    // utf8解码
    // NSStringEncoding utf8 = NSUTF8StringEncoding;
    
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:localfilePath];
    [inputStream open];
    NSInteger maxLength = 512;
    uint8_t readBuffer [maxLength];
    //是否已经到结尾标识
    BOOL endOfStreamReached = NO;
    while (!endOfStreamReached)
    {
        NSInteger bytesRead = [inputStream read:readBuffer maxLength:maxLength];
        if (bytesRead == 0)
        {
            //文件读取到最后
            endOfStreamReached = YES;
        }
        else if (bytesRead == -1)
        {
            //文件读取错误
            endOfStreamReached = YES;
        }
        else
        {
            NSString *readBufferString = [[NSString alloc] initWithBytesNoCopy:readBuffer length:bytesRead encoding:enc freeWhenDone:NO];
            if (readBufferString)
                [mutStr appendString:readBufferString];
            if ([mutStr rangeOfString:@"charset=gb"].location != NSNotFound
                || [mutStr rangeOfString:@"charset=GB"].location != NSNotFound)
            {
                return @"GBK";
            }
            
            endOfStreamReached = YES;
        }
    }
    
    return @"UTF-8";
}


#pragma mark 文本解码
- (NSString *)decodeData2String:(NSString *)path
{
   NSStringEncoding enc = NSUTF8StringEncoding;
    NSString * res = @"UTF-8";
    // 假如txt文件带编码头，则获取头
    NSString *txtContent = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
    if (!txtContent)
    {
        // GBK解码
        enc = 0x80000632;
        res = @"GBK";
        txtContent = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];

    }
    if (!txtContent)
    {
        // GB18030解码
        enc = 0x80000631;
        txtContent = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
        res = @"GB18030";
    }
    if (!txtContent)
    {
        // ISO 8859-1 + GB 2312-80解码
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_CN);
        NSStringEncoding isoEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
        NSString *str = [NSString stringWithContentsOfFile:path encoding:isoEncoding error:nil];
        NSData *name = [str dataUsingEncoding:isoEncoding];
        txtContent = [[NSString alloc] initWithData:name encoding:gbkEncoding];
        res = @"GBK";
        NSLog(@"GB 2312-80解码 %@",txtContent);
    }
    if (!txtContent)
    {
        // ISO 8859-1 + GBK解码
        NSStringEncoding enc = 0x80000632;
        NSStringEncoding isoEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
        NSString *str = [NSString stringWithContentsOfFile:path encoding:isoEncoding error:nil];
        NSData *name = [str dataUsingEncoding:isoEncoding];
        txtContent = [[NSString alloc] initWithData:name encoding:enc];
        res = @"GBK";
        NSLog(@"ISO 8859-1 %@",txtContent);
    }
    if (!txtContent)
    {
        res = @"UTF-8";
    }

    return res;
}

@end

