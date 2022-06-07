#include <stdio.h>
#include <iostream>

using namespace std;

int main(int argc, char const *argv[])
{
    
    system("sqlite3.exe %appdata%/TagRef/tagref/tagref_db.db \"INSERT INTO images (src_url, src_id) VALUES ('test', 0)\"");
    return 0;
}
