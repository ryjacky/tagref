#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string>

using namespace std;

inline bool exists_test (const std::string& name) {
  struct stat buffer;   
  return (stat (name.c_str(), &buffer) == 0); 
}

int main(int argc, char const *argv[])
{

    const string appDataWin = getenv("APPDATA");
    const string dbDir[3] = {"~/Library/Containers/com.tagref.tagref/Data/Library/Application\\ Support/com.tagref.tagref/tagref_db.db", appDataWin + "/TagRef/tagref/tagref_db.db", ""};
    const string sqliteBinary[3] = {"sqlite_mac", "sqlite3.exe", "sqlite_linux"};

    // TODO: Set client to 0 - Mac | 1 - Win | 2 - Linux
    int client = 0;

    for (int i = 0; i < 3; i++)
    {
        if (exists_test(dbDir[i]))
        {
            client = i;
            break;
        }
        
    }
    
    // TODO: receive stdin from NativeMessagingClient in format
    // (values)
    // e.g. insert::the_url             ** insert will also have src_id = 1, make sure to ignore all local files in the chrome extension
    // only insert command
    string url = "";
    unsigned int length = 0;
    for (int i = 0; i < 4; i++)
    {
        unsigned int read_char = getchar();
        length = length | (read_char << i*8);
    }

    for (int i = 0; i < length; i++)
    {
        url += getchar();
    }

    string sysCmd = sqliteBinary[client] + " " + dbDir[client] + " \"INSERT INTO images (src_url, src_id) VALUES ('" + url.substr(1, url.length() - 2) + "', 1)\"";

    // ofstream outfile;
    // outfile.open("D:\\tagref_flutter_windows_android_ios_web\\tagref\\lib\\utils\\log.txt");
    // outfile << sysCmd;
    // outfile.close();

    system(sysCmd.c_str());

    unsigned int len = url.length();
    printf("%c%c%c%c", (char) (len & 0xff),
    (char)(len << 8 & 0xff),
    (char)(len << 16 & 0xff),
    (char)(len << 24 & 0xff));

    printf("%s", url.c_str());

    return 0;
}
