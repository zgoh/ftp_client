import std.socket;
import std.stdio;
import std.conv:to;
import std.array:replace;
import std.algorithm:endsWith;
import std.string:indexOf;
import core.time;

/** Current supported FTP mode are active/passive **/
enum FTP_Mode
{
    ACTIVE,
    PASSIVE
}

/** FTP protocols have two sockets, command and data **/
/** Connected to the command **/
static TcpSocket commandSocket = null;

/** Is connected to the data port of the FTP server **/
static TcpSocket dataSocket = null;

/** Current FTP mode is default to ACTIVE **/
static FTP_Mode mode = FTP_Mode.ACTIVE;

/**
    Connect to the FTP address
    @param ftp_address the address to connect to
    @param ftp_port the port to connect to
**/ 
void session_connect(const string address, const string port = "21")
{
    if (session_isConnected())
    {
        writeln("Already connected");
        return;
    }

    /** Create a new command channel **/
    commandSocket = new TcpSocket;
    assert(commandSocket.isAlive);

    commandSocket.blocking(false);
    commandSocket.connect(new InternetAddress(address, to!ushort(port)));

    session_cmd_recv();
}

/**
    Disconnect the current FTP session
**/
void session_disconnect()
{
    session_cmd_send_recv("QUIT\r\n");

    commandSocket.shutdown(SocketShutdown.BOTH);
    commandSocket.close();
    commandSocket = null;

    session_data_close();
}

/**
    Start the active mode
**/
void session_active_mode()
{
    dataSocket = new TcpSocket;
    assert(dataSocket.isAlive);

    dataSocket.blocking(false);

    // Using 0 as port number will use a random port assigned by OS.
    dataSocket.bind(new InternetAddress(0));
    dataSocket.listen(1);
}

/**
    Send some message and recv something back, will print the recv message
    @param message the message to send
**/
void session_cmd_send_recv(string message, bool continuous = false)
{
    session_cmd_send(message);
    session_cmd_recv(continuous);
}

/**
    Send a message using the command channel
    @param message The message to send
**/
void session_cmd_send(const string message)
{
    // Note: When sending message to FTP server, always append
    // \r\n to the message
    const auto sent = commandSocket.send(message ~ "\r\n");
    if (sent == Socket.ERROR)
    {
        writeln("Sending error");

        // TODO: Return false?
    }
}

/**
    Receive a message on the command channel,
    use blocking for command channels because I think there are sometimes 
    where the server reply slower.
**/
void session_cmd_recv(bool continuous = false)
{
    string output;
    SocketSet socketSet = new SocketSet(1);
    socketSet.add(commandSocket);
    do
    {
        if (Socket.select(socketSet, null, null, seconds(1)) == 0)
            break;
        
        if (socketSet.isSet(commandSocket))
        {
            char[1024] buffer;
            auto data_len = commandSocket.receive(buffer[]);
            
            if (data_len > 0)
            {
                output ~= buffer[0..data_len];
                continue;
            }
            else if (data_len == Socket.ERROR)
                writeln("Connection error.");
            break; // Connection closed
        }
    } while (continuous);
    write(output);
}

/**
    Receive a message on the data channel, we use non blocking channels 
    for data transfer
**/
void session_data_recv()
{
    auto client = dataSocket.accept();
    string output;

    /* Poll for data */
    while (true)
    {
        char[1024] buffer;
        auto data_len = client.receive(buffer[]);

        if (data_len < 1)
            break;
        
        output ~= buffer[0..data_len];
    }

    client.close();
    write(output);
}

/**
    Close the data channel after using
**/
void session_data_close()
{
    if (dataSocket !is null)
    {
        dataSocket.shutdown(SocketShutdown.BOTH);
        dataSocket.close();
    }
    dataSocket = null;
}

/**
    This function will return address, port in the following format
    h1,h2,h3,h4,p1,p2 where h1-h4 is the IP and p1-p2 is the port.
    For port calculation, see below.
**/
string session_getDataAddrPort()
{
    // TODO: Check if it's local/remote address
    // Note: Do not use dataSocket local address as it is 0.0.0.0
    const auto address = commandSocket.localAddress().toAddrString();
    const auto port = to!ushort(dataSocket.localAddress.toPortString());

    // IP format is
    // h1,h2,h3,h4,p1,p2
    // where port = p1 * 256 + p2
    // https://cr.yp.to/ftp/retr.html
    const auto p1 = port / 256;
    const auto p2 = port - p1 * 256;

    // Make the whole string dot separated and then change to comma separated
    const string portStr = to!string(p1) ~ "." ~ to!string(p2);
    return (address ~ "." ~ portStr).replace(".", ",");
}

/**
    Whether the session is connected
    @return true if session is connected
**/
bool session_isConnected()
{
    return commandSocket !is null;
}