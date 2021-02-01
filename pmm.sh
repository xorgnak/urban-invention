
source /etc/os-release
if [ -z "$NAME" ]; then
    export SYS=$NAME;
else
    export SYS=$ID;
fi
if [ "$SYS" == "debian" ]; then
    export PM='apt -y';
elif [ "$SYS" == "fedora" ]; then
    export PM='yum -y';
fi
echo "PM: $PM"
sudo $PM update
sudo $PM upgrade
sudo $PM install git
git clone https://github.com/xorgnak/turbo-rotary-phone && mv turbo-rotary-phone pmm
