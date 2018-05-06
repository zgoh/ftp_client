import std.stdio;
import std.algorithm;
import session;

// This is my attempt at writing a simple FTP client from scratch
void main(string[] args)
{
    writeln("FTP client started");

    if (args.length == 1)
        get_input();

    // // Get FTP address
    // connect("localhost");

    // test();

    // // Login
    // // List files
    // // File ops
    // // Disconnect
    // disconnect();
}

void get_input()
{
    string input;
    while(true)
    {
        writef("d_ftp_client> ");
        input = readln();
        
        // Quit prompt
        if (cmp(input, "bye") == 1 ||
            cmp(input, "quit") == 1)
        {
            break;
        }
        else if (cmp(input, "help") == 1 ||
                 cmp(input, "?") == 1)
        {
            // print all commands
            writeln("Commands below: ");
            writefln("!\t\tdir\t\tmacdef\t\tproxy\t\tsite");
            writefln("$\t\tdisconnect\tmdelete\t\tsendport\tsize");
            writefln("account\t\tepsv4\t\tmmdir\t\tput\t\tstatus");
            writefln("append\t\tform\t\tmget\t\tpwd\t\tstruct");
            writefln("ascii\t\tget\t\tmkdir\t\tquit\t\tsystem");
            writefln("bell\t\tglob\t\tmls\t\tquote\t\tsunique");
            writefln("binary\t\thash\t\tmode\t\trecv\t\ttenex");
            writefln("bye\t\thelp\t\tmodtime\t\treget\t\ttrace");
            writefln("case\t\tidle\t\tmput\t\trstatus\t\ttype");
            writefln("cd\t\timage\t\tnewer\t\trhelp\t\tuser");
            writefln("cdup\t\tipany\t\tnmap\t\trename\t\tmask");
            writefln("chmod\t\tipv4\t\tnlist\t\treset\t\tverbose");
            writefln("close\t\tipv6\t\tntrans\t\trestart\t\t?");
            writefln("cr\t\tlcd\t\topen\t\trmdir");
            writefln("delete\t\tlpwd\t\tpassive\t\trunique");
            writefln("debug\t\tls\t\tprompt\t\tsend");
        }
        else
        {
            writeln("Invalid command, type help to see all commands.");
        }
    }
}