import std.socket;
import std.stdio;
import std.conv:to;
import std.array:replace;

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
void session_connect(string address, string port = "21")
{
    if (session_isConnected())
    {
        writeln("Already connected");
        return;
    }

    /** Create a new command channel **/
    commandSocket = new TcpSocket;
    assert(commandSocket.isAlive);

    commandSocket.blocking(true);
    commandSocket.connect(new InternetAddress(address, to!ushort(port)));

    session_cmd_recv();
}

void session_active_mode()
{
    dataSocket = new TcpSocket;
    assert(dataSocket.isAlive);

    dataSocket.blocking(true);

    // Using 0 as port number will use a random port assigned by OS.
    dataSocket.bind(new InternetAddress(0));
    dataSocket.listen(1);
    writeln("Set active!");
}

/**
    Send some message and recv something back, will print the recv message
    @param message the message to send
**/
void session_cmd_send_recv(string message)
{
    session_cmd_send(message);
    session_cmd_recv();
}

void session_cmd_send(string message)
{
    // Note: When sending message to FTP server, always append
    // \r\n to the message
    writeln("Sent " ~ message);
    const auto sent = commandSocket.send(message ~ "\r\n");
    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }
}

void session_cmd_recv()
{
    char[1024] buffer;
    size_t data_len;
    string output;
    do
    {
        data_len = commandSocket.receive(buffer);
        if (data_len > 0)
        {
            output ~= buffer[0..data_len];
        }
    } while (data_len == 0);
    write(output);
}

void session_data_recv()
{
    char[1024] buffer;
    size_t data_len;
    string output;

    auto client = dataSocket.accept();
    do
    {
        data_len = client.receive(buffer);
        if (data_len > 0)
        {
            output ~= buffer[0..data_len];
        }
    } while (data_len == 0);
    client.close();
    write(output);
}

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
    Disconnect the current FTP session
**/
void session_disconnect()
{
    if (!session_isConnected())
    {
        return;
    }

    session_cmd_send_recv("QUIT\r\n");

    commandSocket.shutdown(SocketShutdown.BOTH);
    commandSocket.close();
    commandSocket = null;

    session_data_close();
}

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