//
//  GCDViewController.m
//  NOTE
//
//  Created by 卢腾达 on 2018/11/5.
//  Copyright © 2018 卢腾达. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //    __block NSInteger time = 59; //倒计时时间
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    //    dispatch_source_set_event_handler(_timer, ^{
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //            });
    //
    //        if (time == 0) {
    //            dispatch_source_cancel(_timer);
    //        }
    //            time--;
    //    });
    //    dispatch_resume(_timer);
    
    
    
    //    NSLog(@"1");
    //    dispatch_queue_t queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    //    dispatch_async(queue, ^{
    //        NSLog(@"2");
    //        dispatch_sync(queue, ^{
    //            NSLog(@"3");
    //        });
    //        NSLog(@"4");
    //    });
    //    NSLog(@"5");
    //    [self interview01];
    [self TDdispatch_group];
}

- (void)interview01
{
    NSLog(@"执行任务1");
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ // 0
        NSLog(@"执行任务2");
        dispatch_sync(queue, ^{ // 1
            NSLog(@"执行任务3");
        });
        NSLog(@"执行任务4");
    });
    NSLog(@"执行任务5");
}

- (void)TDdispatch_queue_create{
    /*
     第一个参数:指定队列的名称
     推荐使用应用程序ID这种逆序全称域名(FQDN fully qualified domain name)
     该名称会在instruments调试器中作为dispatch queue名称表示
     也会出现在程序崩溃日志里
     第二个参数
     serial dispatch queue (串行对列)可以指定为:NULL
     concurrent dispatch queue (并行对列)可指定为:DISPATCH_QUEUE_CONCURRENT
     
     通过dispatch_queue_create创建的dispatch queue 在使用结束后必须通过dispatch_release方法释放
     dispatch_release(queue); 现在ARC好像可以管理GCD对象了
     */
    
    dispatch_queue_t queue = dispatch_queue_create("com.lutengda.www.TestSerial", NULL);
    dispatch_async(queue, ^{
        
    });
}

- (void)TDmain_Global{
    /*
     获取系统标准提供的dispatch queue
     是所有应用程序都能是用的concurrent dispatch queue(并行对列)
     
     第一个参数对列优先级
     
     iOS8 macOS10.10以前分四个优先级
     DISPATCH_QUEUE_PRIORITY_HIGH        高优先级
     DISPATCH_QUEUE_PRIORITY_LOW         低优先级
     DISPATCH_QUEUE_PRIORITY_DEFAULT     默认优先级
     DISPATCH_QUEUE_PRIORITY_BACKGROUND  后台运行队列
     通过XNU内核管理线程的优先级使用
     XNU不能保证global dispatch queue 的实时性,因此执行优先级还是大致判断
     
     iOS8 macOS10.10以后 服务质量
     QOS_CLASS_USER_INTERACTIVE
     QOS_CLASS_USER_INITIATED
     QOS_CLASS_DEFAULT
     QOS_CLASS_UTILITY
     QOS_CLASS_BACKGROUND
     QOS_CLASS_UNSPECIFIED
     
     user interactive类代表着为了提供良好的用户体验而需要被立即执行的任务。它经常用来刷新UI、处理一些要求
     低延迟的加载工作。在App运行的期间，这个类中的工作完成总量应该很小。
     user initiated类代表着从UI端初始化并可异步运行的任务。它在用户等待及时反馈时和涉及继续运行用户交互的
     任务时被使用。
     default类默认(不是给程序员使用的，用来重置对列使用的)
     utility类代表着长时间运行的任务，尤其是那种用户可见的进度条。它经常用来处理计算、I/O、网络通信、持续数
     据反馈及相似的任务。这个类被设计得具有高效率处理能力
     background类代表着那些用户并不需要立即知晓的任务。它经常用来完成预处理、维护及一些不需要用户交互的、对
     完成时间并无太高要求的任务。
     UNSPECIFIED 未指定
     
     第二个参数
     保留供将来使用的标志。始终指定为0。
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_async(globalQueue, ^{
        
    });
    /*
     在主线程执行的dispatch queue
     因为主线程只要一个所以main dispatch queue 是serial dispatch queue(串行队列)
     
     */
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        
    });
}

