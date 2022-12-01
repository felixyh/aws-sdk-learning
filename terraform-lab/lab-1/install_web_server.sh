#!/bin/bash
yum install -y httpd mysql php
wget https://us-west-2-tcprod.s3.amazonaws.com/courses/ILT-TF-100-TECESS/v4.7.10/lab-1-build-a-web-server/scripts/lab-app.zip
unzip lab-app.zip -d /var/www/html/
chkconfig httpd on
service httpd start