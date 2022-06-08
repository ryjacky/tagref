#include <stdio.h>
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char const *argv[])
{

    const string dbDir[3] = {"~/Library/Containers/com.tagref.tagref/Data/Library/Application\ Support/com.tagref.tagref/tagref_db.db", "%appdata%/TagRef/tagref/tagref_db.db", ""};
    const string sqliteBinary[3] = {"sqlite3.exe", "sqlite_mac", "sqlite_linux"};

    // TODO: Set client to 0 - Mac | 1 - Win | 2 - Linux
    int client = 0;

    ifstream ifile;
    ifile.open(dbDir[0]);
    if (ifile)
    {
        client = 0;
    }
    else
    {
        ifile.close();
        ifile.clear();

        ifile.open(dbDir[1]);
        if (ifile)
        {
            client = 1;
        }
        else
        {
            client = 2;
        }
    }

    // TODO: receive stdin from NativeMessagingClient in format
    // (values)
    // e.g. insert::the_url             ** insert will also have src_id = 1, make sure to ignore all local files in the chrome extension
    // only insert command

    system(sqliteBinary[client] + " " + dbDir[client] + " \"INSERT INTO images (src_url, src_id) VALUES ('test', 0)\"");
    return 0;
}
