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
    command_pair(["quit", "bye"], &quit),
    command_pair(["help"], &help),
    command_pair(["test"], &test)
];

string[] args;

void command_line()
{
    string input;
    bool isValidCommand;

    connect("localhost");

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
            invalid_command();
        }
    }

    disconnect();
}

static void quit()
{
    writeln("quit");
    
    running = false;
}

static void help()
{
    writeln("Commands may be abbreviated. Commands are:");
    writeln();
    writeln("bye quit help");
}

static void invalid_command()
{
    writeln("Invalid command.");
}

static void test()
{
    writeln(args);
}