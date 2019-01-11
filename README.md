# JJMemoryTest
本工程是一个测试 iOS 设备内存警告和 OOM 阈值的 demo，参考自 [Split82/iOSMemoryBudgetTest](https://github.com/Split82/iOSMemoryBudgetTest)，该工程已经“年久失修”跑不起来了，我重新优化了一下放上来。

> 没有做机型适配。

这是我测得的 iPhone Xs Max 真机上的运行结果：

<img src="./MDImages/JJMemoryTest 01.jpeg" width="40%" />

其它设备的测试结果：

```
iPad1: 127MB/256MB/49%
iPad2: 275MB/512MB/53%
iPad3: 645MB/1024MB/62%
iPad4: 585MB/1024MB/57% (iOS 8.1)
iPad Mini 1st Generation: 297MB/512MB/58%
iPad Mini retina: 696MB/1024MB/68% (iOS 7.1)
iPad Air: 697MB/1024MB/68%
iPad Air 2: 1383MB/2048MB/68% (iOS 10.2.1)
iPad Pro 9.7": 1395MB/1971MB/71% (iOS 10.0.2 (14A456))
iPad Pro 10.5”: 3057/4000/76% (iOS 11 beta4)
iPad Pro 12.9” (2015): 3058/3999/76% (iOS 11.2.1)
iPad Pro 12.9” (2017): 3057/3974/77% (iOS 11 beta4)
iPad Pro 11.0” (2018): 2858/3769/76% (iOS 12.1)
iPad Pro 12.9” (2018): 4598/5650/81% (iOS 12.1)
iPod touch 4th gen: 130MB/256MB/51% (iOS 6.1.1)
iPod touch 5th gen: 286MB/512MB/56% (iOS 7.0)
iPhone4: 325MB/512MB/63%
iPhone4s: 286MB/512MB/56%
iPhone5: 645MB/1024MB/62%
iPhone5s: 646MB/1024MB/63%
iPhone6: 645MB/1024MB/62% (iOS 8.x)
iPhone6+: 645MB/1024MB/62% (iOS 8.x)
iPhone6s: 1396MB/2048MB/68% (iOS 9.2)
iPhone6s+: 1392MB/2048MB/68% (iOS 10.2.1)
iPhoneSE: 1395MB/2048MB/69% (iOS 9.3)
iPhone7: 1395/2048MB/68% (iOS 10.2)
iPhone7+: 2040MB/3072MB/66% (iOS 10.2.1)
iPhone X: 1392/2785/50% (iOS 11.2.1)
iPhone XS Max: 2039/3735/55% (iOS 12.1)
```



参考 [ios app maximum memory budget](https://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budget)