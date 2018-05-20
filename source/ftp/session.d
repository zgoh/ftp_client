import std.socket;
import std.stdio;
import std.conv:to;

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

/** Data port which is used to listen on **/
// TODO: Randomize this port?
static const ushort dataPort = 40_193;

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

    //connected = true;
    //writeln("Connected");

    session_command_recv();
}

void session_active_mode()
{
    if (dataSocket)
    {
        return;
    }

    dataSocket = new TcpSocket;
    assert(dataSocket.isAlive);

    dataSocket.blocking(true);

    dataSocket.bind(new InternetAddress(dataPort));
    dataSocket.listen(1);
}

/**
    Send some message and recv something back, will print the recv message
    @param message the message to send
**/
void session_send_and_recv(string message)
{
    // Note: When sending message to FTP server, always append
    // \r\n to the message
    writef(message ~ "\r\n");
    const auto sent = commandSocket.send(message ~ "\r\n");
    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }

    char[1024] buffer;
    size_t data_len;
    string output;
    do
    {
        data_len = commandSocket.receive(buffer);
        output ~= buffer[0..data_len];
    } while (data_len == 0);
    
    write(output);
}

void session_send(string message)
{
    // Note: When sending message to FTP server, always append
    // \r\n to the message
    const auto sent = commandSocket.send(message ~ "\r\n");

    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }
}

void session_command_recv()
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

/**
    Disconnect the current FTP session
**/
void session_disconnect()
{
    if (!session_isConnected())
    {
        return;
    }

    session_send_and_recv("QUIT\r\n");

    commandSocket.shutdown(SocketShutdown.BOTH);
    commandSocket.close();

    if (dataSocket !is null)
    {
        dataSocket.shutdown(SocketShutdown.BOTH);
        dataSocket.close();
    }

    commandSocket = null;
    dataSocket = null;
}

string session_get_host()
{
    writeln(commandSocket.hostName());
    return commandSocket.hostName();
}

ushort session_get_data_port()
{
    return dataPort;
}

/**
    Whether the session is connected
    @return true if session is connected
**/
bool session_isConnected()
{
    return commandSocket !is null;
    //return connected;
}