#!/bin/sh

# 作者: Cooper
# 版本: 1.0
# 创建日期: 2023-02-28
# github: https://github.com/HKZ773999/FastExecutionPod.git
# 使用说明: 
: "
此脚本通过在 Xcode 配置 快捷键, 快速 执行 pod 等相关操作
目前支持在系统终端跟 iTerm 运行, 默认系统终端, 可通过修改 "use_terminal_type" 改变终端类型
如果指定终端类型为 iTerm2 请确保已经安装!

具体使用步骤如下:
1.Xcode->Preferences...
2.Behaviors(最上面 Item 选项)
3.左下角点击 (+) 自己起一个名字(比如:CocoaPods), 然后设置自己的快捷键
4.右边 滑到最下面 在 选中 Run 然后设置自己存放此脚本的位置
5.执行自己的快捷键 即可进行 对当前工程 快速的 pod 相关操作 
"



# ⚠️⚠️⚠️:指定使用终端类型
# 系统终端:1
# iTerm2:2
use_terminal_type=1


# 手动输入指令的占位符
input_command_placeholder='pod '


: "
指定变量 input_command_placeholder 在次文件的第几行 当前文件下载下来默认在第 30 行

⚠️⚠️⚠️注意:为了提升性能以及代码安全性,通过手动指定变量 input_command_placeholder 在次文件的第几行
这样在手动输入指令的时候 可以直接将输入的值获取, 然后通过 sed -i 指令修改此文件的 input_command_placeholder 变量值
这样下次 input_command_placeholder 占位符就是上次输入的指令
"
input_command_placeholder_line_number=30


# 自定义弹窗 
# 参数$1 弹窗消息内容
# 参数$2 弹窗标题
# 参数$3 按钮标题,多个用英文逗号隔开 
# 参数$4 默认选中的按钮标题或者按钮数字下标
# 参数$5 是否为输入框类型 传"0"或者"1" 默认"0"
# 参数$6 输入框默认占位内容,传不传无所谓,默认为空字符串 ""
# 参数$7 默认图标note/stop/caution 或者自定义文件路径(:格式路径可以通过choose file获取)  
#        note：信息图标（i）
#        stop：停止图标（红色圆形带白色横线）
#        caution：小心图标（黄色三角形感叹号）
# tips: 如果为输入框模式,那么输出结果就是{button returned:button,text returned:text} 否则只有按钮或者false 
function showAlert()
{
    if [[ -n "$4" ]]; then
        if [[ ${4} == *[!0-9]* ]]; then
            default_button="default button \"${4}\""
        else
            default_button="default button ${4}"
        fi
    else
        default_button=""
    fi

    # 是否为输入框模式
    if [[ "$5" = "1" ]]; then
        is_inputMode="default answer \"${6}\""
        return_value="get result"
    else
        is_inputMode=""
        return_value="get the button returned of the result"
    fi

    if [[ -n "$7" ]]; then
        case ${7} in
            note)
            icon="with icon note"
            ;;
            stop)
            icon="with icon stop"
            ;;
            caution)
            icon="with icon caution"
            ;;
            *)
            icon="with icon file \"${7}\""
            ;;
        esac
    else
        icon="with icon file \"Applications:Xcode.app:Contents:Resources:Xcode.icns\""
    fi

osascript <<EOF
    set buttonStr to "${3}"
    set oldDelimiters to AppleScript's text item delimiters
    set AppleScript's text item delimiters to ","
    set buttonList to every text item of buttonStr
    set AppleScript's text item delimiters to oldDelimiters
    get buttonList
    set btns to buttonList
    display dialog "${1}" with title "${2}" buttons btns ${is_inputMode} ${default_button} ${icon}
    ${return_value}  
EOF
}


# 展示选择器
# 参数$1 title
function choosList()
{
osascript  <<EOF
    tell application "Xcode"
        set podOptions to {"输入Pod指令", "pod install", "pod update", "pod update --no-repo-update"}
        set defaultItems to {"pod update --no-repo-update"}
        choose from list podOptions with title "$1" with prompt "选择要执行的 Pod 操作: " OK button name "执行" cancel button name "取消" default items defaultItems
    end tell
EOF
}



