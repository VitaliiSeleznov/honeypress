# HoneyPress

```
  /_)
(8_))}-  High interaction HoneyPot for WordPress.
  \_)   
```

The goal is to monitor activities on the instance. These activities can be attempted logins, comment spam or in general requests towards the instance to drop scripts.

The HoneyPot can utilize defined users and/ or create users on the fly (with a limited lifespan) and monitors the acitvity as JSON file. Activities will be logged on the logs/ directory inside the WordPress directory.

🛑 **This project is a playground. Use with caution :)** 🛑 

## Features

- [x] Logging of failed login interactions
- [x] Injecting of users into the instance for action tracking
- [x] Tracking of directory traversal attacts (with .htaccess redirect towards index.php)
- [x] Interception of xmlrpc calls
- [x] Timeout for sessions
- [x] FileSystem based logging
- [X] Proper deletion of honeypot users
- [x] Catching of file uploads inside WordPress
- [x] Monitoring of given comments (spam)

## Setup

Make sure not found files are being redirected to the index.php of the WordPress instance (allowing the plugin to catch these requests).

### Setup plugin


Place following `honeypress.json` in your WordPress root folder.

```
{
  "mask": true,
  "existingUsersOnly": false,
  "blockedLogins": [
    "admin"
  ],
  "generatorTag": "WordPress 5.721",
  "allowUploads": true,
  "expireUser": 10,
  "catchComments": true
}
```
|Setting|Description|Default|
|---|---|--|
|mask|Hide the plugin behind "Hello Dolly"|true|
|existingUsersOnly|If only existing users should be allowed to be logged in|false|
|blockedLogins|(if existingUsersOnly = false) don't create/ use following users (e. g. admin)| array|
|generatorTag|The meta generator tag to be used|WordPress 5.7|
|allowUploads|if true, uploads will be allowed, if false not. In both cases uploads will be logged|true|
|expireUser|(if existingUsersOnly = false) delete the user `n` seconds after login|60|
|catchComments|Should comments be monitored|true|

Install the HoneyPress plugin into WordPress. Make sure the "Hello Dolly plugin is present". 

In case you give the default user role permission to access the plugin list, HoneyPress will try to mask itself behind Hello Dolly's description.

## Recommendations

- Use an proxy for outgoing connections (so you can monitor installed droppers)
- Use containers and/ or virtual machines
- Apply a regular reset of HoneyPress instances
- 🛑 **Don't use this on a production environment** 🛑 
- Make the `wp-contents/` directory readonly
- Prevent access throught the webserver towards `logs/` and `honeypress.json` (redirect it to 404)

## License

GPLv3