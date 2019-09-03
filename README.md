# wordpress-apache

A basic container image with Apache2, mod_php and wp-cli.

Mount wordpress installation to the `/var/www/html`.

```console
docker volume add wordpress-data
docker run -v wordpress-data:/var/www/html --name wp selim13/wordpress-apache
```

To exec wp-cli:

```console
docker exec --user www-data dtlc.ru wp-cli
```

## Environment variables

No wordpress configuration through environment variables, mount wp-config.php using volumes.

Additional variables to configure default apache virtual host: `APACHE_DOCUMENT_ROOT` and `APACHE_SERVER_ADMIN`.