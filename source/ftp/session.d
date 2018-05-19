import std.socket;
import std.stdio;
import std.conv:to;

/** Whether it is connected or not **/
bool connected;

/** Socket of current session **/
TcpSocket socket;

/**
    Connect to the FTP address
    @param ftp_address the address to connect to
    @param ftp_port the port to connect to
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

    char[1024] buffer;
    const long data_len = socket.receive(buffer);
    if (data_len > 0)
        writef("%s", buffer[0..data_len]);
}

/**
    Send some message and recv something back
    @param message the message to send
    @return message sent from the server
**/
string send_and_recv(string message)
{
    // writef("Sending %s\\n\n", message);
    // Note: When sending message to FTP server, always append
    // \n to the message
    const long sent = socket.send(message ~ "\n");
    // writeln(sent);

    if (sent == Socket.ERROR)
    {
        writeln("Sending error");
    }

    char[1024] buffer;
    long data_len;
    string output;
    do
    {
        data_len = socket.receive(buffer);
        output ~= buffer[0..data_len];
    } while (data_len == 0);

    return output;
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
    Whether the session is connected
    @return true if socket is connected
**/
bool isConnected()
{
    return connected;
}