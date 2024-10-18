<h1 align="center" style="color: #2c3e50;">OSS Casino</h1> <h2 align="center" style="color: #34495e;">Formerly Goldsvet</h2> <h2 align="center" style="color: #7f8c8d;">Aapanel/Cpanel/Plesk Casino Server Configuration Guide</h2> <p align="center"> <img src="https://raw.githubusercontent.com/zeusbyte/goldsvet/main/slot.png" alt="OSS Casino Slot" width="50%"> </p> <p align="center"> <a href="https://legendreels.com" title="DEMO HERE" style="font-weight: bold; color: #2980b9;">DEMO SITE HERE</a> </p> <p align="center"> <a href="https://legacybet.xyz" title="DEMO HERE 2" style="font-weight: bold; color: #2980b9;">DEMO SITE HERE 2</a> </p> <p align="center"> <a href="https://t.me/goldsvetcasino1" rel="nofollow" style="color: #27ae60;">Telegram Community</a> </p> <h3 align="center" style="color: #e74c3c;">BEWARE OF ANY FORKS/LINKS IMPERSONATING OUR OFFICIAL ACCOUNT</h3> <p align="center" style="color: #e74c3c; font-weight: bold;">OSS Casino Latest 2024 Release: Laravel 10 and PHP 8.1+ Support, Easy Installer</p> <p>&nbsp;</p> <h2>This code is just a preview. Contact admin on Telegram for the full version.</h2> <p><strong>Currently, we provide the full source on Telegram. There are approximately 1200 games totaling over 45 GB, including the latest Pragmatic Games and full source code.</strong></p> <p><strong>For the complete source code and installation instructions for your VPS/Dedicated Server, message me on Telegram.</strong></p> <p style="color: #e74c3c;"><strong>Multiple fixes, merged single database:</strong></p> <ul> <li>Demo user accounts are added and activated.</li> <li>Added 100 games, bringing the total to 1200 games now.</li> </ul> <h2>Server Setup Requirements</h2> <ul> <li>Set up your server with the following components: <ul> <li>OS: Almalinux 8 / CentOS 7 (recommended)</li> <li>Web Server: Apache</li> <li>Database: MySQL</li> <li>PHP: 8.0+</li> <li>Framework: Laravel 10</li> <li>Node.js: 16</li> <li>Process Manager: PM2</li> <li>Cache Store: Redis</li> </ul> </li> <li>Enforce SSL for the domain.</li> <li>Extract/Clone this repo into the public_html folder.</li> <li>Enable PHP Extensions: Fileinfo, Imagick, Redis.</li> <li>Create a new email and set a password.</li> <li>Create a new database and grant full access.</li> <li>Import the SQL file <code>db.sql</code> from the directory.</li> <li>Ensure SSL is enforced for the domain.</li> <li>Run the following command in the terminal under the public_html folder: <code>composer install</code></li> <li>Generate SSL CRT, KEY, and BUNDLE. Copy the contents to the files in the <code>/casino/PTwebsocket/ssl/</code> folder.</li> <li>For file uploads, consider the following additional tip:</li> <ul> <li> <p>//**** Additional tip: As it includes demo user accounts, generate a new password hash for existing users and execute the following in phpMyAdmin (replace the hash). Use <a href="https://bcrypt-generator.com/" rel="nofollow">bcrypt-generator.com</a> to generate hashes. If you need to hash a new word, run this in phpMyAdmin:</p> </li> </ul> </ul> <h2>Minimal Installer</h2> <p>Upload/Clone all files from this repo and run <code>yourdomain.com/start.php</code>. This will guide you through the installation process.</p> <h2>SSL Instructions</h2> <ul> <li>Delete any self-signed certificates.</li> <li>Generate or install the Lets Encrypt certificate if available.</li> <li>Save the certificate files as follows: <ul> <li>Certificate (CRT) ==> <code>crt.crt</code></li> <li>Private Key (KEY) --> <code>key.key</code></li> </ul> </li> <li>Go to the folder <code>PTWebSocket/ssl</code> and replace those three files.</li> <li>Edit <code>.env</code> and <code>/config/app.php</code> (URL line 65) for domain, database, username/password, email, and password.</li> </ul> <h2>File Edits</h2> <p>Edit the socket file changes in *json files located in the root directory.</p> <h2>PM2 Commands</h2> <p>Refer to the PM2 documentation for usage: <a href="https://pm2.keymetrics.io/docs/usage/quick-start/" rel="nofollow">PM2 Quick Start</a></p> <p>From inside the <code>PTWEBSOCKET</code> web folder, use the following commands:</p> <code>pm2 start Arcade.js --watch</code><br> <code>pm2 start Server.js --watch</code><br> <code>pm2 start Slots.js --watch</code> <p>Alternatively, you can run all commands in one line if you have tested and are not expecting errors:</p> <code>pm2 start Arcade.js --watch && pm2 start Server.js --watch && pm2 start Slots.js --watch</code> <h3>Sample Useful Commands</h3> <code>pm2 stop all</code><br> <code>pm2 delete all</code><br> <code>pm2 flush</code><br> <code>pm2 logs</code> <p>For additional commands, visit the PM2 documentation: <a href="https://pm2.keymetrics.io/docs/usage/quick-start/" rel="nofollow">PM2 Quick Start</a></p> <p>Consider using the <code>wscat</code> tool (install via SSH):</p> <code>wscat -c "wss://domain:PORT/slots"</code> <p>This is an example command to check the connection.</p> <h2>Firewall Configuration</h2> <p>Ensure to open the following ports in your firewall: <code>22154</code>, <code>22188</code>, <code>22197</code> (or any ports you have set for your socket files).</p> <h2>Final Steps</h2> <p>Run the site; it should work if everything was set up correctly.</p> <h2>Troubleshooting</h2> <p>If your composer or artisan did not run correctly, you can perform minor troubleshooting using:</p> <code>php artisan cache:clear && php artisan view:clear && php artisan config:clear && php artisan event:clear && php artisan route:clear</code> <h2>Have a Problem or Question?</h2> <p><strong>If you have difficulty with setup or installation, consider installation services via my Telegram.</strong></p> <p> <a href="https://t.me/chessmate77" rel="nofollow" style="color: #2980b9;">Personal Telegram</a><br> <a href="https://t.me/goldsvetcasino1" rel="nofollow" style="color: #2980b9;">Telegram Group</a> </p> <p>&nbsp;</p>
