import std.algorithm;
import std.string;
import std.stdio;

import session;

static bool running = true;

struct command_pair
{
    string[] names;
    void function() fp;
}

const static command_pair[] commands = [
    command_pair(["quit", "bye"], &cmd_quit),
    command_pair(["help", "?"], &cmd_help),
    command_pair(["open"], &cmd_open),
    command_pair(["disconnect"], &cmd_disconnect),
    command_pair(["user"], &cmd_user),
    command_pair(["test"], &cmd_test)
];

static string[] args;

void command_line()
{
    string input;
    bool isValidCommand;

    while (running)
    {
        args.length = 0;
        isValidCommand = false;

        write("ftp> ");

        // Split string delimited by spaces
        auto lines = toLower(readln()).split();
        input = lines[0];
        args = lines[1..lines.length];
        
        foreach (command; commands)
        {
            foreach (name; command.names)
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

/*
 * Quit the client
 */

static void cmd_quit()
{
    writeln("quit");
    
    running = false;
}

/*
 * Print the help message
 */
static void cmd_help()
{
    writeln("Commands may be abbreviated. Commands are:");
    writeln();
    writeln("? bye help open quit");
}

/*
 * Open a new connection to a FTP host
 */
static void cmd_open()
{
    if (isConnected())
    {
        writeln("Already connected to ", "something", " use disconnect first.");
        return;
    }

    if (args.length == 0)
    {
        // Get args
        writef("To ");
        auto input = split(strip(readln()));
        if (input.length == 0)
        {
            writeln("Usage: open host name [port]");
            return;
        }

        args = input;
        assert(args.length < 3);
    }

    if (args.length == 1)
    {
        connect_session(args[0]);
    }
    else
    {
        // Send connection request
        connect_session(args[0], args[1]);
    }

    if (isConnected())
    {
        cmd_user();
    }
}

static void cmd_disconnect()
{
    disconnect_session();
}

static void cmd_user()
{
    writeln(send_and_recv("USER"));
}

static void cmd_invalid()
{
    writeln("Invalid command.");
}

static void cmd_test()
{
    writeln(args);
    test_socket();
}