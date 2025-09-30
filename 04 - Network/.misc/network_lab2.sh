#!/bin/bash

set -e
colors=(green blue)

for i in {0..1}
do
    j=$((i + 4))
    ip="192.168.40.$j"

    ssh -i ~/.ssh/id_rsa louis@$ip bash -c "'
        set -e
        export DEBIAN_FRONTEND=noninteractive
        export VAR=$i

        sudo apt update -y --fix-missing
        sudo apt install -y apache2
        sudo mkdir -p /var/www/html
        sudo chmod -R 755 /var/www/

        sudo cat << 'EOF' > ~/index.html
<html>
<body style=\"background-color: PAGECOLOR\">
    <h1 style=\"color: white\">Hello world</h1>
</body>
</html>
EOF
        sudo cp --no-preserve=all ~/index.html /var/www/html/index.html
        sudo sed -i \"s/PAGECOLOR/${colors[$i]}/g\" /var/www/html/index.html

        sudo systemctl restart apache2
        sudo systemctl enable apache2
    '"
done