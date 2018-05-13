import std.algorithm;
import std.string;
import std.stdio;

import session;

/** Flags for command line running status **/
static bool running = true;

/** The args supplied to the commands **/
static string[] command_args;

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
        command_args.length = 0;
        isValidCommand = false;

        write("ftp> ");

        // Split string delimited by spaces
        string[] lines = toLower(readln()).split();
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

/*
 * All commands are implemented below
 */

/**
    Quit the client
**/
static void cmd_quit()
{
    writeln("quit");
    
    running = false;
}

/**
    Print the help message
**/
static void cmd_help()
{
    writeln("Commands may be abbreviated. Commands are:");
    writeln();
    writeln("? bye help open quit");
}

/**
    Open a new connection to a FTP host
**/
static void cmd_open()
{
    if (isConnected())
    {
        writeln("Already connected to ", "something", " use disconnect first.");
        return;
    }

    if (command_args.length == 0)
    {
        // Get args for command
        writef("To ");
        command_args = split(strip(readln()));
        if (command_args.length == 0)
        {
            writeln("Usage: open host name [port]");
            return;
        }
        
        assert(command_args.length < 3);
    }

    if (command_args.length == 1)
    {
        connect_session(command_args[0]);
    }
    else
    {
        // Send connection request
        connect_session(command_args[0], command_args[1]);
    }

    if (isConnected())
    {
        cmd_user();
    }
}

/**
    Disconnect the session
**/
static void cmd_disconnect()
{
    disconnect_session();
}

/**
    Send user command to the FTP server
**/
static void cmd_user()
{
    //writeln(send_and_recv("USER"));
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
        write(send_and_recv(command_args[0]));
    }
}