# 在iTerm运行
# 参数$1 进入目录
# 参数$2 执行指令
function runInITerm()
{
osascript <<EOF
    tell application "iTerm"
        if not (exists window 1) then reopen
        set myWindow to current window
        tell current session of myWindow
            write text "cd $1/..; $2"
        end tell
        activate
    end tell
EOF
}



# 在终端运行
# 参数$1 进入目录
# 参数$2 执行指令
function runInTerminal()
{
osascript <<EOF 
    tell application "Terminal"
        if not (exists window 1) then reopen
        activate
        do script "cd $1/..; $2" in window 1
    end tell
EOF
}


# 在终端运行
# 参数$1 进入目录
# 参数$2 执行指令
function runPodCommand()
{
    # 判断指定的终端类型
    case $use_terminal_type in
    "1") # 系统终端

        echo "选择了系统终端执行"
        runInTerminal "$1" "$2"
        ;;
    "2") # iTerm2

        echo "选择了 iTerm2 终端执行"
        runInITerm "$1" "$2"
        ;;
    *) # 其它
        message="指定了不支持的终端类型!"
        showAlert $message "提示" "知道了" "1" "0" "占位" "stop"
        ;;
    esac
}




# 🔴 <<<<<--------------- 开始执行 --------------->>>>> 🔻
# Xcode 工程主目录
path=""
# 获取当前 Xcode 工程主目录
if [ -n "$XcodeProjectPath" ]; then
    path=$XcodeProjectPath
else
    path=$XcodeWorkspacePath    
fi



# 判断 是否获取到了 Xcode 工程主目录
if [ -n "$path" ]; then

    # 如果不存在 Podfile 文件
    if [ ! -f "$path/../Podfile" ]; then

        # 不存在 Podfile 文件 弹出Alert请求创建
        buttonName=$(showAlert "没有 Podfile 文件是否创建?" "提示" "取消,创建" "2" "0" "占位" "caution")
        if [ "$buttonName" == '创建' ]; then
            runPodCommand "$path" "pod init"
        fi

        # 终止
        exit
    fi

    # 从路径截取 工程名(带扩展名) 使用 ## 截取, 直到最后一个指定字符（/）再匹配结束
    full_name=${path##*/}

    # 只截取工程名 使用%号截取指定字符（.）左边的所有字符
    name='📌'${full_name%.*}'📌'

    # 如果存在弹出 选择器 选择要执行的操作
    pod_command=$(choosList $name)

    if [ $pod_command == 'false' ]; then
        # 如果选择了 取消 操作 直接终止脚本
        exit 
    fi

    # 如果 选择的是 手动输入 操作 
    if [ $pod_command == '输入Pod指令' ]; then

        # 指定 showAlert 为输入模式 
        # 如果选择执行输出结果为: button returned:执行,text returned:输入内容
        # 如果选择内容为取消输出结果为空
        button_and_text_result=$(showAlert "请输入自定义指令:" "提示" "取消,执行" "2" "1" "$input_command_placeholder" "note")
        if [ -z "$button_and_text_result" ]; then
            # 如果选择了 取消 操作则终止
            exit 
        fi


        # 通过使用cut命令可以根据指定的分隔符将字符串分割为多个字段，并提取其中的第 3 个字段。也就是输入的内容
        text_result=$(echo "$button_and_text_result" | cut -d ":" -f 3)

        # 如果有输入内容
        if [ -n "$text_result" ]; then

            # 将输入指令赋值给 pod_command
            pod_command=$text_result

            # 注意 ${input_command_placeholder_line_number}表示只在第${input_command_placeholder_line_number}行上执行替换操作。
            sed -i '' "${input_command_placeholder_line_number}s/input_command_placeholder=.*/input_command_placeholder='${pod_command}'/" "$0"
        else  
            # text_result 为空('') 弹出Alert告知
            showAlert "指令为空无法执行 Cocoapods 相关操作" "提示" "知道了" "1" "0" "占位" "stop"  
            exit
        fi
    fi

    # 执行 pod 指令
    runPodCommand "$path" "$pod_command"
else
    # path 为空('') 弹出Alert告知
    showAlert "当前没有打开任何 Xcode 工程无法执行 Cocoapods 相关操作" "提示" "知道了" "1" "0" "占位" "stop"
fi