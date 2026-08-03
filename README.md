# FastExecutionPod 使用说明

通过 Xcode Behaviors 快捷执行常用 CocoaPods 命令，无需手动进入工程目录。

## 功能

- 支持 `pod install`
- 支持 `pod update`
- 支持 `pod update --no-repo-update`
- 支持手动输入 Pod 命令
- 使用 `PodCommandPickerTool` 显示可视化命令选择窗口
- 支持 macOS 系统终端和 iTerm2
- 支持包含空格或中文名称的工程路径

默认使用 iTerm2，可以修改 `FastExecutionPod.sh` 中的 `use_terminal_type` 切换终端：

```bash
# 系统终端：1
# iTerm2：2
use_terminal_type=2
```

如果选择 iTerm2，请先确保电脑已经安装 iTerm2。

## 环境要求

- macOS
- Xcode
- CocoaPods
- Apple 芯片 Mac（仓库中的 `PodCommandPickerTool` 当前为 arm64 可执行文件）

## 下载与安装

`FastExecutionPod.sh` 依赖 `PodCommandPickerTool`，请不要只下载 Shell 脚本。推荐克隆完整仓库：

```bash
git clone https://github.com/Cooper-Han/FastExecutionPod.git
cd FastExecutionPod
```

添加执行权限：

```bash
chmod +x FastExecutionPod.sh
chmod +x PodCommandPickerTool
```

请确保两个文件始终位于同一目录：

```text
FastExecutionPod/
├── FastExecutionPod.sh
└── PodCommandPickerTool
```

脚本会自动调用同目录下的 `PodCommandPickerTool`：

```bash
"$(dirname "$0")/PodCommandPickerTool"
```

> Intel 芯片 Mac 无法直接运行仓库中现有的 arm64 版本，需要使用 `PodCommandPicker` 源码重新编译对应架构的可执行文件。

## PodCommandPickerTool 无法打开

如果首次运行时 macOS 提示无法打开、无法验证开发者，或者系统阻止运行，可以先在“系统设置 → 隐私与安全性”中找到对应提示并选择“仍要打开”。

如果仍然无法运行，可以进入仓库目录并移除该文件的隔离属性：

```bash
xattr -d com.apple.quarantine ./PodCommandPickerTool
```

然后重新添加执行权限：

```bash
chmod +x ./PodCommandPickerTool
```

通常不需要使用 `sudo`，也不建议对整个目录执行 `xattr -r`。只处理明确的 `PodCommandPickerTool` 文件可以避免误改其他文件的安全属性。

![iShot_2023-08-02_13 06 53](https://github.com/HKZ773999/FastExecutionPod/assets/16662173/1b0f28e9-d566-4b79-8e7c-af9be9c065f9)


## Xcode 快捷键配置

完成上述下载和权限配置后，按照以下步骤操作：
### 1. 打开 Xcode → Settings...
<img width="1211" alt="iShot_2023-08-01_17 35 40" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/5324cf05-be3d-41f2-bf23-afd56ecaeb96">

### 2. 选择 Behaviors
<img width="866" alt="iShot_2023-08-01_17 37 28" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/8b8e8264-93be-4951-8254-61eb48fe20aa">

### 3. 点击左下角的（+）按钮
<img width="866" alt="iShot_2023-08-01_17 38 27" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/91ed9f40-b404-4ecb-86b1-a2943473afd1">

为 Behavior 设置一个名称，例如 `PodCommand`。
<img width="866" alt="iShot_2023-08-01_17 39 48" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/0749d564-0477-43c0-bc52-20e2c892a419">

然后设置快捷键。示例使用 `Command + P`，会替换 Xcode 默认的打印快捷键。
<img width="866" alt="iShot_2023-08-01_17 42 03" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/92035bc4-b9d1-4f56-a79e-bea874e1613e">

### 4. 配置 Run 脚本

在右侧滚动到最下方，勾选 `Run`，选择下载目录中的 `FastExecutionPod.sh`，配置完成后关闭窗口。请勿单独移动脚本，`PodCommandPickerTool` 必须与脚本保持在同一目录。
<img width="866" alt="iShot_2023-08-01_17 42 56" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/f280eac6-529f-4ebf-86c0-773a9cdaf422">

示例中将完整项目存放在“文稿”下自建的 Shell 文件夹中。
<img width="866" alt="iShot_2023-08-01_17 44 19" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/4cadf79a-0342-4091-9fd6-dbbfdcdf9710">

### 5. 执行 Pod 命令

在需要执行 Pod 操作的 Xcode 工程中按下配置的快捷键（示例为 `Command + P`），即可选择 Pod 命令并跳转到终端执行。
<img width="1440" alt="iShot_2023-08-01_17 46 55" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/db790cbb-3d9a-4bd0-bdc0-de298214f9ca">

也可以不使用快捷键，通过 Xcode 菜单手动执行对应的 Behavior：
<img width="1259" alt="iShot_2023-08-01_17 50 49" src="https://github.com/HKZ773999/FastExecutionPod/assets/16662173/42d71137-aa7a-452b-9217-e0d18407192a">
