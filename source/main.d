import std.stdio;


import session;
import commands;

// This is my attempt at writing a simple FTP client from scratch
void main(string[] args)
{
    writeln("FTP client started");

    if (args.length == 1)
        command_line();
}

