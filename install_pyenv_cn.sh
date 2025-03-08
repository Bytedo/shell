#!/bin/bash

# 终端输出颜色设置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印彩色消息的函数
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 打印章节标题的函数
print_header() {
    local message=$1
    echo -e "\n${BLUE}=== ${message} ===${NC}"
}

# 用户确认提示函数
confirm() {
    local message=$1
    local default=${2:-y}
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -p "$message $prompt " response
    response=${response:-$default}
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# 检查 pyenv 是否已安装
check_pyenv_exists() {
    if [ -d "$HOME/.pyenv" ]; then
        return 0
    elif command -v pyenv &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 卸载 pyenv
uninstall_pyenv() {
    print_header "卸载已存在的 pyenv 安装"
    
    # 从 shell 配置文件中移除 pyenv 配置
    local shell_files=(".bashrc" ".bash_profile" ".zshrc" ".profile")
    for file in "${shell_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            print_message "$YELLOW" "正在从 $HOME/$file 移除 pyenv 配置"
            sed -i '/pyenv/d' "$HOME/$file"
        fi
    done
    
    # 删除 pyenv 目录
    if [ -d "$HOME/.pyenv" ]; then
        print_message "$YELLOW" "正在删除 pyenv 目录：$HOME/.pyenv"
        rm -rf "$HOME/.pyenv"
    fi
    
    print_message "$GREEN" "pyenv 已成功卸载！"
}

# 安装依赖项
install_dependencies() {
    print_header "安装依赖项"
    
    print_message "$YELLOW" "更新软件包列表..."
    sudo apt update -y
    
    print_message "$YELLOW" "安装必要的软件包..."
    # 尝试安装 python-openssl，如果失败则尝试 python3-openssl
    if ! sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git; then
        
        print_message "$YELLOW" "未找到 python-openssl 软件包，尝试安装 python3-openssl..."
        sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
        libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git
    fi
    
    print_message "$GREEN" "所有依赖项已成功安装！"
}

# 安装 pyenv
install_pyenv() {
    print_header "安装 pyenv"
    
    print_message "$YELLOW" "使用官方安装程序安装 pyenv..."
    curl https://pyenv.run | bash
    
    print_message "$GREEN" "pyenv 已成功安装！"
}

# 配置 pyenv
configure_pyenv() {
    print_header "配置 pyenv"
    
    local shell_file="$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ] && confirm "检测到 zsh。您是否想要为 zsh 配置 pyenv（而不是 bash）？"; then
        shell_file="$HOME/.zshrc"
    fi
    
    print_message "$YELLOW" "将 pyenv 配置添加到 $shell_file"
    
    # 检查配置是否已存在
    if grep -q "PYENV_ROOT" "$shell_file"; then
        print_message "$YELLOW" "pyenv 配置已存在于 $shell_file 中。正在更新..."
        sed -i '/pyenv/d' "$shell_file"
    fi
    
    # 添加 pyenv 配置（使用更兼容的方式）
    cat >> "$shell_file" << 'EOF'

# pyenv 配置
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
    
    print_message "$GREEN" "pyenv 已在 $shell_file 中配置完成！"
    print_message "$YELLOW" "请重启您的 shell 或运行 'source $shell_file' 以开始使用 pyenv。"
}

# 配置 Python 镜像
configure_python_mirrors() {
    print_header "配置 Python 镜像"
    
    if confirm "您是否想要设置 Python 镜像以加速安装？"; then
        echo
        print_message "$YELLOW" "可用的 Python 镜像："
        print_message "$BLUE" "1) 清华大学镜像 (TUNA)"
        print_message "$BLUE" "2) 中国科学技术大学镜像 (USTC)"
        print_message "$BLUE" "3) 阿里云镜像 (Aliyun)"
        print_message "$BLUE" "4) PyPI 官方镜像"
        print_message "$BLUE" "5) 自定义镜像"
        print_message "$BLUE" "6) 跳过镜像配置"
        
        local mirror_choice
        while true; do
            read -p "请选择镜像 (1-6): " mirror_choice
            
            if [[ "$mirror_choice" =~ ^[1-6]$ ]]; then
                break
            else
                print_message "$RED" "无效选择。请输入 1 到 6 之间的数字。"
            fi
        done
        
        local mirror_url=""
        case $mirror_choice in
            1)
                mirror_url="https://pypi.tuna.tsinghua.edu.cn/simple"
                ;;
            2)
                mirror_url="https://mirrors.ustc.edu.cn/pypi/web/simple"
                ;;
            3)
                mirror_url="https://mirrors.aliyun.com/pypi/simple"
                ;;
            4)
                mirror_url="https://pypi.org/simple"
                ;;
            5)
                read -p "请输入您的自定义镜像 URL: " mirror_url
                ;;
            6)
                print_message "$YELLOW" "跳过镜像配置。"
                return
                ;;
        esac
        
        if [ -n "$mirror_url" ]; then
            # 创建目录（如果尚不存在）
            mkdir -p "$HOME/.pyenv/plugins/python-build/share"
            
            # 配置 pyenv 使用镜像
            echo "export PYTHON_BUILD_MIRROR_URL=\"$mirror_url\"" > "$HOME/.pyenv/plugins/python-build/share/python-build.mirror"
            
            # 同时为 pip 配置镜像
            mkdir -p "$HOME/.pip"
            # 从 URL 提取主机名用于 trusted-host 设置
            mirror_host=$(echo "$mirror_url" | sed -E 's|^https?://([^/]+).*|\1|')
            cat > "$HOME/.pip/pip.conf" << EOF
