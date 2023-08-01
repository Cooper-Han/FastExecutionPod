# FastExecutionPod.sh 使用说明
通过 Xcode 快捷键 快速执行 Pod install 等基础操作
此脚本通过在 Xcode 配置 快捷键, 快速 执行 pod 等相关操作
目前支持在系统终端跟 iTerm 运行, 默认系统终端, 可通过修改 "use_terminal_type" 改变终端类型
如果指定终端类型为 iTerm2 请确保已经安装!

具体使用步骤如下:
## 1.Xcode->Settings...
<img width="1211" alt="iShot_2023-08-01_17 35 40" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/5324cf05-be3d-41f2-bf23-afd56ecaeb96">

## 2.Behaviors(最上面 Item 选项)
<img width="866" alt="iShot_2023-08-01_17 37 28" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/8b8e8264-93be-4951-8254-61eb48fe20aa">

## 3.左下角点击 (+) 自己起一个名字(比如:CocoaPods), 然后设置自己的快捷键(这里直接设为：command+p 直接替换掉打印机打印的快捷键)
<img width="866" alt="iShot_2023-08-01_17 38 27" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/91ed9f40-b404-4ecb-86b1-a2943473afd1">
自己起一个名字(比如:PodCommand)
<img width="866" alt="iShot_2023-08-01_17 39 48" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/0749d564-0477-43c0-bc52-20e2c892a419">
然后设置自己的快捷键，这里直接设为：command+p 直接替换掉打印机打印的快捷键（反正这个快捷键也用不上）
<img width="866" alt="iShot_2023-08-01_17 42 03" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/92035bc4-b9d1-4f56-a79e-bea874e1613e">

## 4.右边 滑到最下面 在 选中 Run 然后设置自己下载的此脚本存放的位置
<img width="866" alt="iShot_2023-08-01_17 42 56" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/f280eac6-529f-4ebf-86c0-773a9cdaf422">
<img width="866" alt="iShot_2023-08-01_17 44 19" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/4cadf79a-0342-4091-9fd6-dbbfdcdf9710">

## 5.在自己想要执行 Pod 操作的 Xcode 工程界面执行自己的快捷键（command+p） 即可跳转到终端对当前工程进行快速 pod 相关操作 
<img width="1440" alt="iShot_2023-08-01_17 46 55" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/db790cbb-3d9a-4bd0-bdc0-de298214f9ca">

也可不使用快捷键手动点击执行，操作如下：
<img width="1259" alt="iShot_2023-08-01_17 50 49" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/42d71137-aa7a-452b-9217-e0d18407192a">
