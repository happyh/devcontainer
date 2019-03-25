FROM docker.io/centos:7

RUN yum install -y epel-release
RUN yum install vim git curl ctags git gcc gcc-c++ make readline readline-devel readline-staticsud openssl openssl-devel openssl-static sqlite-devel bzip2-devel bzip2-libs wget patch cmake net-tools htop tree iftop openssh-server go -y

RUN mkdir -p /var/run/sshd /root/.ssh
RUN sed -ri 's#session    required     pam_loginuid.so#session    required     pam_loginuid.so#g' /etc/pam.d/sshd
ADD authorized_keys /root/.ssh/authorized_keys
ADD run.sh /run.sh
RUN chmod 755 /run.sh

RUN yum install unzip python-devel -y

ADD ./vim.zip /tmp/
RUN cd /tmp/ && unzip vim.zip
RUN cd /tmp/vim-master && ./configure --with-features=huge --enable-multibyte --enable-pythoninterp=yes && make -j 8 && make install
RUN cd /tmp && rm -rf vim.zip vim-master

ADD ./vimrc /root/.vimrc
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
ADD ./YouCompleteMe.tar.gz /root/.vim/bundle/
RUN cd /root/.vim/bundle/YouCompleteMe && git pull && git submodule update --init --recursive
RUN cd /root/.vim/bundle/YouCompleteMe && ./install.py --clang-completer --go-completer
RUN vim -c PluginInstall -c q -c q
RUN cd /root/.vim/bundle/YouCompleteMe && rm -rf .git ./third_party/ycmd/third_party/OmniSharpServer 

ADD ./ycm_extra_conf.py /root/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/

ADD astyle /usr/bin/

#RUN vim -c GoInstallBinaries -c q -c q
RUN ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_ecdsa_key && ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_ed25519_key

# 暴露22端口
EXPOSE 22

# 设置脚本自启动
CMD ["/run.sh"]