[global]
index-url = $mirror_url
trusted-host = $mirror_host
EOF
            
            print_message "$GREEN" "Python 镜像已配置为: $mirror_url"
        fi
    else
        print_message "$YELLOW" "跳过镜像配置。"
    fi
}

# 主脚本执行
main() {
    print_header "pyenv 安装脚本"
    
    # 检查是否在 Debian/Ubuntu 上运行
    if ! command -v apt &> /dev/null; then
        print_message "$RED" "此脚本专为 Debian/Ubuntu 系统设计。请在受支持的发行版上运行。"
        exit 1
    fi
    
    # 检查用户是否具有 sudo 权限
    if ! command -v sudo &> /dev/null; then
        print_message "$RED" "此脚本需要 sudo 权限。请安装 sudo 或以 root 身份运行。"
        exit 1
    fi
    
    # 检查 pyenv 是否已安装
    if check_pyenv_exists; then
        print_message "$YELLOW" "系统上已安装 pyenv。"
        if confirm "您是否想要在继续之前卸载现有的 pyenv 安装？"; then
            uninstall_pyenv
        else
            print_message "$RED" "安装已中止。请手动移除现有的 pyenv 安装，或重新运行此脚本并选择卸载。"
            exit 1
        fi
    fi
    
    # 安装依赖项
    if confirm "您是否想要安装所需的依赖项？"; then
        install_dependencies
    else
        print_message "$YELLOW" "跳过依赖项安装。请注意，如果没有所需的依赖项，pyenv 可能无法正常工作。"
    fi
    
    # 安装 pyenv
    if confirm "您是否想要安装 pyenv？"; then
        install_pyenv
    else
        print_message "$RED" "已跳过 pyenv 安装。退出..."
        exit 1
    fi
    
    # 配置 pyenv
    if confirm "您是否想要在 shell 中配置 pyenv？"; then
        configure_pyenv
    else
        print_message "$YELLOW" "跳过 pyenv shell 配置。您需要手动配置它。"
    fi
    
    # 配置 Python 镜像
    configure_python_mirrors
    
    print_header "安装完成"
    print_message "$GREEN" "pyenv 已成功安装并配置！"
    print_message "$YELLOW" "请重启您的 shell 或运行 'source ~/.bashrc'（或您的 shell 配置文件）以开始使用 pyenv。"
    print_message "$BLUE" "您可以使用以下命令安装 Python 版本：pyenv install <版本>"
    print_message "$BLUE" "例如：pyenv install 3.10.0"
}

# 执行主函数
main
