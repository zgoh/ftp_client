import std.socket;
import std.stdio;

/** Hold all session information **/
struct Session
{
    /** Whether it is connected or not **/
    bool connected;

    /** Socket of current session **/
    TcpSocket *socket;
}

/** Current session of app **/
static Session session;

/**
    Connect to the FTP address
    @param ftp_address
**/ 
void connect(string ftp_address)
{
    if (session.connected)
    {
        writeln("Already connected");
        return;
    }
    
    auto socket = new TcpSocket();
    session.socket = &socket;

    Address[] addresses = getAddress(ftp_address, 80);

    assert(session.socket.isAlive);


    session.connected = true;
    writeln("Connected");
}

/**
    Disconnect the current FTP session
**/
void disconnect()
{
    if (!session.connected)
    {
        writeln("Already disconnected");
        return;
    }

    session.connected = false;
    writeln("Disconnected");
}