import std.algorithm;
import std.string;
import std.stdio;

import session;

/** Flags for command line running status **/
static bool running = true;

/** The args supplied to the commands **/
static string[] command_args;

/** Passive or Port mode **/
enum Mode{PASSIVE, PORT}

/** The current mode for this ftp **/
static Mode currentMode = Mode.PORT;

/** Map the commands to the function to call **/
struct CommandPair
{
    /** Name of the command **/
    string[] name;

    /** The corresponding function to call **/
    void function() fp;
}

/** All FTP command line commands are registered here **/
const static CommandPair[] commands = [
    CommandPair(["quit", "bye"], &cmd_quit),
    CommandPair(["help", "?"], &cmd_help),
    CommandPair(["open"], &cmd_open),
    CommandPair(["disconnect"], &cmd_disconnect),
    CommandPair(["user"], &cmd_user),
    CommandPair(["ls"], &cmd_list),
    CommandPair(["test"], &cmd_test)
];

/**
    Where all the command line logic is,
    - Getting input.
    - Process input and call the corresponding command functions.
    - Run until quit commands is send,
**/
void command_line()
{
    string input;
    bool isValidCommand;

    while (running)
    {
        clear_args();
        isValidCommand = false;

        write("ftp> ");

        // Split string delimited by spaces
        string[] lines = split(toLower(chomp(readln())));
        if (lines.length < 1)
        {
            continue;
        }
        
        input = lines[0];
        command_args = lines[1..lines.length];
        
        foreach (command; commands)
        {
            foreach (name; command.name)
            {
                if (input.cmp(name) == 0)
                {
                    isValidCommand = true;
                    command.fp();
                }
            }
        }

        if (!isValidCommand)
        {
            cmd_invalid();
        }
    }
}

/**
    Clear the aguments length
**/
void clear_args()
{
    command_args.length = 0;
}

/*
 * All commands are implemented below
 */

/**
    Quit the client
**/
static void cmd_quit()
{
    session_disconnect();
    running = false;
}

/**
    Print the help message
**/
static void cmd_help()
{
    writeln("Commands may be abbreviated. Commands are:");
    writeln();
    writeln("? bye help open quit user");
}

/**
    Open a new connection to a FTP host
**/
static void cmd_open()
{
    if (session_isConnected())
    {
        writeln("Already connected to ", "something", " use disconnect first.");
        return;
    }

    if (command_args.length == 0)
    {
        // Get args for command
        writef("To ");
        command_args = split(strip(chomp(readln())));
        if (command_args.length == 0)
        {
            writeln("Usage: open host name [port]");
            return;
        }
        
        assert(command_args.length < 3);
    }

    if (command_args.length == 1)
    {
        session_connect(command_args[0]);
    }
    else
    {
        // Send connection request
        session_connect(command_args[0], command_args[1]);
    }

    if (session_isConnected())
    {
        clear_args();
        cmd_user();
    }
}

/**
    Disconnect the session
**/
static void cmd_disconnect()
{
    session_disconnect();
}

/**
    Send user command to the FTP server
**/
static void cmd_user()
{
    string user;
    string pass;

    if (command_args.length == 2)
    {
        user = command_args[0];
        pass = command_args[1];
    }
    else if (command_args.length == 1)
    {
        user = command_args[0];
    }

    clear_args();

    if (user == null)
    {
        writef("USER: ");
        user = chomp(readln());
    }

    string message = "USER " ~ user;
    session_send_and_recv(message);

    if (pass == null)
    {
        //TODO: Hide password and typing
        writef("PASS: ");
        pass= chomp(readln());
    }
    
    //TODO: Hide password when sending
    message = "PASS " ~ pass;
    session_send_and_recv(message);

    // session_send_and_recv("SYST");
}

/**
    List all files on FTP.
**/
static void cmd_list()
{
    writeln("Listing");

    // TODO: Use PORT/PASSIVE mode accordingly
    //switch (currentMode)
    //{
        // case Mode.PASSIVE:
        //     break;

        // case Mode.PORT:
        // {
        //     // TODO: Get current host info
        //     auto host = session_get_host();
        //     auto port = session_get_data_port();
            
        //     session_send_and_recv("PORT 127,0,0,1,157,1");
        //     session_send_and_recv("LIST");
        //     session_data_recv();
        //     session_command_recv();
        // } break;

    //    default:
    //        break;
    //}
}

/**
    Invalid command entered.
**/
static void cmd_invalid()
{
    writeln("Invalid command.");
}

/**
    NOTE: For testing only
**/
static void cmd_test()
{
    writeln(command_args);
    if (command_args.length == 1)
    {
        session_send_and_recv(command_args[0]);
    }
}