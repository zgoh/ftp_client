# ftp_client

This project is for me to learn D Lang as well as sockets.

I want to create a simple FTP client to connect to my local FTP.

# Currently Implemented
 - User Auth (Except password hiding)
 - List dirs on FTP
 - Active mode
 - Changing dirs

# List of commands
http://www.nsftools.com/tips/RawFTP.htm

Note: Only shared commands will be supported

## Linux FTP
!		dir		macdef		proxy		site
$		disconnect	mdelete		sendport	size
account		epsv4		mdir		put		status
append		form		mget		pwd		struct
ascii		get		mkdir		quit		system
bell		glob		mls		quote		sunique
binary		hash		mode		recv		tenex
bye		help		modtime		reget		trace
case		idle		mput		rstatus		type
cd		image		newer		rhelp		user
cdup		ipany		nmap		rename		umask
chmod		ipv4		nlist		reset		verbose
close		ipv6		ntrans		restart		?
cr		lcd		open		rmdir
delete		lpwd		passive		runique
debug		ls		prompt		send

## Windows FTP


# Reference
- https://cr.yp.to/ftp/retr.html
- http://slacksite.com/other/ftp.html
- https://www.techrepublic.com/article/how-ftp-port-requests-challenge-firewall-security/
- https://superuser.com/questions/801514/in-ftp-what-are-the-differences-between-passive-and-extended-passive-modes

# Warning
This client might not work as expected. It's really more for educational purpose.