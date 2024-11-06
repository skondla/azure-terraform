server {
    listen 80;
    listen [::]:80;

    server_name default.com www.default.com;

    return 302 https://$server_name$request_uri;
}