- (void)TDdispatch_set_target_queue{
    /*
     把第一个参数的对列优先级改成第二个参数的优先级
     在必须将不可并行执行处理 追加到serial dispatch queue 中时,可以使用此函数将目标指定为某一个serial dispatch queue,即可防止处理并发执行
     第一个参数
     要变更优先级的对列
     main dispatch queue 和 global dispatch queue 不能作为第一参数使用
     第二个参数
     目标对列
     */
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_queue_t TestSerialQueue = dispatch_queue_create("com.lutengda.www.TestSerial", NULL);
    dispatch_set_target_queue(TestSerialQueue, globalQueue);
}

- (void)TDdispacth_after{
    /*
     dispatch_after 并不是在指定时间后处理执行,而是在指定时间后追加dispatch queue
     此代码表示在3秒后追加block到mainQueue中执行
     因为mainQueue 在主线程中的RunLoop中执行
     runLoop循环一圈时间为 t
     那么block最快3秒后执行,最慢3+t秒后执行
     如果主线程有耗时操作或者大量追加 那么延迟的时间会更长
     第一个参数
     指定时间用的dispatch_time_t类型的值
     dispatch_time()通常计算相对时间 或 dispatch_walltime()通常计算绝对时间 获取
     第一个参数
     指定时间开始
     第二个参数
     t时间后的时间
     
     第二个参数
     指定要追加的dispatch Queue
     
     第三个参数
     追加执行的block
     */
    
    dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_after(time, mainQueue, ^{
        
    });
}

- (void)TDdispatch_group{
    /*
     使用dispatch group可以监视执行结束,一旦检测到所有处理都结束,就将结束处理追加到dispatch Queue中
     
     dispatch_notify(,,)
     第一个参数
     要监视的dispatch group
     第二个参数
     结束后要追加到的dispatch Queue
     第三个参数
     结束后要追加到dispatch Queue的block
     
     dispatch_group_wait
     
     */
    
    
    /**
     
     
     异步网络请求都完成后再通知dispatch_notify 处理后续逻辑
     方法1
     
     dispatch_group_enter 和 dispatch_group_leave 一般是成对出现的, 进入一次，就得离开一次。也就是说，当离开和进入的次数相同时，就代表任务组完成了。如果enter比leave多，那就是没完成，如果leave调用的次数多了， 会崩溃的
     方法2
     
     dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
     dispatch_semaphore_signal(semaphore);
     dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
     
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t TestSerialQueue = dispatch_queue_create("com.lutengda.www.TestSerial", DISPATCH_QUEUE_CONCURRENT);
    
    NSMutableArray *array = [NSMutableArray array];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i<100000; i++) {
        dispatch_group_async(group, TestSerialQueue, ^{
            
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            [array addObject:[NSNumber numberWithInt:i]];
            dispatch_semaphore_signal(semaphore);
            
            
        });
    }
    
    //    dispatch_group_enter(group);
    //    dispatch_group_async(group, TestSerialQueue, ^{
    //        NSLog(@"1");
    ////       方法1
    ////        [req POSTImageWithURL_Type:IMAGE_UPLOAD success:^(BOOL successBool, id reslutObject) {
    ////
    //            dispatch_group_leave(group);
    ////        } fail:^(NSString *errorMSG) {
    ////
    //            dispatch_group_leave(group);
    ////        }];
    //    });
    //
    //
    //    dispatch_group_async(group, TestSerialQueue, ^{
    //        sleep(3);
    //        NSLog(@"2");
    ////        方法2
    //        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    ////        [req POSTImageWithURL_Type:IMAGE_UPLOAD success:^(BOOL successBool, id reslutObject) {
    ////
    //        dispatch_semaphore_signal(semaphore);
    ////        } fail:^(NSString *errorMSG) {
    ////
    //        dispatch_semaphore_signal(semaphore);
    ////        }];
    //        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //    });
    
    dispatch_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"done");
    });
    //----------------------
    //    dispatch_time_t time =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    //    long result = dispatch_group_wait(group, time);
    //    if (result == 0) {
    //        //全部处理执行结束
    //    }else{
    ////        执行未结束
    //    }
}

- (void)TDdispatch_barrier_async{
    /*
     serail dispatch queue 可以避免数据竞争问题
     
     写入处理不可与其他写入和读取并行执行
     读取与读取并行执行不会有问题
     读取处理追加到并发队列
     写入处理在任一一个读取处理没有执行的情况下 追加到串行队列中即可 (在写入操作结束之前,读取操作不可执行)
     
     dispatch_barrier_async会等待追加到concurrent dispatch queue的并行处理执行结束,再指定处理追加到concurrent dispatch queue中
     dispatch_barrier_async处理执行结束后 concurrent dispatch Queue才恢复一般动作,
     
     */
    dispatch_queue_t TestQueue = dispatch_queue_create("com.lutengda.www.Test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(TestQueue, ^{
        
        
    });
}

