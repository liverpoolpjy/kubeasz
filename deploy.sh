#/bin/bash

# 生成ssh公私钥
# ssh-keygen -t rsa -P ''
# 以root权限复制到authorized_keys
# cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# 再分发到各个worker服务器
# 分别测试是否可以连接
# ssh ip



sudo cat >/etc/apt/sources.list<<EOF
deb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties
deb http://archive.canonical.com/ubuntu xenial partner
deb-src http://archive.canonical.com/ubuntu xenial partner
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse
EOF

sudo apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y

apt-get install python2.7 git python-pip

pip install pip --upgrade -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
pip install --no-cache-dir ansible -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com

git clone https://github.com/liverpoolpjy/kubeasz.git
mkdir -p /etc/ansible
mv kubeasz/* /etc/ansible

# 解压二进制包，放入/etc/ansible/bin
cd /tmp
tar zxvf k8s.193.tar.gz
mv bin/* /etc/ansible/bin

cd /etc/ansible
cp example/hosts hosts

# 测试连通性
ansible all -m ping
# 如果不通先ssh试试
# ssh 10.64.3.x


# 一部安装
ansible-playbook 90.setup.yml

# 重新ssh登录，启用kubectl
ssh kube-1

# 安装 kube-dns
kubectl create -f /etc/ansible/manifests/kubedns

# 安装heapster
kubectl create -f /etc/ansible/manifests/heapster/

# 安装dashboard
# 部署dashboard 主yaml配置文件
# kubectl create -f /etc/ansible/manifests/dashboard/kubernetes-dashboard.yaml
# 部署基本密码认证配置[可选]，密码文件位于 /etc/kubernetes/ssl/basic-auth.csv
# kubectl create -f /etc/ansible/manifests/dashboard/ui-admin-rbac.yaml
# kubectl create -f /etc/ansible/manifests/dashboard/ui-read-rbac.yaml
# kubectl create -f /etc/ansible/manifests/dashboard/admin-user-sa-rbac.yaml
# 拿到登录token
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

# 访问https://{{ ip }}:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

