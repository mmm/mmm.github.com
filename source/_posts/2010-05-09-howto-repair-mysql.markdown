---
layout: post
title: repair mysql
categories: howtos
comments: true
---



    mysql> check
        -> table products;
    +---------------------------+-------+----------+---------------------------------------------------------+
    | Table                     | Op    | Msg_type | Msg_text                                                |
    +---------------------------+-------+----------+---------------------------------------------------------+
    | dlbeduca_dbbooks.products | check | warning  | Table is marked as crashed                              |
    | dlbeduca_dbbooks.products | check | error    | Checksum for key:  3 doesn't match checksum for records |
    | dlbeduca_dbbooks.products | check | error    | Checksum for key: 10 doesn't match checksum for records |
    | dlbeduca_dbbooks.products | check | error    | Corrupt                                                 |
    +---------------------------+-------+----------+---------------------------------------------------------+
    4 rows in set (4.26 sec)

    mysql> quit
    Bye
    You have new mail in /var/spool/mail/dlb
    [dlb@linode ~]$ mysqlcheck -udlb_user -pdlb_user --repair --extended dlbeduca_dbbooks
    dlbeduca_dbbooks.address_book                      OK
    dlbeduca_dbbooks.address_format                    OK
    dlbeduca_dbbooks.administrators                    OK
    dlbeduca_dbbooks.banners                           OK
    dlbeduca_dbbooks.banners_history                   OK
    dlbeduca_dbbooks.catalog_books
    note     : The storage engine for the table doesn't support repair
    dlbeduca_dbbooks.catalog_users
    note     : The storage engine for the table doesn't support repair
    dlbeduca_dbbooks.catalogs
    note     : The storage engine for the table doesn't support repair
    dlbeduca_dbbooks.categories                        OK
    dlbeduca_dbbooks.categories_description            OK
    dlbeduca_dbbooks.configuration                     OK
    dlbeduca_dbbooks.configuration_group               OK
    dlbeduca_dbbooks.counter                           OK
    dlbeduca_dbbooks.counter_history                   OK
    dlbeduca_dbbooks.countries                         OK
    dlbeduca_dbbooks.currencies                        OK
    dlbeduca_dbbooks.customers                         OK
    dlbeduca_dbbooks.customers_basket                  OK
    dlbeduca_dbbooks.customers_basket_attributes       OK
    dlbeduca_dbbooks.customers_info                    OK
    dlbeduca_dbbooks.duplicate_isbn                    OK
    dlbeduca_dbbooks.geo_zones                         OK
    dlbeduca_dbbooks.imports
    note     : The storage engine for the table doesn't support repair
    dlbeduca_dbbooks.languages                         OK
    dlbeduca_dbbooks.manufacturers                     OK
    dlbeduca_dbbooks.manufacturers_info                OK
    dlbeduca_dbbooks.newsletters                       OK
    dlbeduca_dbbooks.orders                            OK
    dlbeduca_dbbooks.orders_products                   OK
    dlbeduca_dbbooks.orders_products_attributes        OK
    dlbeduca_dbbooks.orders_products_download          OK
    dlbeduca_dbbooks.orders_status                     OK
    dlbeduca_dbbooks.orders_status_history             OK
    dlbeduca_dbbooks.orders_total                      OK
    dlbeduca_dbbooks.products                          OK
    dlbeduca_dbbooks.products1                         OK
    dlbeduca_dbbooks.products_attributes               OK
    dlbeduca_dbbooks.products_attributes_download      OK
    dlbeduca_dbbooks.products_description              OK
    dlbeduca_dbbooks.products_description1             OK
    dlbeduca_dbbooks.products_notifications            OK
    dlbeduca_dbbooks.products_options                  OK
    dlbeduca_dbbooks.products_options_values           OK
    dlbeduca_dbbooks.products_options_values_to_products_options OK
    dlbeduca_dbbooks.products_to_categories            OK
    dlbeduca_dbbooks.reviews                           OK
    dlbeduca_dbbooks.reviews_description               OK
    dlbeduca_dbbooks.schema_migrations
    note     : The storage engine for the table doesn't support repair
    dlbeduca_dbbooks.sessions                          OK
    dlbeduca_dbbooks.settings                          OK
    dlbeduca_dbbooks.specials                          OK
    dlbeduca_dbbooks.sphinx_searches                   OK
    dlbeduca_dbbooks.tax_class                         OK
    dlbeduca_dbbooks.tax_rates                         OK
    dlbeduca_dbbooks.test                              OK
    dlbeduca_dbbooks.whos_online                       OK
    dlbeduca_dbbooks.zones                             OK
    dlbeduca_dbbooks.zones_to_geo_zones                OK
    You have new mail in /var/spool/mail/dlb
    [dlb@linode ~]$ mysql -udlb_user -pdlb_user dlbeduca_dbbooks
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8670
    Server version: 5.1.42 Source distribution

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> check table products;
    +---------------------------+-------+----------+----------+
    | Table                     | Op    | Msg_type | Msg_text |
    +---------------------------+-------+----------+----------+
    | dlbeduca_dbbooks.products | check | status   | OK       |
    +---------------------------+-------+----------+----------+
    1 row in set (1.11 sec)

    mysql> quit
    Bye

