import std.socket;
import std.stdio;
import std.conv:to;

// enum FTP_Mode
// {
//     PASSIVE,
//     PORT
// }

// struct FTP_Session
// {
//     bool connected = false;
//     TcpSocket command = null;
//     TcpSocket data = null;
//     Mode mode = Mode.PORT;
// }

// void session_connect(ref Session session, string address, string port)
// {

// }

/** Whether it is connected or not **/
static bool connected;

/** FTP protocols have two sockets, command and data **/
/** Connected to the command **/
static TcpSocket commandSocket;

/** Is connected to the data port of the FTP server **/
static TcpSocket dataSocket;

static const ushort dataPort = 40_193;

/**
    Connect to the FTP address
    @param ftp_address the address to connect to
    @param ftp_port the port to connect to
**/ 
void session_connect(string ftp_address, string ftp_port = "21")
{
    const ushort port = to!ushort(ftp_port);
    if (connected)
    {
        writeln("Already connected");
        return;
    }

    commandSocket = new TcpSocket;
    dataSocket = new TcpSocket;

    assert(commandSocket.isAlive);
    assert(dataSocket.isAlive);

    commandSocket.blocking(true);
    dataSocket.blocking(true);
    
    commandSocket.connect(new InternetAddress(ftp_address, port));

    dataSocket.bind(new InternetAddress(dataPort));
    dataSocket.listen(1);

    connected = true;
    writeln("Connected");

    session_command_recv();
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
    if (!connected)
    {
        return;
    }

    session_send_and_recv("QUIT\r\n");

    commandSocket.shutdown(SocketShutdown.BOTH);
    commandSocket.close();

    dataSocket.shutdown(SocketShutdown.BOTH);
    dataSocket.close();

    connected = false;
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
    return connected;
}