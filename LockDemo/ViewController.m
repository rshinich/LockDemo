//
//  ViewController.m
//  LockDemo
//
//  Created by 张忠瑞 on 2018/4/23.
//  Copyright © 2018年 张忠瑞. All rights reserved.
//

#import "ViewController.h"
#import <libkern/OSAtomic.h>
#import <pthread.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self setOSSpinLock];
//    [self setSemaphore];
//    [self setPthread_mutex];
//    [self setPthreadMutexRecursive];
//    [self setNSLock];
//    [self setNSConditionUntilDate];
//    [self setNSConditionWait];
//    [self setNSConditionBroadcast];
//    [self setSynchronized];
    [self setConditionLock];

}

- (void)setOSSpinLock
{
    __block OSSpinLock ossPinLock = OS_SPINLOCK_INIT;
    __block NSInteger  number = 10;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，OSSpinLock上锁",[NSThread currentThread]);
        OSSpinLockLock(&ossPinLock);
        
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 10;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);

        NSLog(@"当前线程：%@，OSSpinLock解锁",[NSThread currentThread]);
        OSSpinLockUnlock(&ossPinLock);
        
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，OSSpinLock上锁",[NSThread currentThread]);
        OSSpinLockLock(&ossPinLock);

        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 20;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);

        NSLog(@"当前线程：%@，OSSpinLock解锁",[NSThread currentThread]);
        OSSpinLockUnlock(&ossPinLock);
        
    });
}

- (void)setSemaphore
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC);
    __block NSInteger  number = 10;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，semaphore信号量+1",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
        
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 10;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，semaphore信号量-1",[NSThread currentThread]);
        dispatch_semaphore_wait(semaphore, overTime);
        
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，semaphore信号量+1",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
        
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 20;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，semaphore信号量-1",[NSThread currentThread]);
        dispatch_semaphore_wait(semaphore, overTime);

    });
}

- (void)setPthread_mutex
{
    static pthread_mutex_t pLock;
    pthread_mutex_init(&pLock, NULL);
    __block NSInteger  number = 10;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，上锁",[NSThread currentThread]);
        pthread_mutex_lock(&pLock);

        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 10;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，解锁",[NSThread currentThread]);
        pthread_mutex_unlock(&pLock);
        
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，上锁",[NSThread currentThread]);
        pthread_mutex_lock(&pLock);
        
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 20;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，解锁",[NSThread currentThread]);
        pthread_mutex_unlock(&pLock);
        
    });

}


- (void)setPthreadMutexRecursive
{
    static pthread_mutex_t pLock;
    pthread_mutexattr_t attr;
    //初始化attr并且给它赋予默认
    pthread_mutexattr_init(&attr);
    //设置锁类型，这边是设置为递归锁
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&pLock, &attr);
    //销毁一个属性对象，在重新进行初始化之前该结构不能重新使用
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            pthread_mutex_lock(&pLock);
            if (value > 0) {
                NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],value);
                RecursiveBlock(value - 1);
            }
            pthread_mutex_unlock(&pLock);
        };
        RecursiveBlock(5);
    });
}

- (void)setNSLock
{
    NSLock *lock = [NSLock new];
    __block NSInteger  number = 10;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，NSLock上锁",[NSThread currentThread]);
        [lock lock];
        
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 10;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，NSLock解锁",[NSThread currentThread]);
        [lock unlock];
        
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，NSLock上锁",[NSThread currentThread]);
        [lock lock];

        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        number += 20;
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        
        NSLog(@"当前线程：%@，NSLock解锁",[NSThread currentThread]);
        [lock unlock];

    });

}


- (void)setNSConditionUntilDate
{
    NSCondition *conditionLock = [NSCondition new];
    __block NSInteger  number = 10;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"当前线程：%@，NSCondition上锁",[NSThread currentThread]);
        [conditionLock lock];
        [conditionLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
        number = number + 1;
        NSLog(@"number=%ld",number);
        NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        [conditionLock unlock];
    });
}

- (void)setNSConditionWait
{
    NSCondition *conditionLock = [NSCondition new];
    __block NSInteger  number = 10;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSLog(@"当前线程：%@，NSCondition上锁",[NSThread currentThread]);
        [conditionLock lock];
        [conditionLock wait];
        number = number + 10;
        NSLog(@"number=%ld",number);
        [conditionLock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，NSCondition上锁",[NSThread currentThread]);
        [conditionLock lock];
        [conditionLock wait];
        number = number + 20;
        NSLog(@"number=%ld",number);
        [conditionLock unlock];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSLog(@"当前线程：%@，NSCondition唤醒等待的线程",[NSThread currentThread]);
        [conditionLock signal];
    });
    
}

- (void)setNSConditionBroadcast
{
    NSCondition *conditionLock = [NSCondition new];
    __block NSInteger  number = 10;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，NSCondition上锁",[NSThread currentThread]);
        [conditionLock lock];
        [conditionLock wait];
        number = number + 10;
        NSLog(@"number=%ld",number);
        [conditionLock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"当前线程：%@，NSCondition上锁",[NSThread currentThread]);
        [conditionLock lock];
        [conditionLock wait];
        number = number + 20;
        NSLog(@"number=%ld",number);
        [conditionLock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSLog(@"当前线程：%@，NSCondition唤醒所有等待的线程",[NSThread currentThread]);
        [conditionLock broadcast];
    });

}

- (void)setSynchronized
{
    __block NSInteger  number = 10;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @synchronized (self)
        {
            NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
            number += 10;
            NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        }
    });
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @synchronized (self)
        {
            NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
            number += 20;
            NSLog(@"当前线程：%@，number=%ld",[NSThread currentThread],number);
        }

    });

}

- (void)setConditionLock
{
    NSConditionLock *condationLock = [[NSConditionLock alloc] init];
    
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([condationLock tryLockWhenCondition:0]){
            NSLog(@"线程1");
            [condationLock unlockWithCondition:1];
        }else{
            NSLog(@"失败");
        }
    });
    
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [condationLock lockWhenCondition:3];
        NSLog(@"线程2");
        [condationLock unlockWithCondition:2];
    });
    
    
    //线程3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [condationLock lockWhenCondition:1];
        NSLog(@"线程3");
        [condationLock unlockWithCondition:3];
    });
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
