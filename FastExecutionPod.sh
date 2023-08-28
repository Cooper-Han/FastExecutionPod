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


# 自定义弹窗 
# 参数$1 弹窗消息内容
# 参数$2 弹窗标题
# 参数$3 按钮标题,多个用英文逗号隔开 
# 参数$4 默认选中的按钮标题或者按钮数字下标
# 参数$5 是否为输入框类型 传"0"或者"1" 默认"0"
# 参数$6 输入框默认占位内容,传不传无所谓,默认为空字符串 ""
# 参数$7 默认图标note/stop/caution 或者自定义文件路径(:格式路径可以通过choose file获取)  
# tips: 如果为输入框模式,那么输出结果就是{button returned:button,text returned:text} 否则只有按钮或者false 
function showAlert()
{
    if [[ -n "$4" ]]; then
        if [[ ${4} == *[!0-9]* ]]; then
            defaultButton="default button \"${4}\""
            else
            defaultButton="default button ${4}"
        fi
    else
        defaultButton=""
    fi

    # 是否为输入框模式
    if [[ "$5" = "1" ]]; then
        IS_InputMode="default answer \"${6}\""
        ReturnValue="get result"
    else
        IS_InputMode=""
        ReturnValue="get the button returned of the result"
    fi

    if [[ -n "$7" ]]; then
        case ${7} in
            note)
            ICON="with icon note"
            ;;
            stop)
            ICON="with icon stop"
            ;;
            caution)
            ICON="with icon caution"
            ;;
            *)
            ICON="with icon file \"${7}\""
            ;;
        esac
    else
        ICON="with icon file \"Applications:Xcode.app:Contents:Resources:Xcode.icns\""
    fi

osascript  <<EOF
    set buttonStr to "${3}"
    set oldDelimiters to AppleScript's text item delimiters
    set AppleScript's text item delimiters to ","
    set buttonList to every text item of buttonStr
    set AppleScript's text item delimiters to oldDelimiters
    get buttonList
    set btns to buttonList
    display dialog "${1}" with title "${2}" buttons btns ${IS_InputMode} ${defaultButton} ${ICON}
EOF
}


# 展示选择器
# 参数$1 title
function choosList()
{
osascript  <<EOF
    tell application "Xcode"
        set podOptions to {"pod install", "pod update", "pod update --no-repo-update"}
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

    # 判断指定的终端类型
    case $use_terminal_type in
    "1") # 系统终端

        echo "选择了系统终端执行"
        runInTerminal "$path" "$pod_command"
        ;;
    "2") # iTerm2

        echo "选择了 iTerm2 终端执行"
        runInITerm "$path" "$pod_command"
        ;;
    *) # 其它
        message="指定了不支持的终端类型!"
        showAlert $message "提示" "知道了" "1" "0" "占位" "stop"
        ;;
    esac
else
    # path 为空('') 弹出Alert告知
    showAlert "当前没有打开任何 Xcode 工程无法执行 Cocoapods 相关操作" "提示" "知道了" "1" "0" "占位" "stop"
fi