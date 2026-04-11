set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

wp_service := "wordpress-apache"
compose_cmd := "docker compose -f docker-compose.yml"
exec_cmd := compose_cmd + " exec --user www-data " + wp_service

default:
    just --list

dc +args:
    {{ compose_cmd }} {{ args }}

wp +args:
    {{ exec_cmd }} wp {{ args }}

build version:
    {{ compose_cmd }} build wordpress-apache-{{ version }}

setup-test-wp admin_user="admin" admin_email="admin@example.com" admin_password="adm1n" editor_role="editor" editor_email="editor@example.com" editor_user="editor" editor_password="ed1tor" locale="en_US" db_host="db" db_name="wordpress" db_user="wordpress" db_pass="wordpress" db_charset="utf8mb4" url="test.lan" title="Test wordpress installation" rewrite_structure="/%postname%/" wp_debug="true" wp_debug_log="wp-content/logs/debug.log":
    #!/usr/bin/env bash
    set -euo pipefail

    {{ compose_cmd }} exec --user www-data {{ wp_service }} bash -lc "cd /var/www/html && test ! -f wp-config.php"
    {{ exec_cmd }} wp core download --locale "{{ locale }}"
    {{ compose_cmd }} exec -T --user www-data -e DB_HOST='{{ db_host }}' -e DB_NAME='{{ db_name }}' -e DB_USER='{{ db_user }}' -e DB_PASS='{{ db_pass }}' -e DB_CHARSET='{{ db_charset }}' -e LOCALE='{{ locale }}' -e WP_DEBUG='{{ wp_debug }}' -e WP_DEBUG_LOG='{{ wp_debug_log }}' {{ wp_service }} bash -s <<'BASH'
    cd /var/www/html
    wp config create --dbhost="$DB_HOST" --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --dbcharset="$DB_CHARSET" --locale="$LOCALE" --extra-php <<PHP
    define('WP_DEBUG', ${WP_DEBUG});
    define('WP_DEBUG_LOG', '${WP_DEBUG_LOG}');
    define('WP_DEBUG_DISPLAY', true);

    //define('DISABLE_WP_CRON', true);
    //define('SCHEDULE_EMAILS', true); // send emails on cron

    //define('FORCE_SSL_ADMIN', true);
    //if (strpos($_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false) {
    //    $_SERVER['HTTPS'] = 'on';
    //}
    PHP
    BASH
    {{ exec_cmd }} wp core install --url "{{ url }}" --title "{{ title }}" --admin_user "{{ admin_user }}" --admin_email "{{ admin_email }}" --admin_password "{{ admin_password }}"
    {{ compose_cmd }} exec --user www-data {{ wp_service }} bash -lc "cd /var/www/html && mkdir -p wp-content/logs && touch wp-content/logs/debug.log wp-content/debug.log"
    {{ exec_cmd }} wp user create "{{ editor_user }}" "{{ editor_email }}" --user_pass "{{ editor_password }}" --role "{{ editor_role }}"
    {{ exec_cmd }} wp rewrite structure "{{ rewrite_structure }}"
