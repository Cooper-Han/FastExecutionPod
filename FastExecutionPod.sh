#!/bin/sh

# 作者: Cooper
# 版本: 1.1
# 创建日期: 2023-02-28
# github: https://github.com/Cooper-Han/FastExecutionPod.git
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
    -- 告诉System Events应用程序执行后续的命令
    tell application "System Events"

        -- 激活System Events应用程序，确保选择列表窗口位于前台，并且可以被选中
        activate

        -- 要显示在选择列表中的选项
        set podOptions to {"输入Pod指令", "pod install", "pod update", "pod update --no-repo-update"}

        -- 选择列表中默认选中的选项
        set defaultItems to {"pod update --no-repo-update"}

        -- 使用上述定义的变量和参数来显示选择列表窗口
        choose from list podOptions with title "$1" with prompt "选择要执行的 Pod 操作: " OK button name "执行" cancel button name "取消" default items defaultItems
    end tell
EOF
}



# 在iTerm运行
# 参数$1 进入目录
# 参数$2 执行指令
function runInITerm()
{
# 注意:
# 原本在终端只需执行: "cd $1/..; $2"
# 但是如果 $1 的 path 中如果有文件夹命名中有空格 在终端执行指令就会报 "cd: string not in pwd: XXX/XXX" 的错误 导致无法成功进入文件夹
# 这种情况在 shell 中只需在带空格的文件夹名的空格前面加上 \ 转义即可, 例: /Users/test 2 => /Users/test\ 2
# 但是 此时 shell 是通过 AppleScript 执行的, 如果有 / 会造成 AppleScript 的语法错误,无法执行.
# 在 AppleScript 中添加额外的转义字符，以正确处理具有转义字符的路径和命令.
# 通过修改为: "cd \"$1/..\"; $2" 
# 在此使用了双引号来包裹整个路径。这样可以确保路径中的空格和其他特殊字符被正确解析.
osascript <<EOF
    tell application "iTerm"
        if not (exists window 1) then reopen
        set myWindow to current window
        tell current session of myWindow
            write text "cd \"$1/..\"; $2"
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
# 注意:
# 原本在终端只需执行: "cd $1/..; $2"
# 但是如果 $1 的 path 中如果有文件夹命名中有空格 在终端执行指令就会报 "cd: string not in pwd: XXX/XXX" 的错误 导致无法成功进入文件夹
# 这种情况在 shell 中只需在带空格的文件夹名的空格前面加上 \ 转义即可, 例: /Users/test 2 => /Users/test\ 2
# 但是 此时 shell 是通过 AppleScript 执行的, 如果有 / 会造成 AppleScript 的语法错误,无法执行.
# 在 AppleScript 中添加额外的转义字符，以正确处理具有转义字符的路径和命令.
# 通过修改为: "cd \"$1/..\"; $2" 
# 在此使用了双引号来包裹整个路径。这样可以确保路径中的空格和其他特殊字符被正确解析.
osascript <<EOF 
    tell application "Terminal"
        if not (exists window 1) then reopen
        activate
        do script "cd \"$1/..\"; $2" in window 1
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



# 关闭指定工程
# 参数$1 指定的 Xcode工程目录
function closeProject()
{
osascript <<EOF
    tell application "Xcode"

        -- 获取所有已打开的窗口
        set openWindows to windows
        
        -- 遍历所有已打开的窗口
        repeat with theWindow in openWindows
            -- 检查窗口是否有关联的文档
            if exists document of theWindow then
                -- 获取文档的文件路径
                set docPath to (path of document of theWindow) as text
                
                -- 检查文档路径是否与指定的路径匹配
                if docPath is equal to "$1" then
                    -- 关闭窗口
                    close theWindow
                end if
            end if
        end repeat
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
    name="目标:${full_name%.*}"


    # 如果不存在 Podfile 文件
    if [ ! -f "$path/../Podfile" ]; then

        # 不存在 Podfile 文件 弹出Alert请求创建
        buttonName=$(showAlert "没有 Podfile 文件是否创建并执行 pod install?" "$name" "取消,确定" "2" "0" "占位" "caution")

        # 点击了创建
        if [ "$buttonName" == '确定' ]; then

            # 关闭 .xcodeproj
            closeProject "$path"

            # 执行 pod init && pod install 并打开 .xcworkspace
            runPodCommand "$path" "pod init && pod install && open '${path%.*}.xcworkspace'"
        fi

        # 终止
        exit
    fi


    # 如果存在弹出 选择器 选择要执行的操作
    pod_command=$(choosList $name)

    # 如果选择了 取消 操作
    if [ $pod_command == 'false' ]; then

        # 先将 Xcode 的进程设置为前台来选中其窗口。(体验更好)
        # 注意，在执行此代码之前，虽然需要确保已经打开了Xcode。否则，此代码将无法正常工作。
        # 但是 这个脚本选是由 Xcode 触发的, 如果不是手动特意退出,此时 Xcode 必然是打开的
        # 如果手动退出了 Xcode 只是 下面 AppleScript 执行 错误, 脚本还是正常退出
        osascript -e 'tell application "System Events" 
            set frontmost of process "Xcode" to true 
        end tell'

        # 然后直接终止脚本
        exit 
    fi


    # 如果 选择的是 手动输入 操作 
    if [ $pod_command == '输入Pod指令' ]; then

        # 指定 icon path
        icon_path='System:Applications:Utilities:Terminal.app:Contents:Resources:Terminal.icns'

        # 指定 showAlert 为输入模式 
        # 如果选择执行输出结果为: button returned:执行,text returned:输入内容
        # 如果选择内容为取消输出结果为空
        button_and_text_result=$(showAlert "请输入指令:" "$name" "取消,执行" "2" "1" "$input_command_placeholder" "$icon_path")

        # 如果没有输入内容则终止
        if [ -z "$button_and_text_result" ]; then
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
            showAlert "指令为空无法执行!" "提示" "知道了" "1" "0" "占位" "stop"  
            exit
        fi
    fi

    # 执行 pod 指令
    runPodCommand "$path" "$pod_command"
else
    # path 为空('') 弹出Alert告知
    showAlert "当前没有打开任何 Xcode 工程无法执行 Cocoapods 相关操作" "提示" "知道了" "1" "0" "占位" "stop"
fi