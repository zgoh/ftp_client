import std.socket;
import std.stdio;
import std.conv:to;

/** Whether it is connected or not **/
bool connected;

/** Socket of current session **/
TcpSocket socket;

/**
    Connect to the FTP address
    @param ftp_address
**/ 
void connect_session(string ftp_address, string ftp_port = "21")
{
    const ushort port = to!ushort(ftp_port);
    if (connected)
    {
        writeln("Already connected");
        return;
    }

    socket = new TcpSocket();

    assert(socket.isAlive);
    socket.blocking(true);

    socket.connect(new InternetAddress(ftp_address, port));

    connected = true;
    writeln("Connected");
}

void test_socket()
{
    const auto sent = socket.send("aaaa");
    writeln(sent);

    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }

    char[1024] buffer;
    const auto data_len = socket.receive(buffer);
    writef("%s\n", buffer[0..data_len]);
}

void send(string message)
{
    const auto sent = socket.send(message);
    // writeln(sent);

    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }

    char[1024] buffer;
    const auto data_len = socket.receive(buffer);
    writef("%s\n", buffer[0..data_len]);
}

/**
    Disconnect the current FTP session
**/
void disconnect_session()
{
    if (!connected)
    {
        writeln("Already disconnected");
        return;
    }

    socket.close();

    connected = false;
    writeln("Disconnected");
}

/**
*/
bool isConnected()
{
    return connected;
}