- (void)TDdispatch_apply{
    /*
     按指定次数将block追加到指定的dispatch Queue中,并等待全部执行处理结束
     也可以遍历数组
     
     第一个参数
     重复次数
     第二个参数
     追加对象的对列
     第三个参数
     指定的block 追加到参数二
     
     */
    dispatch_queue_t testQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_apply(10, testQueue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    NSLog(@"done");
}

- (void)TDdispatch_suspend_resume{
    /*
     dispatch_suspend挂起指定的dispatch Queue
     dispatch_resume恢复指定的dispatch Queue
     */
    dispatch_queue_t testQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_suspend(testQueue);
    dispatch_resume(testQueue);
}

- (void)TDdispatch_semaphore{
    /*
     dispatch_semaphore 使用的是更细粒度的对象,是持有计数的信号,该计数是多线程编程中的计数类型信号
     计数为0时等待,计数为1或大于1时,减去1而不等待
     
     dispatch_semaphore_wait等待semaphore计数大于或等于1,当semaphore计数大于或等于1或者在待机中计数值大于或等于1时
     ,对该计数进行减法 并获取返回值
     返回值为0时可以安全的执行排他控制的处理
     该处理结束时通过dispatch_semaphore_signal函数将semaphore加1
     
     */
    //    计数值初始化为1
    
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray *marray = [NSMutableArray array];
    
    for (int i = 0; i<10000; i++) {
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [marray addObject:[NSNumber numberWithInt:i]];
            dispatch_semaphore_signal(semaphore);
        });
    }
}

- (void)TDdispatch_once{
    /*
     确保在应用中只执行一次处理
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}

- (void)TDdispatchIO{
    /*
     
     */
    //    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    //    dispatch_io_t io = dispatch_io_create(DISPATCH_IO_STREAM, fd, queue, ^(int error) {
    //
    //    });
}

/*
 GCD苹果多线程任务技术之一,C语言接口执行效率更高,充分利用了苹果的多核心硬件
 
 dispatch queue 是执行处理的等待队列
 按照追加顺序执行(FIFO)
 两种dispatch queue
 一种等待现在执行中处理结束 的seril dispatch queue(串行队列)
 一种不等待现在执行种处理结束 的concurrent dispatch queue(并行队列)
 
 GCD API
 dispatch_queue_t queue = dispatch_queue_create(const char * _Nullable label, dispatch_queue_attr_t  _Nullable attr)
 
 创建多少个queue就会创建多个线程
 
 
 
 
 串行队列只有一个线程，并行队列有多个线程。
 
 DISPATCH_QUEUE_SERIAL //(NULL) 串行
 DISPATCH_QUEUE_SERIAL_INACTIVE  //暂停状态串行队列
 DISPATCH_QUEUE_CONCURRENT //并行
 DISPATCH_QUEUE_CONCURRENT_INACTIVE  //暂停状态并发队列
 
 
 
 
 
 
 提交一个用于在分派队列上异步执行的块。
 dispatch_async(dispatch_queue_t  _Nonnull queue, ^{
 
 });
 提交一个用于在分派队列上同步执行的块。
 dispatch_async(dispatch_queue_t  _Nonnull queue, ^{
 
 })
 
 
 
 
 
 
 
 为给定的对象设置目标队列。
 object
 要修改的对象。在这个参数中传递NULL的结果是未定义的。
 queue
 对象的新目标队列。保留队列，并释放前一个队列（如果有）。这个参数不能NULL。
 
 第一个参数为要设置优先级的queue,第二个参数是参照物，既将第一个queue的优先级和第二个queue的优先级设置一样
 dispatch_set_target_queue(dispatch_object_t  _Nonnull object, dispatch_queue_t  _Nullable queue)
 
 
 
 创建一个新的分派源来监视低级系统对象，并自动向分派队列提交处理程序块以响应事件。
 
 
 */



@end
