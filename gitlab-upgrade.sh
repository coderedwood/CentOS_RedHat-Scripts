cp /etc/gitlab/gitlab.rb /home/gitlab.rb
rm -f /etc/gitlab/gitlab.rb
cp /etc/gitlab/gitlab-secrets.json /home/gitlab-secrets.json
rm -f /etc/gitlab/gitlab-secrets.json
secs=$((5))
while [ $secs -gt 0 ]; 
do
    echo -ne "$secs\033[OK\r"
    sleep 1
    : $((secs--))
done
ver=$(yum list installed gitlab-ce)
ver=${ver#*x86_64}
ver=${ver%%-ce*}
path_array=( 14.6.2 14.9.0 14.9.5 14.10.0 14.10.5 15.0.0 15.0.2 15.1.0 15.4.0 15.5.0)
sudo gitlab-ctl deploy-page up;
for i in ${path_array[@]}; do
    # sudo yum clean packages
    sudo gitlab-ctl stop;
    sudo gitlab-ctl hup puma;
    sudo systemctl restart gitlab-runsvdir.service;
    sudo yum upgrade-to gitlab-ce-${i}-ce.0.el7 --nogpgcheck -y;
    if [[ $i == 14.10.0  ||  $i == 15.0.0 ]];
    then 
        sudo gitlab-ctl pg-upgrade;
    fi;
done
sudo gitlab-ctl deploy-page up;
sudo gitlab-ctl stop;
sudo gitlab-ctl hup puma;
sudo systemctl restart gitlab-runsvdir.service;
sudo yum upgrade gitlab-ce -y;
cp /home/gitlab.rb /etc/gitlab/gitlab.rb 
cp /home/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json
sudo gitlab-ctl reconfigure;
sudo gitlab-ctl restart;
secs=$((3*60));
while [ $secs -gt 0 ]; do
    echo -ne "$secs\033[OK\r"
    sleep 1
    : $((secs--))
done
sudo gitlab-ctl deploy-page down;
sudo yum clean packages

