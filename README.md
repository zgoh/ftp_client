# ftp_client

This project is for me to learn D Lang as well as sockets.

I want to create a simple FTP client to connect to my local FTP.

# Port
- FTP server's port 21 from anywhere (Client initiates connection)
- FTP server's port 21 to ports > 1023 (Server responds to client's control port)
- FTP server's port 20 to ports > 1023 (Server initiates data connection to client's data port)
- FTP server's port 20 from ports > 1023 (Client sends ACKs to server's data port)


# List of commands
http://www.nsftools.com/tips/RawFTP.htm

# Reference
https://cr.yp.to/ftp/retr.html
http://slacksite.com/other/ftp.html
https://www.techrepublic.com/article/how-ftp-port-requests-challenge-firewall-security/
https://superuser.com/questions/801514/in-ftp-what-are-the-differences-between-passive-and-extended-passive-modes
