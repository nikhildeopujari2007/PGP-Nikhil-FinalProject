#!/bin/bash
echo "1st parameter = "$1
 
if [ $1 = 'Jenkin-Master' ]
then
    sudo apt update
    sudo apt upgrade -y
 
    # Add Jenkins repository key
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
 
    # Add Jenkins repository to sources list
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
 
    # Update package lists
    sudo apt-get update
 
    # Install Jenkins
    sudo apt-get install -y jenkins
 
    # Install OpenJDK 17
    sudo apt-get install -y openjdk-17-jdk
    sudo apt-get install -y openjdk-17-jre
 
    # Check Java version
    java -version
 
    # Enable Jenkins service
    sudo systemctl daemon-reload
    sudo systemctl start jenkins.service
    sudo systemctl enable jenkins
 
    # Fetch public IP address using curl
    public_ip=$(curl -s https://api.ipify.org)
 
    # Print the fetched IP address along with port 8080
    echo "Your Application is running on: $public_ip:8080"
    echo "Software-Installation completed on Jenkin-Master"
fi
if [ $1 = 'PGP-Agents-Tools' ]
then
    # Install OpenJDK 17
    sudo apt-get install -y openjdk-17-jdk
    sudo apt-get install -y openjdk-17-jre
 
    # Install Ansible
    sudo apt update -y
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
 
    # Install Docker
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update -y
    sudo apt install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
 
    # Fetch public IP address using curl
    public_ip=$(curl -s https://api.ipify.org)
 
    # Print the fetched IP address along with port 8080
    echo "Your Application is running on: $public_ip:8080"
    echo "Software-Installation completed on PGP-Tools"
fi
if [ $1 = 'PGP-Monitoring' ]
then
# Install Prometheus.......
 
        # Update package list
        sudo apt update
        sudo groupadd --system prometheus
        sudo useradd -s /sbin/nologin --system -g prometheus prometheus
        sudo mkdir /etc/prometheus
        sudo mkdir /var/lib/prometheus
 
        wget https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz
 
        tar vxf prometheus*.tar.gz
 
        cd prometheus*/
 
        sudo mv prometheus /usr/local/bin
        sudo mv promtool /usr/local/bin
        sudo chown prometheus:prometheus /usr/local/bin/prometheus
        sudo chown prometheus:prometheus /usr/local/bin/promtool
        sudo mv consoles /etc/prometheus
        sudo mv console_libraries /etc/prometheus
        sudo mv prometheus.yml /etc/prometheus
        sudo chown prometheus:prometheus /etc/prometheus
        sudo chown -R prometheus:prometheus /etc/prometheus/consoles
        sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
        sudo chown -R prometheus:prometheus /var/lib/prometheus
 
        echo "[Unit]
        Description=Prometheus
        After=network.target
 
        [Service]
        User=prometheus
        Group=prometheus
        Type=simple
        ExecStart=/usr/local/bin/prometheus \
         --config.file /etc/prometheus/prometheus.yml \
         --storage.tsdb.path /var/lib/prometheus/ \
         --web.console.templates=/var/lib/prometheus/consoles \
         --web.console.libraries=/var/lib/prometheus/console_libraries
        Restart=always
        StandardOutput=syslog
        StandardError=syslog
 
        [Install]
        WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service
 
        # Reload systemd and start Prometheus
        sudo systemctl daemon-reload
        sudo systemctl start prometheus
        sudo systemctl enable prometheus
	# Install Grafana .....
 
        sudo wget -q -O - https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/grafana.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
 
        sudo apt update
        sudo apt install -y grafana
        sudo systemctl daemon-reload
        sudo systemctl start grafana-server
        sudo systemctl enable grafana-server
 
    public_ip=$(curl -s https://api.ipify.org)
 
    # Print the fetched IP address along with port 8080
    echo "Your Application is running on: $public_ip:9090"
    echo "Software-Installation completed on PGP-Monitoring"
fi